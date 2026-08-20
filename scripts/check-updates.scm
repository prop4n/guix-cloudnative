#!/usr/bin/env guile
!#

;;; Signale les paquets dont la version amont sur GitHub est plus récente que
;;; celle que nous packageons.  À lancer depuis la racine du dépôt :
;;;
;;;   guile scripts/check-updates.scm
;;;
;;; Écrit une ligne « nom<TAB>actuelle<TAB>amont » par paquet en retard sur la
;;; sortie standard, et la progression sur l'erreur standard.  Sort en erreur
;;; si un paquet n'a pas pu être vérifié : un résultat partiel ne doit jamais
;;; passer pour un run réussi.
;;;
;;; Ce script n'utilise délibérément pas (guix upstream) et ses updaters, qui
;;; seraient la façon idiomatique d'interroger la dernière version : charger
;;; nos modules de paquets exige un Guix assez récent pour tout ce qu'ils
;;; importent, et le construire sur un runner CI standard coûte une douzaine
;;; de minutes par run.  On lit donc les définitions nous-mêmes et on
;;; interroge GitHub directement, ce qui prend quelques secondes et ne demande
;;; que Guile.  En contrepartie, un paquet hébergé ailleurs est signalé comme
;;; une erreur plutôt que vérifié — bruyamment, pour qu'il ne passe pas
;;; inaperçu.
;;;
;;; Les définitions sont lues comme des données, et non parcourues comme du
;;; texte : « read » nous rend les S-expressions et on les traverse.  Seules
;;; les deux tâches qui relèvent vraiment du texte — extraire owner/repo d'une
;;; URL, et une version d'un tag — passent par une expression régulière.

(use-modules (ice-9 regex)
             (ice-9 ftw)
             (srfi srfi-1)
             (rnrs bytevectors)
             (web client)
             (web response)
             (web uri))

(define %package-directory "guix-cloudnative/packages")

(define %repo-rx
  (make-regexp "github\\.com/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+)"))
(define %tag-rx (make-regexp "/releases/tag/(.+)$"))
(define %feed-tag-rx (make-regexp "/releases/tag/([^\"]+)\""))
(define %number-rx (make-regexp "[0-9]+"))

;; La version contenue dans un tag : une suite de nombres séparés par des
;; points, dont on jette tout ce qui précède.  Ancrée sur un chiffre qui ne
;; suit ni un autre chiffre ni un point, pour que le 1.4.0 de bun-v1.4.0 ne
;; soit pas lu comme 4.0.
(define %version-in-tag-rx
  (make-regexp "(^|[^0-9.])([0-9]+(\\.[0-9]+)+)"))

(define (capture rx str n)
  "Renvoie le groupe de capture N de RX dans STR, ou #f si RX ne correspond
pas."
  (let ((m (regexp-exec rx str)))
    (and m (match:substring m n))))


;;;
;;; Lecture des définitions de paquets.
;;;

;; Les définitions de paquets contiennent des gexps, que le lecteur Guile nu
;; ne connaît pas.  On lui en apprend juste assez pour les lire comme des
;; données : comme on n'évalue jamais ce qui en ressort, n'importe quel
;; marqueur fait l'affaire.
(read-hash-extend #\~ (lambda (chr port) (list 'gexp (read port))))
(read-hash-extend #\$ (lambda (chr port)
                        (case (peek-char port)
                          ((#\@) (read-char port)
                                 (list 'ungexp-splicing (read port)))
                          (else (list 'ungexp (read port))))))

(define (read-forms file)
  "Renvoie les formes de premier niveau de FILE, lues comme des données."
  (call-with-input-file file
    (lambda (port)
      (let loop ((forms '()))
        (let ((form (read port)))
          (if (eof-object? form)
              (reverse forms)
              (loop (cons form forms))))))))

(define (field form name)
  "Renvoie l'argument de la sous-forme (NAME argument) de FORM, à n'importe
quelle profondeur, ou #f s'il n'y en a pas.  La première occurrence dans
l'ordre de lecture l'emporte, ce qui pour un paquet écrit conventionnellement
correspond à son propre champ plutôt qu'à celui d'une entrée."
  (and (pair? form)
       (if (and (eq? (car form) name)
                (pair? (cdr form)))
           (cadr form)
           (any (lambda (sub) (field sub name))
                (filter pair? form)))))

(define (strings-in form)
  "Renvoie toutes les chaînes de FORM, dans leur ordre d'apparition."
  (cond ((string? form) (list form))
        ((pair? form) (append-map strings-in form))
        (else '())))

(define (strip-git-suffix name)
  (if (string-suffix? ".git" name)
      (string-drop-right name 4)
      name))

(define (form->repository form)
  "Renvoie le « owner/repo » de la première URL GitHub de FORM, ou #f.  Les
URL sont souvent assemblées avec string-append, d'où l'examen de chaque
chaîne plutôt que l'attente d'une adresse complète.  Prendre la première
place l'URL de la source avant une home-page qui pointerait ailleurs."
  (any (lambda (str)
         (let ((m (regexp-exec %repo-rx str)))
           (and m
                (string-append (match:substring m 1) "/"
                               (strip-git-suffix (match:substring m 2))))))
       (strings-in form)))

(define (definition->package form)
  "Renvoie (nom version dépôt) pour FORM lorsqu'elle définit un paquet que
nous suivons, sinon #f.  Les paquets go-* sont des dépendances Go épinglées
sur un commit, sans version amont à suivre."
  (and (pair? form)
       (eq? (car form) 'define-public)
       (let ((name (field form 'name))
             (version (field form 'version)))
         (and (string? name)
              (string? version)
              (not (string-prefix? "go-" name))
              (list name version (form->repository form))))))

(define (packages-in file)
  (filter-map definition->package (read-forms file)))

(define (package-files directory)
  (map (lambda (entry) (string-append directory "/" entry))
       (sort (filter (lambda (entry) (string-suffix? ".scm" entry))
                     (or (scandir directory) '()))
             string<?)))


;;;
;;; Interrogation de GitHub.
;;;

(define %redirect-codes '(301 302 303 307 308))
(define %max-redirects 5)
(define %request-timeout 20)            ;secondes
(define %request-attempts 2)

;; Guile n'offre pas de délai d'attente sur http-request, et une connexion
;; bloquée suspendrait le run aussi longtemps que l'autre bout la maintient
;; ouverte.
(sigaction SIGALRM (lambda (signal) (throw 'request-timeout)))

(define (call-with-timeout seconds thunk)
  "Exécute THUNK, en l'abandonnant au bout de SECONDS."
  (dynamic-wind
    (lambda () (alarm seconds))
    thunk
    (lambda () (alarm 0))))

(define (request url method)
  "Effectue METHOD sur URL et renvoie (réponse corps).  Réessaie une fois, car
une vérification hebdomadaire ne devrait pas échouer sur un incident passager,
puis lève 'network-failure : l'appelant la convertit en message pour un seul
paquet, au lieu de la laisser emporter tout le run."
  (let attempt ((remaining %request-attempts))
    (catch #t
      (lambda ()
        (call-with-timeout %request-timeout
          (lambda ()
            (call-with-values
                (lambda ()
                  (http-request url #:method method
                                #:streaming? (eq? method 'HEAD)))
              list))))
      (lambda (key . args)
        (if (> remaining 1)
            (begin (sleep 1) (attempt (- remaining 1)))
            (throw 'network-failure url key))))))

(define (follow-redirects url)
  "Renvoie l'URL finale sur laquelle URL aboutit, ou #f si elle ne cesse
jamais de rediriger.  Un dépôt renommé redirige vers son nouveau nom avant que
/releases/latest ne redirige vers un tag : un seul saut ne suffit pas."
  (let loop ((url url) (hops 0))
    (if (> hops %max-redirects)
        #f
        (let ((response (first (request url 'HEAD))))
          (if (memv (response-code response) %redirect-codes)
              (loop (uri->string
                     (assq-ref (response-headers response) 'location))
                    (+ hops 1))
              url)))))

(define (published-release-tag repository)
  "Renvoie le tag de la dernière release publiée de REPOSITORY, ou #f s'il n'y
en a aucune.  /releases/latest redirige vers la page du tag de la release, ce
qui évite l'API et le jeton qu'elle réclame."
  (let ((target (follow-redirects
                 (string-append "https://github.com/" repository
                                "/releases/latest"))))
    (and target (capture %tag-rx target 1))))

(define (fetch url)
  "Renvoie le corps de URL sous forme de chaîne, ou #f si elle répond autre
chose que 200."
  (let* ((result (request url 'GET))
         (response (first result))
         (body (second result)))
    (and (= 200 (response-code response))
         (if (string? body) body (utf8->string body)))))

(define (newest-tag repository)
  "Renvoie le tag de version le plus élevé de REPOSITORY, ou #f.  Beaucoup de
projets poussent des tags sans jamais publier de release GitHub : c'est ce qui
les rend vérifiables malgré tout.  Le flux liste les tags du plus récent au
plus ancien, mais par date de création, d'où le choix de la version la plus
haute plutôt que de la première entrée."
  (let ((feed (fetch (string-append "https://github.com/" repository
                                    "/tags.atom"))))
    (and feed
         (fold (lambda (match best)
                 (let ((version (tag->version
                                 (uri-decode (match:substring match 1)))))
                   (cond ((not version) best)
                         ((not best) version)
                         ((version-newer? version best) version)
                         (else best))))
               #f
               (list-matches %feed-tag-rx feed)))))

(define (latest-version repository)
  "Renvoie la version amont de REPOSITORY : celle de ses releases s'il en
publie, celle de ses tags sinon."
  (let ((tag (published-release-tag repository)))
    (or (and tag (tag->version tag))
        (newest-tag repository))))


;;;
;;; Comparaison des versions.
;;;

(define (version->numbers version)
  (map (lambda (m) (string->number (match:substring m)))
       (list-matches %number-rx version)))

(define (version-newer? version other)
  "VERSION est-elle plus récente que OTHER ?  Compare les nombres de chacune,
afin qu'un tag amont de forme inhabituelle ne puisse pas se lire comme une
régression."
  (let loop ((version (version->numbers version))
             (other (version->numbers other)))
    (cond ((null? version) #f)
          ((null? other) #t)
          ((> (car version) (car other)) #t)
          ((< (car version) (car other)) #f)
          (else (loop (cdr version) (cdr other))))))

(define (tag->version tag)
  "Renvoie la version que TAG désigne, ou #f s'il n'en désigne aucune.

Un tag n'est pas qu'une version : les projets les préfixent d'un nom
\(bun-v1.4.0), d'un composant (cli/v2.2.1), ou de rien du tout (0.10.4).  On
en extrait la suite de nombres pointés en jetant ce qui la précède, pour qu'un
préfixe ne déborde ni sur la version rapportée ni, pire, sur la comparaison —
où un préfixe comme release-2024 se lirait comme un numéro majeur très élevé.
Un tag sans nombre pointé, tel un marqueur de CI, ne désigne aucune version."
  (capture %version-in-tag-rx tag 2))


;;;
;;; Restitution.
;;;

(define (report package)
  "Affiche l'état de PACKAGE.  Renvoie un message s'il n'a pas pu être
vérifié, sinon #f."
  (let ((name (first package))
        (version (second package))
        (repository (third package)))
    (if (not repository)
        (format #f "~a : aucune URL GitHub dans sa définition" name)
        (catch 'network-failure
          (lambda ()
            (let ((latest (latest-version repository)))
              (cond
               ((not latest)
                (format #f "~a : ~a n'a ni release ni tag de version"
                        name repository))
               ((version-newer? latest version)
                (format #t "~a\t~a\t~a~%" name version latest)
                (format (current-error-port) "~a : ~a -> ~a~%"
                        name version latest)
                #f)
               (else
                (format (current-error-port) "~a : ~a à jour~%"
                        name version)
                #f))))
          ;; Un hôte injoignable est signalé comme n'importe quel autre paquet
          ;; non vérifié, pour que le reste du run aille à son terme.
          (lambda (key url reason)
            (format #f "~a : ~a injoignable (~a)" name url reason))))))

(define (main)
  (let ((unchecked (filter-map report
                               (append-map packages-in
                                           (package-files %package-directory)))))
    (unless (null? unchecked)
      (format (current-error-port) "~%paquets non vérifiés :~%")
      (for-each (lambda (message)
                  (format (current-error-port) "  ~a~%" message))
                unchecked)
      (exit 1))))

(main)

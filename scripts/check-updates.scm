#!/usr/bin/env guile
!#

;;; Report packages whose upstream GitHub release is newer than the version we
;;; package.  Run from the repository root:
;;;
;;;   guile scripts/check-updates.scm
;;;
;;; Prints one "name<TAB>current<TAB>latest" line per outdated package on
;;; stdout, and progress on stderr.  Exits non-zero if any package could not be
;;; checked, so a partial result never passes as a clean run.
;;;
;;; This deliberately does not use (guix upstream) and its updaters, which
;;; would be the idiomatic way to ask for the latest release: loading our
;;; package modules needs a Guix new enough for everything they import, and
;;; building that on a stock CI runner costs about twelve minutes per run.  So
;;; we read the definitions as text and ask GitHub directly, which takes
;;; seconds and needs nothing but Guile.  The cost is that a package hosted
;;; anywhere else is reported as an error rather than checked -- loudly, so it
;;; cannot pass unnoticed.

(use-modules (ice-9 regex)
             (ice-9 textual-ports)
             (ice-9 ftw)
             (srfi srfi-1)
             (rnrs bytevectors)
             (web client)
             (web response)
             (web uri))

(define %package-directory "guix-cloudnative/packages")

(define %define-public-rx (make-regexp "\\(define-public[ \t\n]+"))
(define %name-rx (make-regexp "\\(name[ \t\n]+\"([^\"]+)\""))
(define %version-rx (make-regexp "\\(version[ \t\n]+\"([^\"]+)\""))
(define %repo-rx
  (make-regexp "github\\.com/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+)"))
(define %tag-rx (make-regexp "/releases/tag/(.+)$"))
(define %feed-tag-rx (make-regexp "/releases/tag/([^\"]+)\""))
(define %number-rx (make-regexp "[0-9]+"))

;; The version inside a tag: a run of dot-separated numbers, taken with
;; whatever precedes it discarded.  Anchored on a digit that does not follow
;; another digit or a dot, so 1.4.0 in bun-v1.4.0 is not read as 4.0.
(define %version-in-tag-rx
  (make-regexp "(^|[^0-9.])([0-9]+(\\.[0-9]+)+)" ))


;;;
;;; Reading package definitions.
;;;

(define (capture rx str n)
  "Return capture group N of RX in STR, or #f if RX does not match."
  (let ((m (regexp-exec rx str)))
    (and m (match:substring m n))))

(define (split-definitions content)
  "Return CONTENT split into one string per top-level define-public form.
CONTENT may hold none at all: a file of plain definitions, such as the output
of one of the Guix importers, is not an error."
  (let loop ((matches (list-matches %define-public-rx content))
             (result '()))
    (if (null? matches)
        (reverse result)
        (loop (cdr matches)
              (cons (substring content
                               (match:end (car matches))
                               (if (null? (cdr matches))
                                   (string-length content)
                                   (match:start (cadr matches))))
                    result)))))

(define (strip-git-suffix name)
  (if (string-suffix? ".git" name)
      (string-drop-right name 4)
      name))

(define (tracked-package definition)
  "Return (name version repository) for DEFINITION, where repository is the
\"owner/repo\" it lives in or #f if it names no GitHub URL.  Return #f when
DEFINITION holds no package, or a go-* one: those are Go dependencies pinned
to a commit, with no releases to follow."
  (let ((name (capture %name-rx definition 1))
        (version (capture %version-rx definition 1))
        (repo (regexp-exec %repo-rx definition)))
    (and name version
         (not (string-prefix? "go-" name))
         (list name version
               (and repo
                    (string-append (match:substring repo 1) "/"
                                   (strip-git-suffix
                                    (match:substring repo 2))))))))

(define (packages-in file)
  (filter-map tracked-package
              (split-definitions (call-with-input-file file get-string-all))))

(define (package-files directory)
  (map (lambda (entry) (string-append directory "/" entry))
       (sort (filter (lambda (entry) (string-suffix? ".scm" entry))
                     (or (scandir directory) '()))
             string<?)))


;;;
;;; Querying GitHub.
;;;

(define %redirect-codes '(301 302 303 307 308))
(define %max-redirects 5)

(define (follow-redirects url)
  "Return the URL that URL finally lands on, or #f if it never stops
redirecting.  A renamed repository redirects to its new name before
/releases/latest redirects to a tag, so one hop is not enough."
  (let loop ((url url) (hops 0))
    (if (> hops %max-redirects)
        #f
        (call-with-values
            (lambda ()
              (http-request url #:method 'HEAD #:streaming? #t))
          (lambda (response body)
            (if (memv (response-code response) %redirect-codes)
                (loop (uri->string
                       (assq-ref (response-headers response) 'location))
                      (+ hops 1))
                url))))))

(define (published-release-tag repository)
  "Return the tag of REPOSITORY's newest published release, or #f if it has
none.  /releases/latest redirects to the release's tag page, which saves
hitting the API and the token it wants."
  (let ((target (follow-redirects
                 (string-append "https://github.com/" repository
                                "/releases/latest"))))
    (and target (capture %tag-rx target 1))))

(define (fetch url)
  "Return the body of URL as a string, or #f if it cannot be read."
  (call-with-values (lambda () (http-request url #:method 'GET))
    (lambda (response body)
      (and (= 200 (response-code response))
           (if (string? body) body (utf8->string body))))))

(define (newest-tag repository)
  "Return the highest version tag of REPOSITORY, or #f.  Plenty of projects
push tags without ever publishing a GitHub release, so this is what makes
those checkable at all.  The feed lists tags newest-first, but ordered by
creation date, so pick the highest version rather than the first entry."
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
  "Return REPOSITORY's newest version, from its releases if it publishes any
and from its tags otherwise."
  (let ((tag (published-release-tag repository)))
    (or (and tag (tag->version tag))
        (newest-tag repository))))


;;;
;;; Comparing versions.
;;;

(define (version->numbers version)
  (map (lambda (m) (string->number (match:substring m)))
       (list-matches %number-rx version)))

(define (version-newer? version other)
  "Is VERSION newer than OTHER?  Compares the numbers in each, so an upstream
tag with an unusual shape cannot read as a downgrade."
  (let loop ((version (version->numbers version))
             (other (version->numbers other)))
    (cond ((null? version) #f)
          ((null? other) #t)
          ((> (car version) (car other)) #t)
          ((< (car version) (car other)) #f)
          (else (loop (cdr version) (cdr other))))))

(define (tag->version tag)
  "Return the version TAG names, or #f if it names none.

Tags are not just versions: projects prefix them with a name (bun-v1.4.0), a
component (cli/v2.2.1) or nothing at all (0.10.4).  Take the dotted number
run and drop whatever leads up to it, so a prefix cannot leak into the
version we report -- or worse, into the comparison, where a prefix like
release-2024 would read as a very high major.  A tag with no dotted number,
such as a CI marker, names no version."
  (capture %version-in-tag-rx tag 2))


;;;
;;; Reporting.
;;;

(define (report package)
  "Print PACKAGE's status.  Return a message if it could not be checked, else #f."
  (let ((name (first package))
        (version (second package))
        (repository (third package)))
    (if (not repository)
        (format #f "~a: no GitHub URL in its definition" name)
        (let ((latest (latest-version repository)))
          (cond
           ((not latest)
            (format #f "~a: ~a has no release or version tag" name repository))
           ((version-newer? latest version)
            (format #t "~a\t~a\t~a~%" name version latest)
            (format (current-error-port) "~a: ~a -> ~a~%" name version latest)
            #f)
           (else
            (format (current-error-port) "~a: ~a up to date~%" name version)
            #f))))))

(define (main)
  (let ((unchecked (filter-map report
                               (append-map packages-in
                                           (package-files %package-directory)))))
    (unless (null? unchecked)
      (format (current-error-port) "~%failed to check:~%")
      (for-each (lambda (message)
                  (format (current-error-port) "  ~a~%" message))
                unchecked)
      (exit 1))))

(main)

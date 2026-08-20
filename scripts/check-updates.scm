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
(define %number-rx (make-regexp "[0-9]+"))


;;;
;;; Reading package definitions.
;;;

(define (capture rx str n)
  "Return capture group N of RX in STR, or #f if RX does not match."
  (let ((m (regexp-exec rx str)))
    (and m (match:substring m n))))

(define (split-definitions content)
  "Return CONTENT split into one string per top-level define-public form."
  (let ((matches (list-matches %define-public-rx content)))
    (map (lambda (this rest)
           (substring content (match:end this)
                      (if (null? rest)
                          (string-length content)
                          (match:start (car rest)))))
         matches
         (append (map list (cdr matches)) '(())))))

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

(define (latest-release repository)
  "Return the tag of REPOSITORY's newest release, or #f if it has none.
/releases/latest redirects to the release's tag page, which saves hitting the
API and the token it wants."
  (let ((target (follow-redirects
                 (string-append "https://github.com/" repository
                                "/releases/latest"))))
    (and target (capture %tag-rx target 1))))


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

(define (strip-v tag)
  "Drop the leading v of a tag such as v1.2.3."
  (if (and (not (string-null? tag))
           (memv (string-ref tag 0) '(#\v #\V)))
      (string-drop tag 1)
      tag))


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
        (let ((tag (latest-release repository)))
          (cond
           ((not tag)
            (format #f "~a: ~a has no releases" name repository))
           (else
            (let ((latest (strip-v tag)))
              (when (version-newer? latest version)
                (format #t "~a\t~a\t~a~%" name version latest))
              (format (current-error-port) "~a: ~a~a~%" name version
                      (if (version-newer? latest version)
                          (format #f " -> ~a" latest)
                          " up to date"))
              #f)))))))

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

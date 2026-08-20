#!/usr/bin/env guile
!#

;;; Report packages whose upstream GitHub release is newer than ours.
;;;
;;; Reads the package definitions as text rather than going through `guix
;;; refresh', which needs a full `guix pull' to load the modules some of our
;;; packages import -- that pull is what kept this check slow and red.  Every
;;; package here lives on GitHub, and /releases/latest redirects to the tag of
;;; the newest release, so following that redirect is enough.  No API token, no
;;; JSON parsing, no Guix.
;;;
;;; Prints one "name<TAB>old<TAB>new" line per outdated package on stdout, and
;;; progress on stderr.  Exits non-zero if any package could not be checked: a
;;; partial result must never look like a clean run.

(define-module (scripts check-updates))

(use-modules (ice-9 regex)
             (ice-9 popen)
             (ice-9 rdelim)
             (ice-9 ftw)
             (ice-9 textual-ports)
             (srfi srfi-1))

(define %package-dir "guix-cloudnative/packages")

(define %define-public-rx (make-regexp "\\(define-public[ \t\n]+"))
(define %name-rx (make-regexp "\\(name[ \t\n]+\"([^\"]+)\""))
(define %version-rx (make-regexp "\\(version[ \t\n]+\"([^\"]+)\""))
(define %repo-rx
  (make-regexp "github\\.com/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+)"))
(define %tag-rx (make-regexp "/releases/tag/(.+)$"))
(define %digits-rx (make-regexp "[0-9]+"))

(define (file-contents path)
  (call-with-input-file path get-string-all))

(define (group rx str n)
  "Return capture group N of RX in STR, or #f."
  (let ((m (regexp-exec rx str)))
    (and m (match:substring m n))))

(define (split-packages content)
  "Split CONTENT into one chunk per top-level define-public form."
  (let ((matches (list-matches %define-public-rx content)))
    (let loop ((ms matches) (acc '()))
      (if (null? ms)
          (reverse acc)
          (let ((start (match:end (car ms)))
                (end (if (null? (cdr ms))
                         (string-length content)
                         (match:start (cadr ms)))))
            (loop (cdr ms) (cons (substring content start end) acc)))))))

(define (strip-v str)
  "Drop the leading v of a tag like v1.2.3."
  (if (and (not (string-null? str))
           (memv (string-ref str 0) '(#\v #\V)))
      (string-drop str 1)
      str))

(define (strip-suffix suffix str)
  (if (string-suffix? suffix str)
      (string-drop-right str (string-length suffix))
      str))

(define (chunk->package chunk)
  "Return (name version repo-or-#f) for CHUNK, or #f when it holds no package
or is a go-* dependency, which we pin to a commit rather than track."
  (let ((name (group %name-rx chunk 1))
        (version (group %version-rx chunk 1)))
    (and name version
         (not (string-prefix? "go-" name))
         (let ((m (regexp-exec %repo-rx chunk)))
           (list name version
                 (and m (string-append (match:substring m 1) "/"
                                       (strip-suffix
                                        ".git" (match:substring m 2)))))))))

(define (packages-in path)
  (filter-map chunk->package (split-packages (file-contents path))))

(define (effective-url url)
  "Follow redirects for URL and return where it lands, or #f on failure."
  (let* ((port (open-pipe* OPEN_READ "curl" "-s" "-L" "-o" "/dev/null"
                           "--max-time" "30" "-w" "%{url_effective}" url))
         (out (read-string port)))
    (and (zero? (status:exit-val (close-pipe port)))
         (not (string-null? out))
         out)))

(define (latest-release repo)
  "Return the newest release tag of REPO, or #f."
  (let ((landed (effective-url
                 (string-append "https://github.com/" repo
                                "/releases/latest"))))
    ;; A repo with no release at all stays on /releases, with no tag to read.
    (and landed (group %tag-rx landed 1))))

(define (version->list version)
  (map (lambda (m) (string->number (match:substring m)))
       (list-matches %digits-rx version)))

(define (version-newer? a b)
  "Is version A strictly newer than B?  Compares numerically so an odd
upstream tag never gets reported as a downgrade."
  (let loop ((a (version->list a)) (b (version->list b)))
    (cond ((null? a) #f)
          ((null? b) #t)
          ((> (car a) (car b)) #t)
          ((< (car a) (car b)) #f)
          (else (loop (cdr a) (cdr b))))))

(define (scm-files dir)
  (map (lambda (f) (string-append dir "/" f))
       (sort (filter (lambda (f) (string-suffix? ".scm" f))
                     (or (scandir dir) '()))
             string<?)))

(define (main)
  (let ((failures '()))
    (for-each
     (lambda (path)
       (for-each
        (lambda (pkg)
          (let ((name (first pkg))
                (version (second pkg))
                (repo (third pkg)))
            (if (not repo)
                (set! failures
                      (cons (string-append name ": no github.com URL found")
                            failures))
                (let ((tag (latest-release repo)))
                  (cond
                   ((not tag)
                    (set! failures
                          (cons (string-append name " (" repo
                                               "): no release found")
                                failures)))
                   (else
                    (let ((new (strip-v tag)))
                      (cond
                       ((version-newer? new version)
                        (format #t "~a\t~a\t~a~%" name version new)
                        (format (current-error-port)
                                "~a: ~a -> ~a~%" name version new))
                       (else
                        (format (current-error-port)
                                "~a: ~a up to date~%" name version))))))))))
        (packages-in path)))
     (scm-files %package-dir))

    (unless (null? failures)
      (format (current-error-port) "~%failed to check:~%")
      (for-each (lambda (f) (format (current-error-port) "  ~a~%" f))
                (reverse failures))
      (exit 1))))

(main)

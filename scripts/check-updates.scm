#!/usr/bin/env -S guix repl --
!#

;;; Report packages in this channel whose upstream release is newer than the
;;; version we package.  Run from the repository root:
;;;
;;;   guix repl -- scripts/check-updates.scm
;;;
;;; Prints one "name<TAB>current<TAB>latest" line per outdated package on
;;; stdout, and progress on stderr.  Exits non-zero if any package could not
;;; be checked, so a partial result never passes as a clean run -- note that
;;; `guix refresh' itself only warns and still exits 0 in that case.

(define-module (scripts check-updates)
  #:use-module (guix packages)
  #:use-module (guix discovery)
  #:use-module (guix upstream)
  #:use-module (guix ui)
  #:use-module (guix i18n)
  #:use-module (guix utils)
  #:use-module (guix scripts refresh)
  #:use-module (srfi srfi-1))

(add-to-load-path ".")

(define %package-directory "guix-cloudnative/packages")

(define (abort-on-load-error file . rest)
  ;; Skipping a module we cannot load is how a broken check ends up looking
  ;; green, so refuse to continue instead.
  (leave (G_ "cannot load '~a': ~s~%") file rest))

(define (tracked-package? obj)
  ;; go-* variables are Go module dependencies pinned to a commit, not
  ;; something with releases to follow.
  (and (package? obj)
       (not (string-prefix? "go-" (package-name obj)))))

(define (channel-packages)
  "Return the packages defined in this channel, sorted by name."
  (sort (fold-module-public-variables
         (lambda (obj result)
           (if (tracked-package? obj) (cons obj result) result))
         '()
         (all-modules (list (cons "." %package-directory))
                      #:warn abort-on-load-error))
        (lambda (a b)
          (string<? (package-name a) (package-name b)))))

(define (latest-version package)
  "Return the newest upstream version of PACKAGE, or #f if no updater knows."
  (let ((source (package-latest-release package (force %updaters))))
    (and (upstream-source? source)
         (upstream-source-version source))))

(define (report package)
  "Print PACKAGE's status.  Return its name if it could not be checked, else #f."
  (let* ((name (package-name package))
         (current (package-version package))
         (latest (latest-version package)))
    (cond
     ((not latest)
      name)
     ((version>? latest current)
      (format #t "~a\t~a\t~a~%" name current latest)
      (format (current-error-port) "~a: ~a -> ~a~%" name current latest)
      #f)
     (else
      (format (current-error-port) "~a: ~a up to date~%" name current)
      #f))))

(define (main)
  (let ((unchecked (filter-map report (channel-packages))))
    (unless (null? unchecked)
      (leave (G_ "no upstream release found for: ~a~%")
             (string-join unchecked ", ")))))

(main)

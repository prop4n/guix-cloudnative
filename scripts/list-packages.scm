#!/usr/bin/env -S guix repl --
!#

(define-module (scripts list-packages))

(add-to-load-path ".")

(use-modules (guix packages)
             (ice-9 ftw)
             (srfi srfi-1))

(define (scm-files dir)
  (map (lambda (f) (string-append dir "/" f))
       (filter (lambda (f) (string-suffix? ".scm" f))
               (or (scandir dir) '()))))

(define (path->module-name path)
  (map string->symbol
       (string-split (string-drop-right path 4) #\/)))

(define module-names
  (map path->module-name
       (scm-files "guix-cloudnative/packages")))

(define (module->packages mod-name)
  (let* ((iface (false-if-exception (resolve-interface mod-name)))
         (acc '()))
    (when iface
      (module-for-each
       (lambda (sym var)
         (let ((val (false-if-exception (variable-ref var))))
           (when (and val
                      (package? val)
                      (not (string-prefix? "go-" (package-name val))))
             (set! acc (cons val acc)))))
       iface))
    acc))

(for-each
 (lambda (pkg)
   (display (package-name pkg))
   (newline))
 (append-map module->packages module-names))

(define-module (guix-cloudnative packages wails)
  #:use-module (guix packages)
  #:use-module (guix build-system go)
  #:use-module (guix gexp)
  #:use-module (guix-cloudnative packages golang)
  #:use-module ((guix licenses) #:prefix license:))

(define-public wails
  (package
    (inherit go-github-com-wailsapp-wails)
    (name "wails")
    (arguments
     (list
      #:import-path "github.com/wailsapp/wails/v2/cmd/wails"
      #:unpack-path "github.com/wailsapp/wails"
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'fix-embed
                     (lambda _
                       (for-each
                        (lambda (f)
                          (let ((target (readlink f)))
                            (delete-file f)
                            (copy-file target f)))
                        (find-files "." (lambda (f stat)
                                          (eq? (stat:type stat) 'symlink)))))))
      #:tests? #f))))

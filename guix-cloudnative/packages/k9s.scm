(define-module (guix-cloudnative packages k9s)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module ((guix licenses) #:prefix license:))

(define-public k9s
  (package
    (name "k9s")
    (version "0.50.18")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/derailed/k9s/releases/download/v"
                    version "/k9s_Linux_amd64.tar.gz"))
              (sha256
               (base32
                "16wy5bx4abwdyaqr3xlbna8z2gd7zgqxdvnywiypz6c0mba7ws8b"))))
    (build-system copy-build-system)
    (arguments
     '(#:install-plan '(("k9s" "bin/k9s"))))
    (native-inputs (list tar gzip))
    (home-page "https://github.com/derailed/k9s")
    (synopsis "Kubernetes CLI to manage clusters in style")
    (description "k9s provides a terminal UI to interact with your Kubernetes clusters.")
    (license license:asl2.0)))

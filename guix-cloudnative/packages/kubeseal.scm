(define-module (guix-cloudnative packages kubeseal)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (nonguix build-system binary)
  #:use-module ((guix licenses) #:prefix license:))

(define-public kubeseal
  (package
    (name "kubeseal")
    (version "0.36.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/bitnami-labs/sealed-secrets/releases/download/v"
             version "/kubeseal-" version "-linux-amd64.tar.gz"))
       (sha256
        (base32 "1xzmddi3skccgkfxzm9vhafqv9accbxy2vylnhw7b31vmryz7rn0"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("kubeseal" "bin/"))))
    (home-page "https://github.com/bitnami-labs/sealed-secrets")
    (synopsis "CLI tool for sealing Kubernetes secrets")
    (description
     "Kubeseal is a CLI tool that encrypts Kubernetes Secret resources into
SealedSecret resources, which are safe to store in version control.  Only the
Sealed Secrets controller running in the target cluster can decrypt them.")
    (license license:asl2.0)))

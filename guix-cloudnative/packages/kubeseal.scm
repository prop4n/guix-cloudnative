(define-module (guix-cloudnative packages kubeseal)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (nonguix build-system binary)
  #:use-module ((guix licenses) #:prefix license:))

(define-public kubeseal
  (package
    (name "kubeseal")
    (version "0.36.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/bitnami-labs/sealed-secrets/releases/download/v"
             version "/kubeseal-" version "-linux-amd64.tar.gz"))
       (sha256
        (base32 "1ij0vj00a087gb873bynk7cyy4bnf66dawqh4q9rxmz85c2a0iqw"))))
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

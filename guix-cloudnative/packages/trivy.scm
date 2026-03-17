(define-module (guix-cloudnative packages trivy)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:))

(define-public trivy
  (package
    (name "trivy")
    (version "0.69.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/aquasecurity/trivy/releases/download/v"
             version "/trivy_" version "_Linux-64bit.tar.gz"))
       (sha256
        (base32 "0xcbr1biv345997n7mcbd2vrqqnidgii628cfjf8cag5vwrbc5hq"))))
    (build-system copy-build-system)
    (arguments
     '(#:install-plan
       '(("../trivy" "bin/trivy"))
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'fix-permissions
           (lambda _
             (chmod "../trivy" #o755))))))
    (supported-systems '("x86_64-linux"))
    (home-page "https://trivy.dev")
    (synopsis "Security scanner for vulnerabilities and misconfigurations")
    (description
     "Trivy is a comprehensive security scanner that finds vulnerabilities,
misconfigurations, and secrets in container images, filesystems, Git
repositories, Kubernetes manifests, and IaC files.")
    (license license:asl2.0)))

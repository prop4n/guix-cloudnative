(define-module (guix-cloudnative packages golang)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system go)
  #:use-module (guix status)
  #:use-module (guix gexp)
  #:use-module (gnu packages golang)
  #:use-module (gnu packages package-management)
  #:use-module ((guix licenses) #:prefix license:))

(define-public go-github-com-mkmik-multierror
  (package
    (name "go-github-com-mkmik-multierror")
    (version "0.4.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/mkmik/multierror")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0dvxd0scrxnm8q4xhb1db4bmkj0avpk2k65w7f216cmhkkksdx7g"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/mkmik/multierror"
      #:test-flags #~(list "-vet=off")))
    (home-page "https://github.com/mkmik/multierror")
    (synopsis "Combine multiple errors into one")
    (description
     "The multierror package provides useful helpers to handle multiple errors wrapped together.")
    (license license:expat)))

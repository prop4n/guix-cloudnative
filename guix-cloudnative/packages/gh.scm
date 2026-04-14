(define-module (guix-cloudnative packages gh)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (nonguix build-system binary)
  #:use-module ((guix licenses) #:prefix license:))

(define-public gh
  (package
    (name "gh")
    (version "2.89.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/cli/cli/releases/download/v"
             version "/gh_" version "_linux_amd64.tar.gz"))
       (sha256
        (base32 "1n4h6jxgmmnp1bqpysrx43hsifmfgnj8sm8wdkkk01ajvsm2qhnh"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("bin/gh" "bin/")
          ("share/" "share/"))))
    (home-page "https://github.com/cli/cli")
    (synopsis "GitHub's official command line tool")
    (description
     "@command{gh} is GitHub on the command line.  It brings pull requests,
issues, and other GitHub concepts to the terminal next to where you are
already working with @command{git} and your code.")
    (license license:expat)))

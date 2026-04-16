(define-module (guix-cloudnative packages glance)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system go)
  #:use-module (guix gexp)
  #:use-module (gnu packages golang-build)
  #:use-module (gnu packages golang-web)
  #:use-module (gnu packages golang-xyz)
  #:use-module (guix-cloudnative packages golang)
  #:use-module ((guix licenses) #:prefix license:))

(define-public glance
  (package
    (name "glance")
    (version "0.8.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/glanceapp/glance")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1d6wr7k4n93g43bjs2f8q96afwshcbv4xwhdf6b0mqsjdc4brjz2"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/glanceapp/glance"
      #:install-source? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'wrap-binary
            (lambda* (#:key outputs #:allow-other-keys)
              (wrap-program (string-append (assoc-ref outputs "out")
                                           "/bin/glance")
                `("GODEBUG" ":" prefix ("httpmuxgo121=0"))))))))
    (inputs (list go-github-com-fsnotify-fsnotify
                  go-github-com-mmcdole-gofeed
                  go-github-com-shirou-gopsutil-v4
                  go-github-com-tidwall-gjson
                  go-golang-org-x-crypto
                  go-golang-org-x-text
                  go-gopkg-in-yaml-v3))
    (home-page "https://github.com/glanceapp/glance")
    (synopsis "Self-hosted dashboard")
    (description
     "Glance is a self-hosted dashboard that puts all your feeds in one place.")
    (license license:agpl3)))

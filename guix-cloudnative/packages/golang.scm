*(define-module (guix-cloudnative packages golang)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (gnu packages golang-check)
  #:use-module (guix build-system go)
  #:use-module (gnu packages golang-build)
  #:use-module (guix status)
  #:use-module (gnu packages golang-xyz)
  #:use-module (gnu packages golang-web)
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

(define-public go-github-com-throttled-throttled
  (package
    (name "go-github-com-throttled-throttled")
    (version "1.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/throttled/throttled")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "00rllq53h83cvxd9r7dd65xa1k4kn116jk2yf2amxh53x080qggf"))))
    (build-system go-build-system)
    (propagated-inputs
     (list go-github-com-golang-groupcache))
    (arguments
     (list
      #:import-path "gopkg.in/throttled/throttled.v1"
      #:unpack-path "gopkg.in/throttled/throttled.v1"
      #:tests? #f))
    (home-page "https://github.com/throttled/throttled")
    (synopsis "Throttled")
    (description
     "Package throttled implements rate limiting access to resources such as HTTP endpoints.")
    (license license:bsd-3)))

(define-public go-k8s-io-code-generator
  (package
    (name "go-k8s-io-code-generator")
    (version "0.35.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/kubernetes/code-generator")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "110ngkzvv3832sdal7v8v6zfjx5k1ncg04hlyiyfs0ssjlnbbqq2"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "k8s.io/code-generator"
      #:tests? #f))
    (propagated-inputs (list go-github-com-gogo-protobuf
                             go-github-com-google-gnostic-models
                             go-github-com-google-go-cmp
                             go-github-com-spf13-pflag
                             go-go-yaml-in-yaml-v2
                             go-golang-org-x-text
                             go-k8s-io-apimachinery
                             go-k8s-io-gengo-v2
                             go-k8s-io-klog-v2
                             go-k8s-io-kube-openapi
                             go-k8s-io-utils
                             go-sigs-k8s-io-randfill))
    (home-page "https://k8s.io/code-generator")
    (synopsis "code-generator")
    (description
     "Golang code-generators used to implement
@@url{https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md,Kubernetes-style
API types}.")
    (license license:asl2.0)))

(define-public go-k8s-io-klog
  (package
    (name "go-k8s-io-klog")
    (version "1.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/kubernetes/klog")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1cgannfmldcrcksb2wqdn2b5qabqyxl9r25w9y4qbljw24hhnlvn"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "k8s.io/klog"
      #:tests? #f))
    (propagated-inputs (list go-github-com-go-logr-logr))
    (home-page "https://k8s.io/klog")
    (synopsis "klog")
    (description
     "Package klog implements logging analogous to the Google-internal C++
INFO/ERROR/V setup.  It provides functions Info, Warning, Error, Fatal, plus
formatting variants such as Infof.  It also provides V-style logging controlled
by the -v and -vmodule=file=2 flags.")
    (license license:asl2.0)))

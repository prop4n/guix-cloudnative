(define-module (guix-cloudnative packages golang)
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

(define-public go-github-com-go-ole-go-ole
  (package
    (name "go-github-com-go-ole-go-ole")
    (version "1.3.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/go-ole/go-ole")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1vr62wwjp206sxah2l79l007s7n187fjzkrnwb85ivqmazfjspxl"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/go-ole/go-ole"))
    (propagated-inputs (list go-golang-org-x-sys))
    (home-page "https://github.com/go-ole/go-ole")
    (synopsis "Go OLE")
    (description
     "Go bindings for Windows COM using shared libraries instead of cgo.")
    (license license:expat)))

(define-public go-github-com-lufia-plan9stats
  (package
    (name "go-github-com-lufia-plan9stats")
    (version "0.0.0-20260330125221-c963978e514e")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/lufia/plan9stats")
             (commit (go-version->git-ref version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1wf1q1n72d46k5a6h40a7jnqhainmibxbgl94qhfclbyys876q86"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/lufia/plan9stats"))
    (propagated-inputs (list go-github-com-google-go-cmp))
    (home-page "https://github.com/lufia/plan9stats")
    (synopsis "plan9stats")
    (description "Package stats provides statistic utilities for Plan 9.")
    (license license:bsd-3)))

(define-public go-github-com-mmcdole-gofeed
  (package
    (name "go-github-com-mmcdole-gofeed")
    (version "1.3.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/mmcdole/gofeed")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "03cmj4wk6yicv5pqxwa3sbqxxbw3srx2j5c9938yv0ydkccnlyhq"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/mmcdole/gofeed"
      #:tests? #f))
    (propagated-inputs (list go-github-com-json-iterator-go
                             go-github-com-mmcdole-goxpp
                             go-github-com-puerkitobio-goquery
                             go-github-com-stretchr-testify
                             go-github-com-urfave-cli
                             go-golang-org-x-net
                             go-golang-org-x-text))
    (home-page "https://github.com/mmcdole/gofeed")
    (synopsis "gofeed")
    (description
     "@@code{gofeed} is a powerful and flexible library designed for parsing
@@strong{RSS}, @@strong{Atom}, and @@strong{JSON} feeds across various formats
and versions.  It effectively manages non-standard elements and known
extensions, and demonstrates resilience against common feed issues.")
    (license license:expat)))

(define-public go-github-com-power-devops-perfstat
  (package
    (name "go-github-com-power-devops-perfstat")
    (version "0.0.0-20240221224432-82ca36839d55")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/power-devops/perfstat")
             (commit (go-version->git-ref version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0lmsxb3wlf0088198mcljq6krqnvpy1qy8li833hhhkdbckywg5s"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/power-devops/perfstat"
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
                       (add-after 'unpack 'remove-aix-c-files
                                  (lambda* (#:key import-path #:allow-other-keys)
                                           (with-directory-excursion (string-append "src/" import-path)
                                                                     (for-each delete-file (find-files "." "\\.c$"))))))))

    (propagated-inputs (list go-golang-org-x-sys))
    (home-page "https://github.com/power-devops/perfstat")
    (synopsis #f)
    (description
     "Copyright 2020 Power-Devops.com.  All rights reserved.  Use of this source code
is governed by the license that can be found in the LICENSE file.")
    (license license:expat)))

(define-public go-github-com-yusufpapurcu-wmi
  (package
    (name "go-github-com-yusufpapurcu-wmi")
    (version "1.2.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/yusufpapurcu/wmi")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1c6xjjad3zxddw8x910aiy5h9h8ndlal99cxn47ddrwn6c307rip"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/yusufpapurcu/wmi"
      #:tests? #f
      #:skip-build? #t))
    (propagated-inputs (list go-github-com-go-ole-go-ole))
    (home-page "https://github.com/yusufpapurcu/wmi")
    (synopsis "wmi")
    (description "Package wmi provides a WQL interface for WMI on Windows.")
    (license license:expat)))

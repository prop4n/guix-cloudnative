(define-module (guix-cloudnative packages kubeseal)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system go)
  #:use-module (gnu packages golang)
  #:use-module (guix gexp)
  #:use-module (gnu packages prometheus)
  #:use-module (gnu packages golang-check)
  #:use-module (gnu packages golang-build)
  #:use-module (gnu packages golang-xyz)
  #:use-module (gnu packages golang-web)
  #:use-module (gnu packages golang-crypto)
  #:use-module (gnu packages kubernetes)
  #:use-module (guix-cloudnative packages golang)
  #:use-module ((guix licenses) #:prefix license:))


(define-public kubeseal
  (package
    (name "kubeseal")
    (version "0.36.6")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/bitnami-labs/sealed-secrets")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1mmqyflq4mx3bbc2mrf1hrpqlq4bjb13xf4s7rrylv6dslaxz68z"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/bitnami-labs/sealed-secrets/cmd/kubeseal"
      #:unpack-path "github.com/bitnami-labs/sealed-secrets"
      #:build-flags #~(list (string-append "-ldflags=-X main.VERSION=v" #$version))
      #:tests? #f))
    (propagated-inputs (list go-github-com-google-go-cmp
                             go-github-com-google-renameio
                             go-github-com-masterminds-sprig-v3
                             go-github-com-mattn-go-isatty
                             go-github-com-mkmik-multierror
                             go-github-com-onsi-ginkgo-v2
                             go-github-com-onsi-gomega
                             go-github-com-prometheus-client-golang
                             go-github-com-prometheus-client-model
                             go-github-com-spf13-pflag
                             go-github-com-throttled-throttled
                             go-golang-org-x-crypto
                             go-gopkg-in-yaml-v2
                             go-k8s-io-api
                             go-k8s-io-apimachinery
                             go-k8s-io-client-go
                             go-k8s-io-code-generator
                             go-k8s-io-klog
                             go-k8s-io-klog-v2
                             go-k8s-io-utils))
    (home-page "https://github.com/bitnami-labs/sealed-secrets")
    (synopsis "Sealed Secrets for Kubernetes")
    (description
     "Package sealed-secrets implements one-way encrypted Secrets for Kubernetes.")
    (license license:asl2.0)))

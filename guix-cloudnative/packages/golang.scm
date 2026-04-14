(define-module (guix-cloudnative packages golang)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (gnu packages golang-check)
  #:use-module (guix build-system go)
  #:use-module (gnu packages golang-build)
  #:use-module (guix status)
  #:use-module (gnu packages golang-vcs)
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

(define-public go-github-com-bep-debounce
  (package
    (name "go-github-com-bep-debounce")
    (version "1.2.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/bep/debounce")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1i8r381j92b49l7vywcmi4s5hvp9hzj0dmz5n722gln1ifkwx8gf"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/bep/debounce"))
    (home-page "https://github.com/bep/debounce")
    (synopsis "Go Debounce")
    (description
     "Package debounce provides a debouncer func.  The most typical use case would be
the user typing a text into a form; the UI needs an update, but let's wait for a
break.")
    (license license:expat)))

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

(define-public go-github-com-jchv-go-winloader
  (package
    (name "go-github-com-jchv-go-winloader")
    (version "0.0.0-20250406163304-c1995be93bd1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jchv/go-winloader")
             (commit (go-version->git-ref version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0bvpww4fak48h98rzby2sym7y4byf13b1sm9qbhbv61wnak41223"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/jchv/go-winloader"))
    (propagated-inputs (list go-golang-org-x-sys))
    (home-page "https://github.com/jchv/go-winloader")
    (synopsis "go-winloader")
    (description
     "@@strong{Note:} This library is still experimental.  There are no guarantees of
API stability, or runtime stability.  Proceed with caution.")
    (license license:isc)))

(define-public go-github-com-klauspost-crc32
  (package
    (name "go-github-com-klauspost-crc32")
    (version "1.3.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/klauspost/crc32")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1a3dc0aj9qd12ynhpy1hccjij306h0dc5y1fz90kamsv68qbzi26"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/klauspost/crc32"))
    (propagated-inputs (list go-golang-org-x-sys))
    (home-page "https://github.com/klauspost/crc32")
    (synopsis "2025 revival")
    (description
     "Package crc32 implements the 32-bit cyclic redundancy check, or CRC-32,
checksum.  See
@@url{https://en.wikipedia.org/wiki/Cyclic_redundancy_check,https://en.wikipedia.org/wiki/Cyclic_redundancy_check}
for information.")
    (license license:bsd-3)))

(define-public go-github-com-leaanthony-debme
  (package
    (name "go-github-com-leaanthony-debme")
    (version "1.2.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/leaanthony/debme")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1fy04bandf497yxag9lli42k775541dyhi1p0mk6bivwsnpz30jl"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/leaanthony/debme"))
    (propagated-inputs (list go-github-com-leaanthony-slicer
                             go-github-com-matryer-is))
    (home-page "https://github.com/leaanthony/debme")
    (synopsis "Features")
    (description
     "@@code{embed.FS} wrapper providing additional functionality
@@url{https://github.com/leaanthony/debme/blob/master/LICENSE,(img (@@ (src
https://img.shields.io/badge/License-MIT-blue.svg)))}
@@url{https://goreportcard.com/report/github.com/leaanthony/debme,(img (@@ (src
https://goreportcard.com/badge/github.com/leaanthony/debme)))}
@@url{https://godoc.org/github.com/leaanthony/debme,(img (@@ (src
https://img.shields.io/badge/godoc-reference-blue.svg)))}
@@url{https://www.codefactor.io/repository/github/leaanthony/debme,(img (@@ (src
https://www.codefactor.io/repository/github/leaanthony/debme/badge) (alt
@code{CodeFactor})))} @@url{https://github.com/leaanthony/debme/issues,(img (@@
(src
https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)
(alt @code{CodeFactor})))}
@@url{https://app.fossa.io/projects/git%2Bgithub.com%2Fleaanthony%2Fdebme?ref=badge_shield,(img
(@@ (src
https://app.fossa.io/api/projects/git%2Bgithub.com%2Fleaanthony%2Fdebme.svg?type=shield)))}
@@url{https://github.com/avelino/awesome-go,(img (@@ (src
https://awesome.re/mentioned-badge.svg)))}.")
    (license license:expat)))

(define-public go-github-com-leaanthony-slicer
  (package
    (name "go-github-com-leaanthony-slicer")
    (version "1.6.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/leaanthony/slicer")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "17kij9rd35s9f8j92390zisv7l06hli1p9fks33bi708ls3w35v7"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/leaanthony/slicer"))
    (propagated-inputs (list go-github-com-matryer-is))
    (home-page "https://github.com/leaanthony/slicer")
    (synopsis "Install")
    (description
     "Package slicer contains utility classes for handling slices.")
    (license license:expat)))

(define-public go-github-com-leaanthony-gosod
  (package
    (name "go-github-com-leaanthony-gosod")
    (version "1.0.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/leaanthony/gosod")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0w3fpsv7v79v4b69p4nax4ky029xwc5jawyjwynq25skr8rv1rbd"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/leaanthony/gosod"))
    (propagated-inputs (list go-github-com-leaanthony-debme
                             go-github-com-matryer-is))
    (home-page "https://github.com/leaanthony/gosod")
    (synopsis "Installation")
    (description
     "Scaffolding simplified
@@url{https://github.com/leaanthony/gosod/blob/master/LICENSE,(img (@@ (src
https://img.shields.io/badge/License-MIT-blue.svg)))}
@@url{https://goreportcard.com/report/github.com/leaanthony/gosod,(img (@@ (src
https://goreportcard.com/badge/github.com/leaanthony/gosod)))}
@@url{https://godoc.org/github.com/leaanthony/gosod,(img (@@ (src
https://img.shields.io/badge/godoc-reference-blue.svg)))}
@@url{https://github.com/leaanthony/gosod/issues,(img (@@ (src
https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)
(alt @code{CodeFactor})))}
@@url{https://app.fossa.io/projects/git%2Bgithub.com%2Fleaanthony%2Fgosod?ref=badge_shield,(img
(@@ (src
https://app.fossa.io/api/projects/git%2Bgithub.com%2Fleaanthony%2Fgosod.svg?type=shield)))}.")
    (license license:expat)))

(define-public go-github-com-leaanthony-u
  (package
    (name "go-github-com-leaanthony-u")
    (version "1.1.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/leaanthony/u")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "10x3m31xghjrq7r9dr7y712djhknmn8h3vsf4ycvfr1dxwn903k7"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/leaanthony/u"))
    (home-page "https://github.com/leaanthony/u")
    (synopsis "u")
    (description
     "u provides a simple way to create variables that are \"unset\" by default.")
    (license license:expat)))

(define-public go-github-com-tkrajina-go-reflector
  (package
    (name "go-github-com-tkrajina-go-reflector")
    (version "0.5.8")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/tkrajina/go-reflector")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "151jcf23spwb0ggb57q58dj6wb0qmmmbafzdrdw4namcql2aix5v"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/tkrajina/go-reflector/reflector"
      #:unpack-path "github.com/tkrajina/go-reflector"
      #:tests? #f))
    (propagated-inputs (list go-github-com-stretchr-testify))
    (home-page "https://github.com/tkrajina/go-reflector")
    (synopsis "Golang reflector")
    (description "First of all, don't use reflection if you don't have to.")
    (license license:asl2.0)))

(define-public go-github-com-wailsapp-mimetype
  (package
    (name "go-github-com-wailsapp-mimetype")
    (version "1.4.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/wailsapp/mimetype")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0hblxw5fpg3gz0ar2f8d5gypniwig1bcwv8y3699yxbp6pyykf16"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/wailsapp/mimetype"
      #:tests? #f))
    (propagated-inputs (list go-golang-org-x-net))
    (home-page "https://github.com/wailsapp/mimetype")
    (synopsis "Features")
    (description
     "Package mimetype uses magic number signatures to detect the MIME type of a file.")
    (license license:expat)))

(define-public go-github-com-wailsapp-wails
  (package
    (name "go-github-com-wailsapp-wails")
    (version "2.12.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/wailsapp/wails")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1jcypf5c1rlqwhfxvcsk0148hmqajnkgssdk558z916p8rn1yy2y"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/wailsapp/wails/v2"
      #:unpack-path "github.com/wailsapp/wails"))
    (propagated-inputs (list go-github-com-acarl005-stripansi
                             go-github-com-bep-debounce
                             go-github-com-bitfield-script
                             go-github-com-charmbracelet-glamour
                             go-github-com-flytam-filenamify
                             go-github-com-fsnotify-fsnotify
                             go-github-com-go-git-go-git-v5
                             go-github-com-go-ole-go-ole
                             go-github-com-godbus-dbus-v5
                             go-github-com-google-shlex
                             go-github-com-google-uuid
                             go-github-com-gorilla-websocket
                             go-github-com-jackmordaunt-icns
                             go-github-com-jaypipes-ghw
                             go-github-com-labstack-echo-v4
                             go-github-com-labstack-gommon
                             go-github-com-leaanthony-clir
                             go-github-com-leaanthony-debme
                             go-github-com-leaanthony-go-ansi-parser
                             go-github-com-leaanthony-gosod
                             go-github-com-leaanthony-slicer
                             go-github-com-leaanthony-u
                             go-github-com-leaanthony-winicon
                             go-github-com-masterminds-semver
                             go-github-com-matryer-is
                             go-github-com-pkg-browser
                             go-github-com-pkg-errors
                             go-github-com-pterm-pterm
                             go-github-com-sabhiram-go-gitignore
                             go-github-com-samber-lo
                             go-github-com-stretchr-testify
                             go-github-com-tc-hib-winres
                             go-github-com-tidwall-sjson
                             go-github-com-tkrajina-go-reflector
                             go-github-com-wailsapp-go-webview2
                             go-github-com-wailsapp-mimetype
                             go-github-com-wzshiming-ctc
                             go-golang-org-x-mod
                             go-golang-org-x-net
                             go-golang-org-x-sys
                             go-golang-org-x-tools))
    (home-page "https://github.com/wailsapp/wails")
    (synopsis "Table of Contents")
    (description
     "Package wails is the main package of the Wails project.  It is used by client
applications.")
    (license license:expat)))

(define-public go-github-com-bitfield-script
  (package
    (name "go-github-com-bitfield-script")
    (version "0.24.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/bitfield/script")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1pzmz7n39sh9sprclzd0m0l0flf626286fh51m065yjhkqzrjw89"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/bitfield/script"
      #:tests? #f))
    (propagated-inputs (list go-github-com-google-go-cmp
                             go-github-com-itchyny-gojq
                             go-github-com-rogpeppe-go-internal
                             go-mvdan-cc-sh-v3))
    (home-page "https://github.com/bitfield/script")
    (synopsis "What is")
    (description
     "Package script aims to make it easy to write shell-type scripts in Go, for
general system administration purposes: reading files, counting lines, matching
strings, and so on.")
    (license license:expat)))

(define-public go-github-com-flytam-filenamify
  (package
    (name "go-github-com-flytam-filenamify")
    (version "1.2.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/flytam/filenamify")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0qpynwjm1mjm8na0l8avgc3hnzniwh5cml5n06q55dncxyfk0hdk"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/flytam/filenamify"))
    (home-page "https://github.com/flytam/filenamify")
    (synopsis "go-filenamify")
    (description "Convert a string to a valid safe filename.")
    (license license:expat)))

(define-public go-github-com-jackmordaunt-icns
  (package
    (name "go-github-com-jackmordaunt-icns")
    (version "1.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/JackMordaunt/icns")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1q0cliwgj24vb9fr6k1wbqmv9iq3bafl6i5rvw6afpq3ykxh37kr"))))
    (build-system go-build-system)
    (propagated-inputs
     (list go-github-com-nfnt-resize
           go-github-com-pkg-errors))
    (arguments
     (list
      #:import-path "github.com/jackmordaunt/icns"
      #:tests? #f))
    (home-page "https://github.com/jackmordaunt/icns")
    (synopsis "icns")
    (description
     "Package icns implements an encoder for Apple's `.icns` file format.")
    (license license:expat)))

(define-public go-github-com-jaypipes-ghw
  (package
    (name "go-github-com-jaypipes-ghw")
    (version "0.24.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jaypipes/ghw")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0l711bpd3lrfi674124jqpdv1nv40m8v6db96nda1h3h809l0fln"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/jaypipes/ghw"
      #:tests? #f))
    (propagated-inputs (list go-github-com-jaypipes-pcidb
                             go-github-com-yusufpapurcu-wmi
                             go-gopkg-in-yaml-v3 go-howett-net-plist))
    (home-page "https://github.com/jaypipes/ghw")
    (synopsis "- Go HardWare discovery/inspection library")
    (description
     "package ghw discovers hardware-related information about the host computer,
including CPU, memory, block storage, NUMA topology, network devices, PCI, GPU,
and baseboard/BIOS/chassis/product information.")
    (license license:asl2.0)))

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
      #:skip-build? #t
      #:tests? #f))
    (propagated-inputs (list go-github-com-go-ole-go-ole))
    (home-page "https://github.com/yusufpapurcu/wmi")
    (synopsis "wmi")
    (description "Package wmi provides a WQL interface for WMI on Windows.")
    (license license:expat)))

(define-public go-github-com-jaypipes-pcidb
  (package
    (name "go-github-com-jaypipes-pcidb")
    (version "1.1.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jaypipes/pcidb")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "177v1qzn7hc5jdvgppc04cbxx7vwvrdgd22f1dzrf0sy1hqgk43m"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/jaypipes/pcidb"
      #:tests? #f))
    (home-page "https://github.com/jaypipes/pcidb")
    (synopsis "- the Golang PCI DB library")
    (description
     "@@code{pcidb} is a small Go library for programmatic querying of PCI vendor,
product and class information.")
    (license (list license:asl2.0 license:asl2.0))))

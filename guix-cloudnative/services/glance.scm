(define-module (guix-cloudnative services glance)
  #:use-module (gnu packages admin)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu system shadow)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (guix-cloudnative packages glance)
  #:export (glance-configuration
            glance-service-type))

;;;
;;; Default configuration file
;;;

(define %glance-default-config
  (plain-file "glance.yml"
              "\
server:
  port: 8080

pages:
  - name: Home
    columns:
      - size: small
        widgets:
          - type: clock
            hour-format: 24h

          - type: calendar

      - size: full
        widgets:
          - type: rss
            title: News
            feeds:
              - url: https://feeds.bbci.co.uk/news/world/rss.xml
                title: BBC World

      - size: small
        widgets:
          - type: weather
            units: metric
            location: Paris, France
"))

;;;
;;; Configuration record
;;;

(define-record-type* <glance-configuration>
  glance-configuration make-glance-configuration
  glance-configuration?
  (glance      glance-configuration-glance      (default glance))
  (config-file glance-configuration-config-file (default %glance-default-config)))

;;;
;;; Accounts
;;;

(define %glance-accounts
  (list (user-group
         (name "glance")
         (system? #t))
        (user-account
         (name "glance")
         (group "glance")
         (system? #t)
         (comment "Glance dashboard user")
         (home-directory "/var/lib/glance")
         (shell (file-append shadow "/sbin/nologin")))))

;;;
;;; Activation
;;;

(define (glance-activation config)
  #~(begin
      (use-modules (guix build utils))
      (let ((dir "/var/lib/glance"))
        (mkdir-p dir)
        (let* ((pw  (getpwnam "glance"))
               (uid (passwd:uid pw))
               (gid (passwd:gid pw)))
          (chown dir uid gid)))))

;;;
;;; Shepherd service
;;;

(define (glance-shepherd-service config)
  (let ((pkg    (glance-configuration-glance config))
        (cfgfile (glance-configuration-config-file config)))
    (list (shepherd-service
           (documentation "Run the Glance self-hosted dashboard.")
           (provision '(glance))
           (requirement '(networking user-processes))
           (start #~(make-forkexec-constructor
                     (list #$(file-append pkg "/bin/glance")
                           "--config" #$cfgfile)
                     #:user "glance"
                     #:group "glance"
                     #:log-file "/var/log/glance.log"))
           (stop #~(make-kill-destructor))
           (respawn? #t)))))

;;;
;;; Service type
;;;

(define glance-service-type
  (service-type
   (name 'glance)
   (extensions
    (list (service-extension shepherd-root-service-type
                             glance-shepherd-service)
          (service-extension account-service-type
                             (const %glance-accounts))
          (service-extension activation-service-type
                             glance-activation)))
   (default-value (glance-configuration))
   (description "Run Glance, a self-hosted dashboard.")))

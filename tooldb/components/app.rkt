#lang racket/base

(require koyo
         koyo/database/migrator
         racket/contract/base
         racket/contract/region
         racket/list
         threading
         web-server/dispatch
         (prefix-in sequencer: web-server/dispatchers/dispatch-sequencer)
         web-server/managers/lru
         web-server/servlet-dispatch
         "../pages/all.rkt"
         "auth.rkt"
         "mail.rkt"
         "user.rkt"
         "tool.rkt")

(provide
 make-app
 app?
 app-dispatcher)

(struct app (dispatcher)
  #:transparent)

(define/contract (make-app auth broker flashes mailer _migrator sessions users tools
 #:debug? [debug? #f]
 #:memory-threshold [memory-threshold (* 1 1024 1024 1024)]
 #:static-path [static-path #f])
(->* [auth-manager? broker? flash-manager? mailer? migrator? session-manager? user-manager? tool-manager?]
 [#:debug? boolean?
  #:memory-threshold exact-positive-integer?
  #:static-path (or/c #f path-string?)]
 app?)
(define-values (dispatch reverse-uri req-roles)
  (dispatch-rules+roles
   [("")
      ; #:roles (user)
      (tools-page tools)]

      ; TOOL LIST PAGE

      [("tools")
        (tools-page tools)]

      [("tools-search" (string-arg))
        #:method "get"
        (tools-search-results tools)]

      ; TOOL INFO PAGE

      [("tool-info" (integer-arg))
        (tool-info-page tools)]
      
      [("tool-edit" (integer-arg))
        #:method "post"
        (tool-edit tools)]

      [("tool-autocomplete" (string-arg))
        #:method "get"
        (tool-autocomplete tools)]

      [("tool-image" (integer-arg))
        (tool-img tools)]

      [("tool-image-thumb" (integer-arg))
        (tool-img-thumb tools)]

      [("tool-delete-confirmation" (integer-arg))
        (tool-delete-confirmation tools)]

      [("tool-delete-action" (integer-arg))
        #:method "post"
        (tool-delete-action tools)]

      ; MATERIAL LIST PAGE

      [("materials")
        (materials-page tools)]

      [("materials-search" (string-arg))
        #:method "get"
        (materials-search-results tools)]

      ; MATERIALS INFO PAGE

      [("material-info" (integer-arg))
        (material-info-page tools)]

      [("material-edit" (integer-arg))
        #:method "post"
        (material-edit tools)]

      [("material-image" (integer-arg))
        (material-img tools)]

      [("material-image-thumb" (integer-arg))
        (material-img-thumb tools)]

      [("material-delete-confirmation" (integer-arg))
        (material-delete-confirmation tools)]

      [("material-delete-action" (integer-arg))
        #:method "post"
        (material-delete-action tools)]

      [("material-autocomplete" (string-arg))
        #:method "get"
        (material-autocomplete tools)]

      ; APPLICATIONS PAGE

      [("application-info" (integer-arg))
        (application-info tools)]

      [("application-img-first-material" (integer-arg))
        (application-img-first-material tools)]

      [("application-img-first-tool" (integer-arg))
        (application-img-first-tool tools)]

      [("application-edit" (integer-arg))
        #:method "post"
        (application-edit tools)]

      [("application-delete-confirmation" (integer-arg))
        (application-delete-confirmation tools)]

      [("application-delete-action" (integer-arg))
        #:method "post"
        (application-delete-action tools)]

      [("dashboard")
        (dashboard-page tools)]

      [("login")
        (login-page auth)]

      [("logout")
        (logout-page auth)]

      [("password-reset")
        (request-password-reset-page mailer users)]

      [("password-reset" (integer-arg) (string-arg))
        (password-reset-page users)]

      [("signup")
        (signup-page auth mailer users)]

      [("verify" (integer-arg) (string-arg))
        (verify-page users)]))

  (define ((wrap-params handler) req)
    (parameterize ([current-broker broker]
                   [current-continuation-key-cookie-secure? (not debug?)]
                   [current-continuation-wrapper stack]
                   [current-reverse-uri-fn reverse-uri])
      (handler req)))

  ;; Requests go up (starting from the last wrapper) and respones go down!
  (define (stack handler)
    (~> handler
        (wrap-protect-continuations)
        ((wrap-auth-required auth req-roles))
        ((wrap-browser-locale sessions))
        ((wrap-flash flashes))
        ((wrap-session sessions))
        (wrap-preload)
        (wrap-cors)
        (wrap-profiler)
        ((wrap-errors debug?))
        (wrap-params)))

  (define manager
    (make-threshold-LRU-manager (stack expired-page) memory-threshold))

  (define dispatchers
    (list
     (and static-path (make-static-dispatcher static-path))
     (dispatch/servlet #:manager manager (stack dispatch))
     (dispatch/servlet #:manager manager (stack not-found-page))))

  (app (apply sequencer:make (filter-map values dispatchers))))

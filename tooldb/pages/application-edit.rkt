#lang racket/base

(require koyo/haml
         koyo/url
         deta
         racket/dict
         racket/hash
         koyo/database
         racket/contract/base
         web-server/http
         web-server/http/bindings
         threading
         "../components/template.rkt"
         "../components/tool.rkt")

(provide
 (contract-out
  [application-edit (-> tool-manager? (-> request? integer? response?))]))

; (define ((dashboard-page tm) _req))
;   (page
;    (haml
;     (.container
;      (:h1 "Hello World!")))))


; This function is responsible for serving POST requests to edit APPLICATIONS, APPLICATION TOOLS AND APPLICATION MATERIALS.
; A new application will be created if appid = -1
; Existing application will be loaded otherwise
; Application tool and material entries are updated based on hidden inputs tool-hidden-id\\[([0-9]+)\\].
; The number between the square brackets is used as id of appliication_tools table.
; If the id = -1, a new record is created
; otherwise the record is updated
(define ((application-edit tm) _req mid)
  (define bindings (make-hash (request-bindings _req)))

  (with-database-connection [conn (tool-manager-db tm)]
    
    (define application
      ; -1 means the appliciation needs to be created
      (if (= mid -1)
        (begin 
          (let ([a (make-application
                      #:description "..."
                      #:note "...")])
            (insert-one! conn a)))
      (get-application-by-id tm mid) ))

    (set! application (set-application-description application (hash-ref bindings `description)))

    (set! application (set-application-note application (hash-ref bindings `note)))

    (update-one! conn application)

    ; Update application tool entries from form fields
    (dict-for-each bindings

     ; The form fields are passed here as key/value pairs
     (lambda (k v)

      ; Use regex to extract application_tools.id from the id of hidden fields 
      (define bindingid_match (regexp-match #rx"tool-hidden-id\\[(-?[0-9]+)\\]$" (symbol->string k)))
      (define tool-id-field-value (string->number v))

      ; Only process matching keys AND those entries where hidden input was set
      (when (and bindingid_match (> tool-id-field-value 0))
        ;(printf "~a = ~s\n" k v)
        ; Parse application_tool.id
        (define atid (string->number (cadr bindingid_match)))
        (define application-tool 
          ; -1 means the tool entry needs to be created
          (if (= atid -1)
          (begin
            (let ([a (make-application_tool 
              ; assign application id to application id that may have been created above
              #:applicationid (application-id application)
              ; assign toolid from hidden field
              #:toolid tool-id-field-value)])
              ; insert new record and assign to application-tool
              (insert-one! conn a))
            )
          ; else, record should already exist
          (get-application-tool-by-id tm atid)))

          ; change other fields
          (set! application-tool (set-application_tool-toolid application-tool (string->number v)))
          (displayln application-tool)
          ; submit update to the database
          (update-one! conn application-tool #:force? #t)

    )))

    ; Remove marked entries
    ; Update application tool entries from form fields
    (dict-for-each bindings

     ; The form fields are passed here as key/value pairs
     (lambda (k v)

      ; Use regex to extract application_tools.id from the id of hidden fields 
      (define bindingid_match (regexp-match #rx"remove-id\\[(-?[0-9]+)\\]$" (symbol->string k)))
      (printf "REMOVE-ID: ~a = ~s\n" k v)
      ; Only process matching keys
      (when (and bindingid_match (string=? v "on"))
        ;(printf "REMOVE-ID: ~a = ~s\n" k v)
        (printf "removing ~a from ~a ~a\n" bindingid_match mid v)
        (define atid (string->number (cadr bindingid_match)))
        (define application-tool (get-application-tool-by-id tm atid))
        (delete-one! conn application-tool)
        ; Parse application_tool.id
        ; (define atid (string->number (cadr bindingid_match)))
        ; (define application-tool 
        ;   ; -1 means the tool entry needs to be created
        ;   (if (= atid -1)
        ;   (begin
        ;     (let ([a (make-application_tool 
        ;       ; assign application id to application id that may have been created above
        ;       #:applicationid (application-id application)
        ;       ; assign toolid from hidden field
        ;       #:toolid tool-id-field-value)])
        ;       ; insert new record and assign to application-tool
        ;       (insert-one! conn a))
        ;     )
        ;   ; else, record should already exist
        ;   (get-application-tool-by-id tm atid)))

        ;   ; change other fields
        ;   (set! application-tool (set-application_tool-toolid application-tool (string->number v)))
        ;   (displayln application-tool)
        ;   ; submit update to the database
        ;   (update-one! conn application-tool #:force? #t)

    )))

    
    ; go back to application info screen
    (redirect-to (reverse-uri 'application-info (application-id application)))))
  

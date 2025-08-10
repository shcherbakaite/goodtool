#lang racket/base

(require 
  racket/contract/base
  racket/dict
  racket/hash
  threading
  koyo/haml
  koyo/url
  koyo/flash
  koyo/database
  deta
  web-server/http
  web-server/http/bindings
  "../components/template.rkt"
  "../components/tool.rkt")

(provide
 (contract-out
  [application-edit (-> tool-manager? (-> request? integer? response?))]))

; Process POST request to edit APPLICATIONS, APPLICATION TOOLS AND APPLICATION MATERIALS.
(define ((application-edit tm) _req mid)
  (define bindings (make-hash (request-bindings _req)))

  (with-database-connection [conn (tool-manager-db tm)]
    
    (define application
      ; -1 means the appliciation needs to be created
      (if (= mid -1)
        (begin 
          (let ([a (make-application
                      #:description ""
                      #:note "")])
            (flash 'success "Created new APPLICATION" )
            (insert-one! conn a)))
      (get-application-by-id tm mid) ))

    (set! application (set-application-description application (hash-ref bindings `description)))

    (set! application (set-application-note application (hash-ref bindings `note)))

    (flash 'success (format  "Updating APPLICATION #~s" (application-id application)) )
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
              (flash 'success (format  "Added new APPLICATION TOOL #~s to APPLICATION #~s" tool-id-field-value (application-id application)) )
              (insert-one! conn a))
            )
          ; else, record should already exist
          (get-application-tool-by-id tm atid)))

          ; change other fields
          (set! application-tool (set-application_tool-toolid application-tool (string->number v)))
          (displayln application-tool)
          ; submit update to the database
          (flash 'success (format  "Updated APPLICATION TOOL #~s"  (application_tool-id application-tool )))
          (update-one! conn application-tool #:force? #t))))

    ; Remove marked tool entries
    ; Update application tool entries from form fields
    (dict-for-each bindings

     ; The form fields are passed here as key/value pairs
     (lambda (k v)

      ; Use regex to extract application_tools.id from the id of hidden fields 
      (define bindingid_match (regexp-match #rx"tool-remove-id\\[(-?[0-9]+)\\]$" (symbol->string k)))
      ;(printf "REMOVE-ID: ~a = ~s\n" k v)
      ; Only process matching keys
      (when (and bindingid_match (string=? v "on"))
        ;(printf "REMOVE-ID: ~a = ~s\n" k v)
        ;(printf "removing ~a from ~a ~a\n" bindingid_match mid v)
        (define atid (string->number (cadr bindingid_match)))
        (define application-tool (get-application-tool-by-id tm atid))
        (flash 'success (format  "Removing TOOL #~s from APPLICATION #~s" atid (application-id application)) )
        (delete-one! conn application-tool))))

    ; Update application tool entries from form fields
    (dict-for-each bindings

     ; The form fields are passed here as key/value pairs
     (lambda (k v)

      ; Use regex to extract application_tools.id from the id of hidden fields 
      (define bindingid_match (regexp-match #rx"material-hidden-id\\[(-?[0-9]+)\\]$" (symbol->string k)))
      (define material-id-field-value (string->number v))

      ; Only process matching keys AND those entries where hidden input was set
      (when (and bindingid_match (> material-id-field-value 0))
        ;(printf "~a = ~s\n" k v)
        ; Parse application_material.id
        (define atid (string->number (cadr bindingid_match)))
        (define application-material 
          ; -1 means the material entry needs to be created
          (if (= atid -1)
          (begin
            (let ([a (make-application_material 
              ; assign application id to application id that may have been created above
              #:applicationid (application-id application)
              ; assign toolid from hidden field
              #:materialid material-id-field-value)])
              ; insert new record and assign to application-material
              (flash 'success (format  "Added new APPLICATION MATERIAL #~s to APPLICATION #~s" material-id-field-value (application-id application)) )
              (insert-one! conn a))
            )
          ; else, record should already exist
          (get-application-material-by-id tm atid)))

          ; change other fields
          (set! application-material (set-application_material-materialid application-material (string->number v)))
          (displayln application-material)
          ; submit update to the database
          (flash 'success (format  "Updated APPLICATION MATERIAL #~s" (application_material-id application-material  )))
          (update-one! conn application-material #:force? #t))))

    ; Remove marked material entries
    ; Update application tool entries from form fields
    (dict-for-each bindings

     ; The form fields are passed here as key/value pairs
     (lambda (k v)

      ; Use regex to extract application_tools.id from the id of hidden fields 
      (define bindingid_match (regexp-match #rx"material-remove-id\\[(-?[0-9]+)\\]$" (symbol->string k)))
      ;(printf "REMOVE-ID: ~a = ~s\n" k v)
      ; Only process matching keys
      (when (and bindingid_match (string=? v "on"))
        ;(printf "REMOVE-ID: ~a = ~s\n" k v)
        ;(printf "removing ~a from ~a ~a\n" bindingid_match mid v)
        (define atid (string->number (cadr bindingid_match)))
        (define application-tool (get-application-material-by-id tm atid))
        (flash 'success (format  "Removing MATERIAL #~s from APPLICATION #~s" atid (application-id application)) )
        (delete-one! conn application-tool))))

    (flash 'success "Changes saved")

    ; go back to application info screen
    (redirect-to (reverse-uri 'application-info (application-id application)))))
  

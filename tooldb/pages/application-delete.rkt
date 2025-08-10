#lang racket/base

(require koyo/haml
         koyo/url
         koyo/database
         racket/contract/base
         web-server/http
         deta
         db
         "../components/template.rkt"
         "../components/tool.rkt")

(provide
 (contract-out
  [application-delete-action (-> tool-manager? (-> request? integer? response?))])
 (contract-out
  [application-delete-confirmation (-> tool-manager? (-> request? integer? response?))]))

(define ((application-delete-action tm) _req aid)
  (define a (get-application-by-id tm aid))
  (with-database-connection [conn (tool-manager-db tm)]
    (delete-one! conn a))
  (redirect-to (reverse-uri `tools-page)))

(define ((application-delete-confirmation tm) _req aid)
  (define a (get-application-by-id tm aid))
  (page
   (haml
    (.container
      (:h1 "Remove Application?")
      "This will NOT affect materials and tools referenced in the application."
      (:form ([:action (reverse-uri 'application-info aid)] [:method "GET"] [:id "application-delete-cancel"]))
      (:form ([:action (reverse-uri 'application-delete-action aid)] [:method "POST"] [:id "application-delete"]))
      (:div ([:class "buttons"])
        (:button [(:class "") (:form "application-delete-cancel")] "Cancel") (:button [(:class "") (:form "application-delete")] "Delete"))
      ))))
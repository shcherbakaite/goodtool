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
  [material-delete-action (-> tool-manager? (-> request? integer? response?))])
 (contract-out
  [material-delete-confirmation (-> tool-manager? (-> request? integer? response?))]))

(define ((material-delete-action tm) _req mid)
  (define m (get-material-by-id tm mid))
  (with-database-connection [conn (tool-manager-db tm)]
    (delete-one! conn m))
  (redirect-to (reverse-uri `materials-page)))

(define ((material-delete-confirmation tm) _req mid)
  (define m (get-material-by-id tm mid))

  (page
   (haml
    (.container
      (:h1 "Remove Material?")
      "The material will also be deleted from all applications where it was used."
      (:form ([:action (reverse-uri 'material-info-page mid)] [:method "GET"] [:id "material-delete-cancel"]))
      (:form ([:action (reverse-uri 'material-delete-action mid)] [:method "POST"] [:id "material-delete"]))
      (:div ([:class "buttons"])
        (:button [(:class "") (:form "material-delete-cancel")] "Cancel") (:button [(:class "") (:form "material-delete")] "Delete"))
      ))))
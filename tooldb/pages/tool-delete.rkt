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
  [tool-delete-action (-> tool-manager? (-> request? integer? response?))])
 (contract-out
  [tool-delete-confirmation (-> tool-manager? (-> request? integer? response?))]))

(define ((tool-delete-action tm) _req tid)
  (define t (get-tool-by-id tm tid))
  (with-database-connection [conn (tool-manager-db tm)]
    (delete-one! conn t))
  (redirect-to (reverse-uri `tools-page)))

(define ((tool-delete-confirmation tm) _req tid)
  (define t (get-tool-by-id tm tid))

  (page
   (haml
    (.container
      (:h1 "Remove Tool?")
      "The tool will also be deleted from all applications where it was used."
      (:form ([:action (reverse-uri 'tool-info-page tid)] [:method "GET"] [:id "tool-delete-cancel"]))
      (:form ([:action (reverse-uri 'tool-delete-action tid)] [:method "POST"] [:id "tool-delete"])


        )
      (:div ([:class "buttons"])
        (:button [(:class "") (:form "tool-delete-cancel")] "Cancel") (:button [(:class "") (:form "tool-delete")] "Delete"))

      ))))


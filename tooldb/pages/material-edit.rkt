#lang racket/base

(require koyo/haml
         koyo/url
         deta
         racket/dict
         koyo/database
         racket/contract/base
         web-server/http
         web-server/http/bindings
         "../components/template.rkt"
         "../components/tool.rkt")

(provide
 (contract-out
  [material-edit (-> tool-manager? (-> request? integer? response?))]))

; (define ((dashboard-page tm) _req))
;   (page
;    (haml
;     (.container
;      (:h1 "Hello World!")))))


(define ((material-edit tm) _req mid)
  (define bindings (make-hash (request-bindings _req)))
  (define m (get-material-by-id tm mid) )

  ;(set-tool-partno t (hash-ref bindings `partno))
  ;(set-tool-description t (hash-ref bindings `description))
  (with-database-connection [conn (tool-manager-db tm)]
    
    (update-one! conn (set-material-partno m (hash-ref bindings `partno)))
    (update-one! conn (set-material-description m (hash-ref bindings `description)))
    (update-one! conn (set-material-manufactorer m (hash-ref bindings `manufactorer)))
    (update-one! conn (set-material-mpn m (hash-ref bindings `mpn)))
    )
  
    (redirect-to (reverse-uri 'material-info-page mid)))
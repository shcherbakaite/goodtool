#lang racket/base

(require koyo/haml
         racket/contract/base
         web-server/http
         "../components/template.rkt"
         "../components/tool.rkt")

(provide
 (contract-out
  [dashboard-page (-> tool-manager? (-> request? response?))]))

; (define ((dashboard-page tm) _req))
;   (page
;    (haml
;     (.container
;      (:h1 "Hello World!")))))


(define ((dashboard-page tools) _req)
  (page
   (haml
    (.container
      


      ) )))
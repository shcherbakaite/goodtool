#lang racket/base

(require koyo/haml
         racket/contract/base
         web-server/http
         koyo/url
         "../components/template.rkt"
         "../components/tool.rkt")

(provide
 (contract-out
  [materials-page (-> tool-manager? (-> request? response?))]))

; (define ((dashboard-page tm) _req))
;   (page
;    (haml
;     (.container
;      (:h1 "Hello World!")))))


(define ((materials-page tools) _req)
  (page
   (haml
    (.container
     (:h1 "Materials")
     
     ,@(for/list ([m (materials-list-all tools)])
        (haml
          (:div
            (:a [(:href (reverse-uri 'material-info-page (material-id m)))] (material-partno m) " - " (material-description m) )
          )
        )
      ; (format "~s ::::::  " (tool-partno t))
      )
     ))))
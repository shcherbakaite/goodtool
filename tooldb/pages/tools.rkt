#lang racket/base

(require koyo/haml
         racket/contract/base
         web-server/http
         koyo/url
         "../components/template.rkt"
         "../components/tool.rkt")

(provide
 (contract-out
  [tools-page (-> tool-manager? (-> request? response?))]))

; (define ((dashboard-page tm) _req))
;   (page
;    (haml
;     (.container
;      (:h1 "Hello World!")))))


(define ((tools-page tools) _req)
  (page
   (haml
    (.container
     (:h1 "Tools")
     
     ,@(for/list ([t (tools-list-all tools)])
        (haml
          (:div [(:class "tool-entry")]
            (:img [(:class "thumb-image") (:src (reverse-uri 'tool-img (tool-id t)))] )
            (:a [(:href (reverse-uri 'tool-info-page (tool-id t)))] (tool-partno t) " - " (tool-description t) )
          )

        )
      ; (format "~s ::::::  " (tool-partno t))
 
      )


      (:a [(:href (reverse-uri 'tool-info-page -1  ))] "Add Tool" )

     ))))
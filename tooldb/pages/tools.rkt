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
     
     (:input ([:class "search-field"] [:name "search-field"] [:search-url "/tools-search"] [:search-results-id "tool-search-results-id"] ))

     (:div ([:id "tool-search-results-id"])

       ,@(for/list ([t (tools-list-all tools)])
          (haml
            (:div [(:class "tool-entry")]
              (:img [(:class "thumb-image") (:src (reverse-uri 'tool-img (tool-id t)))] )
              (:a [(:href (reverse-uri 'tool-info-page (tool-id t)))] (tool->string t) )
            )

          )
        ; (format "~s ::::::  " (tool-partno t))
   
        )

     )))))
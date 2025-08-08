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
     
     (:input ([:class "search-field"] [:name "search-field"] [:search-url "/materials-search"] [:search-results-id "material-search-results-id"] ))
     
     (:div ([:id "material-search-results-id"])

       ,@(for/list ([m (materials-list-all tools)])
          (haml
            (:div [(:class "tool-entry")]
              (:img [(:class "thumb-image") (:src (reverse-uri 'material-img (material-id m)))] )
              (:a [(:href (reverse-uri 'material-info-page (material-id m)))] (material->string m) )
            )
          )
        ; (format "~s ::::::  " (tool-partno t))
   
        )

      ; (format "~s ::::::  " (tool-partno t))
      )
     ))))




; (define ((tools-page tools) _req)
;   (page
;    (haml
;     (.container
;      (:h1 "Tools")
     

;      (:div ([:id "tool-search-results-id"])

;        ,@(for/list ([t (tools-list-all tools)])
;           (haml
;             (:div [(:class "tool-entry")]
;               (:img [(:class "thumb-image") (:src (reverse-uri 'tool-img (tool-id t)))] )
;               (:a [(:href (reverse-uri 'tool-info-page (tool-id t)))] (tool->string t) )
;             )

;           )
;         ; (format "~s ::::::  " (tool-partno t))
   
;         )

;      )))))
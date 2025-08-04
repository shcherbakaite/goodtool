#lang racket/base

(require koyo/haml
         koyo/url
         racket/contract/base
         web-server/http
         "../components/template.rkt"
         "../components/tool.rkt")

(provide
 (contract-out
  [material-info-page (-> tool-manager? (-> request? integer? response?))]))

; (define ((dashboard-page tm) _req))
;   (page
;    (haml
;     (.container
;      (:h1 "Hello World!")))))


(define ((material-info-page tm) _req mid)
  (define m (get-material-by-id tm mid) )
  (page
   (haml
    (.container
     (:h1 "Material Info")
      (:form ([:action (reverse-uri 'material-edit mid)] [:method "POST"])
        (:label "Part Number")
        (:input [(:type "text") (:name "partno") (:value (material-partno m))])
        (:label "Description")
        (:input [(:type "text") (:name "description") (:value (material-description m))])
        (:label "Manufactorer")
        (:input [(:type "text") (:name "manufactorer") (:value (material-manufactorer m))])
        (:label "MPN")
        (:input [(:type "text") (:name "MPN") (:value (material-mpn m))])
        (:button [(:class "")] "Save")
        )
     ; ,@(for/list ([t (tools-list-all tools)])
     ;    (haml
     ;      (:div
     ;        (:a [(:href (reverse-uri 'tool-info (tool-id t)))] (tool-partno t) " - " (tool-description t) )
     ;      )

     ;    )
      ; (format "~s ::::::  " (tool-partno t))

        (:h2 "Applications")


        ; ;(format "~s ::::::  " (get-tool-applications tm tid))
          

        ,@(for/list ([a (get-material-applications tm mid)])
          (haml
            (:div
              (:a [(:href (reverse-uri 'application-info (application-id a)) )] (application-description a) )
            )
          )
        )
 
      ))))
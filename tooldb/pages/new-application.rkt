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
  [application-info (-> tool-manager? (-> request? integer? response?))]))

; (define ((dashboard-page tm) _req))
;   (page
;    (haml
;     (.container
;      (:h1 "Hello World!")))))


(define ((application-info tm) _req aid)
  (define a (get-application-by-id tm aid))
  (page
   (haml
    (.container
     (:h1 "Application Info")
      (:form ([:action (reverse-uri 'tool-edit aid)] [:method "POST"])
        (:label "Description")
        (:input [(:type "text") (:name "description") (:value (application-description a))])
        ; (:label "Description")
        ; (:input [(:type "text") (:name "description") (:value (tool-description t))])
        ; (:label "Manufactorer")
        ; (:input [(:type "text") (:name "manufactorer") (:value (tool-manufactorer t))])
        ; (:label "MPN")
        ; (:input [(:type "text") (:name "MPN") (:value (tool-mpn t))])
        ; (:button [(:class "")] "Save")
        )

     ; ,@(for/list ([t (tools-list-all tools)])
     ;    (haml
     ;      (:div
     ;        (:a [(:href (reverse-uri 'tool-info (tool-id t)))] (tool-partno t) " - " (tool-description t) )
     ;      )

     ;    )
      ; (format "~s ::::::  " (tool-partno t))

        (:h2 "Tools")


        ;(format "~s ::::::  " (get-application-tools tm aid))
          

        ,@(for/list ([t (get-application-tools tm aid)])
          (haml
            (:div
              (:a [(:href (reverse-uri 'tool-info-page (tool-id t))) ] (tool-partno t) " - " (tool-description t) )
            )
          )
        )

        (:h2 "Materials")

        ,@(for/list ([m (get-application-materials tm aid)])
          (haml
            (:div
              (:a [(:href (reverse-uri 'material-info-page (material-id m)))] (material-partno m) " - " (material-description m) )
            )
          )
        )
 
      ))))
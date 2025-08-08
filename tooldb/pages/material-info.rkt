#lang racket/base

(require koyo/haml
         koyo/url
         racket/contract/base
         web-server/http
         db
         "../components/template.rkt"
         "../components/tool.rkt")

(provide
 (contract-out
  [material-img (-> tool-manager? (-> request? integer? response?))])
 (contract-out
  [material-info-page (-> tool-manager? (-> request? integer? response?))]) )

; (define ((dashboard-page tm) _req))
;   (page
;    (haml
;     (.container
;      (:h1 "Hello World!")))))


; Serve tool image r redirect to default image
(define ((material-img tm) _req mid)
  (let ([m (get-material-by-id tm mid)])
    (if (and m (sql-null->false (material-image m)))
      (begin 
        (response/output
         #:code 200
         #:mime-type #"image/jpeg;"
         (lambda (out) (write-bytes (material-image m) out))))
      (redirect-to (static-uri "img/material-default.jpg")))))

(define ((material-info-page tm) _req mid)
  (define m (get-material-by-id tm mid) )
  (page
   (haml
    (.container
     (:h1 "Material Info")
      (:form ([:action (reverse-uri 'material-edit mid)] [:enctype "multipart/form-data"] [:method "POST"])

        (:div ([:class "form-group"])
          (:img [(:class "title-image") (:src (reverse-uri 'material-img mid))] ) 

          (:label [(:type "myfile")] "Replace image")
          (:input [(:type "file") (:id "myfile") (:name "myfile") (:accept "image/png, image/jpeg")])

          )

        (:div ([:class "form-group"])
          (:label "Part Number")
          (:input [(:type "text") (:name "partno") (:value (material-partno m))]))

        (:div ([:class "form-group"])
          (:label "Description")
          (:input [(:type "text") (:name "description") (:value (material-description m))]))
        
        (:div ([:class "form-group"])
          (:label "Manufactorer")
          (:input [(:type "text") (:name "manufactorer") (:value (material-manufactorer m))]))
        
        (:div ([:class "form-group"])
          (:label "MPN")
          (:input [(:type "text") (:name "MPN") (:value (material-mpn m))]))

        (:div ([:class "buttons"])
          (:button [(:class "")] "Save"))
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
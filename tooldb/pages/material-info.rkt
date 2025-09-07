#lang racket/base

(require 
  racket/contract/base
  racket/list
  koyo/haml
  koyo/url
  web-server/http
  db
  (prefix-in list: racket/list)
  "../misc.rkt"
  "../images.rkt"
  "../components/template.rkt"
  "../components/tool.rkt")

(provide
 (contract-out
  [material-img (-> tool-manager? (-> request? integer? response?))])
 (contract-out
  [material-img-thumb (-> tool-manager? (-> request? integer? response?))])
 (contract-out
  [material-info-page (-> tool-manager? (-> request? integer? response?))]) )

; Serve tool image r redirect to default image
(define ((material-img tm) _req mid)
  (let ([m (get-material-by-id tm mid)])
    (if (and m (sql-null->false (material-image m)))
      (jpeg-response (image-scale-to-width (material-image m) 400 ))
      (redirect-to (static-uri "img/tool-default.jpg")))))

; Serve tool image r redirect to default image
(define ((material-img-thumb tm) _req mid)
  (let ([m (get-material-by-id tm mid)])
    (if (and m (sql-null->false (material-image m)))
      (jpeg-response (image-scale-to-width (material-image m) 150 ))
      (redirect-to (static-uri "img/tool-default.jpg")))))


(define ((material-info-page tm) _req mid)
  (define m 
  (if (= mid -1)
    (make-material #:partno (format "~a" (random 9999999)) #:description "A NEW MATERIAL" #:mpn "" #:manufactorer "" )
    (get-material-by-id tm mid)))
  (page
   (haml
    (.container
     (:h1 "Material Info")
      (:form ([:id "material-form"] [:action (reverse-uri 'material-edit mid)] [:enctype "multipart/form-data"] [:method "POST"])

        (:div ([:class "form-group"])
          (:img [(:class "title-image") (:src (reverse-uri 'material-img mid))] ) 

          (:label [(:for "image")] "Replace image")
          (:input [(:type "file") (:id "image") (:name "image") (:accept "image/png, image/jpeg")])
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
        )

        (:h2 "Applications")

        (haml
         (let ([applications (get-material-applications tm mid)])
           (if (list:empty? applications)
               (haml (:div "No applications found"))
               (haml
                (:div
                 ,@(for/list ([a applications])
                  (haml
                    (:div [(:class "tool-entry")]
                      (:img [(:class "thumb-image") (:src (reverse-uri 'application-img-first-tool (application-id a)))] )
                      (:a [(:target "_blank") (:href (reverse-uri 'application-info (application-id a)) )] (application->string a) )
                    )
                  )
                ))))))

        (:a ([:class "action-link"]  [:target "_blank"] [:href (reverse-uri 'application-info -1 #:query (list (cons `materialid (format "~s" mid))) )] ) "Add Application" )

        (:form ([:id "delete-material-form"] [:action (reverse-uri 'material-delete-confirmation mid)] [:method "GET"]))

        (:div ([:class "buttons"])
          (:button [(:class "") (:form "delete-material-form")] "Delete") (:button [(:class "") (:form "material-form")] "Save"))))))
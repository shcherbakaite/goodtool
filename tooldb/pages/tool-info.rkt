#lang racket/base

(require 
  racket/contract/base
  koyo/haml
  koyo/url
  koyo/database
  web-server/http
  deta
  db
  (prefix-in list: racket/list)
  "../components/template.rkt"
  "../components/tool.rkt")

(provide
 (contract-out
  [tool-info-page (-> tool-manager? (-> request? integer? response?))])
 (contract-out
  [tool-img (-> tool-manager? (-> request? integer? response?))]))

(define (jpeg-response image-bytes)
  (response/output
   #:code 200
   #:mime-type #"image/jpeg;"
   (lambda (out) (write-bytes image-bytes out))))

; Serve tool image r redirect to default image
(define ((tool-img tm) _req tid)
  (let ([t (get-tool-by-id tm tid)])
    (if (and t (sql-null->false (tool-image t)))
      (jpeg-response (tool-image t))
      (redirect-to (static-uri "img/tool-default.jpg")))))

(define ((tool-info-page tm) _req tid)

  (define t 
  (if (= tid -1)
    (make-tool #:partno (format "~a" (random 9999999)) #:description "A NEW TOOL" #:mpn "" #:manufactorer "" )
    (get-tool-by-id tm tid)))

  (page
   (haml
    (.container
     (:h1 "Tool Info")
      (:form ([:action (reverse-uri 'tool-edit tid)] [:method "POST"] [:enctype "multipart/form-data"] [:id "tool-form"])
      
        (:div ([:class "form-group"])
          (:img [(:class "title-image") (:src (reverse-uri 'tool-img tid))] ) 

          (:label [(:for "image")] "Replace image")
          (:input [(:type "file") (:id "image") (:name "image") (:accept "image/png, image/jpeg")])

          )
        
        (:div ([:class "form-group"])  
          (:label "Part Number")
          (:input [(:type "text") (:name "partno") (:value (tool-partno t))]))
        
        (:div ([:class "form-group"])
          (:label "Description")
          (:input [(:type "text") (:name "description") (:value (tool-description t))]))
        
        (:div ([:class "form-group"])
          (:label "Manufactorer")
          (:input [(:type "text") (:name "manufactorer") (:value (tool-manufactorer t))]))
          
        (:div ([:class "form-group"])
          (:label "MPN")
          (:input [(:type "text") (:name "MPN") (:value (tool-mpn t))]))
      
        (:h2 "Applications")

        (haml
         (let ([applications (get-tool-applications tm tid)])
           (if (list:empty? applications)
               (haml (:div "No applications found"))
               (haml
                (:div
                 ,@(for/list ([a applications])
                  (haml
                    (:div [(:class "tool-entry")]
                      (:img [(:class "thumb-image") (:src (reverse-uri 'application-img-first-material (application-id a)))] )
                      (:a [(:target "_blank") (:href (reverse-uri 'application-info (application-id a)) )] (application->string a) )
                    )
                  )
                ))))))

        (:a ([:class "action-link"] [:target "_blank"] [:href (reverse-uri 'application-info -1 #:query (list (cons `toolid (format "~s" tid))) )] ) "Add Application" )
      )

      (:form ([:id "delete-tool-form"] [:action (reverse-uri 'tool-delete-confirmation tid)] [:method "GET"]))

      (:div ([:class "buttons"])
        (:button [(:class "") (:form "delete-tool-form")] "Delete") (:button [(:class "") (:form "tool-form")] "Save" ))))))

#lang racket/base

(require koyo/haml
         koyo/url
         racket/contract/base
         web-server/http
         "../components/template.rkt"
         "../components/tool.rkt")

(provide
 (contract-out
  [tool-info-page (-> tool-manager? (-> request? integer? response?))])
 (contract-out
  [tool-img (-> tool-manager? (-> request? integer? response?))]))

; (define ((dashboard-page tm) _req))
;   (page
;    (haml
;     (.container
;      (:h1 "Hello World!")))))


; Serve tool image
(define ((tool-img tm) _req tid)
  (define t (get-tool-by-id tm tid))
  (define data (tool-image t)) 
  (response/output
   #:code 200
   #:mime-type #"image/jpeg;"
   (lambda (out) (write-bytes data out))))


(define ((tool-info-page tm) _req tid)

  (define t 
  (if (= tid -1)
    (make-tool #:partno "PARTNO" #:description "DESCRIPTION" #:mpn "MPN" #:manufactorer "MANUFACTORER" #:image "test" )
    (get-tool-by-id tm tid)))

  (page
   (haml
    (.container
     (:h1 "Tool Info")
      (:form ([:action (reverse-uri 'tool-edit tid)] [:method "POST"] [:enctype "multipart/form-data"])
      
      (:img [(:class "title-image") (:src (reverse-uri 'tool-img tid))] ) 

      (:label [(:type "myfile")] "Replace image")
      (:input [(:type "file") (:id "myfile") (:name "myfile") (:accept "image/png, image/jpeg")]) 
      
      (:label "Part Number")
      (:input [(:type "text") (:name "partno") (:value (tool-partno t))])
      
      (:label "Description")
      (:input [(:type "text") (:name "description") (:value (tool-description t))])
      
      (:label "Manufactorer")
      (:input [(:type "text") (:name "manufactorer") (:value (tool-manufactorer t))])
      
      (:label "MPN")
      (:input [(:type "text") (:name "MPN") (:value (tool-mpn t))])
      
      (:button [(:class "")] "Save"))

     ; ,@(for/list ([t (tools-list-all tools)])
     ;    (haml
     ;      (:div
     ;        (:a [(:href (reverse-uri 'tool-info (tool-id t)))] (tool-partno t) " - " (tool-description t) )
     ;      )

     ;    )
      ; (format "~s ::::::  " (tool-partno t))

        (:h2 "Applications")


        ;(format "~s ::::::  " (get-tool-applications tm tid))
          

        ,@(for/list ([a (get-tool-applications tm tid)])
          (haml
            (:div
              (:a [(:href (reverse-uri 'application-info (application-id a)) )] (format "#~a - ~a" (application-id a) (application-description a)) )
            )
          )
        )

        (:a [(:href (reverse-uri 'application-info -1 #:query (list (cons `toolid (format "~s" tid))) ))] "Add Application" )
 
      ))))
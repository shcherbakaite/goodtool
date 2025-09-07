#lang racket/base

(require 
  racket/contract/base
  threading
  koyo/url
  koyo/haml
  koyo/database
  web-server/http/bindings
  web-server/http
  deta
  db
  (prefix-in list: racket/list)
  "../images.rkt"
  "../components/template.rkt"
  "../components/tool.rkt"
  "../misc.rkt")

(provide
  (contract-out
  [application-img-first-material (-> tool-manager? (-> request? integer? response?))])
  (contract-out
  [application-img-first-tool (-> tool-manager? (-> request? integer? response?))])
 (contract-out
  [application-info (-> tool-manager? (-> request? integer? response?))]))

(define (stub-autocomlete-entry form-prefix autocomplete-url placeholder-text image-url initial-description initial-id )
  (let* 
    [(hidden-field-name (format "~a-hidden-id[~s]" form-prefix -1))
     (search-field-name (format "~a-id[~s]" form-prefix -1))
     (item-img-id (format "~a-img-id[~s]" form-prefix -1))]
      (haml
        (:div [(:class "autocomplete-container")]
          (:img [(:id item-img-id) (:class "thumb-image stub") (:src image-url)] ) 
          (:input [(:id hidden-field-name ) (:type "hidden") (:name hidden-field-name) (:value (number->string initial-id) ) ])
          (:div ([:class "autocomplete-dropdown-container"])
            (:input [
              (:type "text") 
              (:placeholder placeholder-text) 
              (:autocomplete "off") 
              (:class "autocomplete") 
              (:name search-field-name) 
              (:autocomplete-hidden-field-id hidden-field-name) 
              (:autocomplete-url autocomplete-url ) 
              (:value initial-description )
              (:previous-value initial-description )]))))))

(define ((application-img-first-material tm) _req aid)
  (define a (get-application-by-id tm aid))
  (define tools (get-application-tools tm aid))
  (define materials (get-application-materials tm aid)) 
  
  (define images
    (filter-false
      (list 
        (~>
          materials
          safe-car
          ((lambda (m) (and m (material-image m))))
          sql-null->false
          ((lambda (img) (and img (image-scale-to-width img 150 ))))
          sql-null->false) 
        (~>
          tools
          safe-car
          ((lambda (m) (and m (tool-image m))))
          sql-null->false
          ((lambda (img) (and img (image-scale-to-width img 150 ))))
          ) 
        ))
    )
    (if (list:empty? images)
      (redirect-to (static-uri "img/material-default.jpg"))
      (jpeg-response (car images))))

(define ((application-img-first-tool tm) _req aid)
  (define a (get-application-by-id tm aid))
  (define tools (get-application-tools tm aid))
  (define materials (get-application-materials tm aid)) 
  
  (define images
    (filter-false
      (list 
        (~>
          tools
          safe-car
          ((lambda (t) (and t (tool-image t))))
          sql-null->false
          ((lambda (img) (and img (image-scale-to-width img 150 ))))) 
        (~>
          materials
          safe-car
          ((lambda (t) (and t (material-image t))))
          sql-null->false
          ((lambda (img) (and img (image-scale-to-width img 150 ))))
          ) 
        ))
    )
    (if (list:empty? images)
      (redirect-to (static-uri "img/tool-default.jpg"))
      (jpeg-response (car images))))

(define ((application-info tm) _req aid)
  (define bindings (make-hash (request-bindings _req)))
  (define a 
    (if (= aid -1)
      (make-application #:description "NEW APPLICATION" #:note "")
      (get-application-by-id tm aid)))
  (page
   (haml
    (.container

     (:h1 "Application Info")

      (:form ([:action (reverse-uri 'application-edit aid)] [:method "POST"] [:id "application-form"])
        
        (:div ([:class "form-group"])  
          (:label "Description")
          (:input [(:type "text") (:name "description") (:value (application-description a))]))

        (:div ([:class "form-group"])  
          (:label "Note")
          (:textarea [(:name "note") ] (application-note a)))

        (:h2 "Tools")
        ,@(for/list ([t (rows-result->alist (query-application-tools tm aid))] [i (in-naturals 1)])
          (printf "ENTRY: ~s\n" t)
          (displayln "TEST")
          (define hidden-field-name (format "tool-hidden-id[~s]" (assoc-ref "toolentryid" t)))
          (define search-field-name (format "tool-id[~s]"  (assoc-ref "toolentryid" t)))
          (define image-name (format "img-id[~s]"  (assoc-ref "toolentryid" t)))
          (define remove-checkbox-name (format "tool-remove-id[~s]"  (assoc-ref "toolentryid" t)))
          (define original-value (string-append (assoc-ref "partno" t) " - " (assoc-ref "description" t)))

          (haml
            (:div [(:class "autocomplete-container")]
              (:img [(:id image-name) (:class "thumb-image") (:src (reverse-uri 'tool-img (assoc-ref "id" t)))]) 
              (:input [(:id hidden-field-name ) (:type "hidden") (:name hidden-field-name) (:value (number->string (assoc-ref "id" t))) ])
              
              (:div ([:class "autocomplete-dropdown-container"])
                (:input [(:type "text") 
                  (:autocomplete "off") 
                  (:class "autocomplete") 
                  (:name search-field-name) 
                  (:autocomplete-hidden-field-id hidden-field-name) 
                  (:autocomplete-url "/tool-autocomplete") 
                  (:value original-value ) 
                  (:previous-value original-value ) ])
              )
              (:a [(:target "_blank") (:href (reverse-uri 'tool-info-page (assoc-ref "id" t)))] "View")
                (:input [(:type "checkbox")  (:id remove-checkbox-name) (:name remove-checkbox-name)] )
                (:label [(:for remove-checkbox-name)] "Remove"))))

        (let* [
          (initial-tool-id (string->number (hash-ref bindings `toolid "0")))
          (t (get-tool-by-id tm initial-tool-id))
          (initial-tool-desc (or (tool->string t) ""))]
            (stub-autocomlete-entry 
              "tool" ; form prefix
               "/tool-autocomplete"
               "New tool entry"
               (static-uri "img/tool-default.jpg")
               initial-tool-desc 
               initial-tool-id ))

        (:h2 "Materials")
        ,@(for/list ([m (rows-result->alist (query-application-materials tm aid))])
          (displayln a)
          (define hidden-field-name (format "material-hidden-id[~s]" (assoc-ref "materialentryid" m)))
          (define search-field-name (format "material-id[~s]"  (assoc-ref "materialentryid" m)))
          (define image-name (format "img-id[~s]"  (assoc-ref "materialentryid" m)))
          (define remove-checkbox-name (format "material-remove-id[~s]"  (assoc-ref "materialentryid" m)))
          (define original-value (string-append (assoc-ref "partno" m) " - " (assoc-ref "description" m)))

          (haml
            (:div [(:class "autocomplete-container")]
              (:img [(:id image-name) (:class "thumb-image") (:src (reverse-uri 'material-img (assoc-ref "id" m)))]) 
              (:input [(:id hidden-field-name ) (:type "hidden") (:name hidden-field-name) (:value (number->string (assoc-ref "id" m))) ])
              
              (:div ([:class "autocomplete-dropdown-container"])
                (:input [(:type "text") 
                  (:autocomplete "off") 
                  (:class "autocomplete") 
                  (:name search-field-name) 
                  (:autocomplete-hidden-field-id hidden-field-name) 
                  (:autocomplete-url "/tool-autocomplete") 
                  (:value original-value ) 
                  (:previous-value original-value ) ])
              )

              (:a [(:target "_blank") (:href (reverse-uri 'material-info-page (assoc-ref "id" m)))] "View")
                (:input [(:type "checkbox")  (:id remove-checkbox-name) (:name remove-checkbox-name)] )
                (:label [(:for remove-checkbox-name)] "Remove"))))

        (let* [
          (initial-material-id (string->number (hash-ref bindings `materialid "0")))
          (m (get-material-by-id tm initial-material-id))
          (initial-material-desc (or (material->string m) ""))]
            (stub-autocomlete-entry 
              "material" ; form prefix
               "/material-autocomplete"
               "New material entry"
               (static-uri "img/material-default.jpg")
               initial-material-desc 
               initial-material-id )))

        (:form ([:id "delete-application-form"] [:action (reverse-uri 'application-delete-confirmation aid)] [:method "GET"]))
        (:div ([:class "buttons"])
          (:button [(:class "") (:form "delete-application-form")] "Delete") (:button [(:class "") (:form "application-form")] "Save"))))))
#lang racket/base

(require koyo/haml
         koyo/url
         deta
         db
         racket/dict
         racket/match
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


(define (assoc-ref k lst)
  (cdr (assoc k lst)))

(define (rows-result->alist rs)
  (match rs
    [(rows-result columns rows)
     (define keys (map (λ (col) (cdr (assoc 'name col))) columns))
     (map (λ (row)
            (for/list ([k keys] [v (vector->list row)])
              (cons k v)))
          rows)]))


(define ((application-info tm) _req aid)
  (define bindings (make-hash (request-bindings _req)))

  (define a 
    (if (= aid -1)
      (make-application #:description "ddd" #:note "ddd")
      (get-application-by-id tm aid)))

  ;(printf "~a\n" (rows-result->alist (query-application-tools tm aid)))
  (printf "~a\n" a)
  (page
   (haml
    (.container

     (:h1 "Application Info")

      (:form ([:action (reverse-uri 'application-edit aid)] [:method "POST"])
        
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
          (define remove-checkbox-name (format "remove-id[~s]"  (assoc-ref "toolentryid" t)))
          (define original-value (string-append (assoc-ref "partno" t) " - " (assoc-ref "description" t)))

          (haml
            (:div [(:class "autocomplete-container")]
              ; (:div (format "~s" i))
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

              ;(:div [(:class "checkbox-group")]
                (:input [(:type "checkbox")  (:id remove-checkbox-name) (:name remove-checkbox-name)] )
                (:label [(:for remove-checkbox-name)] "Remove");)
            )
          )
          )
        (let* 
          [(hidden-field-name (format "tool-hidden-id[~s]" -1))
          (search-field-name (format "tool-id[~s]" -1))
          ; toolid GET parameter indicates that initial tool needs to be filled out
          (for-tool-id (string->number (hash-ref bindings `toolid "0")))
          (t (get-tool-by-id tm for-tool-id))
          (for-tool-desc (or (tool->string t) ""))]
            (haml
              (:div [(:class "autocomplete-container")]
                (:img [(:id "new-tool-img") (:class "thumb-image") (:src (static-uri "img/tool-default.jpg"))] ) 
                (:input [(:id hidden-field-name ) (:type "hidden") (:name hidden-field-name) (:value (number->string for-tool-id) ) ])
                (:div ([:class "autocomplete-dropdown-container"])
                  (:input [
                    (:type "text") 
                    (:placeholder "New tool entry") 
                    (:autocomplete "off") 
                    (:class "autocomplete") 
                    (:name search-field-name) 
                    (:autocomplete-hidden-field-id hidden-field-name) 
                    (:autocomplete-url "/tool-autocomplete") 
                    (:value for-tool-desc )
                    (:previous-value for-tool-desc )])
                )
              )
            ))

        (:div ([:class "buttons"])
          (:button [(:class "")] "Save"))

        )


        (:h2 "Materials")

        ,@(for/list ([m (get-application-materials tm aid)])
          (haml
            (:div
              (:a [(:href (reverse-uri 'material-info-page (material-id m)))] (material-partno m) " - " (material-description m) )
            )
          )
        )

        

      (:input ((:id "autocompleteInput")
          (:type "text")
          (:class "form-control")
          (:autocomplete "off")))

          (:ul ((:id "autocompleteMenu")
               (:class "list-group position-absolute w-100")
               (:style "z-index: 1000; display: none;"))
            (:li ((:class "list-group-item list-group-item-action")) "Suggestion 1")
            (:li ((:class "list-group-item list-group-item-action")) "Suggestion 2")
            (:li ((:class "list-group-item list-group-item-action")) "Suggestion 3"))

 
      ))))
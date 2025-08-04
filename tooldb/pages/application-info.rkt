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
  (define a 
    (if (= aid -1)
      (make-application #:description "")
      (get-application-by-id tm aid)))

  ;(printf "~a\n" (rows-result->alist (query-application-tools tm aid)))

  (page
   (haml
    (.container

     (:h1 "Application Info")

      (:form ([:action (reverse-uri 'application-edit aid)] [:method "POST"])
        

        (:label "Description")
        (:input [(:type "text") (:name "description") (:value (application-description a))])

        (:h2 "Tools")
        ,@(for/list ([t (rows-result->alist (query-application-tools tm aid))] [i (in-naturals 1)])
          (printf "ENTRY: ~s\n" t)

          (define hidden-field-name (format "tool-hidden-id[~s]" (assoc-ref "toolentryid" t)))
          (define search-field-name (format "tool-id[~s]"  (assoc-ref "toolentryid" t)))
          (define image-name (format "img-id[~s]"  (assoc-ref "toolentryid" t)))
          (define original-value (string-append (assoc-ref "partno" t) " - " (assoc-ref "description" t)))

          (haml
            (:div [(:class "autocomplete-container")]
              (:img [(:id image-name) (:class "thumb-image") (:src (reverse-uri 'tool-img (assoc-ref "id" t)))]) 
              (:input [(:id hidden-field-name ) (:type "hidden") (:name hidden-field-name) (:value (number->string (assoc-ref "id" t))) ])
              (:input [(:type "text") (:autocomplete "off") (:class "autocomplete") (:name search-field-name) (:autocomplete-hidden-field-id hidden-field-name) (:autocomplete-url "/tool-quicksearch") (:value original-value ) (:previous-value original-value ) ])
              (:a [(:href (reverse-uri 'tool-info-page (assoc-ref "id" t)))] "View")
            )
          )
          )
        (let 
          [(hidden-field-name (format "tool-hidden-id[~s]" -1))
          (search-field-name (format "tool-id[~s]" -1))]
            (haml
              (:div [(:class "autocomplete-container")]
                (:img [(:id "new-tool-img") (:class "thumb-image") (:src (reverse-uri 'tool-img 1))] ) 
                (:input [(:id hidden-field-name ) (:type "hidden") (:name hidden-field-name) (:value (number->string 0 ) ) ])
                (:input [(:type "text") (:placeholder "New tool entry") (:autocomplete "off") (:class "autocomplete") (:name search-field-name) (:autocomplete-hidden-field-id hidden-field-name) (:autocomplete-url "/tool-quicksearch") (:value "" )])
              )
            ))

        (:button [(:class "")] "Save")

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
#lang racket/base

(require 
  racket/contract/base
  koyo/haml
  koyo/url
  web-server/http
  "../components/template.rkt"
  "../components/tool.rkt")

(provide
 (contract-out
  [materials-page (-> tool-manager? (-> request? response?))]))

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
            (:img [(:class "thumb-image") (:src (reverse-uri 'material-img-thumb (material-id m)))] )
            (:a [(:href (reverse-uri 'material-info-page (material-id m)))] (material->string m) )))))))))
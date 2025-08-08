#lang racket/base

(require koyo/haml
         racket/contract/base
         web-server/http
         koyo/url
         koyo/preload
         koyo/profiler
         xml
         (prefix-in config: "../config.rkt")
         "../components/tool.rkt")

(provide
 (contract-out
  [materials-search-results (-> tool-manager? (-> request? string? response?))]))


(define ((materials-search-results tm) _req term)
  (define results (materials-search tm term))
  (define page
    (haml
      (:haml
        ,@(for/list  ([m results])
            (haml
              (:div ([:class "tool-entry"])
                (:img [(:class "thumb-image") (:src (reverse-uri 'material-img (material-id m)))] )
                (:a [(:href (reverse-uri 'material-info-page (material-id m)))] (material->string m) ))
              )
            )))
      )

  (response
     200
     #"OK"
     (current-seconds)
     #"text/html; charset=utf-8"
     (make-preload-headers)
     (lambda (out)
       (parameterize ([current-output-port out])
         (displayln "<!doctype html>")
         (write-xml/content (xexpr->xml page))
         ))))

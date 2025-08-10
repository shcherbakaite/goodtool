#lang racket/base

(require 
  racket/contract/base
  koyo/haml
  koyo/url
  koyo/preload
  koyo/profiler
  web-server/http
  xml
  (prefix-in config: "../config.rkt")
  "../components/tool.rkt")

(provide
 (contract-out
  [tools-search-results (-> tool-manager? (-> request? string? response?))]))

(define ((tools-search-results tm) _req term)
  (define results (tools-search tm term))
  (define page
    (haml
      (:haml
        ,@(for/list  ([t results])
          (haml
            (:div ([:class "tool-entry"])
              (:img [(:class "thumb-image") (:src (reverse-uri 'tool-img (tool-id t)))] )
              (:a [(:href (reverse-uri 'tool-info-page (tool-id t)))] (tool->string t) )))))))

  (response
   200
   #"OK"
   (current-seconds)
   #"text/html; charset=utf-8"
   (make-preload-headers)
   (lambda (out)
     (parameterize ([current-output-port out])
       (displayln "<!doctype html>")
       (write-xml/content (xexpr->xml page))))))

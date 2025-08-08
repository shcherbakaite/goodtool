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
  [tools-search-results (-> tool-manager? (-> request? string? response?))]))

; (define ((dashboard-page tm) _req))
;   (page
;    (haml
;     (.container
;      (:h1 "Hello World!")))))


(define ((tools-search-results tm) _req term)
  (define results (tools-search tm term))
  (define page
    (haml
      (:haml
        ,@(for/list  ([t results])
            (haml
              (:div ([:class "tool-entry"])
                (:img [(:class "thumb-image") (:src (reverse-uri 'tool-img (tool-id t)))] )
                (:a [(:href (reverse-uri 'tool-info-page (tool-id t)))] (tool->string t) ))
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


  ; (page
  ;  (haml
  ;   (.container
  ;    ,@(for/list ([t (tools-list-all tools)])
  ;       (haml
  ;         (:div [(:class "tool-entry")]
  ;           (:img [(:class "thumb-image") (:src (reverse-uri 'tool-img (tool-id t)))] )
  ;           (:a [(:href (reverse-uri 'tool-info-page (tool-id t)))] (tool-partno t) " - " (tool-description t) )
  ;         )

  ;       )
  ;     ; (format "~s ::::::  " (tool-partno t))
 
  ;     )


      
#lang racket/base

(require 
  racket/contract/base
  racket/dict
  racket/port
  koyo/haml
  koyo/url
  json
  web-server/http
  "../components/template.rkt"
  "../components/tool.rkt")

(provide
 (contract-out
  [tool-autocomplete (-> tool-manager? (-> request? string? response?))]))

(define ((tool-autocomplete tm) _req term)
  (displayln term)
  (define resp (map 
    (lambda (a)
      (list (tool-id a) (string-append (tool-partno a) " - " (tool-description a)))
        )
    (tools-search tm term)))
  (json-response (with-output-to-string 
    (lambda () (write-json resp)))))

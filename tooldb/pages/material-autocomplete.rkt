#lang racket/base

(require koyo/haml
         koyo/url
         racket/contract/base
         web-server/http
         racket/dict
         json
         racket/port
         "../components/template.rkt"
         "../components/tool.rkt")

(provide
 (contract-out
  [material-autocomplete (-> tool-manager? (-> request? string? response?))]))

(define ((material-autocomplete tm) _req term)
  (define resp (map
    (lambda (a)
      (list (material-id a) (string-append (material-partno a) " - " (material-description a)))
        )
    (materials-search tm term)))
  (json-response (with-output-to-string 
    (lambda () (write-json resp)))))
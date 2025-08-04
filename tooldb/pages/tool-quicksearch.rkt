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
  [tool-quicksearch (-> tool-manager? (-> request? string? response?))]))

; (define ((dashboard-page tm) _req))
;   (page
;    (haml
;     (.container
;      (:h1 "Hello World!")))))


(define ((tool-quicksearch tm) _req term)
  ;(displayln (dict-ref json 'client_secret))
  (displayln term)
  (define json_response (make-hash))
  (define resp (tools-search tm term))
  (hash-set! json_response 'key (list "1" "2"))
  ;(displayln resp)
  (define resp2 (map 
    (lambda (a)
      (list (tool-id a) (string-append (tool-partno a) " - " (tool-description a)))
        )
    resp))

  ;(displayln json)
  (json-response (with-output-to-string 
    (lambda () (write-json resp2)))))


; (page
;    (haml
;     (.container
;      (:h1 "Hello World!")))))f
#lang racket/base

(require 
  web-server/http
  racket/function
  racket/match
  db
  threading)

(provide
  jpeg-bytes-response
  safe-car
  filter-false
  assoc-ref
  rows-result->alist)

(define (safe-car lst)
  (if (pair? lst)
      (car lst)
      #f))

(define filter-false
  (~> (lambda (xs) (filter identity xs))))

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

(define (jpeg-bytes-response image-bytes)
  (response/output
   #:code 200
   #:mime-type #"image/jpeg;"
   (lambda (out) (write-bytes image-bytes out))))
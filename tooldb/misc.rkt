#lang racket/base

(require 
  racket/function
  racket/match
  db
  threading)

(provide
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
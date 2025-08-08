#lang racket/base

(define-syntax-rule (reprovide mod ...)
  (begin
    (require mod ...)
    (provide (all-from-out mod ...))))

(reprovide
 "auth.rkt"
 "common.rkt"
 "dashboard.rkt"
 "tools.rkt"
 "tool-info.rkt"
 "materials.rkt"
 "material-info.rkt"
 "tool-edit.rkt"
 "material-edit.rkt"
 "application-info.rkt"
 "tool-autocomplete.rkt"
 "application-edit.rkt"
 "tool-search.rkt"
 "tool-delete.rkt"
 "material-search.rkt")

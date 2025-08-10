#lang racket/base

(require 
  koyo/haml
  koyo/url
  deta
  racket/dict
  koyo/database
  koyo/flash
  racket/contract/base
  racket/draw
  racket/class
  racket/match
  web-server/http
  web-server/http/bindings
  "../images.rkt"
  "../components/template.rkt"
  "../components/tool.rkt")

(provide
 (contract-out
  [tool-edit (-> tool-manager? (-> request? integer? response?))]))

(define (file-binding-get-content-type file-binding)
  (headers-assq #"Content-Type" (binding:file-headers file-binding)))
(define ((tool-edit tm) _req tid)
  (define bindings (make-hash (request-bindings _req)))
  (with-database-connection [conn (tool-manager-db tm)]
    ; -1 means the appliciation needs to be created
    (define t (if (= tid -1)
      (begin 
        (let ([a (make-tool #:partno (hash-ref bindings `partno) #:description (hash-ref bindings `description) #:mpn "" #:manufactorer "" )])
          (displayln a)
          (flash 'success "Created new TOOL")
          (insert-one! conn a)))
      (get-tool-by-id tm tid) ))
    (update-one! conn (set-tool-partno t (hash-ref bindings `partno)))
    (update-one! conn (set-tool-description t (hash-ref bindings `description)))
    (update-one! conn (set-tool-manufactorer t (hash-ref bindings `manufactorer)))
    (update-one! conn (set-tool-mpn t (hash-ref bindings `mpn)))
    (flash 'success (format  "Updated TOOL ~s" (tool-id t)))

    (let* [(file-binding (bindings-assq #"image" (request-bindings/raw _req)))
     (file-bytes (binding:file-content file-binding))]
    (when (> (bytes-length file-bytes) 0)
      (flash 'success (format  "Updated TOOL ~s image" (tool-id t)))
      (update-one! conn (set-tool-image t (image-square file-bytes)))))
    (redirect-to (reverse-uri 'tool-info-page (tool-id t) ))))

#lang racket/base

(require koyo/haml
         koyo/url
         deta
         racket/dict
         koyo/database
         racket/contract/base
         racket/draw
         racket/class
         racket/match
         web-server/http
         web-server/http/bindings
         "../components/template.rkt"
         "../components/tool.rkt")

(provide
 (contract-out
  [tool-edit (-> tool-manager? (-> request? integer? response?))]))

; (define ((dashboard-page tm) _req))
;   (page
;    (haml
;     (.container
;      (:h1 "Hello World!")))))



(define (argb-bytes-to-colors bs)
  (for/list ([x (in-range (floor (/ (bytes-length bs) 4)))])
    (let* ([offset (* 4 x)]
           [r (bitwise-and (bytes-ref bs (+ 1 offset)) #xFF)]
           [g (bitwise-and (bytes-ref bs (+ 2 offset)) #xFF)]
           [b (bitwise-and (bytes-ref bs (+ 3 offset)) #xFF)])
      ;(printf "A: ~a, ~a, ~a \n"  (+ 1 offset)  (+ 2 offset)  (+ 3 offset) )
      (make-object color% r g b))
    ))

(define (colors-avg colors) 
   (define rgb-sum (foldl (lambda (c acc)
    (match-define (list r g b) acc)
       (list
        (+ r (send c red))
        (+ g (send c green))
        (+ b (send c blue))))
    (list 0 0 0)
    colors))

  (define len (length colors))

  (define color-avg (make-object color% 
    (floor (/ (list-ref rgb-sum 0) len))   ; red
    (floor (/ (list-ref rgb-sum 1) len))   ; green
    (floor (/ (list-ref rgb-sum 2) len)))) ; blue

  color-avg
  )


(provide/contract
 [file-binding-get-content-type
  (-> binding:file? string?)])


(define (file-binding-get-content-type file-binding)
   (headers-assq #"Content-Type" (binding:file-headers file-binding)))

(define (image-perimeter-avg-color bm)

  (define w (send bm get-width))
  (define h (send bm get-height))

  (define top-edge-bytes (make-bytes (* w 4)))
  (define right-edge-bytes (make-bytes (* h 4)))
  (define bottom-edge-bytes (make-bytes (* w 4)))
  (define left-edge-bytes (make-bytes (* h 4)))

  ; How much to step from the border
  (define inside-offset 5)

  ;; Top row: (0, 0) to (w, 1)
  (send bm get-argb-pixels 0 inside-offset w 1 top-edge-bytes)

  ;; Right column: (w-1, 0) to (1, h)
  (send bm get-argb-pixels (- (- w 1) inside-offset) 0 1 h right-edge-bytes)

  ;; Bottom row: (0, h-1) to (w, 1)
  (send bm get-argb-pixels 0 (- (- h 1) inside-offset) w 1 bottom-edge-bytes)

  ;; Left column: (0, 0) to (1, h)
  (send bm get-argb-pixels 0 inside-offset 1 h left-edge-bytes)

  (define perimeter-colors (append 
    (argb-bytes-to-colors top-edge-bytes)
    (argb-bytes-to-colors right-edge-bytes)
    (argb-bytes-to-colors bottom-edge-bytes)
    (argb-bytes-to-colors left-edge-bytes)))

  (define color-avg (colors-avg perimeter-colors))
 
  ; (printf "AA: ~a\n" color-avg )

  (printf "~a, ~a, ~a\n" (send color-avg red) (send color-avg green) (send color-avg blue))

  color-avg
  ; ; ;; Sample pixel (top-left corner)
  ; ; (define sample-color
  ; ;   (let* ([r (bitwise-and (bytes-ref color 1) #xFF)]
  ; ;          [g (bitwise-and (bytes-ref color 2) #xFF)]
  ; ;          [b (bitwise-and (bytes-ref color 3) #xFF)])
  ; ;     (make-object color% r g b)))
  ; 1
  )

(define (image-square image-bytes)
  ; Read bitmap from bytes
  (define bm (read-bitmap (open-input-bytes image-bytes)))
  
  (define w (send bm get-width))
  (define h (send bm get-height))

  ; Pick max side
  (define side (+ (max w h) 10))

  ; New bitmap of size side x side
  (define result (make-bitmap side side))

  ; DC (Drawing Context)
  (define dc (new bitmap-dc% [bitmap result]))

  (define color (make-bytes 4))
  (send bm get-argb-pixels 0 0 1 1 color)

  ;; Sample pixel (top-left corner)
  (define sample-color
    (let* ([r (bitwise-and (bytes-ref color 1) #xFF)]
           [g (bitwise-and (bytes-ref color 2) #xFF)]
           [b (bitwise-and (bytes-ref color 3) #xFF)])
      (make-object color% r g b)))

  (printf "~a, ~a, ~a\n" (send sample-color red) (send sample-color green) (send sample-color blue))

  (define image-border-avg-color (image-perimeter-avg-color bm))

  (send dc set-smoothing 'aligned)

  ; Fill with sampled color
  (send dc set-background image-border-avg-color) ; white
  (send dc clear)

  ;; Draw original image centered
  (if (> w h)
    (let ( [x 5]
           [y (floor (- (/ side 2) (/ h 2)))] )
      (send dc draw-bitmap bm x y))
    (let ([x (floor (- (/ side 2) (/ w 2)))]
          [y 5])
      (send dc draw-bitmap bm x y)))


  ; Return image bytes (jpeg)
  (define out (open-output-bytes))
  (send result save-file out 'jpeg)
  (get-output-bytes out))

  (define ((tool-edit tm) _req tid)

  ; (displayln (file-binding-get-content-type file-binding))
  ; (displayln (binding:file-filename file-binding))
  ; (define file-bytes (binding:file-content file-binding))
  
  (define bindings (make-hash (request-bindings _req)))
  

  ;(set-tool-partno t (hash-ref bindings `partno))
  ;(set-tool-description t (hash-ref bindings `description))
  (with-database-connection [conn (tool-manager-db tm)]

    ; -1 means the appliciation needs to be created
    (define t (if (= tid -1)
      (begin 
        (let ([a (make-tool #:partno "PARTNO" #:description "DESCRIPTION" #:mpn "MPN" #:manufactorer "MANUFACTORER" )])
          (displayln a)
          (insert-one! conn a)))
          (get-tool-by-id tm tid) ))

    ;(displayln (hash-ref bindings `myfile))
    
    (update-one! conn (set-tool-partno t (hash-ref bindings `partno)))
    (update-one! conn (set-tool-description t (hash-ref bindings `description)))
    (update-one! conn (set-tool-manufactorer t (hash-ref bindings `manufactorer)))
    (update-one! conn (set-tool-mpn t (hash-ref bindings `mpn)))

    ; Update tool image
    (let* [(file-binding (bindings-assq #"myfile" (request-bindings/raw _req)))
           (file-bytes (binding:file-content file-binding))
           (file-content-type (file-binding-get-content-type file-binding))
           (file-name (binding:file-filename file-binding))]
      (displayln file-name)
      
      (when (> (bytes-length file-bytes) 0)
        (update-one! conn (set-tool-image t (image-square file-bytes))))
      )


    
    (redirect-to (reverse-uri 'tool-info-page (tool-id t) ))

    ))
  
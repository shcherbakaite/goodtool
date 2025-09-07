#lang racket/base

(require 
  racket/contract/base
  racket/class
  racket/match
  racket/math
  racket/draw)

(provide 
  bitmap-scale
  image-scale-to-width
  bitmap-scale-to-width
  (contract-out [image-square (-> bytes? bytes?)]))

(define (argb-bytes-to-colors bs)
  (for/list ([x (in-range (floor (/ (bytes-length bs) 4)))])
    (let* ([offset (* 4 x)]
           [r (bitwise-and (bytes-ref bs (+ 1 offset)) #xFF)]
           [g (bitwise-and (bytes-ref bs (+ 2 offset)) #xFF)]
           [b (bitwise-and (bytes-ref bs (+ 3 offset)) #xFF)])
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
  color-avg)

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

  color-avg)

; (define (image-resize image-bytes)
;   ; Read bitmap from bytes
;   (define bm (read-bitmap (open-input-bytes image-bytes)))

;   ; New bitmap of size side x side
;   (define result (make-bitmap 200 200))
;   ; DC (Drawing Context)
;   (define dc (new bitmap-dc% [bitmap result]))

;   (send dc draw-bitmap bm x y)

;   ; Return image bytes (jpeg)
;   (define out (open-output-bytes))
;   (send result save-file out 'jpeg)
;   (get-output-bytes out))

(define bitmap-blank
  (lambda [[w 0] [h #false] #:backing-scale [backing-scale 2.0]]
    (define width  (max 1 (exact-ceiling w)))
    (define height (max 1 (exact-ceiling (or h w))))
    (make-bitmap width height #:backing-scale backing-scale)))

(define bitmap-scale
  (case-lambda
    [(bmp scale)
     (if (= scale 1.0) bmp (bitmap-scale bmp scale scale))]
    [(bmp scale-x scale-y)
     (cond [(and (= scale-x 1.0) (= scale-y 1.0)) bmp]
           [else (let ([w (max 1 (exact-ceiling (* (send bmp get-width) scale-x)))]
                       [h (max 1 (exact-ceiling (* (send bmp get-height) scale-y)))])
                   (define dc (make-object bitmap-dc% (bitmap-blank w h)))
                   (send dc set-smoothing 'aligned)
                   (send dc set-scale scale-x scale-y)
                   (send dc draw-bitmap bmp 0 0)
                   (or (send dc get-bitmap) (bitmap-blank)))])]))


; Scale bitmap (proportionally) to have specified width
(define (bitmap-scale-to-width bmp width)
  ; Read bitmap from bytes
  (define w (send bmp get-width))
  (define h (send bmp get-height))

  (define scale (/ width w))
  (bitmap-scale bmp scale))


(define (image-scale-to-width image-bytes width)
  ; Read bitmap from bytes
  (define result (bitmap-scale-to-width 
    (read-bitmap (open-input-bytes image-bytes))
    width))

  ; Return image bytes (jpeg)
  (define out (open-output-bytes))
  (send result save-file out 'jpeg)
  (get-output-bytes out))

(define (image-square image-bytes)
  ; Read bitmap from bytes
  (define bm (bitmap-scale-to-width 
    (read-bitmap (open-input-bytes image-bytes))
    800))
  
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
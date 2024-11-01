\version "2.24.3"

\include "point-transform.ly"

% Functions returning path (list of pairs representing points)

#(define (early:quadrata::side)
  '((0.33 0.01)(0.66 -0.01)(1 0))
)

#(define (early:quadrata::corner)
  '((0 0))
)

#(define (early:quadrata::band) ;; side + corner
  (let* ((side (early:quadrata::side))
         (corner (transform
                  (early:quadrata::corner)
                  0
                  (last side))))
   (append side corner)
))

#(define (early:quadrata::brim) ;; two bases
  (let* ((b1 (early:quadrata::band))
         (b2 (transform
              (early:quadrata::band)
              90
              (last b1))))
   (append b1 b2)
))

#(define (early:quadrata::path) ;; two brims
  (let* ((brim1 (early:quadrata::brim))
         (brim2 (transform
                 (early:quadrata::brim)
                 -180
                 (last brim1))))
   (append brim1 brim2)
))

#(define-public (early:quadrata::note-head)
  (let* ((path (early:quadrata::path)))
   (make-connected-path-stencil path
    0.1 ; thickness
    1 1 ; xy scale
    #t  ; connect
    #t  ; fill
   )
))

#(define-public (early:note-head::print grob)
  (let* ((dur-log (ly:grob-property grob 'duration-log)))
   (if (and (> dur-log -3) (< dur-log 0))
    (begin
     (early:quadrata::note-head))
    (ly:note-head::print grob))
))

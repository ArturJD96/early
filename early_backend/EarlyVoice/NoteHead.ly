\version "2.24.3"

\include "../early-styles.ly"

% Function: ly:make-stencil expr xext yext
% expr: e.g. (list 'circle radius thickness fill)
% Stencils are device independent output expressions. They carry two pieces of information:
% A specification of how to print this object. This specification is processed by the output backends, for example ‘scm/output-ps.scm’.
% The vertical and horizontal extents of the object, given as pairs. If an extent is unspecified (or if you use empty-interval as its value), it is taken to be empty.

% ly:make-stencil
% * expr xext yext
% make-path-stencil
% * path thickness x-scale y-scale fill #:line-cap-style line-cap-style #:line-join-style line-join-style
% make-connected-path-stencil
% * pointlist thickness x-scale y-scale connect fill

#(define (early:get-notehead-path style type notation properties)
  '())

#(define (rotate-path path-commands angle) ; ChatGPT]
    "path-commands: list of lists like (('l x1 x2)('c x1 y1 x2 y2 x3 y3))"

    (define (rotate-point x y angle) ; ChatGPT
      (let* ((phi (degrees->radians angle))
             (cos-phi (cos phi))
             (sin-phi (sin phi)))
       (list (+ (* x cos-phi) (* (- y) sin-phi))
             (+ (* x sin-phi) (* y cos-phi)))))

    (define (rotate-points points angle) ; ChatGPT
      (map (lambda (point)
            (rotate-point (car point) (cadr point) angle))
       points))

    (define (rotate-line command angle)
      (let ((i (list-ref command 0))
            (x (list-ref command 1))
            (y (list-ref command 2)))
       (cons (list i) (rotate-point x y angle))))

    (define (rotate-curve command angle)
      (let ((c (list-ref command 0))
            (x1 (list-ref command 1))
            (y1 (list-ref command 2))
            (x2 (list-ref command 3))
            (y2 (list-ref command 4))
            (x3 (list-ref command 5))
            (y3 (list-ref command 6)))
        (append (list c)
                (rotate-points (list (list x1 y1)
                                     (list x2 y2)
                                     (list x3 y3))
                               angle))))

    (map (lambda (command)
          (if (= (length command) 7)
           (rotate-curve command angle)
           (rotate-line command angle)))
      path-commands))

#(define (early:get-notehead-quadrata-random-side)
  ;(let ((side
  ;      (corner
  '((c 0 0
       0.35 0
       0.8 0)
    (c 0.5 0
       0.1 -0.5
       0.1 0.1))) )

#(define (early:get-notehead-quadrata-sides)
  (let ((side-left (early:get-notehead-quadrata-random-side  ))
        (side-up (early:get-notehead-quadrata-random-side  ))
        (side-right (early:get-notehead-quadrata-random-side  ))
        (side-down (early:get-notehead-quadrata-random-side  )) )
   (list '(m 0.1 0)
         side-down
         (rotate-path side-right 90)
         (rotate-path side-up 180)
         (rotate-path side-left 270))))

#(define (early:get-notehead-stencil grob)
  "Return early note head stencil."
  (let* ((duration-log (ly:grob-property grob 'duration-log))
         ;(stem (ly:grob-property grob 'stem))
         (style (ly:grob-property grob 'style))
         (staff-position (ly:grob-property grob 'staff-position)))
   (let* ((corner-offset 0.1)
          (side-length (- 1 (* corner-offset 2))) )
    (make-path-stencil
      (flatten-list (early:get-notehead-quadrata-sides))
      0.05 1 1 #f) )))

#(define-public (early:note-head::print grob)
  "Create early stencil for a notehead."
  (let ((style (ly:grob-property grob 'style)))
   (if (early:has-style style)
    (early:get-notehead-stencil grob)
    (ly:note-head::print grob))))

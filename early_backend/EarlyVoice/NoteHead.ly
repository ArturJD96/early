\version "2.24.3"

\include "../early-path-utilities.ly"
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

#(define (early:path-notehead-square-side-simple width)
  (list (list 'l width 0)))

#(define (early:get-notehead-path style type notation properties)
  '())

#(define (early:path-notehead-square-side-complex width)
    (let ((side (list 'c   0 0   0.34 0   width 0))
        (corner (list 'c   0.5 0   0.1 -0.5  0 0)))
    (list side corner)))

#(define (early:path-notehead-square-side complex len corner-offset angle)
  (let ((side (if complex
               (early:path-notehead-square-side-complex len)
               (early:path-notehead-square-side-simple len))))
    (rotate-path side angle)))

#(define (early:notehead-quadrata x-len y-len)
  (let ((side (make-hash-table))
        (random-angle (lambda () (zero? (random 2)))))
   (hashq-set! side 'x-len x-len)
   (hashq-set! side 'y-len y-len)
   (hashq-set! side 'lengths (list x-len y-len x-len y-len))
   (hashq-set! side 'corners (list (random-angle) (random-angle) (random-angle) (random-angle)))
   (hashq-set! side 'corner-offsets (list 0.1 0.1 0.1 0.1))
   (hashq-set! side 'angles (list 0 90 180 270))
   side))

#(define (early:get-notehead-path)
   (let* ((notehead (early:notehead-quadrata 1.5 1))
          (path-notehead (append-map early:path-notehead-square-side ; len corner corner-offset
                          (hashq-ref notehead 'corners)
                          (hashq-ref notehead 'lengths)
                          (hashq-ref notehead 'corner-offsets)
                          (hashq-ref notehead 'angles))))
    path-notehead))

#(define (early:path-notehead-quadrata-random-side width)
  (early:path-notehead-square-side (zero? (random 2)) width) )

#(define (early:get-notehead-stencil grob) ; main function
  "Return early note head stencil."
  (let* ((duration-log (ly:grob-property grob 'duration-log))
          ;(stem (ly:grob-property grob 'stem))
          (style (ly:grob-property grob 'style))
          (staff-position (ly:grob-property grob 'staff-position)))
      (let* ((corner-offset 0.1)
          (side-length (- 1 (* corner-offset 2))) )
      (make-path-stencil
      (flatten-list (early:get-notehead-path))
      0.05 1 1 #f) )))

% #(define (early:get-notehead-quadrata-sides)
%   (let ((side-left (early:path-notehead-quadrata-random-side  1))
%         (side-up (early:path-notehead-quadrata-random-side  2))
%         (side-right (early:path-notehead-quadrata-random-side  1))
%         (side-down (early:path-notehead-quadrata-random-side  2)) )
%    (list '(m 0.1 0)
%          side-down
%          (rotate-path side-right 90)
%          (rotate-path side-up 180)
%          (rotate-path side-left 270))))

% #(define (early:get-notehead-stencil grob) ; main function
%   "Return early note head stencil."
%   (let* ((duration-log (ly:grob-property grob 'duration-log))
%          ;(stem (ly:grob-property grob 'stem))
%          (style (ly:grob-property grob 'style))
%          (staff-position (ly:grob-property grob 'staff-position)))
%    (let* ((corner-offset 0.1)
%           (side-length (- 1 (* corner-offset 2))) )
%     (make-path-stencil
%       (flatten-list (early:get-notehead-quadrata-sides))
%       0.05 1 1 #f) )))

#(define-public (early:note-head::print grob)
  "Create early stencil for a notehead."
  (let ((style (ly:grob-property grob 'style)))
   (if (early:has-style style)
    (early:get-notehead-stencil grob)
    (ly:note-head::print grob))))

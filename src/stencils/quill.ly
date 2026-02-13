\version "2.24.4"

%{
% Define different custom quills.
%}

#(define-public early:QUILLS '())

% Quill constructor.
#(define-public (early:quill thin thick) `(
  (thin . ,thin)
  (thick . ,thick)
))

%{
%   Define different quill strokes (like "swoosh").
%}

% #(define early:define-shape 'define)
% more checks needed.
% It:
% – returns a 'make-shape' function (with one argument: quill)

#(define swoosh1-params '(
  (angle . 65)
  (width . 1)
  (height . 1)
  (top-offset . 24/71)
  (bottom-offset . 45/71)
))
% Should be: early:define-shape – this is more explicit.
% This is a 'class': shape.
#(define (swoosh params quill) ;; -> path
   (let* ((w (assq-ref params 'width))
          (h (assq-ref params 'height))
          (thick (assq-ref quill 'thick))
          ; (quill-width-thin 0.05)
          (angle (degrees->radians (assq-ref params 'angle)))
          (top-offset (* w (assq-ref params 'top-offset)))
          (bottom-offset (* w (assq-ref params 'bottom-offset)))
          ;; Apex point – the tip of the swoosh.
          (apex (point (* w top-offset) h))
          ;; Line and it's two points – the bottom side of the cone.
          (line-length (* thick (cos angle)))
          (line-bottom (point bottom-offset 0))
          (line-upper  (point (+ bottom-offset line-length)
                              (sqrt (- (expt thick 2)
                                       (expt line-length 2)))))
          ;; control points.
         )
    (path
        ;; from top, outer curve from apex to line-bottom
        (moveto  apex)
        (curveto 10/284 219/312    0 178/312       0 159/312)
        (curveto 4/284  64/312     20/284 40/312   line-bottom)
        ;; from bottom, inner curve from line-upper to apex
        (lineto  line-upper)
        (curveto 73/284  114/312   35/284 137/312  35/284 204/312)
        (lineto  apex)
    )
  )
)

% Returns stencil from shape path.
#(define (early:draw-shape shape params quill thickness x-scale y-scale)
; NOT IMPLEMENTED:
; #:line-cap-style line-cap-style
; #:line-join-style line-join-style
  (make-path-stencil
   (shape params quill)
   thickness x-scale y-scale
   #t ;; fill always true.
  )
)

% A shape (like "double-swoosh") consist of smaller shapes.
#(define double-swoosh-params `(
  (left . ,swoosh1-params)
  (right . ,swoosh1-params)
))

% Create stencil for the "double-swoosh" shape.
#(define (early:double-swoosh-stencil params quill thickness x-scale y-scale)
  (centered-stencil
   (stack-stencil-line (- (random 0.1) 0.55) ;; those should be moved to settings.
    (list (early:draw-shape swoosh (assq-ref double-swoosh-params 'left) quill thickness x-scale y-scale)
          (ly:stencil-rotate
           (early:draw-shape swoosh (assq-ref double-swoosh-params 'right) quill thickness x-scale y-scale)
           180 0 0)
    )
   )
 )
)

%{
%   print note-head using 'quill' backend.
%}
#(define-public (early:note-head::quill grob)
  (let* ((dur-log (ly:grob-property grob 'duration-log))
         (notehead (cond ((< dur-log -1) 'maxima)
                         ((< dur-log 0) 'quadrata)
                         (else 'rhombus)))
         (hollow (ly:grob-property grob 'early-hollow))
         (quill (ly:grob-property grob 'early-quill)) ;; What if not provided? Guard by using a default quill.
        )

   (case notehead
    ((rhombus) (early:double-swoosh-stencil double-swoosh-params quill 0.001 1 1)) ;; double-swoosh is HARDCODED here.
    (else (ly:note-head::print grob))
   )
))

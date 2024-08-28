\version "2.24.3"

% Function: ly:make-stencil expr xext yext
% Stencils are device independent output expressions. They carry two pieces of information:
% A specification of how to print this object. This specification is processed by the output backends, for example ‘scm/output-ps.scm’.
% The vertical and horizontal extents of the object, given as pairs. If an extent is unspecified (or if you use empty-interval as its value), it is taken to be empty.

#(define-public early:styles-list
  '(tournai))

#(define-public (early:has-style style)
  (when (not (symbol? style)) (display "style must be a symbol."))
  (any (lambda (style-name)
        (eq? style-name style))
   early:styles-list))

#(define (early:get-notehead-path style type notation properties)
  '())

#(define-public (early:note-head::print grob)
  "Create early stencil for a notehead."
  (let* ((staff-position (ly:grob-property grob 'staff-position))
         (style (ly:grob-property grob 'style)) )
   (if (not (early:has-style style))
    (ly:note-head::print grob)
    (begin
     (ly:note-head::print grob)))))

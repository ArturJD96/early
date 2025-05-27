\version "2.24.3"

\include "../stencils/noteheads.ly"

#(define (early:guard style type?)
  (when (not (type? style))
   (display "argument must be a symbol.")))

% Style definitions

#(define-public early:all-styles '())

#(define-public (early:has-style style)
  (early:guard style symbol?)
  (any (lambda (style-name)
        (eq? style-name style))
   early:all-styles))

#(define-public (early:add-notation-style style settings)
  (early:guard style symbol?)
  (early:guard settings alist?)
  (when (assoc-ref early:all-styles 'style)
   (ly:error "Style already exists."))
  (unless (assoc-ref settings 'default)
   (ly:error "Style settings must contain at lease \"default\" key."))
  (set! early:all-styles
   (assoc-set! early:all-styles style settings)))

% Style properties getter and setter

#(define-public (early:grob-property grob property)
  (assoc-ref (ly:grob-property grob 'early-style-properties) property))

#(define-public (early:grob-set-property! grob property value)
  (ly:grob-set-property! grob 'early-style-properties
   (assoc-set!
    (ly:grob-property grob 'early-style-properties)
    property
    value)))

\version "2.24.3"

\include "../stencils/noteheads.ly"

#(define (early:guard style type?)
  (when (not (type? style))
   (display "argument must be a symbol.")))

#(define-public early:all-styles
  '(tournai . (blackmensural)))

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
   (append early:all-styles (list style))))

#(for-each (lambda (style) (early:add-notation-style (car style) (cdr style)))
  '((tournai . ((default . blackmensural)
                (quadrata . ,early:quadrata::note-head )))
))

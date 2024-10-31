\version "2.24.3"

#(define (early:guard-symbol style)
  (when (not (symbol? style))
   (display "argument must be a symbol.")))

#(define-public early:styles-list
  '(tournai))

#(define-public (early:has-style style)
  (early:guard-symbol style)
  (any (lambda (style-name)
        (eq? style-name style))
   early:styles-list))

#(define-public (early:add-style style)
  (early:guard-symbol style)
  (set! early:styles-list
   (append early:styles-list (list style))))

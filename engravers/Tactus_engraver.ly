\version "2.24.3"

% early custom engraver
#(define-public (early:Tactus_engraver context)
  (let ((test-count 0))
   (make-engraver
    (listeners
     ((rhythmic-event engraver event)
      ;(newline)
      (set! test-count (1+ test-count))
      ;(display (ly:context-property context 'mensura))
      ;(display (ly:event-property event 'length))
      '()
      ;(newline)
      ;(display (ly:event-property event 'early:mensura-properties))
     )
     ;((time-signature-event engraver event)
     ; (display event))
    )
)))

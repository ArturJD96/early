\version "2.24.3"

#(define-public (early:Augmentation_engraver context)
  (make-engraver
   (listeners
    ((rhythmic-event engraver event)
     (let* ((aug (ly:context-property context 'augmentation))
            (dur (ly:event-property event 'duration))
            (dur-log (ly:duration-log dur))
            (dur-dots (ly:duration-dot-count dur))
            (dur-factor (ly:duration-scale dur)))
      (ly:event-set-property! event 'duration
       (ly:make-duration (- dur-log aug) dur-dots dur-factor)))))))

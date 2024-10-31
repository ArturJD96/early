\version "2.24.3"

#(define (pitched-rest? grob)
  (let* ((rest-event (ly:grob-property grob 'cause)))
   (not (null? (ly:event-property rest-event 'pitch)))))

#(define (bound staff-position)
  (if (even? staff-position)
   staff-position
   ((if (> 0 staff-position) 1+ 1-) staff-position)))

% early custom engraver
#(define-public (early:Rest_position_engraver context)
  (let ((last-note-position #f)
        (rests-to-be-decided '()))
   (make-engraver
    (acknowledgers
     ((rhythmic-grob-interface engraver grob source)
      (let ((cause (ly:grob-property grob 'cause)))
       ;(newline)
       ;(display (ly:context-property context 'tactusPosition))))
       '()))

     ((note-head-interface engraver grob source)
      (set! last-note-position (ly:grob-staff-position grob))
     )
     ((rest-interface engraver grob source)
      (newline)
      (display (ly:context-property context 'mensuraCompletion))
      (if (pitched-rest? grob)

       '() ;; idk...think about it.

       (if last-note-position
        (ly:grob-set-property! grob 'staff-position (bound last-note-position))
        (set! rests-to-be-decided
              (append rests-to-be-decided (list grob)))
       )
      )
     )
    )
)))

% \displayMusic { c2\rest r2 }

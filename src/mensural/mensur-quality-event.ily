\version "2.24.4"
\include "./../definitions/events.ily" % TO DO: de-centralize and define early:MensurSetting and MensurEvent here?

% TO DO: rename to quality:... etc.
% TO DO: rename mensur:quality-type to quality:type etc.

% TO DO: consult a good source on definitions of those terms.
#(define quality:reasons `(
  ;; Usual case.
  (simple-mensur .
   ((description . "Mensura is duplex so complex mensuration does not apply")
    (event . rhythmic-event)
    (qualities . (simple)))) ; TO DO: rename to 'types'
  ;; Reasons for complex.
  (rest .
   ((description . "Rest in mensural music is compulsory complex in complex meters.")
    (event . rest-event)
    (qualities . (complex))))
  (position .
   ((description . "Note mensuration is deduced from position.")
    (event . note-event)
    (qualities . (simple complex partial altera))))
  (punctum-perfectionis .
   ((descritpion . "In complex mensura, note is complex (perfect) because it followed by an immediate dot.")
    (event . note-event)
    (qualities . (complex))))
  ;; For documentation purposes.
  (undocumented .
   ((description . "The reason for mensuration is not explicitly provided")
    (event . rhythmic-event)
    (qualities . (complex simple partial altera))))
  (exception .
   ((description . "A note defies mensural rules")
    (event . rhythmic-event)
    (qualities . (complex simple partial altera))))
))

#(define-public mensur:make-quality-event
  (early:define-constructable-music-event!
   'MensurQualityEvent
   "Note duration is recalculated using \\mensura."
   '(mensur-event post-event event StreamEvent) '()
   `(type . ,(choice '(simple complex partial altera)))
   `(reason . ,(choice (map car quality:reasons)))
   `(fraction . ,(nullable fraction?))
))

#(define-public (quality:type quality-event) (ly:music-property quality-event 'type)) % TO DO: rename!
#(define-public (quality:reason quality-event) (ly:music-property quality-event 'reason))
#(define-public (quality:fraction quality-event)
  (let ((fraction (ly:music-property quality-event 'fraction)))
   (if (null? fraction) 1 fraction)))

   %;; Returns #f if point is not found.
#(define-public (early:quality rhythmic-event) ; TO DO: rename to mensur:quality
  (find-post-event rhythmic-event 'mensur-quality-event))

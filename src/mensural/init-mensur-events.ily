\version "2.24.4"
\include "./../definitions/events.ily" % TO DO: de-centralize and define early:MensurSetting and MensurEvent here?

#(unless (ly:make-event-class 'mensur-event)
  (define-event-class 'mensur-event 'early-event)
  (define-event-class 'mensur-context-event 'mensur-event) ;; Modyfies mensur *context* object.
  (define-event-class 'mensur-rhythmic-event 'mensur-event) ;; Modyfies lilypond's rhythmic music objects.
)

\version "2.24.4"
\include "./../definitions/events.ily" % TO DO: de-centralize and define early:MensurSetting and MensurEvent here?

#(define-public mensur:make-mensura-event
  (early:define-constructable-music-event!
   'EarlyMensuraEvent
   "Inserts mensuration sign to a mensural music. Used for overriding mensural rhythmic event subdivisions."
   '(mensur-context-event time-signature-event StreamEvent) '()
   `(subdivisions . ,alist?)
))

#(define-public mensur:make-mensura-music
  (early:define-constructable-music-event!
   'EarlyMensuraMusic
   "See EarlyMensuraEvent. NOT IMPLEMENTED, copied from time-signature-music."
   '(mensur-context-event time-signature-music StreamEvent) '()
   ; TO DO: validators?
))

#(define-public mensur:make-proportio-event
  (early:define-constructable-music-event!
   'EarlyProportioEvent
   "Inserts mensuration sign to a mensural music. Used for overriding mensural rhythmic event subdivisions."
   '(mensur-context-event time-signature-event StreamEvent) '()
   `(proportio . ,rational?)
))

#(define-public mensur:make-proportio-music
  (early:define-constructable-music-event!
   'EarlyProportioMusic
   "See EarlyMensuraEvent. NOT IMPLEMENTED, copied from time-signature-music."
   '(mensur-context-event time-signature-music StreamEvent) '()
   ; TO DO: validators?
))

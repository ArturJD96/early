\version "2.24.4"
\include "./../definitions/events.ily" % TO DO: de-centralize and define early:MensurSetting and MensurEvent here?
\include "mensur.ily"

%{
%       Some complex subdivisions.
% %}
#(define-public mensur:tempus-perfectum
  (mensur:make-subdivision -1 3)) % done!

#(define-public mensur:prolatio-maior
  (mensur:make-subdivision 0 3)) % done!

%{
%       Symbols used with "mensura" command.
%       It is an alist of subdivisions
% %}
#(define-public early:mensur-signa
  `((C   . ,(mensur:make-mensura-event '()))
    (O   . ,(mensur:make-mensura-event (list mensur:tempus-perfectum)))
    (C.  . ,(mensur:make-mensura-event (list mensur:prolatio-maior)))
    (O.  . ,(mensur:make-mensura-event (list mensur:tempus-perfectum mensur:prolatio-maior)))

  ;; Sources of symbols:
  ;; https://wiki.ccarh.org/wiki/MuseData_Example:_mensural_signs
))

#(define-public (early:signum->mensur-event signum)
  (if (string? signum)
   (set! signum (string->symbol signum)))
  (or (assoc-ref early:mensur-signa signum)
      (ly:error "Unknown mensural sign: ~a. Define it using early:register-mensur-signum (not yet implemented)." signum))
)

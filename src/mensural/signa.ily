\version "2.24.4"
\include "./../definitions/events.ily" % TO DO: de-centralize and define early:MensurSetting and MensurEvent here?
\include "mensur.ily"

%{
%       Some complex subdivisions.
% %}
#(define-public mensur:tempus-perfectum
  (cons -1 (mensur:relationship 3)))

#(define-public mensur:prolatio-maior
  (cons 0 (mensur:relationship 3)))

%{
%       Symbols used with "mensura" command.
%       It is an alist of mensur:relationship.
% %}
#(define-public early:mensur-signa
  `((C   . ,(make-music 'EarlyMensuraEvent))
    (O   . ,(make-music 'EarlyMensuraEvent 'relationships (list mensur:tempus-perfectum)))
    (C.  . ,(make-music 'EarlyMensuraEvent 'relationships (list mensur:prolatio-maior)))
    (O.  . ,(make-music 'EarlyMensuraEvent 'relationships (list mensur:tempus-perfectum mensur:prolatio-maior)))

  ;; Sources of symbols:
  ;; https://wiki.ccarh.org/wiki/MuseData_Example:_mensural_signs
))

#(define-public (early:signum->mensur-event signum)
  (if (string? signum)
   (set! signum (string->symbol signum)))
  (or (assoc-ref early:mensur-signa signum)
      (ly:error "Unknown mensural sign: ~a. Define it using early:register-mensur-signum (not yet implemented)." signum))
)

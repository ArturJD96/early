\version "2.24.4"

#(use-modules (ice-9 copy-tree))

%{
%       Property constructors (with sanitiztion).
% %}

#(define (complex-subdivision dur-log subdivision)
  "Complex division object defines how many of faster notes it takes
   to complete the note mensura for a note with a duration of dur-log."
  (unless (and (integer? dur-log) (integer? subdivision))
   (ly:error "Wrong type.")) ;; Too dummy...
  (unless (> subdivision 2)
   (ly:error "To be regarded as complex, subdivision must be greater than 2."))
  `(,dur-log . ,subdivision)
)

#(define (proportio proportio)
  (unless (fraction? proportio)
   (ly:error "proportio needs to be expressed as fraction."))
  proportio)

%{
%       Object.
% %}

#(define-public (early:mensur complex-subdivisions . proportio)
  "Mensur object holds the information about
   the mensural notation on the notes duration."
  (list
   (cons 'complex-subdivisions
         (map (lambda (pair)
               (apply complex-subdivision (list (car pair) (cdr pair))))
          complex-subdivisions))
   (cons 'proportio
         (if (null? proportio)
          1
          (proportio (car proportio)))))
)

%{
%       Accessors.
%}

#(define-public (mensur:complex-subdivisions mensur)
  (assq-ref mensur 'complex-subdivisions))

#(define-public (mensur:proportio mensur)
  (assq-ref mensur 'proportio))

%{
%       Some complex subdivisions.
% %}
#(define-public mensur:tempus-perfectum (complex-subdivision -1 3))
#(define-public mensur:prolatio-maior (complex-subdivision 0 3))

%{
%       Symbols used with "mensura" command.
% %}
#(define-public early:mensur-signa
  `((C   . ,(early:mensur `()))
    (O   . ,(early:mensur `(,mensur:tempus-perfectum)))
    (C.  . ,(early:mensur `(,mensur:prolatio-maior)))
    (O.  . ,(early:mensur `(,mensur:tempus-perfectum ,mensur:prolatio-maior)))

  ;; Sources of symbols:
  ;; https://wiki.ccarh.org/wiki/MuseData_Example:_mensural_signs
))

% #(define-public (early:early:register-mensur-signum signum complex-subdivisions proportion)
%   "Add custom mensuration sign."
%   (unless (and (symbol? signum) (alist? complex-subdivisions) (fraction? proportion))
%    (ly:error "Wrong type.")) ;; Too dummy...
%   (when )
%   (assq-set! early:mensur-signa signum
%    (early:mensur complex-subdivisions (or proportion 1))))


#(define-public (early:signum->mensur signum)
  (or (assoc-ref early:mensur-signa signum)
      (ly:error "Unknown mensural sign: ~a. Define it using early:register-mensur-signum (not yet implemented)." signum))
)

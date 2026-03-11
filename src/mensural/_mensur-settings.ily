\version "2.24.4"
\include "./../definitions/events.ily"

%{
%       Property constructors (with sanitiztion).
% %}

#(define (implicit-subdivision dur-log is-implicit)
  "Defines whether a note with duration of dur-log is complex
   or does it need additional specification."
  (unless (and (integer? dur-log) (boolean? is-implicit)) (ly:error "Wrong type.")) ;; Too dummy...
   `(,dur-log . ,is-implicit)
)

#(define (as-tuplet dur-log is-tuplet)
  "Defines whether internal division is treated as a tuplet
   – in such a situation, the note does not gain duration."
  (unless (and (integer? dur-log) (boolean? is-tuplet)) (ly:error "Wrong type.")) ;; Too dummy...
   `(,dur-log . ,is-tuplet)
)

%{
%       Object.
% %}

#(define-public (early:mensur-settings implicit-subdivisions as-tuplet)
  "Mensur settings are 🌺EarLy-specific modifications to note durations
   serving as a set of additional control upon mensural notation behaviours."
  `((implicit-subdivisions . ,implicit-subdivisions)
    (as-tuplet . ,as-tuplet))
)

%{
%       Accessors.
%}

#(define-public (mensur-settings:as-tuplet mensur)
  (assq-ref mensur 'as-tuplet))

#(define-public (mensur-settings:implicit-subdivisions mensur)
  (assq-ref mensur 'implicit-subdivisions))



#(define-public (early:make-implicit-subdivision-setting arg)
  "Creates a MensurSetting event that modifies mensur-context."
  (make-music
   'early:MensurSetting
   'implicit-subdivisions
   (cond
    ((pair? arg) (list (implicit-subdivision (car arg) (cdr arg))))
    ((alist? arg) arg)
    (else (case arg ;; Validation of used symbols.
           ((all) 'all)
           ((none) 'none)
           (else (ly:error "Wrong type of argument for implicit subdivision: ~A" arg)))))))

%{
%       Implicit mensurations
% %}

mensuraImplicit =
#(define-music-function () ()
  (early:make-implicit-subdivision-setting 'all))

modusmaiorImplicit =
#(define-music-function () ()
  (early:make-implicit-subdivision-setting '(-3 . #t)))

modusImplicit =
#(define-music-function () ()
  (early:make-implicit-subdivision-setting '(-2 . #t)))

tempusImplicit =
#(define-music-function () ()
  (early:make-implicit-subdivision-setting '(-1 . #t)))

prolatioImplicit =
#(define-music-function () ()
  (early:make-implicit-subdivision-setting '(0 . #t)))

%{
%       Explicit mensurations
% %}

mensuraExplicit =
#(define-music-function () ()
  (early:make-implicit-subdivision-setting 'none))

modusmaiorExplicit =
#(define-music-function () ()
  (early:make-implicit-subdivision-setting '(-3 . #f)))

modusExplicit =
#(define-music-function () ()
  (early:make-implicit-subdivision-setting '(-2 . #f)))

tempusExplicit =
#(define-music-function () ()
  (early:make-implicit-subdivision-setting '(-1 . #f)))

prolatioExplicit =
#(define-music-function () ()
  (early:make-implicit-subdivision-setting '(0 . #f)))

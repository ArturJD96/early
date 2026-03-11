\version "2.24.4"
\include "mensur-context.ily"

%{
%       Helpers.
% %}

#(define (subdivision subdivisions dur-log note-mensur)
  "When calculating the first level of note subdivision, take into
  account perfection, imperfection and alteration using note-mensur."
  (let ((implicit (assq-ref subdivisions dur-log)) ;; only for the top.
        (mod note-mensur)) ;; if anything is here, then note is perfect. BUT ONLY IN IMPERFECT METER.
                          ;; to do: perfect meter variant serving 'imperfect' in note-mensur.))
   (if (eq? (if implicit #t #f) (if (and mod (not (null? mod))) #t #f))
    2
    implicit)
))

#(define (mensur-factor subdivisions as-tuplet dur-log note-mensur)
  "Calculate how much mensuration changes the duration.
   Takes into account only the first-level subdivision."
  (if (assq-ref as-tuplet dur-log)
   1
   (/ (subdivision subdivisions dur-log note-mensur)
      2))
)

#(define (calc-note-mensur-factor note-durlog subdivisions as-tuplet note-mensur)
  (fold (lambda (subd prev)
         (let ((durlog (car subd))
               (value (cdr subd)))
          (* prev (if (> durlog note-durlog)
                   (mensur-factor subdivisions as-tuplet durlog #f)
                   1)))) ; ignore?
    (mensur-factor subdivisions as-tuplet note-durlog note-mensur)
    subdivisions)
)


%{
%       The proc of \mensural music context.
% %}

#(define-public (early:mensurate-event rhythmic-event mensur-context)
  "Append note-mensur properties, store old duration
   and modify duration according to the mensur-context."
  (let* ((dur (ly:music-property rhythmic-event 'duration))
         (is-rest (music-is-of-type? rhythmic-event 'rest-event))
         (note-mensur (ly:music-property rhythmic-event 'mensur))
         (dur-log (ly:duration-log dur))
         ;; Destruct mensur context.
         (mensur (mensur-context:mensur mensur-context))
         (settings (mensur-context:settings mensur-context))
         ;; From mensur
         (subdivisions (mensur:complex-subdivisions mensur))
         (proportio (mensur:proportio mensur))
         (as-tuplet (mensur-settings:as-tuplet settings))
         (implicit-subdivisions (mensur-settings:implicit-subdivisions settings)))

   ;; Set implicit subdivision (if relevant).
   (when (and (assq-ref subdivisions dur-log)
              (null? (ly:music-property rhythmic-event 'mensur)))
    (cond
     (is-rest
      (make-complex! rhythmic-event 'rest))
     ((not (assq-ref implicit-subdivisions dur-log))
      (make-complex! rhythmic-event 'implicit)))
   )

   (let ((mensur-factor (calc-note-mensur-factor dur-log subdivisions as-tuplet (ly:music-property rhythmic-event 'mensur))))

    ;; Store data.
    (ly:music-set-property! rhythmic-event 'early:duration-original dur)
    (ly:music-set-property! rhythmic-event 'early:mensur-factor mensur-factor)

    ;; Update duration.
    (ly:music-set-property! rhythmic-event 'duration (ly:duration-compress dur mensur-factor))

    rhythmic-event))
)


%{
%       Specific modifications to note.
%
%       NOTE: this are not made public yet, but if 'reasons' become
%             more formal, an API will be provided.
% %}

#(define (note-mensur-set! note note-mensur-type reason)
  ;; TO DO: add check for note.
  (ly:music-set-property! note 'mensur `(,note-mensur-type ,reason))
  note)

#(define (make-complex! note reason) ;; TO DO: 'reason': position, punctum perfectionis/divisionis etc.
  (note-mensur-set! note 'complex reason))
#(define (make-alter! note reason)
  (note-mensur-set! note 'alter reason))


%{
%
%   Note MENSUR
%   * perfected
%   * altered
%   * imperfected
%
% %}

perfect =
#(define-music-function (note reason) (ly:music? (symbol? 'undocumented)) ; TO DO: replace 'symbol?' with exact check of allowed values.
  (make-alter! note reason)
)

altera =
#(define-music-function (note reason) (ly:music? (symbol? 'position)) ; TO DO: replace 'symbol?' with exact check of allowed values.
  (make-alter! note reason)
)

%{
%
%   P U N C T U M
%   * augmentationis
%   * perfectionis
%   * divisionis
%   * alterationis
%
% %}

%% punctum augmentationis is expressed by a Lilypond's dot.

punctumPerfectionis =
#(define-music-function (note) (ly:music?)
  (make-complex! note 'punctum-perfectionis)
  note)

punctumDivisionis = {}

punctumAlterationis =
#(define-music-function (note1 note2 note3) (ly:music?)
  (make-alter! note1 'punctum-alterationis)
  #{ #note1 #note2 #note3 #})

% punctum = ... – this function will stand for an ambigious punctum in a music that has once imperfect and once complex mensuration.
% #(define-music-function (note1 note2 note3) (ly:music?)


%{
%   Aliases.
% %}

%% Mensuration.
perf = perfect
alt = altera

%% Dots.
pperf = punctumPerfectionis
pdiv = punctumDivisionis
palt = punctumAlterationis

\version "2.24.3"

\include "music-definitions.ily"
\include "mensuration.ily"

#(define (early:get-default-mensura-properties)
    ;; default public properties
  '((blackmensural . #f)
    (color . white)
    (hollow . #f)
    (default-ternary . #f)
    (proportio . #f)
    (perfection . ()) ; e.g. (-3 . (#t . #t)) – maximodus perfectum (interpreted as triplet)
))


#(define (early:handle-color-minor music mensura-properties)
  (let* (;; note moment's main fractions
         (note '())
         (first-note '())
         (remaining (ly:moment-main (ly:music-length music)))
         (total remaining)
         ;; ratio of the first note and the remaining moment duration.
         (first-note-dur-correction '())
         (remaining-dur-correction '())
         (perfection-setting '())
        )
   (music-map
    (lambda (m)
     (cond
      ;; ignore nested color-minor expressions
      ((and (music-is-of-type? m 'sequenctial-event)
            (early:music-property m 'color-minor))
       (early:handle-color-minor music mensura-properties))
      ;; looping only through the notes etc
      ((music-is-of-type? m 'rhythmic-event)
       (set! note (ly:moment-main (ly:music-duration-length m)))
       ;; get first note moment and duration correction
       (if (null? first-note)
        (begin
         (set! remaining (- remaining note))
         (set! first-note note)
         (set! first-note-dur-correction
               (case (/ remaining first-note)
                ((1/2) 3/4) ; eg longa brevis
                ((1/4) 7/8) ; eg longa semibrevis
                (else (ly:error "Unsupported durations of notes"))))
         (set! remaining-dur-correction (- 1 first-note-dur-correction))
         ;; check if we can we do color minor anyway.
         (set! perfection-setting
               (assoc-ref (assoc-ref mensura-properties 'perfection)
                          (ly:duration-log (ly:music-property m 'duration))))
         (when (and perfection-setting (car perfection-setting))
          (ly:error "Cannot do color minor when division is perfect"))
         (early:music-set-property! m 'color-minor
          first-note-dur-correction)
        )
        (begin
         (early:music-set-property! m 'color-minor
          (* remaining-dur-correction
             (/ note remaining)
             (/ first-note note)))
        )
       )
       ;; for all the notes in color minor:
       (ly:music-set-property! m 'duration
        (ly:duration-compress (ly:music-property m 'duration)
                              (early:music-property m 'color-minor)))
     ))
     m)
    music)))


#(define (early:duration-mensurate dur mensura-properties)
  (let* ((props mensura-properties)
         (props:get (lambda (key) (assoc-ref props key)))
         (props:is  (lambda (k v) (eq? (props:get k) v)))

         (dur-log (ly:duration-log dur))
         (perfection (props:get 'perfection))
         (proportion (props:get 'proportio))
         (default-ternary (props:get 'default-ternary))

         (punctum-perfectionis (props:get 'punctum-perfectionis))

         (compress-factor (if (fraction? proportion)
                           proportion
                           (/ 1 proportion)))

         ;(color-allows-perfection ; for checking
         ; (props:is 'color
         ;           (if (props:get 'blackmensural) 'black 'white)))

        )

    ;; gather together all compress factors.
    (for-each
     (lambda (setting)
      (let* ((dlog (car setting))
             (ternary (and (cadr setting) default-ternary))
             (triplet (cddr setting))
             (mod (cond
                   ((< dlog dur-log) 1)
                   ((and ternary (not triplet)) 3/2)
                   ((and (not ternary) triplet) 2/3)
                   (else 1))))
       (set! compress-factor (* compress-factor mod))))
      perfection)

    (ly:duration-compress dur compress-factor)

  ))

% tactus =
% #(define-music-function (beat-structure fraction)
%                         ((number-list? '()) fraction?)
%   (make-music 'TimeSignatureMusic
%               'numerator (car fraction)
%               'denominator (cdr fraction)
%               'beat-structure beat-structure))

#(define (mensuration alist)
  (make-music
    'early:MensuraEvent
    'mensura-properties
    alist))

mensura =
#(define-music-function (signum) (number-or-string?)
  (let* ((mensuration-properties (assoc-ref all-mensurations signum))
         (time-signature-dummy (assoc-ref mensuration-properties 'time-signature-dummy)))
    (unless mensuration-properties
    (ly:error "Unrecognized signum of mensuration. You can define your own mensuration using add-mensuration procedure."))
    #{
        #(mensuration mensuration-properties)
        \time #time-signature-dummy
    #}))

tempus =
#(define-music-function (perfection) (boolean-or-symbol?)
(let* ((perf (cond
                ((eq? perfection 'perfectum) #t)
                ((eq? perfection 'perfect) #t)
                ((eq? perfection 'imperfectum) #f)
                ((eq? perfection 'imperfect) #f)
                ((boolean? perfection) perfection)
                (else
                 (ly:error "Incorrect perfection. Can be: perfect, perfectum, imperfect, imperfectum or boolean.")
                ))))
    #{
        #(mensuration (list (cons -1 perf)))
    #}))

prolatio =
#(define-music-function (prolation) (boolean-or-symbol?)
(let* ((symb (symbol? prolation))
        (prol (cond
                ((eq? prolation 'maior) #t)
                ((eq? prolation 'major) #t)
                ((eq? prolation 'minor) #f)
                ((boolean? prolation) prolation)
                (else
                 (ly:error "Incorrect prolation. Can be: maior, major, minor or boolean.")
                ))))
    #{
        #(mensuration (list (cons 0 prol)))
    #}))

proportio =
#(define-music-function (proportion) (number-or-pair?) #{
    % THIS IS NOW BROKEN
    % 'proportio' doesn't get registered in the mensura property of the context.
    #(mensuration (list (cons 'proportio proportion)))
    \once \override TimeSignature.style = #'single-digit
#})


% Main function
mensural =
#(define-music-function (music) (ly:music?)
    ;; BUG: Parsing...ice-9/eval.scm:159:9: In procedure /: Wrong type argument in position 2: #f
    ;;      This occurs when defining: voice = \relative \mensural { a } TWICE !!!
  (let* ((mensura-properties (early:get-default-mensura-properties))
         (props:get (lambda (key) (assoc-ref mensura-properties key)))
         (props:set! (lambda (k v)
                      (set! mensura-properties
                            (assoc-set! mensura-properties k v))))
         (debug #f))

   (music-map
    (lambda (m)
     (cond
      ;; handle all mensuration changes
      ((music-is-of-type? m 'early:mensura-event)
       (let* ((props-new (ly:music-property m 'mensura-properties)))
        (for-each (lambda (prop)
                   (let ((key (car prop))
                         (val (cdr prop)))
                    ;; TO DO: add
                    (if (number? key)
                     (let* ((perfection (props:get 'perfection))
                            (settings (assoc-ref perfection key))
                            (triplet (and (null? settings) (cdr settings))))
                      (props:set! 'perfection
                       (assoc-set! (props:get 'perfection) key
                        (cons val triplet))))
                     (props:set! key val))))
         props-new)
        m))
      ;; handle color minor apart
      ((and (music-is-of-type? m 'sequential-music)
            (early:music-property m 'color-minor))
       (early:handle-color-minor m mensura-properties))
      ;; adjust duration
      ((music-is-of-type? m 'rhythmic-event)
       (ly:music-set-property! m 'early:mensura-properties (alist-copy mensura-properties))
       (ly:music-set-property! m 'duration
       (early:duration-mensurate (ly:music-property m 'duration) mensura-properties))
       m)

     (else m)))
    music)))

% relative-mensural =
% #(define-music-function
% \relative \mensural

#(define (early:make-duration len dots den num)
  (ly:make-duration len dots num den))


flexa = \once \override NoteHead.ligature-flexa = ##t
% only in v. 2.25
virga = \once \override NoteHead.right-down-stem = ##t
virgaUp = \once \override NoteHead.right-up-stem = ##t


perfect =
#(define-music-function () ()
  (make-music
   'early:MensuraEvent
   'mensura-properties
   '((default-ternary . #t))))


imperfect =
#(define-music-function () ()
    (make-music
    'early:MensuraEvent
    'mensura-properties
    '((default-ternary . #f))))


#(define (pair->fraction pair)
  (/ (car pair) (cdr pair)))

#(define (add-punctum note)
  (let* ((dur (ly:music-property note 'duration))
         (dur-log (ly:duration-log dur))
         (dot-count (ly:duration-dot-count dur))
         (dur-factor (pair->fraction (ly:duration-factor dur))))
   (unless (= 0 dot-count)
    (ly:warning "Note with punctum should not have an explicit dot."))
   (ly:music-set-property! note 'duration
    (ly:duration-compress
     (ly:make-duration dur-log 1 dur-factor)
     2/3))
   note
))

pdiv =
#(define-music-function (note) (ly:music?)
  (early:music-set-property! note 'punctum-divisionis #t)
  (add-punctum note)
)


pperf =
#(define-music-function (note) (ly:music?)
  (early:music-set-property! note 'punctum-perfectionis #t)
  (add-punctum note)
)


colorMinor =
#(define-music-function (music-sequence) (ly:music?)
  ;; setting color-minor to true already on sequence level
  ;; because the 'mensural' function will take care of it separately.
  (early:music-set-property! music-sequence 'color-minor #t)
  #{
    \set EarlyVoice.earlyColor = #'black % TO DO: use the default color used for imperfectum.
    #music-sequence
  #})


planus = \mensura "X"

hollow = % better use context?
#(define-music-function (note) (ly:music?)
  (early:music-set-property! note 'hollow #t)
  note)

% maxima = #(ly:make-duration -3 0 1/1)

  % (ly:music-set-property! music 'elements
  %  (append
  %   (list (make-music 'early:ColorMinorStart))
  %   (ly:music-property music 'elements)
  %   (list (make-music 'early:ColorMinorEnd))))
  % music)

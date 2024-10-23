\version "2.24.3"

% #(set-object-property! 'early-music-properties 'music-type? alist?)

#(define (define-event! type properties)
   (set-object-property! type
                         'music-description
                         (cdr (assq 'description properties)))
   (set! properties (assoc-set! properties 'name type))
   (set! properties (assq-remove! properties 'description))
   (hashq-set! music-name-to-property-table type properties)
   (set! music-descriptions
         (sort (cons (cons type properties)
                     music-descriptions)
               alist<?)))

#(define-event-class 'early-event 'music-event)
#(define-event-class 'early:mensura-event 'early-event)
#(define-event-class 'early:color-minor-sequence 'early-event)

#(define-event!
  'early:MensuraEvent
  '((description . "Used to modify current early:mensura-properties")
    (types . (early:mensura-event time-signature-event))))

% #(define-event!
%     'early:ColorMinorStart
%     '((description . "Signaling start of color event context")
%     (types . (early:color-minor-start))))

% #(define-event!
%     'early:ColorMinorEnd
%     '((description . "Signaling end of color event context")
%     (types . (early:color-minor-end))))

#(define (early:duration->name dur)
  (case (ly:duration-log dur)
   ((-3) 'maxima)
   ((-2) 'longa)
   ((-1) 'brevis)
   ((0) 'semibrevis)
   ((1) 'minima)
   ((2) 'semiminima)
   ((3) 'fusa)
   ((4) 'semifusa)))

#(define (early:music-property music early-property)
  (let ((props (ly:music-property music 'early:music-properties)))
   (if props
    (assoc-ref props early-property)
    #f)))

#(define (early:music-set-property! music early-property value)
  (let ((props (ly:music-property music 'early:music-properties)))
   (ly:music-set-property! music 'early:music-properties
    (if props
     (assoc-set! props early-property value)
     (list (cons early-property value))))
   music))

#(define (early:mensura-properties)
    ;; default public properties
  '((blackmensural . #f)
    (color . white)
    (hollow . #f)
    (default-ternary . #f)
    (proportio . #f)
    (perfection . ()) ; e.g. (-2 . (#t . #f)) – maximodus perfectum (interpreted as triplet)
))

% #(alist-deep-copy ;; LIST SHOULD BE COPIED!
#(define-public early:ars-subtilior (early:mensura-properties))

mensuration =
#(define-music-function (alist) (alist?)
  (make-music
   'early:MensuraEvent
   'mensura-properties
   alist))

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
        \mensuration #(list (cons -1 perf))
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
        \mensuration #(list (cons 0 prol))
   #}))

proportio =
#(define-music-function (proportion) (number-or-pair?) #{
    \mensuration #(list (cons 'proportio proportion))
    \once \override TimeSignature.style = #'single-digit
#})

#(define (string-or-numeric? arg)
  (or (number-or-string? arg)
      (pair? arg)))

mensura =
#(define-music-function (signum) (string-or-numeric?)
  ;; make it better (use regexp)
  (cond
   ((equal? signum "O") #{
    \tempus #'perfectum
    \prolatio #'minor
    \proportio 1
    \time 3/2
   #})
   ((equal? signum "O.") #{
    \tempus #'perfectum
    \prolatio #'maior
    \proportio 1
    \time 9/4
   #})
   ((equal? signum "C|") #{
    \tempus #'imperfectum
    \prolatio #'minor
    \proportio 2
    \time 2/2
   #})
   (else #{
    \proportio #signum
   #})))


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
         (dur-name (early:duration->name dur))
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

mensural =
#(define-music-function (mensura-properties music) (alist? ly:music?)
  (let* ((props:get (lambda (key) (assoc-ref mensura-properties key)))
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

colorMinor =
#(define-music-function (n1 n2) (ly:music? ly:music?)
  ;; THIS IS OVERRIDEN BELOW
  ;; flags: – long-note-encountered
  ;; - short-note-encountered
  (let* ((dur1 (ly:music-property n1 'duration))
         (dur2 (ly:music-property n2 'duration))
         (log1 (ly:duration-log dur1))
         (log2 (ly:duration-log dur2))
         (len1 (duration-length dur1))
         (len2 (duration-length dur2))
         (dot1 (ly:duration-dot-count dur1))
         (dot2 (ly:duration-dot-count dur2))
         (com1 (ly:duration-scale dur1))
         (com2 (ly:duration-scale dur2)))
   (unless (= (/ len1 len2) 2)
    (error "Wrong durations of notes interpreted as color minor (must be 1/2 ratio).\n"))
   (ly:music-set-property! n1 'duration
    (ly:make-duration log1 dot1 (* 3/4 com1)))
   (ly:music-set-property! n2 'duration
    (ly:make-duration log2 dot2 (* 1/2 com2)))
   ;; return
   #{
        \once \set earlyColor = #'black
        #n1
        \once \set earlyColor = #'black
        #n2
   #}))

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

  % (ly:music-set-property! music 'elements
  %  (append
  %   (list (make-music 'early:ColorMinorStart))
  %   (ly:music-property music 'elements)
  %   (list (make-music 'early:ColorMinorEnd))))
  % music)

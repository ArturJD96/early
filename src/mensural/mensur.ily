\version "2.24.4"
\include "./../definitions/events.ily" % TO DO: de-centralize and define early:MensurSetting and MensurEvent here?
\include "./../testing.ily"

\include "./init-mensur-events.ily"
\include "./mensur-context-event.ily"
\include "./mensur-mensura-event.ily"
\include "./mensur-quality-event.ily"
\include "./mensur-punctum-event.ily"


%{
%       🌺 M E N S U R .ily 🌺
%        *   part of early  *
%
%       This file contains definition of `mensur`,
%       a scheme record object providing mensuration
%       context for music insde `\mensural`.
%
%       Based on this mensuration context,
%       `\mensural` can adjust note durations.
% %}


%{
%       PUBLIC INTERFACE
%       Access and set mensur subrecords from the level of mensur itself.
%       This is the public interface of the `mensur-context` record.
% %}

#(define-public (mensur:subdivisions context)
  (ly:music-property context 'subdivisions))
#(define-public (mensur:subdivisions! context subdivisions) ;; TO DO: typing.
  (ly:music-set-property! context 'subdivisions subdivisions))

#(define-public (mensur:proportio context)
  (ly:music-property context 'proportio))
#(define-public (mensur:proportio! context proportio)
  (ly:music-set-property! context 'proportio proportio))

#(define-public (mensur:settings context)
  (ly:music-property context 'settings))
#(define-public (mensur:settings! context settings)
  (ly:music-set-property! context 'settings settings))

#(define-public (mensur:subdivision context dur-log)
  (or (assq-ref (mensur:subdivisions context) dur-log) 2)) % TO DO: make default value explicit: 2.
#(define-public (mensur:subdivision! context dur-log subdivision) ; TO DO: typecheck.
  (mensur:subdivisions! context
   (assq-set! (mensur:subdivisions context) dur-log subdivision)))

#(define-public (mensur:setting context dur-log)
  (or (assq-ref (mensur:settings context) dur-log) '())) % TO DO: make default value explicit: '().
#(define-public (mensur:setting! context dur-log setting) ; TO DO: typecheck: (music-is-type-of m 'MensurSettingEvent)
  (mensur:settings! context
   (assq-set! (mensur:settings context) dur-log setting)))

#(define-public (mensur:implicit context dur-log)
  (or (assq-ref (mensur:setting context dur-log) 'implicit) #f)) % ;; TO DO: make default value explicit: #f.
#(define-public (mensur:implicit! context dur-log bool)
  (mensur:setting! context dur-log
   (let ((setting (mensur:setting context dur-log)))
    (unless setting (set! setting (mensur:make-default-setting)))
    (assq-set! setting 'implicit bool))))

#(define-public (mensur:as-tuplet context dur-log)
  (or (assq-ref (mensur:setting context dur-log) 'as-tuplet) #f)) % ;; TO DO: make default value explicit: #f.
#(define-public (mensur:as-tuplet! context dur-log bool)
  (mensur:setting! context dur-log
   (let ((setting (mensur:setting context dur-log)))
    (unless setting (set! setting (mensur:make-default-setting)))
    (assq-set! setting 'as-tuplet bool))))

#(testing "Context-level subrecord setters."
  (define c (mensur:default))
  (define (set-get field durlog-or-symbol value)
   (let* ((env (interaction-environment))
          (field-setter (eval (symbol-append 'mensur: field '!) env))
          (field-getter (eval (symbol-append 'mensur: field) env)))
    (field-setter c durlog-or-symbol value)
    (field-getter c durlog-or-symbol)
  ))
  (test-group "Empty context fields return default values."
   (test-equal "Field: subdivision." 2 (mensur:subdivision c -1))
   (test-equal "Field: implicit." #f (mensur:implicit c -1))
   (test-equal "Field: as-tuplet." #f (mensur:as-tuplet c -1))
  )
  (test-group "Setting and getting."
   (test-equal "Field: subdivision (existing)." 3 (set-get 'subdivision -2 3))
   (test-equal "Field: implicit (in existing)." #t (set-get 'implicit -1 #t))
   (test-equal "Field: implicit (in new)." #t (set-get 'implicit 0 #t))
   (test-equal "Field: as-tuplet." #t (set-get 'as-tuplet 1 #t))
  )
  ;; Note: from now on, context `c` has some properties set.
  (test-group "Empty subrecord fields return default values."
   (test-equal "Field: subdivision (existing)." 2 (mensur:subdivision c 0))
   (test-equal "Field: implicit (in existing)." #f (mensur:implicit c 1))
   (test-equal "Field: as-tuplet." #f (mensur:as-tuplet c -1))
  )
  ; (test-group "Error handling."
   ; (test-error "Catch: wrong dur-log type." #t (set-get 'subdivision 'wrong-type 4))
   ; (test-error "Catch: wrong subdivision type." #t (set-get 'subdivision -1 'wrong-type))
   ; (test-error "Catch: wrong implicit type." #t (set-get 'subdivision -1 'wrong-type))
   ; (test-error "Catch: wrong as-tuplet type." #t (set-get 'subdivision -1 'wrong-type))
  ; )
)


#(define-public (mensur:update! context mensur-setting-event)
  "Modify mensur-context applying to its settings from MensurSetting event."
  (for-each
   (lambda (prop)
    (let* ((field (car prop))
           (set-field (eval (symbol-append 'mensur: field '!) (interaction-environment)))
           (new-val (cdr prop)))
     (cond
      ((null? new-val) '())
      ((alist? new-val)
       (for-each (lambda (pair) (set-field context (car pair) (cdr pair))) new-val))
      ((pair? new-val)
       (set-field context (car new-val) (cdr new-val)))
      (else
       (set-field context new-val)))))
   (map (lambda (setting)
         (cons setting (ly:music-property mensur-setting-event setting)))
    early:available-mensur-settings))
)


#(testing "Context update."

  ;; Preparing variables. Mensur-context `c` is going to be modified.
  (define c (mensur:default))

  (define values1 '((subdivision . ((-1 . 3)
                                    (0 . 3)))
                    (implicit .    ((0 . #t)))))

  (mensur:update! c (make-music 'MensurContextSetting values1))
  (test-group "Pushing to fresh mensur-context."
   (test-equal "Added fresh to mensur-relationship." 3 (mensur:subdivision c -1))
   (test-equal "Added fresh to mensur-setting." 3 (mensur:subdivision c 0))
   (test-equal "Added fresh to mensur-setting." #t (mensur:implicit c 0))
  )

  (define values2 '((subdivision . ((-2 . 5)     ;; Adding new subdivision.
                                    (0 . 5)))    ;; Overridin old subdivision.
                    (implicit .    ((-2 . #t)    ;; Adding new subdivision.
                                    (0 . #f)))   ;; Removing old subdivision.
                    (proportio .   2/3)))    ;; adding proportion.

  (mensur:update! c (make-music 'MensurContextSetting values2))
  (test-group "Modifying filled mensur-context."
   (test-equal "Added fresh to mensur-relationship." 5 (mensur:subdivision c -2))
   (test-equal "Not overriding old mensur-relationship." 3 (mensur:subdivision c -1))
   (test-equal "Overriding mensur-relationship" 5 (mensur:subdivision c 0))
   (test-equal "Adding fresh to mensur-setting." #t (mensur:implicit c -2))
   (test-equal "Overriding mensur-setting." #f (mensur:implicit c 0))
   (test-equal "Overriding mensur-context field." 2/3 (mensur:proportio c))
  )

  (mensur:update! c (make-music 'MensurContextSetting 'implicit '(1 . #t)))
  (test-equal "Updating works with pairs." #t (mensur:implicit c 1))

)



#(define-public (mensur:complex? context rhythmic-event)
  "Is duration of `rhythmic-event` complex?"
  (let* ((quality (ly:music-property rhythmic-event 'mensur:quality))
         (explicit (and (not (null? quality)) (quality:type quality)))
         (dur-log (ly:duration-log (ly:music-property rhythmic-event 'duration)))
         (subdivision (mensur:subdivision context dur-log))
        )
   ;; Duration is complex if
   (or (eq? explicit 'complex) ;; it is complex explicitly or implicitly:
       (and (not (= subdivision 2))        ;; – it's dur-log has complex subdivision (that is not 2)
            (not (eq? explicit 'simple)))) ;; – it is not simple...
))

% THIS BECOMES LEGACY SOON and needs refactor
#(define-public (mensur:factor context rhythmic-event)

  (let* ((quality (ly:music-property rhythmic-event 'mensur:quality))
         (reason (quality:reason quality))
         (dur-log (ly:duration-log (ly:music-property rhythmic-event 'duration))))

   (define (complex-factor context durlog)
    (let ((subdivision (mensur:subdivision context durlog))
          (as-tuplet (mensur:as-tuplet context durlog)))
     (if as-tuplet 1 (/ subdivision 2))))

   (define (accum-factor subdivision prev)
    (let ((durlog (car subdivision)))
     (* prev (if (> durlog dur-log)
              (complex-factor context durlog)
              1))))

   (cond
    ((null? quality) 1)
    ((eq? reason 'punctum-perfectionis) 1)
    (else
     (let* ((quality-type (quality:type quality))
            (subdivisions (mensur:subdivisions context))
            (is-complex (mensur:complex? context rhythmic-event))
            (init-factor (if is-complex (complex-factor context dur-log) 1))
            (factor (fold accum-factor init-factor subdivisions))
           )
      (case quality-type ;; TO DO: move it to definitiions.
       ((simple) factor)
       ((complex) factor)
       ((altera) (* 2 factor))
       ((partial)
        (let ((fraction (quality:fraction quality)))
         (/ (* factor (car fraction)) (cdr fraction))))
       (else (ly:error "Unimplemented mensur quality: \"~a\"" quality)))

)))))



#(define-public (mensur:mensurate! rhythmic-event context)

  (punctum:supply! rhythmic-event context)

  punctum:supply
  – (punctum:assume subdivision)
  – add assumed point

  (let ((punctum (early:punctum rhythmic-event))
        (quality (early:quality rhythmic-event)))

   (when (and quality (quality:valid? quality rhythmic-event context))
    (mensur:quality! rhythmic-event
     (mensur:make-quality (quality:type quality) (quality:reason quality))))

   (unless punctum
    (set! punctum
     (punctum:assume! rhythmic-event context)))

   (when (and punctum
              (punctum:valid? punctum rhythmic-event context)
              (eq? (punctum:type 'perfectionis)))
    (if (mensur:quality rhythmic-event)
     (mensur:reason! rhythmic-event 'punctum-perfectionis)
     (mensur:quality! rhythmic-event
      (mensur:make-quality 'complex 'punctum-perfectionis))))
  )

  (mensur:factor! (mensur:calc-factor context rhythmic-event))

  ; TO DO: move to definition.
  (ly:music-set-property! rhythmic-event 'mensur:duration
   `((declared . ,(ly:music-property rhythmic-event 'duration) ; TO DO: clone it.
     (cmn . ,(* (ly:music-property rhythmic-event 'duration) factor)) ; include dots etc.
     (early . ,(* (ly:music-property rhythmic-event 'duration) factor)))))

  ; TO DO: use 'cmn or 'early depending on tags set?
  ; E.g.: "let user render mensural notation as cmn".
  (ly:music-set-property! rhythmic-event 'duration
   (assq-ref ' (ly:music-property rhythmic-event 'mensur:duration) 'early))

)


% THIS BECOMES LEGACY SOON
#(define-public (mensur:mensurate-event! context rhythmic-event)

  (let* ((dur (ly:music-property rhythmic-event 'duration))
         (dur-log (ly:duration-log dur))
         (dots (ly:duration-dot-count dur))
         (quality (early:quality rhythmic-event))
         (punctum (early:punctum rhythmic-event))
         (subdivision (or (mensur:subdivision context dur-log) 2))
         (subdivision-parent (or (mensur:subdivision context (1- dur-log)) 2))
         (implicit (mensur:implicit context dur-log))
        )

   ; Some features are only for complex, some for simple.
   ; Maybe filter those features first and only then compare?
   ;; If dot is present but punctum is absent,
   ;; assume punctum augmentationis or perfectionis.
   ; TO DO: move to punctum:assume
   (unless (early:punctum rhythmic-event)
    (when (> dots 0)
     (set! punctum (punctum:append! (punctum:assume subdivision) rhythmic-event))
    ))


   ;; Validate if note has correct punctum.
   (when (early:punctum rhythmic-event)
    (punctum:validate (early:punctum rhythmic-event) context dots subdivision))

   ;; Update quality based on the ComplexityEvent.
   ;; They are ignored if mensura is simple. But:
   ;; – altera is a different and uses parent's subdivision in check
   ;; – complexity and punctum perfectionis do not stack.
   (when quality
    (let ((type (quality:type quality)))
     (cond
      ((and (eq? type 'altera)
            (not (= subdivision-parent 2)))
       (mensur:music-set-quality! rhythmic-event quality))
      ((and (eq? (punctum:type punctum) 'perfectionis)
            (eq? type 'partial))
       (error "Cannot stack together puncumt perfectionis and partial imperfection."))
      ((and (not (eq? (punctum:type punctum) 'perfectionis))
            (not (= subdivision 2)))
       (mensur:music-set-quality! rhythmic-event quality)))))

   ;; If mensuration is complex
   ;; but quality is not given,
   ;; supplement it.
   (when (null? (ly:music-property rhythmic-event 'mensur:quality))
    (cond
     ((= subdivision 2)
      (mensur:make-simple! rhythmic-event 'simple-mensur)) ;; Isn't this redundant?
     ((music-is-of-type? rhythmic-event 'rest-event)
      (mensur:make-complex! rhythmic-event 'rest))
     ((eq? (punctum:type punctum) 'perfectionis)
      (mensur:make-complex! rhythmic-event 'punctum-perfectionis))
     (implicit ;; HACK: if symbol 'all is returned, it evaluates always to #t.
      ; TO DO: check it twice...
      (mensur:make-complex! rhythmic-event 'position))
     (else
      (mensur:make-simple! rhythmic-event 'position))))


   ;; TO DO: supply reason for 'undocumented
   ;; (e.g. similis-ante-similem if the case.)
   ;; Calculate, store and apply factor.
   (let ((factor (mensur:factor context rhythmic-event)))
    ;; Store data.
    (ly:music-set-property! rhythmic-event 'mensur:factor factor)
    (ly:music-set-property! rhythmic-event 'mensur:duration-original dur)
    ;; Take care of dot.
    ; (if (ly:duration-dot-count dur)
    ;; UPDATE duration!
    (ly:music-set-property! rhythmic-event 'duration (ly:duration-compress dur factor))
    ;; Return updated value.
    rhythmic-event
   )

))


#(testing "Mensurate"
  ;; More detailed tests in `mensural.test.ly` file.
  (define c (mensur:default))
  (mensur:update! c (make-music 'MensurContextSetting 'subdivision '((-1 . 3)(0 . 3)(1 . 3)) 'implicit '((-1 . #t)(0 . #f)(1 . #f))))
  (define (event-of-dur event-name dur)
   (make-music event-name 'duration (ly:make-duration dur 0)))
  (define (event-length event-name dur)
   (duration-length
    (ly:music-property
     (mensur:mensurate-event! c
      (event-of-dur event-name dur))
     'duration)))
  (test-equal "Rest (implicit)." 27/4 (event-length 'RestEvent -1))
  (test-equal "Rest (by default)." 9/4 (event-length 'RestEvent 0))
  (test-equal "Note (simple)." 1/2 (event-length 'NoteEvent 1))
  (test-equal "Note (implicitly simple)." 3/2 (event-length 'NoteEvent 0))
  (test-equal "Note (implicitly complex)." 27/4 (event-length 'NoteEvent -1))
  (mensur:subdivisions! c '((1 . 3)))
  (test-equal "Note (simple itself but with complex subdivisions below." 3/2 (event-length 'NoteEvent 0))
)

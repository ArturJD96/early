\version "2.24.4"
\include "./../definitions/events.ily" % TO DO: de-centralize and define early:MensurSetting and MensurEvent here?
\include "./../testing.ily"
#(use-modules (srfi srfi-9))

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

%% Relationship – mensural-related data of the context.
#(define-record-type <mensur:relationship>
  (mensur:relationship subdivision) ;; integer
  mensur:relationship?
  (subdivision  %mensur-relationship:subdivision  %mensur-relationship:subdivision!))

#(define (%mensur-relationship:default) (mensur:relationship 2))

%% Setting – internal Early mensuration interface settings.
#(define-record-type <mensur:setting>
  (mensur:setting implicit   ;; boolean or symbol ('all)
                  as-tuplet) ;; boolean
   mensur:setting?
   (implicit   %mensur-setting:implicit   %mensur-setting:implicit!)
   (as-tuplet  %mensur-setting:as-tuplet  %mensur-setting:as-tuplet!))

#(define (%mensur-setting:default) (mensur:setting #f #f))

%% Context – all information needed for note mensuration (i.e. duration recalculation).
#(define-record-type <mensur:context>
  (mensur:context
   relationships ;; alist (dur-log . mensur:relationship)
   settings      ;; alist (dur-log . mensur:settings)
   proportio)    ;; number
  mensur:context?
  (relationships  %mensur-context:relationships  %mensur-context:relationships!)
  (settings       %mensur-context:settings       %mensur-context:settings!)
  (proportio      %mensur-context:proportio      %mensur-context:proportio!))

#(define (%mensur-context:default) (mensur:context '() '() 1))

%% Event-quality – additional mensural modification of event itself.
#(define-record-type <mensur:event-quality>
  (mensur:event-quality
   quality  ;; symbol
   reason)  ;; symbol
  mensur:event-quality?
  (quality %mensur-event-quality:quality)
  (reason  %mensur-event-quality:reason))

% TO DO: consult a good source on definitions of those terms.
#(define mensur:quality-reasons `(
  ;; Usual case.
  (simple-mensur .
   ((description . "Mensura is duplex so complex mensuration does not apply")
    (event . rhythmic-event)
    (qualities . (simple))))
  ;; Reasons for complex.
  (rest .
   ((description . "Rest in mensural music is compulsory complex in complex meters.")
    (event . rest-event)
    (qualities . (complex))))
  (position .
   ((description . "Note mensuration is deduced from position.")
    (event . note-event)
    (qualities . (simple complex partial altera))))
  (punctum-perfectionis .
   ((descritpion . "In complex mensura, note is complex (perfect) because it followed by an immediate dot.")
    (event . note-event)
    (qualities . (complex))))
  ;; For documentation purposes.
  (undocumented .
   ((description . "The reason for mensuration is not explicitly provided")
    (event . rhythmic-event)
    (qualities . (complex simple partial altera))))
  (exception .
   ((description . "A note defies mensural rules")
    (event . rhythmic-event)
    (qualities . (complex simple partial altera))))

))

%{
%       All the fields above need to be registered in mensur:fields
%       to make the helper functions and type checking work.
% %}

#(define %mensur:fields `(
  (subdivision .
   ((description . "How many durations of durlog `d` has a duration of durlog `d-1`.")
    (owner . relationship)
    (default . 2)
    (type . ,positive?)))
  (implicit .
   ((description . "Does a note with duration needs to be explicitly marked as e.g. perfect to subdivide as in subdivision.")
    (owner . setting)
    (default  . #f)
    (type . ,boolean?)))
  (as-tuplet .
   ((description . "Does the subdivision of a note is treated as a tuplet (e.g. perfect notes divide into triols). This can be used in an old-school medieval music modern transcriptions.")
    (owner . setting)
    (default  . #f)
    (type . ,boolean?)))
  (settings .
   ((description . "Mensural settings for Early-specific options.")
    (owner . context)
    (default . '())
    (type . ,(lambda (s) (or (boolean? s) (eq? s 'all))) )))
  (proportio .
   ((description . "Mensural \"proportio\".")
    (owner . context)
    (default . 1)
    (type . ,fraction?)))
))

#(define (%mensur:field-data field-name data-name)
  "Access nested %mensur:fields data."
  (let* ((field (assq-ref %mensur:fields field-name))
         (data (assq-ref (or field '()) data-name))
         (type (assq-ref (or field '()) 'type)))
   (unless field (ly:error "Wrong mensur field name: \"~a\"." field-name))
   (unless (eq? type boolean?)
    (unless data (ly:error "Wrong data name: \"~a\"." data-name)))
   data))

%{
%       For convenience, let us access all the inner
%       mensur:context alist records accessors and setters
%       from the level of top object (mensur-context)...
% %}

#(define (guard-durlog dur-log)
  (unless (integer? dur-log) (ly:error "Wrong type of dur-log. Must be an integer, but is ~a." dur-log))
  dur-log)


#(define (%mensur:proc-name field-name setter?)
  "Lookup to which mensur subrecord a field belongs to."
  (let ((sym (symbol-append '%mensur-
                            (%mensur:field-data field-name 'owner)
                            ':
                            field-name)))
   (if setter?
    (symbol-append sym '!)
    sym)))


#(define (%mensur:make-subrecord-setter field-name . symbols-if-not-alist)

  (let* ((env (interaction-environment))
         (alist-field-name (%mensur:field-data field-name 'owner))
         (default-constructor (eval (symbol-append '%mensur- alist-field-name ':default) env))
         (type-guard (%mensur:field-data field-name 'type))
         (alist-proc-name (symbol-append '%mensur-context: alist-field-name 's))
         (alist-getter (eval alist-proc-name env))
         (alist-setter (eval (symbol-append alist-proc-name '!) env))
         (field-setter (eval (%mensur:proc-name field-name #t) env)))

   (lambda (context dur-log value)
    (type-guard value)
    (let* ((alist (alist-getter context))
           (subrecord (assq-ref alist dur-log)))
     (unless subrecord (set! subrecord (default-constructor)))
     ;; Modify targeted subrecord.
     (field-setter subrecord value)
     ;; Put this subrecord to alist (again).
     ;; and re-attach alist to context.
     (alist-setter context (assq-set! alist dur-log subrecord))
     ;; Return original context.
     context))

))


#(define (%mensur:make-subrecord-getter field-name)

  (let* ((env (interaction-environment))
         (alist-field-name (%mensur:field-data field-name 'owner))
         (alist-proc-name (symbol-append '%mensur-context: alist-field-name 's))
         (alist-getter (eval alist-proc-name env))
         (field-getter (eval (%mensur:proc-name field-name #f) env))
         (field-default (%mensur:field-data field-name 'default)))

   ;; mensur:field getter.
   (lambda (context dur-log)
    (guard-durlog dur-log)
    (let* ((alist-or-symbol (alist-getter context))
           (subrecord (assq-ref alist-or-symbol dur-log)))
     (if subrecord
         (field-getter subrecord)
         field-default)))

))

%{
%       PUBLIC INTERFACE
%       Access and set mensur subrecords from the level of mensur itself.
%       This is the public interface of the `mensur-context` record.
% %}

#(define-public mensur:subdivision (%mensur:make-subrecord-getter 'subdivision))
#(define-public mensur:subdivision! (%mensur:make-subrecord-setter 'subdivision))

#(define-public mensur:implicit (%mensur:make-subrecord-getter 'implicit))
#(define-public mensur:implicit! (%mensur:make-subrecord-setter 'implicit))

#(define-public mensur:as-tuplet (%mensur:make-subrecord-getter 'as-tuplet))
#(define-public mensur:as-tuplet! (%mensur:make-subrecord-setter 'as-tuplet))

%% Direct fields of mensur-context can be accessed directly.
#(define-public mensur:settings %mensur-context:settings)
#(define-public mensur:settings! %mensur-context:settings!)
#(define-public mensur:proportio %mensur-context:proportio)
#(define-public mensur:proportio! %mensur-context:proportio!)

%% Helpers for rhythmic-event mensural quality.
#(define-public mensur:quality %mensur-event-quality:quality)
#(define-public mensur:reason %mensur-event-quality:reason)

#(define-public (mensur:subdivisions context)
  "Return the alist ((dur-log . subdivision-value))."
  (map (lambda (pair)
        (cons (car pair) (%mensur-relationship:subdivision (cdr pair))))
   (%mensur-context:relationships context)))

#(define-public mensur:default %mensur-context:default)

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
   (lambda (field-name)
    (let ((field-setter (eval (symbol-append 'mensur: field-name '!) (interaction-environment)))
          (fied-reset '())
          (field-new-value (ly:music-property mensur-setting-event field-name)))
     ;; `new-value` of `mensur-setting-event` should be alists, but they can be pairs!
     ;; If that's the case, turn them into alist.
     (cond
      ((null? field-new-value) '())
      ((alist? field-new-value)
       (for-each (lambda (pair) (field-setter context (car pair) (cdr pair))) field-new-value))
      ((pair? field-new-value)
       (field-setter context (car field-new-value) (cdr field-new-value)))
      (else
       (field-setter context field-new-value)))))

   (map car %mensur:fields))
)


#(testing "Context update."

  ;; Preparing variables. Mensur-context `c` is going to be modified.
  (define c (mensur:default))
  (define values1 '((subdivision . ((-1 . 3)
                                    (0 . 3)))
                    (implicit .    ((0 . #t)))))
  (define values2 '((subdivision . ((-2 . 5)     ;; Adding new subdivision.
                                    (0 . 5)))    ;; Overridin old subdivision.
                    (implicit .    ((-2 . #t)    ;; Adding new subdivision.
                                    (0 . #f)))   ;; Removing old subdivision.
                    (proportio .   2/3)))

  (mensur:update! c (make-music 'early:MensurSetting values1))
  (test-group "Pushing to fresh mensur-context."
   (test-equal "Added fresh to mensur-relationship." 3 (mensur:subdivision c -1))
   (test-equal "Added fresh to mensur-setting." 3 (mensur:subdivision c 0))
   (test-equal "Added fresh to mensur-setting." #t (mensur:implicit c 0))
  )

  (mensur:update! c (make-music 'early:MensurSetting values2))
  (test-group "Modifying filled mensur-context."
   (test-equal "Added fresh to mensur-relationship." 5 (mensur:subdivision c -2))
   (test-equal "Not overriding old mensur-relationship." 3 (mensur:subdivision c -1))
   (test-equal "Overriding mensur-relationship" 5 (mensur:subdivision c 0))
   (test-equal "Adding fresh to mensur-setting." #t (mensur:implicit c -2))
   (test-equal "Overriding mensur-setting." #f (mensur:implicit c 0))
   (test-equal "Overriding mensur-context field." 2/3 (mensur:proportio c))
  )

  (mensur:update! c (make-music 'early:MensurSetting 'implicit '(1 . #t)))
  (test-equal "Updating works with pairs." #t (mensur:implicit c 1))

)


#(define-public (mensur:override! context mensur-event)
  "Modify mensur-context top-level fields from MensurEvent exept of mensur-settings.
   This is because mensur settings are lilypond- and early-specific and do not
   interface directly with the semantics of mensural score."

  (define (validate-relationship-pair pair)
   (let ((dur-log (car pair))
         (rel (cdr pair)))
    (cond
     ((number? rel) (cons dur-log (mensur:relationship rel)))
     ((mensur:relationship? rel) pair)
     (else (ly:error "Wrong type of \"~a\", must be a number or mensur:relationship." rel)))))

  (let ((new-relationships (ly:music-property mensur-event 'relationships))
        (new-proportio (ly:music-property mensur-event 'proportio)))

   (%mensur-context:relationships! context
    (cond
     ((null? new-relationships)
      '())
     ((alist? new-relationships)
      (map validate-relationship-pair new-relationships))
     ((pair? new-relationships)
      (list (validate-relationship-pair new-relationships)))
     (else
      (ly:error "Wrong type of 'relationship field in early:MensurEvent: \"~a\"." new-relationships))))

   (%mensur-context:proportio! context
    (cond
     ((null? new-proportio)
      1)
     (((%mensur:field-data 'proportio 'type) new-proportio)
      new-proportio)
     (else
      (ly:error "Wrong type of 'proportio field in early:MensurEvent: \"~a\"." new-proportio))))

))

#(testing "Context override."
  (define c (mensur:default))
  (mensur:update! c (make-music 'early:MensurSetting 'subdivision '(0 . 3) 'implicit '(0 . #t) 'proportio 2))
  (mensur:override! c (make-music 'early:MensurEvent 'relationships '(1 . 5)))
  (test-equal "Adds subdivisions." 5 (mensur:subdivision c 1))
  (test-equal "Removes subdivisions." 2 (mensur:subdivision c 0))
  (test-equal "Overrides proportio." 1 (mensur:proportio c))
  (test-equal "Leaves settings intact." #t (mensur:implicit c 0))
)

#(define (find-post-event music event)
  "Find post-event attached to music's articulations."
  (find (lambda (a) (music-is-of-type? a event))
               (ly:music-property music 'articulations)))

#(define (%mensur:complexity-event-apply! complexity rhythmic-event)
    (let ((type (ly:music-property complexity 'type))
          (reason (ly:music-property complexity 'reason))
          (quality (ly:music-property rhythmic-event 'mensur:quality)))
     (case type
      ((complex)
       (mensur:quality-set-complex! rhythmic-event reason))
      ((simple)
       (mensur:quality-set-simple! rhythmic-event reason))
      ((altera)
       (mensur:quality-set-altera! rhythmic-event reason))
      ((partial)
       (mensur:quality-set-partial! rhythmic-event reason (ly:music-property complexity 'fraction))))
))


#(define %mensur:puncta `(
  (augmentationis . (
   (dot-count . ,positive?)
   (subdivision . 2)
   (callback . ,(lambda (rhythmic-event) rhythmic-event))
  ))
  (perfectionis . (
   (dot-count . 1)
   (subdivision . 3)
   (callback . ,(lambda (rhythmic-event) rhythmic-event))
  ))
  (divisionis . (
   (dot-count . 0)
   (subdivision . not-null) ;; Mensur context must have at least one complex relationship to allow the use of punctum divisionis.
   (callback . ,(lambda (rhythmic-event) rhythmic-event))
  ))
))

#(define (%mensur:punctum-property punctum-name prop-name)
  (let ((props (assoc-ref %mensur:puncta punctum-name)))
   (unless props
    (ly:error "Unrecognized punctum: ~A" props))
   (let ((prop (assoc-ref props prop-name)))
    (unless prop
     (ly:error "Unrecognized punctum property: ~A" prop-name))
    prop)))

#(define (%mensur:punctum-validate punctum-name mensur-context dots subdivision)
  "Check if rhythmic-event properties and context allow for applying punctum."
  (let ((required-dot-count (%mensur:punctum-property punctum-name 'dot-count))
        (required-subdivision (%mensur:punctum-property punctum-name 'subdivision)))
   (when (and (eq? required-subdivision 'not-null)
              (null? (%mensur-context:relationships mensur-context)))
    (error "A punctum requiring complex mensuration cannot be used in simple mensuration."))
   (and (if (procedure? required-dot-count)
         (required-dot-count dots)
         (= required-dot-count dots))
        (if (symbol? required-subdivision)
         (case required-subdivision
          ((not-null)
           (when (null? (%mensur-context:relationships mensur-context))
            (error "A punctum requiring complex mensuration cannot be used in simple mensuration."))
           #t)
          (else
           (ly:error "Unsupported required-subdivision symbol: ~A" required-subdivision)))
        (= required-subdivision subdivision)))))

#(define (%mensur:punctum-apply! punctum-name rhythmic-event)
  "Apply punctum's callback to rhythmic-event. Note: validate first with %mensur:punctum-validate."
  (let ((apply-callback (%mensur:punctum-property punctum-name 'callback))
        (punctum (early:punctum rhythmic-event)))
   (early:punctum-add! rhythmic-event punctum-name)
   (apply-callback rhythmic-event)))


#(define-public (early:punctum music)
  "Find if event has a punctum and return it's type.
   If no punctum is present, return `#f`."
  (let ((punctum (find-post-event music 'early-punctum-event)))
   (if punctum
    (ly:music-property punctum 'type)
    #f)))

#(define-public (early:punctum-add! music punctum-type)
  (ly:music-set-property! music 'articulations
   (cons (make-music 'EarlyPunctumEvent 'type punctum-type)
         (ly:music-property music 'articulations))))


% #(define-public (early:punctum-set-augmentationi)





#(define-public (mensur:complex? context rhythmic-event)
  "Is duration of `rhythmic-event` complex?"
  (let* ((quality (ly:music-property rhythmic-event 'mensur:quality))
         (explicit (and (not (null? quality)) (mensur:quality quality)))
         (dur-log (ly:duration-log (ly:music-property rhythmic-event 'duration)))
         (subdivision (mensur:subdivision context dur-log))
        )
   ;; Duration is complex if
   (or (eq? explicit 'complex) ;; it is complex explicitly or implicitly:
       (and subdivision                       ;; – it's dur-log has complex subdivision
            (not (= subdivision 2))           ;; – (that is not 2)
            (not (eq? explicit 'simple))))    ;; – it is not simple...
))


#(define-public (mensur:factor context rhythmic-event)

  (let* ((quality (ly:music-property rhythmic-event 'mensur:quality))
         (reason (mensur:reason quality))
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
     (let* ((quality (mensur:quality quality))
            (subdivisions (mensur:subdivisions context))
            (is-complex (mensur:complex? context rhythmic-event))
            (init-factor (if is-complex (complex-factor context dur-log) 1))
            (factor (fold accum-factor init-factor subdivisions))
           )

      (case quality
       ((simple) factor)
       ((complex) factor)
       ((altera) (* 2 factor))
       ((partial)
        (let* ((partial-factor (ly:music-property rhythmic-event 'mensur:partial-factor))
               (num (car partial-factor))
               (den (cdr partial-factor)))
         (* factor (/ num den))))
       (else (ly:error "Unimplemented mensur quality: \"~a\"" quality)))

)))))


#(define (mensur:event-quality-set! rhythmic-event quality reason)

  (let ((reason-data (assq-ref mensur:quality-reasons reason)))

   (unless reason-data
    (ly:error "Unrecognized mensur quality reason: \"~a\"." reason))
   (unless (memq quality (assq-ref reason-data 'qualities))
    (ly:error "\"~a\" is not a valid mensural quality reason for a \"~a\" quality. Valid reasons are: ~a." reason quality (assq-ref reason-data 'qualities)))
   (unless (music-is-of-type? rhythmic-event (assq-ref reason-data 'event))
    (ly:error "Event cannot have a mensur quality ~a of reason ~a." quality reason))

   (ly:music-set-property! rhythmic-event 'mensur:quality (mensur:event-quality quality reason))))


#(define-public (mensur:quality-set-simple! rhythmic-event reason)
  (mensur:event-quality-set! rhythmic-event 'simple reason))

#(define-public (mensur:quality-set-complex! rhythmic-event reason)
  (mensur:event-quality-set! rhythmic-event 'complex reason))

#(define-public (mensur:quality-set-altera! note-event reason)
  (unless (music-is-of-type? note-event 'note-event)
   (ly:error "Only note events can be alterated."))
  (mensur:event-quality-set! note-event 'altera reason))

#(define-public (mensur:quality-set-partial! rhythmic-event reason partial-factor)
  (mensur:event-quality-set! rhythmic-event 'partial reason)
  (ly:music-set-property! rhythmic-event 'mensur:partial-factor partial-factor))


#(define-public (mensur:mensurate-event! context rhythmic-event)

  (let* ((dur (ly:music-property rhythmic-event 'duration))
         (dur-log (ly:duration-log dur))
         (dots (ly:duration-dot-count dur))
         (complexity (find-post-event rhythmic-event 'early-complexity-event))
         (punctum (early:punctum rhythmic-event))
         (subdivision (or (mensur:subdivision context dur-log) 2))
         (subdivision-parent (or (mensur:subdivision context (1- dur-log)) 2))
         (implicit (mensur:implicit context dur-log))
        )

   ; Some features are only for complex, some for simple.
   ; Maybe filter those features first and only then compare?

   ;; If dot is present, assume punctum.
   (when (and (not punctum) (> dots 0))
    (set! punctum
     (if (= subdivision 2)
      'augmentationis
      'perfectionis)))

   ;; Apply punctum's callback to rhythmic-event.
   (when (and punctum (%mensur:punctum-validate punctum context dots subdivision))
    (%mensur:punctum-apply! punctum rhythmic-event))

   ;; Update quality based on the ComplexityEvent.
   ;; They are ignored if mensura is simple. But:
   ;; – altera is a different and uses parent's subdivision in check
   ;; – complexity and punctum perfectionis do not stack.
   (when complexity
    (let ((complexity-type (ly:music-property complexity 'type)))
     (cond
      ((and (eq? complexity-type 'altera)
            (not (= subdivision-parent 2)))
       (%mensur:complexity-event-apply! complexity rhythmic-event))
      ((and (eq? punctum 'perfectionis)
            (eq? complexity-type 'partial))
       (error "Cannot stack together puncumt perfectionis and partial imperfection."))
      ((and (not (eq? punctum 'perfectionis))
            (not (= subdivision 2)))
       (%mensur:complexity-event-apply! complexity rhythmic-event)))))


   ;; If mensuration is complex
   ;; but quality is not given,
   ;; supplement it.
   (when (null? (ly:music-property rhythmic-event 'mensur:quality))
    (cond
     ((= subdivision 2)
      (mensur:quality-set-simple! rhythmic-event 'simple-mensur)) ;; Isn't this redundant?
     ((music-is-of-type? rhythmic-event 'rest-event)
      (mensur:quality-set-complex! rhythmic-event 'rest))
     ((eq? punctum 'perfectionis)
      (mensur:quality-set-complex! rhythmic-event 'punctum-perfectionis))
     (implicit ;; HACK: if symbol 'all is returned, it evaluates always to #t.
      ; TO DO: check it twice...
      (mensur:quality-set-complex! rhythmic-event 'position))
     (else
      (mensur:quality-set-simple! rhythmic-event 'position))))

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
  (mensur:update! c (make-music 'early:MensurSetting 'subdivision '((-1 . 3)(0 . 3)(1 . 3)) 'implicit '((-1 . #t)(0 . #f)(1 . #f))))
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
  (mensur:override! c (make-music 'early:MensurEvent 'relationships '((1 . 3)))) ;; 'prolatio.
  (test-equal "Note (simple itself but with complex subdivisions below." 3/2 (event-length 'NoteEvent 0))
)

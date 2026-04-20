\version "2.24.3"
\include "../testing.ily"

% TO DO !!!
% Eliminate 'early:' suffix – it causes segmentation troubles. Use 'EarlyThingyEvent'.
% Remove -event from make- constructors (if applicable)

%% Some validators

% TO DO: make it a part of 'validation' relaxng-like library
% rng:choice validator ???
#(define ((choice elements) e)
  (and (memq e elements) #t))

% TO DO: find relax terminology for 'nullable'.
#(define ((nullable pred?) e)
  (or (pred? e) (null? e)))

%% Main event constructor procedure.

#(define-public (early:define-constructable-music-event! type description types props . validators)
  "Define a music event together with it's event class.
   Returns a constructor function for this event in a form
   '(make-_typed_-music val1 val2 val3...)' where arguments
   are defined in 'validators' alist.

   Args:
   type: symbol (e.g. 'NameOfEvent)
   parent-event: symbol (e.g. music-event)
   description: string (e.g. 'This is X used for Y.')
   types: list of event types. First type is the *parent* type.
   * important: DO NOT include an event-name derived from 'type': let this procedure take care of it!
   props: event properties (without description and types) – can be '().
   validators: pairs of (constructor-prop-name . proc-validator)
   "

  (unless (and (symbol? type)
               (string? description)
               (list? types)
               (alist? props))
    (error (format "Wrong type of argument:\n ~A \n ~A \n ~A \n ~A \n" type description types props)))

  (let ((event-name (ly:camel-case->lisp-identifier type)))
   ;; Protect agains defining twice
   (unless (ly:make-event-class event-name)
    ;; Define new event and include it in 'types'.
    (define-event-class event-name (car types)) ;; First type is the *parent* type.
    (set! types (append types (list event-name)))
    ;; Set props to lilypond registers.
    (set-object-property! type 'music-description description)
    (set! props (assoc-set! props 'name type))
    (set! props (assoc-set! props 'types types))
    (hashq-set! music-name-to-property-table type props)
    (set! music-descriptions
          (sort (cons (cons type props)
                      music-descriptions)
                alist<?)))

   ;; Event constructor.
   ; check if it is music-event..?
   (lambda args

    (let ((al (length args))
          (vl (length validators)))
     (cond ((< al vl)
            (append! args (make-list (- vl al))))
           ((> al vl) ;; Do nothing here because fold takes care of it.
            (ly:warning "Too much arguments provided. Ignoring."))
    ))

    (apply make-music (fold (lambda (arg pair prev)
                             (let ((prop-name (car pair))
                                   (prop-validator (cdr pair)))
                              (unless (prop-validator arg)
                               (error (format #f "Wrong type of argument ~A (expecting a value satisfying ~A): ~A" prop-name prop-validator arg)))
                              (if (null? arg)
                               prev
                               (append prev (list prop-name arg)))
                            ))
                       (list type)
                       args
                       validators)))
))

#(testing "Defining constructible music events"

  (define (define-dummy-event)
   (early:define-constructable-music-event!
    'DummyTestingEvent "Dummy description."
    '(music-event StreamEvent) '()
    `(prop . ,string?)
    `(nullable-prop . ,(nullable string?)))) ;; should not cause troubles.

  (test-group "New music-event is defined."
   (define make-dummy-event (define-dummy-event))
   (test-equal "Works." "dummy" (ly:music-property (make-dummy-event "dummy") 'prop))
   (test-error "Validator throws on wrong type." #t (make-dummy-event 'dummy))
  )


  (test-group "Old event survives redefinition"
   ;; Exactly the same
   (define make-dummy-event (define-dummy-event))
   (test-equal "Works." "dummy" (ly:music-property (make-dummy-event "dummy") 'prop))
  )

)

#(unless (ly:make-event-class 'early-event)
  (define-event-class 'early-event 'music-event)
  (define-event-class 'early:mensur-event 'early-event))

#(define-public early:make-mensur-event ; TO DO: use & implement
  (early:define-constructable-music-event!
   'early:MensurEvent ; TO DO: remove 'early:'
   "An event created when setting a new mensuration. Used in music processed with '\\mensural'."
   '(early:mensur-event time-signature-event StreamEvent)
   ; ((iterator-ctor . ,ly:sequential-iterator::constructor)
   ;  (elements-callback . ,make-mensura-event))
   '()
   ; TO DO: validators
))

#(define-public early:make-mensur-music ; TO DO: use & implement
  (early:define-constructable-music-event!
   'early:MensurMusic ; TO DO: remove 'early:'
   "An event created when setting a new mensuration. Used in music processed with '\\mensural'."
   '(early:mensur-event time-signature-music StreamEvent)
   ; ((iterator-ctor . ,ly:sequential-iterator::constructor)
   ;  (elements-callback . ,make-mensura-event))
   '()
   ; TO DO: validators
))

#(define-public early:make-mensur-setting ; TO DO: use & implement
  (early:define-constructable-music-event!
   'early:MensurSetting ; TO DO: remove 'early:'
   "Set a mensuration setting. Used in music processed with '\\mensural'. Mensuration setting are Lilypond and Early features that allow for modification of mensural music doration interpretation (e.g. interpreting a note as made of tuplets). Useful with 'oldschool' transcriptions of medieval music."
   '(early:mensur-event StreamEvent) ; included 'time-signature-music' ..?
   ; ((iterator-ctor . ,ly:sequential-iterator::constructor)
   ;  (elements-callback . ,make-mensura-event))
   '()
   ; TO DO: validators
))

#(define-public early:make-punctum-event ; TO DO: use & implement
  (early:define-constructable-music-event!
   'EarlyPunctumEvent ; TO DO: remove 'early:'
   "A point whose semantic function and layout differs vastly among early music editions."
   '(early:mensur-event post-event event StreamEvent)
   '()
   ; TO DO: validators
))











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

#(define-public mensur:make-quality ; TO DO: use & implement
  (early:define-constructable-music-event!
   'EarlyComplexityEvent ; TO DO: remove 'early:', TO DO: change to 'EarlyQualityEvent, TO DO: lookup 'early-complex-event as weel.
   "Note duration is recalculated using \\mensura."
   '(early:mensur-event post-event event StreamEvent)
   '()
   ; TO DO: validators
   `(quality . ,(choice '(simple complex partial altera)))
   `(reason . ,(choice (map car mensur:quality-reasons))) ;; reason? undefined
   `(fraction . ,(nullable fraction?)) ;; or undefined.
))

#(define-public (mensur:quality quality-event) (ly:music-property quality-event 'quality))
#(define-public (mensur:reason quality-event) (ly:music-property quality-event 'reason))
#(define-public (mensur:fraction quality-event)
  (let ((fraction (ly:music-property quality-event 'fraction)))
   (display fraction)
   (if (null? fraction) '(1 . 1) fraction)))


#(define-public (mensur:music-is-of-quality? rhythmic-event quality-type) ; TO DO: implement!
  (eq? (mensur:quality (ly:music-property rhythmic-event 'mensur:quality))
       quality-type))

#(define (mensur:music-set-quality! rhythmic-event quality)

  (unless (music-is-of-type? rhythmic-event 'rhythmic-event)
   (ly:error "Only rhythmic-events can have mensural quality, not ~A" rhythmic-event))
  (unless (music-is-of-type? quality 'early-complexity-event)
   (ly:error "Wrong type of quality. Must be 'early-complex-event, is ~A" quality))

  (let* ((quality-type (mensur:quality quality))
         (reason (mensur:reason quality))
         (reason-data (assq-ref mensur:quality-reasons reason)))

   (unless reason-data
    (ly:error "Unrecognized mensur quality reason: \"~a\"." reason))
   (unless (memq quality-type (assq-ref reason-data 'qualities))
    (ly:error "\"~a\" is not a valid mensural quality reason for a \"~a\" quality. Valid reasons are: ~a." reason quality-type (assq-ref reason-data 'qualities)))
   (unless (music-is-of-type? rhythmic-event (assq-ref reason-data 'event))
    (ly:error "Event cannot have a mensur quality ~a of reason ~a." quality-type reason))

   (ly:music-set-property! rhythmic-event 'mensur:quality quality))
)


#(define-public (mensur:make-simple! rhythmic-event reason)
  (mensur:music-set-quality! rhythmic-event
   (mensur:make-quality 'simple reason)))

#(define-public (mensur:make-complex! rhythmic-event reason)
  (mensur:music-set-quality! rhythmic-event
   (mensur:make-quality 'complex reason)))

#(define-public (mensur:make-altera! note-event reason)
  (mensur:music-set-quality!
   (mensur:make-quality 'altera reason)))

#(define-public (mensur:make-partial! rhythmic-event reason fraction)
  (mensur:music-set-quality! rhythmic-event
   (mensur:make-quality 'partial reason fraction)))


%% Left here for future considerations.
%
% #(define (make-mensura-event music)
%   (descend-to-context
%    (make-apply-context
%     (lambda (context)
%      (ly:broadcast (ly:context-event-source context)
%                    (ly:make-stream-event
%                     (ly:make-event-class 'early:mensura-event)
%                     (ly:music-mutable-properties music)))))
%    'EarlyVoice))

%% Legacy code (still lingering in other definitions files.)
% #(unless (ly:make-event-class 'early-event)
%   (define-event-class 'early-event 'music-event)
%   ;; Legacy...
%   (define-event-class 'early:mensura-event 'early-event)
%   (define-event-class 'early:color-minor-sequence 'early-event)
%   (define-event! 'early:MensuraEvent
%    '((description . "Used to modify current early:mensura-properties")
%      ;(iterator-ctor . ,ly:sequential-iterator::constructor)
%      ;(elements-callback . ,make-mensura-event)
%      (types . (early:mensura-event time-signature-event StreamEvent)))
%   ))

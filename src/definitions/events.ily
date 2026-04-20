\version "2.24.3"
\include "../testing.ily"

% TO DO !!!
% Eliminate 'early:' suffix – it causes segmentation troubles. Use 'EarlyThingyEvent'.

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
    (apply make-music (fold (lambda (arg pair prev)
                             (let ((prop-name (car pair))
                                   (prop-validator (cdr pair)))
                              (unless (prop-validator arg)
                               (error (format #f "Wrong type of argument ~A (expecting a value satisfying ~A): ~A" prop-name prop-validator arg)))
                              (append prev (list prop-name arg))))
                       (list type)
                       args
                       validators)))
))

#(testing "Defining constructible music events"

  (define (define-dummy-event)
   (early:define-constructable-music-event!
    'DummyTestingEvent "Dummy description."
    '(music-event StreamEvent) '()
    `(prop . ,string?)))

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

#(define-public mensur:make-quality-event ; TO DO: use & implement
  (early:define-constructable-music-event!
   'EarlyComplexityEvent ; TO DO: remove 'early:', TO DO: change to 'EarlyQualityEvent
   "Note is being made complex."
   '(early:mensur-event post-event event StreamEvent)
   '()
   ; TO DO: validators
   `(type . ,symbol?)
   `(reason . ,reason?) ;; reason? undefined
   `(fraction . ,fraction?) ;; or undefined.
))

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

\version "2.24.3"
\include "../testing.ily"

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
  (define-event-class 'early-event 'music-event))

% TO DO: move to mensur
#(unless (ly:make-event-class 'mensur-event)
  (define-event-class 'mensur-event 'early-event))

% TO DO: move to mensur
#(define-public early:make-mensur-event ; TO DO: use & implement
  (early:define-constructable-music-event!
   'EarlyMensuraEvent
   "An event created when setting a new mensuration. Used in music processed with '\\mensural'."
   '(mensur-event time-signature-event StreamEvent)
   ; ((iterator-ctor . ,ly:sequential-iterator::constructor)
   ;  (elements-callback . ,make-mensura-event))
   '()
   ; TO DO: validators
))

% TO DO: move to mensur
#(define-public early:make-mensur-music ; TO DO: use & implement
  (early:define-constructable-music-event!
   'EarlyMensuraMusic
   "An event created when setting a new mensuration. Used in music processed with '\\mensural'."
   '(mensur-event time-signature-music StreamEvent)
   ; ((iterator-ctor . ,ly:sequential-iterator::constructor)
   ;  (elements-callback . ,make-mensura-event))
   '()
   ; TO DO: validators
))







% START REFACTOR HERE HERE HERE !

% TO DO: remove this notion alltogether?
#(define-public mensur:make-relationship ; TO DO: use & implement
  (early:define-constructable-music-event!
   'MensurRelationshipEvent
   "Mensural-related data of the context."
   '(mensur-event) '()
   `(subdivision . ,integer?)
))

%% TO DO: compare with MensurContextSetting... is it the same thing?
#(define-public mensur:make-setting ; TO DO: use & implement
  (early:define-constructable-music-event!
   'MensurSettingEvent
   "Internal Early mensuration interface settings."
   '(mensur-event) '()
   `(implicit . ,(lambda (s) (or (boolean? s) (eq? s 'all))))
   `(as-tuplet . ,boolean?)
))

% TO DO: move HERE everything from <mensur:context>.
#(define-public mensur:make-context ; TO DO: use & implement
  (early:define-constructable-music-event!
   'MensurContextEvent
   "All information needed for note mensuration (i.e. duration recalculation)."
   '(mensur-event)
   ; ((iterator-ctor . ,ly:sequential-iterator::constructor)
   ;  (elements-callback . ,make-mensura-event))
   '()
   ; TO DO: better validators
   `(relationships . ,alist?) ;; alist (dur-log . mensur:relationship) ; TO DO: alist OF RELATIONSHIPS
   `(proportio . ,fraction?) ; TO DO: for now is a NUMBER
   `(settings . ,alist?) ;; alist (dur-log . mensur:settings)
))





% TO DO: move to 'mensur-context-setting'
#(define-public early:make-mensur-setting ; TO DO: use & implement
  (early:define-constructable-music-event!
   'MensurContextSetting
   "Set a mensuration setting. Used in music processed with '\\mensural'. Mensuration setting are Lilypond and Early features that allow for modification of mensural music doration interpretation (e.g. interpreting a note as made of tuplets). Useful with 'oldschool' transcriptions of medieval music."
   '(mensur-event StreamEvent) ; included 'time-signature-music' ..?
   ; ((iterator-ctor . ,ly:sequential-iterator::constructor)
   ;  (elements-callback . ,make-mensura-event))
   '()
   ; TO DO: validators
))


% TO DO: move to 'mensur-punctum-event'
#(define-public early:make-punctum-event ; TO DO: use & implement
  (early:define-constructable-music-event!
   'EarlyPunctumEvent
   "A point whose semantic function and layout differs vastly among early music editions."
   '(mensur-event post-event event StreamEvent)
   '()
   ; TO DO: validators
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

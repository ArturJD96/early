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

#(define ((alternative pred1? pred2?) e) ; TO DO: make it generic for any number of preds.
  (or (pred1? e) (pred2? e)))

#(define (pair-or-alist? e)
  (or (pair? e) (alist? e)))

#(define (integer-or-procedure? e)
  (or (integer? e) (procedure? e)))

#(define (integer-or-symbol? e)
  (or (integer? e) (symbol? e)))

)

#(define (find-post-event music event) ; TO DO: move to utils.
  "Find post-event attached to music's articulations."
  (find (lambda (a) (music-is-of-type? a event))
         (ly:music-property music 'articulations)))

%% Main event constructor procedure.

#(define-public (early:define-constructable-music-event! type description types props . validators)
  "Define a music event together with it's event class.
   Returns a constructor function for this event in a form
   '(make-named-event val1 val2 val3...)' where arguments
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

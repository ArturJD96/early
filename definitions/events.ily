\version "2.24.3"

% Event properties

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

% #(define (make-mensura-event music)
%   (descend-to-context
%    (make-apply-context
%     (lambda (context)
%      (ly:broadcast (ly:context-event-source context)
%                    (ly:make-stream-event
%                     (ly:make-event-class 'early:mensura-event)
%                     (ly:music-mutable-properties music)))))
%    'EarlyVoice))

#(unless (ly:make-event-class 'early-event)
  (define-event-class 'early-event 'music-event)
  (define-event-class 'early:mensura-event 'early-event)
  (define-event-class 'early:color-minor-sequence 'early-event)
  (define-event! 'early:MensuraEvent
   '((description . "Used to modify current early:mensura-properties")
     ;(iterator-ctor . ,ly:sequential-iterator::constructor)
     ;(elements-callback . ,make-mensura-event)
     (types . (early:mensura-event time-signature-event StreamEvent)))
  )
)

\version "2.24.3"

% TO DO !!!
% Eliminate 'early:' suffix – it causes segmentation troubles. Use 'EarlyThingyEvent'.

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
  ;; Legacy...
  (define-event-class 'early:mensura-event 'early-event)
  (define-event-class 'early:color-minor-sequence 'early-event)
  (define-event! 'early:MensuraEvent
   '((description . "Used to modify current early:mensura-properties")
     ;(iterator-ctor . ,ly:sequential-iterator::constructor)
     ;(elements-callback . ,make-mensura-event)
     (types . (early:mensura-event time-signature-event StreamEvent)))
  )


  ;; ... New, mei-inspired!
  (define-event-class 'early:mensur-event 'early-event)
  (define-event-class 'early-punctum-event 'early-event)
  (define-event-class 'early-complexity-event 'early-event)

  (define-event! 'early:MensurEvent
   '((description . "An event created when setting a new mensuration. Used in music processed with '\\mensural'.")
     ;(iterator-ctor . ,ly:sequential-iterator::constructor)
     ;(elements-callback . ,make-mensura-event)
     (types . (early:mensur-event time-signature-event StreamEvent)))
  )
  (define-event! 'early:MensurMusic
   ;; This advanced lilypond framework is not integrated well yet.
   ;; Ideally, \mensural command would not be needed to recalculate
   ;; the duration values of the music.
   '((description . "Set a new mensuration. Used in music processed with '\\mensural'.")
     ;(iterator-ctor . ,ly:sequential-iterator::constructor)
     ;(elements-callback . ,make-mensura-event) ;; make-time-signature-set
     (types . (early:mensur-event time-signature-music StreamEvent)))
  )
  (define-event! 'early:MensurSetting
   ;; This advanced lilypond framework is not integrated well yet.
   ;; Ideally, \mensural command would not be needed to recalculate
   ;; the duration values of the music.
   '((description . "Set a mensuration setting. Used in music processed with '\\mensural'. Mensuration setting are Lilypond and Early features that allow for modification of mensural music doration interpretation (e.g. interpreting a note as made of tuplets). Useful with 'oldschool' transcriptions of medieval music.")
     ;(iterator-ctor . ,ly:sequential-iterator::constructor)
     ;(elements-callback . ,make-mensura-event) ;; make-time-signature-set
     (types . (early:mensur-event time-signature-music StreamEvent)))
  )
  (define-event! 'EarlyPunctumEvent
   '((description . "A point whose semantic function and layout differs vastly among early music editions.")
     (types . (early-punctum-event post-event event StreamEvent)))
  )
  (define-event! 'EarlyComplexityEvent
   '((description . "Note is being made complex.")
     (types . (early-complexity-event post-event event StreamEvent)))
  )
  ; (define-event! 'early:MensurEvent
  ;  '((description . "An event created when setting a new mensuration. Used in music processed with '\\mensural'.")
  ;    ;(iterator-ctor . ,ly:sequential-iterator::constructor)
  ;    ;(elements-callback . ,make-mensura-event)
  ;    (types . (early:mensur-event time-signature-event StreamEvent)))
  ; )
)

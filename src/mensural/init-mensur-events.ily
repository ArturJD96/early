\version "2.24.4"
\include "./../definitions/events.ily" % TO DO: de-centralize and define early:MensurSetting and MensurEvent here?

#(unless (ly:make-event-class 'mensur-event)
  (define-event-class 'mensur-event 'early-event)
  (define-event-class 'mensur-context-event 'mensur-event) ;; Modyfies mensur *context* object.
  (define-event-class 'mensur-rhythmic-event 'mensur-event) ;; Modyfies lilypond's rhythmic music objects.
)

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

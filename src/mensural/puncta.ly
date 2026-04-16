\version "2.24.4"
\include "./../definitions/events.ily" % TO DO: de-centralize and define early:MensurSetting and MensurEvent here?

% punctumAugmentationis = #(define-event-function () () (make-music 'EarlyPunctumEvent 'type 'augmentationis))
% punctumPerfectionis = #(define-event-function () () (make-music 'EarlyPunctumEvent 'type 'perfectionis))
punctumDivisionis = #(define-event-function () () (make-music 'EarlyPunctumEvent 'type 'divisionis))
% %% TO DO: Punctum alterationis affects the last note in a group.
% punctumAlterationis = #(define-event-function () () (make-music 'EarlyPunctumEvent 'type 'alterationis))

%% Aliases
% paug = \punctumAugmentationis
% pperf = \punctumPerfectionis
pdiv = \punctumDivisionis
% palt = \punctumAlterationis

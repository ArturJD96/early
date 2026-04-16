\version "2.24.4"
\include "./../definitions/events.ily" % TO DO: de-centralize and define early:MensurSetting and MensurEvent here?
% \include "mensur.ily"

%{
%
%   Note MENSUR
%   * perfected
%   * altered
%   * imperfected
%
% %}

perf = #(define-event-function () () (make-music 'EarlyComplexityEvent 'type 'complex 'reason 'undocumented))
imp = #(define-event-function () () (make-music 'EarlyComplexityEvent 'type 'simple 'reason 'position))
part = #(define-event-function (fraction) (fraction?) (make-music 'EarlyComplexityEvent 'type 'partial 'reason 'position 'fraction fraction))
altera = #(define-event-function () () (make-music 'EarlyComplexityEvent 'type 'altera 'reason 'position))

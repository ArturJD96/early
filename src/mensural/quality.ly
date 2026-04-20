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

perf = #(define-event-function () () (mensur:make-quality 'complex 'undocumented))
imp = #(define-event-function () () (mensur:make-quality 'simple 'position))
part = #(define-event-function (fraction) (fraction?) (mensur:make-quality 'partial 'position fraction))
altera = #(define-event-function () () (mensur:make-quality 'altera 'position))

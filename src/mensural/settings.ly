\version "2.24.4"
\include "./../definitions/events.ily"

%{
%       Implicit mensurations
% %}

mensuraImplicit =
#(make-music 'MensurContextSetting
  'implicit
  (map (lambda (durlog) (cons durlog #t))
       '(-3 -2 -1 0 1 2 3 4 5 6 7 8))) %% I could have used `iota` but this is more explicit.

modusmaiorImplicit = #(make-music 'MensurContextSetting 'implicit '(-3 . #t))
modusImplicit = #(make-music 'MensurContextSetting 'implicit '(-2 . #t))
tempusImplicit = #(make-music 'MensurContextSetting 'implicit '(-1 . #t))
prolatioImplicit = #(make-music 'MensurContextSetting 'implicit '(0 . #t))

%{
%       Explicit mensurations
% %}

mensuraExplicit = #(make-music 'MensurContextSetting 'implicit '())
modusmaiorExplicit = #(make-music 'MensurContextSetting 'implicit '(-3 . #f))
modusExplicit = #(make-music 'MensurContextSetting 'implicit '(-2 . #f))
tempusExplicit = #(make-music 'MensurContextSetting 'implicit '(-1 . #f))
prolatioExplicit = #(make-music 'MensurContextSetting 'implicit '(0 . #f))

\version "2.24.4"
\include "./../definitions/events.ily"

%{
%       Implicit mensurations
% %}

mensuraImplicit =
#(make-music 'early:MensurSetting
  'implicit
  (map (lambda (durlog) (cons durlog #t))
       '(-3 -2 -1 0 1 2 3 4 5 6 7 8))) %% I could have used `iota` but this is more explicit.

modusmaiorImplicit = #(make-music 'early:MensurSetting 'implicit '(-3 . #t))
modusImplicit = #(make-music 'early:MensurSetting 'implicit '(-2 . #t))
tempusImplicit = #(make-music 'early:MensurSetting 'implicit '(-1 . #t))
prolatioImplicit = #(make-music 'early:MensurSetting 'implicit '(0 . #t))

%{
%       Explicit mensurations
% %}

mensuraExplicit = #(make-music 'early:MensurSetting 'implicit '())
modusmaiorExplicit = #(make-music 'early:MensurSetting 'implicit '(-3 . #f))
modusExplicit = #(make-music 'early:MensurSetting 'implicit '(-2 . #f))
tempusExplicit = #(make-music 'early:MensurSetting 'implicit '(-1 . #f))
prolatioExplicit = #(make-music 'early:MensurSetting 'implicit '(0 . #f))

\version "2.24.3"

% Augmentation_engraver
#(set-object-property! 'augmentation 'translation-type? integer?)

% Context properties
#(set-object-property! 'mensura 'translation-type? alist?)
#(set-object-property! 'mensuraCompletion 'translation-type? alist?)

% Notation itself
#(set-object-property! 'notation 'translation-type? symbol?)
#(set-object-property! 'earlyStyle 'translation-type? symbol?)
#(set-object-property! 'coloration 'translation-type? color?)
#(set-object-property! 'colorationSecondary 'translation-type? color?)
#(set-object-property! 'implicitColorAfterDurlog 'translation-type? number?)

%{
    Lyrics
%}
#(set-object-property! 'early-font-config 'translation-type? alist?)
#(set-object-property! 'early-font-allographs 'translation-type? alist?)
#(set-object-property! 'early-font-ligatures 'translation-type? alist?)
%% Used for outputing pure unicode (available) variants of graphemes
%% before processing the text further. For example: venissem* -> uenıſſeɜ
%% Using this setting with palaeographic fonts will most likely give poor results.
%% Use it for debugging or highly diplomatic transcriptions with modern fonts.
#(set-object-property! 'early-font-pure-unicode 'translation-type? boolean?)

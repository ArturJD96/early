\version "2.24.3"

% Context properties
#(set-object-property! 'mensura 'translation-type? alist?)
#(set-object-property! 'mensuraCompletion 'translation-type? alist?)

% Trasing rhythm
#(set-object-property! 'tactusLength 'translation-type? ly:moment?)
#(set-object-property! 'tactusPosition 'translation-type? ly:moment?)
#(set-object-property! 'tactusStartNow 'translation-type? boolean?)

% Notation itself
#(set-object-property! 'notation 'translation-type? symbol?)
#(set-object-property! 'early-style 'translation-type? symbol?)
#(set-object-property! 'coloration 'translation-type? symbol?)
#(set-object-property! 'colorationSecondary 'translation-type? symbol?)
#(set-object-property! 'implicitColorAfterDurlog 'translation-type? number?)
% #(set-object-property! 'hollow 'translation-type? boolean?)

% ...!!! Those: implement in \mensural
#(set-object-property! 'earlyMensuraOff 'translation-type? boolean?)
#(set-object-property! 'earlyMensuraOff 'translation-doc?
"Turn off automatic duration mensural recalculation (make it default LilyPond WYSIWYG againg).")

% Augmentation engraver
#(set-object-property! 'augmentation 'translation-type? integer?)

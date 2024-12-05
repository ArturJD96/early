\version "2.24.3"

% Augmentation_engraver
#(set-object-property! 'augmentation 'translation-type? integer?)

% Context properties
#(set-object-property! 'mensura 'translation-type? alist?)
#(set-object-property! 'mensuraCompletion 'translation-type? alist?)

% Notation itself
#(set-object-property! 'notation 'translation-type? symbol?)
#(set-object-property! 'early-style 'translation-type? symbol?)
#(set-object-property! 'coloration 'translation-type? color?)
#(set-object-property! 'colorationSecondary 'translation-type? color?)
#(set-object-property! 'implicitColorAfterDurlog 'translation-type? number?)

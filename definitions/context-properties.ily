\version "2.24.3"

% Context properties
#(set-object-property! 'mensura 'translation-type? alist?)
#(set-object-property! 'mensuraCompletion 'translation-type? alist?)

#(set-object-property! 'tactusLength 'translation-type? ly:moment?)
#(set-object-property! 'tactusPosition 'translation-type? ly:moment?)
#(set-object-property! 'tactusStartNow 'translation-type? boolean?)

% Check those again if they are still needed:
#(set-object-property! 'notation 'translation-type? symbol?)
#(set-object-property! 'coloration 'translation-type? symbol?)
#(set-object-property! 'colorationSecondary 'translation-type? symbol?)
% #(set-object-property! 'hollow 'translation-type? boolean?)

% ...!!! Those: implement in \mensural
#(set-object-property! 'earlyMensuraOff 'translation-type? boolean?)
#(set-object-property! 'earlyMensuraOff 'translation-doc?
"Turn off automatic duration mensural recalculation (make it default LilyPond WYSIWYG againg).")

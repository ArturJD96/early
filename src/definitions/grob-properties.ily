\version "2.24.3"

% Grob properties
#(set-object-property! 'early-notation-type 'backend-type? symbol?)
#(set-object-property! 'early-style 'backend-type? symbol?)
#(set-object-property! 'early-color 'backend-type? color?)
#(set-object-property! 'early-hollow 'backend-type? boolean?)

% quadrata note
#(set-object-property! 'early-quadrata-width 'backend-type? number?)
#(set-object-property! 'early-quadrata-height 'backend-type? number?)
#(set-object-property! 'early-quadrata-side 'backend-type? list?)
#(set-object-property! 'early-quadrata-base 'backend-type? list?)
#(set-object-property! 'early-quadrata-corner 'backend-type? list?)

#(set-object-property! 'early-style-properties 'backend-type? list?)


#(set-object-property! 'early-quadrata-properties 'backend-type? alist?)


#(set-object-property! 'early-quill 'backend-type? alist?)

\version "2.24.3"

%{
%
%   This file is obsolete, thus I don't touch it now.
%
%   I should replace "assert.ly" library with "testing.ily".
%   At this point, "assert.ly" lib is deleted and I use "testing.ily".
%
% %%}

\include "../early_backend/early-styles.ly"

#(define (assert-equals name expr expected)
  (when (not (eq? expr expected))
   (error
    (format #t
     "\nTest failed: ~s.\n|-Expected: ~s\n|-     Got: ~s"
     name expected expr))))

#(assert-equals "early-style exists" (early:has-style 'tournai) #t)
#(assert-equals "early-style is missing" (early:has-style 'non-existent-style-dummy) #f)

#(assert-equals "new early-style added" (early:has-style 'dummy) #f)
#(early:add-notation-style 'dummy)
#(assert-equals "new early-style added" (early:has-style 'dummy) #t)

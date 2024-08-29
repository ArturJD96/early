\version "2.24.3"

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
#(early:add-style 'dummy)
#(assert-equals "new early-style added" (early:has-style 'dummy) #t)

%% Copied from 2.25's lily-library.
%% This should be REMOVED when LilyPond reaches 2.26
%% when the code becomes native.
#(define-syntax-public assert
  (lambda (sintax)
    (syntax-case sintax ()
      ((assert condition)
       #'(when (not condition)
           (error (format #f "assertion ~s failed"
                          'condition))))
      ((assert condition message)
       #'(when (not condition)
           (error (format #f "assertion ~s failed with message: ~a"
                          'condition message)))))))
%% Here ends this shameless copy-paste.
#(define (assert-equal actual expected)
  (let ((result (equal? actual expected)))
   (when (not result)
    (error
     (format #f "\n🥀 Assertion failed.\n* expected : ~a\n* actual   : ~a\n"
      expected actual)))))

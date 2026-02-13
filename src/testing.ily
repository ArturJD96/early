\version "2.24.4"
#(use-modules (srfi srfi-64))

%{
%
%   Simple test runner from Guile 3 SFRI-64.
%
%   RATIONALE: LilyPond 2.24.4 still uses Guile 2.2
%   which contains a BROKEN 'test-runner-simple'
%   that I (currently) intend to use.
%
%   When transition to Guile 3 occurs with LilyPond:
    % * use native 'test-runner-simple' methods and delete their definitions here,
%   * Leave 'test-runner-simple-guile3-customized' as is but remove '-guile3-'.
%
% %}


%{
%
% Definitions copied from Guile 3's distribution of SRFI-64.
%
% %}

#(define (test-on-bad-count-simple-guile3 runner actual-count expected-count)
  "Log the discrepancy between expected and actual test counts."
  (format #t "*** Expected to run ~a tests, but ~a was executed. ***~%"
          expected-count actual-count))

#(define (test-on-bad-end-name-simple-guile3 runner begin-name end-name)
  "Log the discrepancy between the -begin and -end suite names."
  (format #t "*** Suite name mismatch: test-begin (~a) != test-end (~a) ***~%"
          begin-name end-name))

#(define (test-on-final-simple-guile3 runner)
  "Display summary of the test suite."
  (display "*** Test suite finished. ***\n")
  (for-each (λ (x)
              (let ((count ((cdr x) runner)))
                (when (> count 0)
                  (format #t "*** # of ~a: ~a~%" (car x) count))))
            `(("expected passes    " . ,test-runner-pass-count)
              ("expected failures  " . ,test-runner-xfail-count)
              ("unexpected passes  " . ,test-runner-xpass-count)
              ("unexpected failures" . ,test-runner-fail-count)
              ("skips              " . ,test-runner-skip-count))))

#(define (test-on-group-begin-simple-guile3 runner suite-name count)
  "Log that the group is beginning."
  (format #t "*** Entering test group: ~a~@[ (# of tests: ~a) ~] ***~%"
          suite-name count))

#(define (test-on-group-end-simple-guile3 runner)
  "Log that the group is ending."
  ;; There is no portable way to get the test group name.
  (format #t "*** Leaving test group: ~a ***~%"
          (car (test-runner-group-stack runner))))

#(define (test-on-test-begin-simple-guile3 runner)
  "Do nothing."
  #f)

#(define (test-on-test-end-simple-guile3 runner)
  "Log that test is done."
  (define (maybe-print-prop prop pretty?)
    (let* ((val (test-result-ref runner prop))
           (val (string-trim-both
                 (with-output-to-string
                   (λ ()
                     (if pretty?
                         (pretty-print val #:per-line-prefix "             ")
                         (display val)))))))
      (when val
        (format #t "~a: ~a~%" prop val))))

  (let ((result-kind (test-result-kind runner)))
    ;; Skip tests not executed due to run list.
    (when result-kind
      (format #t "* ~:@(~a~): ~a~%"
              result-kind
              (test-runner-test-name runner))
      (unless (member result-kind '(pass xfail))
        (maybe-print-prop 'source-file    #f)
        (maybe-print-prop 'source-line    #f)
        (maybe-print-prop 'source-form    #t)
        (maybe-print-prop 'expected-value #f)
        (maybe-print-prop 'expected-error #t)
        (maybe-print-prop 'actual-value   #f)
        (maybe-print-prop 'actual-error   #t)))))

%{
%   Define early's test runner
%   (currently based on test-runner-simple).
%
%   TO DO:
%   – improve formatting of the test results:
%       * make "accumulative" test group per file (and inner tests as a group),
%       * passed test are hidden (is it a good solution?),
%       * nested tests have deeper intendation.
%   – remove redundant code (after update to Guile 3)
% %}
#(define (early:test-runner)
  "Creates a new simple test-runner, that prints errors and a summary on the
standard output port."
  (let ((r (test-runner-simple)))
    (test-runner-reset r)

    (test-runner-on-bad-count!    r test-on-bad-count-simple-guile3)
    (test-runner-on-bad-end-name! r test-on-bad-end-name-simple-guile3)
    (test-runner-on-final!        r test-on-final-simple-guile3)
    (test-runner-on-group-begin!  r
     (lambda (runner suite-name count)
      (newline)
      (test-on-group-begin-simple-guile3 runner suite-name count)
     ))
    (test-runner-on-group-end!    r test-on-group-end-simple-guile3)
    (test-runner-on-test-begin!   r test-on-test-begin-simple-guile3)
    (test-runner-on-test-end!     r test-on-test-end-simple-guile3)

    ;(test-runner-run-list!        r (make-parameter #f))
    r))

%{
% Setting the test runner to our early's.
% %}
#(test-runner-factory
  (lambda () (early:test-runner)))

#(define-syntax-rule (testing name body ...)
  (begin
   (test-begin name)
    (let () body ...)
   (test-end name)
))

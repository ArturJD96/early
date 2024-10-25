\version "2.24.3"

#(define-public all-mensurations '())

#(define-public (add-mensuration
  signum time-signature modus tempus prolatio proportio other proc)
  (let* ((args (list signum time-signature modus tempus prolatio proportio other proc))
         (tests (list number-or-string? pair? boolean? boolean? boolean? number? alist? procedure?))
         (defaults '("C" (4 . 4) () () () 1 () ()))
         (cars '(() time-signature-dummy -2 -1 0 proportio () ()) ) ; null is ignored in initial assignment.
         (alist (filter-map
                 (lambda (arg test default adress)
                  (if (or (null? arg) (null? adress))
                   #f
                   (cons adress (if (test arg) arg default))))
                 args
                 tests
                 defaults
                 cars))
         (mensura-properties (if (null? other)
                              alist
                              (append alist other))))
   ;; side-effect!
   (set! all-mensurations
    (assoc-set! all-mensurations signum alist))

  ;; NOTE: by now, I ignore time-signature and procedure.
  ;;       How to deal with it?

))

#(define-public (ly:time-signature::print-with-proportio grob)
  "Prints standart LilyPond's time signature but includes appends the proportio number stencil as well."
  ;; TO DO: finish.
  (ly:time-signature::print grob))

#(define-public (ly:time-signature::print-dummy grob)
  (ly:time-signature::print grob))

#(for-each
  (lambda (args) (apply add-mensuration args))
  '(;; https://wiki.ccarh.org/wiki/MuseData_Example:_mensural_signs
    ("O" (3 . 2) () #t #f 1 () ly:time-signature::print)
    ("O:" (3 . 2) () #t #f 1 () ly:time-signature::print-dummy) ;; After humdrum *met (https://wiki.ccarh.org/images/9/9f/Stage2-specs.html)
    ("O." (9 . 4) () #t #t 1 () ly:time-signature::print) ;; After humdrum *met (https://wiki.ccarh.org/images/9/9f/Stage2-specs.html)
    ("O:." (9 . 4) () #t #t 1 () ly:time-signature::print-dummy)
    ("C" (4 . 4) () #f #f 1 () ly:time-signature::print)
    ("C." (6 . 4) () #f #t 1 () ly:time-signature::print)
    ("Cr" (4 . 8) () #f #f 1 () ly:time-signature::print) ;; After humdrum *met (https://wiki.ccarh.org/images/9/9f/Stage2-specs.html)
    ("C|" (2 . 2) () #f #f 1/2 () ly:time-signature::print)
    ("C2" (4 . 4) #f #f #f 1/2 () ly:time-signature::print-with-proportio)
    ("O2" (3 . 2) #t #f #f 1 () ly:time-signature::print-with-proportio)
    ("O|" (3 . 2) () #t #f 1/2 () ly:time-signature::print)
    ("C|3" (2 . 2) #t #f #f 1/2 () ly:time-signature::print-with-proportio) ;; ??? What about C3?
    (3 (3 . 1) () () () 3/2 () ly:time-signature::print)
    (3/2 (3 . 1) () () () 3/2 () ly:time-signature::print)
    ("C|2" (4 . 4) #f #f #f 1/2 () ly:time-signature::print-with-proportio) ;; ??? is it the same as C2 or prop should be 1/4?
    ("Oo" (3 . 2) #f #t #f 4/3 () ly:time-signature::print-dummy) ;; After humdrum *met (https://wiki.ccarh.org/images/9/9f/Stage2-specs.html)
    ;; Lilypond remaining (see: https://wiki.ccarh.org/wiki/MuseData_Example:_mensural_signs)
    ("C|." (6 . 8) () #f #t 1/2 () ly:time-signature::print-with-proportio)
    ("O|." (9 . 8) () #t #t 1/2 () ly:time-signature::print-with-proportio)
    ;; ignored by now: LilyPond's 2/4 (C|r)
    ;; No time signature
    ("X" (1 . 1) #f #f #f 1 () ly:time-signature::print-x))
)

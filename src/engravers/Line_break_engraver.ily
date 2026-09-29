\version "2.24.4"

%{
    TO DO:
    – bar line in "barify" should be a custom one.
    – read all the comments.
    – add support for custos in breaking algorithm.
    – explicit barlines do not show.
    – custos does not show if the next note is rest...
    – spacing-alist is not taken into account.
%}

% NOTE: requires 'barify' to work with music.

#(define (grob-width grob)

;; Not reading from Score context... get it better from EarlyVoice!  (let ((extent (ly:grob-property grob 'X-extent))
        (extra (ly:grob-property grob 'extra-spacing-width))
        (padding (ly:grob-property grob 'padding)))

   (define (limit n)
    (if (inf? n) 0 n))

   (define (width space)
    (if (null? space)
     0
     (+ (limit (- (car space)))
        (limit (cdr space)))))

   (+ (width extent)
      (width extra)
      (if (null? padding) 0 padding))
))

#(define-public (early:Line_break_engraver context)

  (define (calc-system-width grob)
   (let* ((right-margin 1) ;; HAVING A WANNA-BE PROPERTY HERE IS VERY PROBLEMATIC, find og ly setting (perhaps space-alist.right-edge). ;; IMPORTANT!!!
          (mom (ly:context-current-moment context))
          (first-system? (moment<=? mom ZERO-MOMENT))
          (indent-type (if first-system? 'indent 'short-indent))
          (layout (ly:grob-layout grob))
          (line-width (ly:output-def-lookup layout 'line-width))
          (indent (ly:output-def-lookup layout indent-type 0)))
    (- line-width
       indent
       right-margin)))

  (let* ((x 0) ;; SHOULD BE: minus clef!
            ;; Current X offset from the beginning of the line.
         (breaks #f)
            ;; Is a break happening now?
         (line-width '()) ;; SHOULD BE: minus custos!
            ;; Speculated line-width of the current system.
         (break-line! (lambda (x-init)
                       (set! breaks #t)
                       (set! x x-init)))
         (step (lambda (grob)
                (when (null? line-width) (set! line-width (calc-system-width grob)))
                (let* ((width (grob-width grob))
                       (new-x (+ x width)))
                 (if (< new-x line-width)
                  (set! x new-x)
                  (break-line! width)))))
         (step-only-if-broken (lambda (grob)
                               (when (null? line-width) (set! line-width (calc-system-width grob)))
                               (when breaks
                                (set! line-width (calc-system-width grob))
                                (step grob)))))
   (make-engraver
    (listeners
     ((break-event engraver event)
      (break-line! 0)))
    (acknowledgers

     ((bar-line-interface engraver grob source) ;; make it more precise
      (when breaks
       (set! breaks #f)
       (let ((non-musical-paper-column (ly:context-property context 'currentCommandColumn)))
        (ly:grob-set-property!
         non-musical-paper-column
         'line-break-permission
         'force)))
     )
     ;; Here follow the interfaces of grobs affecting horizontal spacing
     ;; only when line is broken.
     ((non-musical-paper-column-interface engraver grob source)
      (display "\nGROB:")(display x)(display grob))
     ((grob-interface engraver grob source)
      (display "\nGROB:")(display x)(display grob))
     ((ambitus-interface engraver grob source)
      (step-only-if-broken grob))
     ((clef-interface engraver grob source)
      (if (= x 0)
       (step grob)
       (step-only-if-broken grob)))
     ((time-signature-interface engraver grob source)
      ;(display (ly:grob-property grob 'X-extent))
      (step grob))
     ((key-signature-interface engraver grob source)
      (step grob))
     ((custos-interface engraver grob source)
      ;; Custos does not affect spacing but should!
      ;; Note that it is created AFTER line-breaking
      ;; occurs, so it will be tricky to implement.]
      ;; PS.
      ;; Custos is placed at the _very last moment_ on the staff-bar
      ;; i.e. when the last (note) item with x-extent has already been placed.
      '())
     ;; Here follow the interfaces of grobs affecting horizontal spacing
     ;; when music time flows.
     ((ledger-line-spanner-interface engraver grob source)
      (step-only-if-broken grob))
     ((dots-interface engraver grob source)
      ;; WHen there is enough space, dot does not increase spacing.
      ;; Thus what is below is incorrect;
      ;; I should check first if the dot causes any x increase
      ;; (i.e. when dot's x-extent/grob width is smaller than it's host's note column extent.)
      ;; 2025: dots do not influence space unless in EarlyVoice.
      (step grob))
     ((dot-column-interface engraver grob source)
      ;(display source)
      ;(display (ly:grob-property grob 'padding))
      ;(display (ly:engraver-make-grob engraver 'Dot grob))
      (step grob))
     ((rhythmic-grob-interface engraver grob source)
      (step grob))
     ;((note-column-interface engraver grob source)
      ;; Well, changing e.g. NoteHeads extra-width-offset
      ;; does not affect note column width.
      ;; Should I just get the bigger available value
      ;; (i.e. notehead vs stem vs column vs dot???)?
      ;(step grob))
    )
)))

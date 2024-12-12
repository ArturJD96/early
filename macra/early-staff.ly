%% Based on Neil Puttock's staff line coloring.
%% http://lsr.di.unimi.it/LSR/Item?id=700

\version "2.24.3"

#(define-public (jagged-line x-start-stop-pair thickness)

  (let* ((x-begin (car x-start-stop-pair))
         (x-end (cdr x-start-stop-pair))
         (random-state (random-state-from-platform))
         ;; randomization settings
         (step-min 0.25)
         (extremity 0.75)
         ;; basic form
         (staff-line-stencil (make-line-stencil thickness x-begin 0 x-end 0))
        )

   (let blur-stencil ((x-curr x-begin))
    (let* ((step (+ step-min (random 0.666 random-state)))
           (x-expected (+ x-curr step))
           (stop-condition (> x-expected x-end))
           (x-next (if stop-condition x-end x-expected)))

     (set! staff-line-stencil
      (ly:stencil-add
        staff-line-stencil
        ;(ly:round-polygon
        ; (list (cons x-curr (- thickness))
        ;       (cons (+ x-curr step) thickness))
        ; 0 ;blot
        ; 0 ;extroversion
        ; #t))) ; filled
        (make-line-stencil
         thickness ;(/ thickness extremity)
         x-curr
         (* extremity
            (- thickness
               (random (* 2. thickness) random-state)))
         x-next
         (* extremity
            (- thickness
               (random (* 2. thickness) random-state)))
     )))

     ; Nota bene: different approach would be to assemble
     ; the polygon from which the staff line is constructed.

     ;; loop back
     (when (not stop-condition)
           (blur-stencil (- x-next (random step)))
     )

   ))
   staff-line-stencil)
)


#(define-public (delicate-jagged-line x-start-stop-pair thickness)

    ;; TO DO: this is exact coppy of jagged-line.
    ;; It should be merged with jagged-line
    ;; and the properties should be abstracted.

  (let* ((x-begin (car x-start-stop-pair))
         (x-end (cdr x-start-stop-pair))
         (random-state (random-state-from-platform))
         ;; randomization settings
         (step-min 0.166)
         (extremity 0.333)
         ;; basic form
         (staff-line-stencil (make-line-stencil thickness x-begin 0 x-end 0))
        )

   (let blur-stencil ((x-curr x-begin))
       (let* ((step (+ step-min (random 0.666 random-state)))
              (x-expected (+ x-curr step))
              (stop-condition (> x-expected x-end))
              (x-next (if stop-condition x-end x-expected)))

         (set! staff-line-stencil
          (ly:stencil-add
           staff-line-stencil
           ;(ly:round-polygon
           ; (list (cons x-curr (- thickness))
           ;       (cons (+ x-curr step) thickness))
           ; 0 ;blot
           ; 0 ;extroversion
           ; #t))) ; filled
           (make-line-stencil
            thickness ;(/ thickness extremity)
            x-curr
            (* extremity
               (- thickness
                  (random (* 2. thickness) random-state)))
            x-next
            (* extremity
               (- thickness
                  (random (* 2. thickness) random-state)))
            )))

            ; Nota bene: different approach would be to assemble
            ; the polygon from which the staff line is constructed.

         ;; loop back
         (when (not stop-condition)
               (blur-stencil (- x-next (random step) )))))

     staff-line-stencil))



#(define-public (penned-line x-start-stop-pair thickness)

  (let* ((x-begin (car x-start-stop-pair))
         (x-end (cdr x-start-stop-pair))
         (x-middle (+ (/ (- x-end x-begin) 2) x-begin))
        )

   (ly:round-polygon
    (list (cons x-begin 0)
          (cons x-middle (/ thickness 2))
          (cons x-end 0)
          (cons x-middle (- (/ thickness 2))))
    0 0 #t) ;; blot, extroversion, filled

))



#(define-public ((early-staff . stencil-func) grob)

  (define (index-cell cell dir)
   (if (equal? dir RIGHT)
       (cdr cell)
       (car cell)))

  (define (index-set-cell! x dir val)
   (case dir ((-1) (set-car! x val))
             ((1) (set-cdr! x val))))

  ; Get lilypond properties
  ; used for the default
  ; staff system grob creation.
  (let* ((common (ly:grob-system grob))
         (span-points '(0 . 0))
         (thickness (* (ly:grob-property grob 'thickness 1.0)
                       (ly:output-def-lookup (ly:grob-layout grob) 'line-thickness)))
         (width (ly:grob-property grob 'width))
         (line-positions (ly:grob-property grob 'line-positions))
         (staff-space (ly:grob-property grob 'staff-space 1))
         (total-lines empty-stencil)
         (make-staff-line-stencil (car stencil-func))
        )

   ; Calculation for correct
   ; stafflines appearance.
   (for-each
    (lambda (dir)
     (if (and (= dir RIGHT) (number? width))
      (set-cdr! span-points width)
      (let* ((bound (ly:spanner-bound grob dir))
             (bound-ext (ly:grob-extent bound bound X))
            )
       (index-set-cell! span-points dir
        (ly:grob-relative-coordinate bound common X))
       (if (and (not (ly:item-break-dir bound))
                (not (interval-empty? bound-ext)))
        (index-set-cell! span-points dir
         (+ (index-cell span-points dir)
            (index-cell bound-ext dir) )))
     ))
     (index-set-cell! span-points dir
      (- (index-cell span-points dir)
         (* dir thickness 0.5))))
    (list LEFT RIGHT)
   )

   (set! span-points
    (coord-translate span-points (- (ly:grob-relative-coordinate grob common X)))
   )

   (if (pair? line-positions)
    (for-each
     (lambda (position)
      (set! total-lines
       (ly:stencil-add
        total-lines
        (ly:stencil-translate-axis
         (make-staff-line-stencil span-points thickness)
         (* position staff-space 0.5)
         Y))))
     line-positions)

    (let* ((line-count (ly:grob-property grob 'line-count 5))
           (height (* (1- line-count) (/ staff-space 2)))
          )
     (do ((i 0 (1+ i)))
         ((= i line-count))
      (set! total-lines
       (ly:stencil-add
        total-lines
        (ly:stencil-translate-axis
         (make-staff-line-stencil span-points thickness)
         (- height (* i staff-space))
         Y)))
   )))

   total-lines
))


% ~ ~ ~ TESTING ~ ~ ~

% \new Staff \relative c' {
%   \mark "Default."
%   c1 c1 c1 c1 c1 c1
% }

% \new Staff \relative c' {
%   \override Staff.StaffSymbol.stencil = #(refined-staff jagged-line)
%   \mark "jagged-line"
%   c1 c1 c1 c1 c1 c1
% }

% \new Staff \relative c' {
%   \override Staff.StaffSymbol.stencil = #(refined-staff penned-line)
%   \mark "penned-line"
%   c1 c1 c1 c1 c1 c1
% }

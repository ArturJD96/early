\version "2.24.3"

\include "../definitions/early-styles.ily"
\include "../stencils/noteheads.ly"
\include "../stencils/point-transform.ly"

% #(define (tournai:quadrata grob)
%   (early:quadrata::note-head grob))

%% Quadrata shape
#(define (tournai:quadrata-bottom grob) '((1/3 0.01) (5/6 -0.01) (1 0)) )
#(define (tournai:quadrata-right grob) '((-0.01 1/2) (0 1)) )

#(define (tournai:quadrata-top grob)
  (flip-x (tournai:quadrata-bottom grob)))

#(define (tournai:quadrata-left grob)
  (flip-y (tournai:quadrata-right grob)))

#(define tournai:quadrata-properties
  `((width . 0.6218445)
    (height . 0.7332)
    ;(test . ,tournai:quadrata)
    (path-pipeline . ((bottom . ,tournai:quadrata-bottom)
                      (right . ,tournai:quadrata-right)
                      (top . ,tournai:quadrata-top)
                      (left . ,tournai:quadrata-left)
                      ))
   )
)

%% Rhombus


#(define (tournai:rhombus-side1 grob) '((0.3 0.6)) )
#(define (tournai:rhombus-side2 grob) '((-0.3 0.6)) )

#(define (tournai:rhombus-br grob)
  (let ((r (+ 0.1
              (/ (random 10) 100)
            )))
   (display r)
   (cons `(,r 0.4) (tournai:rhombus-side1 grob))
))
#(define (tournai:rhombus-tr grob) (tournai:rhombus-side2 grob))
#(define (tournai:rhombus-tl grob) (flip-x (tournai:rhombus-side1 grob)))
#(define (tournai:rhombus-bl grob) (flip-y (tournai:rhombus-side2 grob)))

#(define tournai:rhombus-properties
  `((width . 0.6218445)
    (height . 0.7332)
    (path-pipeline . ((side-bottom-right . ,tournai:rhombus-br)
                      (side-top-right . ,tournai:rhombus-tr)
                      (side-top-left . ,tournai:rhombus-tl)
                      (side-bottom-left . ,tournai:rhombus-bl)))
   )
)

#(early:add-notation-style 'tournai
  `((default . blackmensural)
    (quadrata . ,tournai:quadrata-properties)
    (rhombus . ,tournai:rhombus-properties)
   )
)


tournai = {

    \override NoteHead.early-quadrata-properties = #tournai:quadrata-properties
    % \override NoteHead.early-quadrata-drawing-procedures = #(list )


    \override NoteHead.early-quadrata-width = #(lambda (grob) 0.6218445)
    \override NoteHead.early-quadrata-height = #(lambda (grob) 0.7332)

    \override NoteHead.early-quadrata-base =
    #(lambda (grob)
    ;'((0.1 0.03)(0.66 -0.01)(1 0)) )
      (let ((width (ly:grob-property grob 'early-quadrata-width)))
       (list (list width 0))))

    \override NoteHead.early-quadrata-side =
    #(lambda (grob)
      (let ((width (ly:grob-property grob 'early-quadrata-height)))
       (list (list width 0))))

    \override NoteHead.early-quadrata-corner = #(lambda (grob) '((0 0)) )

}

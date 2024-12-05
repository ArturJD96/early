\version "2.24.3"

\include "init.ily"

% styles
\include "styles/tournai.ily"
\include "styles/alamire.ily"

\defineBarLine "|||" #'(#t #f #t)

#(define-public manuscript-red (rgb-color (/ 182 255) (/ 78 255) (/ 69 255)))
#(define-public manuscript-blue (rgb-color (/ 40 255) (/ 38 255) (/ 57 255)))

% notations
whitemensural = {
    \set notation = #'whitemensural
    \set early-style = ##f
    \set implicitColorAfterDurlog = #'()
    \set coloration = #black
    \set colorationSecondary = ##f % for some obscure English manuscripts
}

blackmensural = {
    \set notation = #'blackmensural
    \set early-style = ##f
    \set implicitColorAfterDurlog = #+inf.0
    \set coloration = #manuscript-red
    \set colorationSecondary = #'blue % for some obscure English manuscripts
}

whitehollow = {
    \whitemensural
    \set implicitColorAfterDurlog = 3
}

blackmensuralhollow = {
    \whitemensural
    \set early-style = ##f
    \set implicitColorAfterDurlog = #+inf.0
}

blackmensural-chantilly = {

    % \set notation = #'blackmensural
    \set early-style = #'chantilly
    \set coloration = #'red
    \set colorationSecondary = ##f % for some obscure English manuscripts

    \override NoteHead.early-quadrata-side = #(lambda (grob) '((0.33 0.01)(0.66 -0.01)(1 0)))
    \override NoteHead.early-quadrata-corner = #(lambda (grob) '((0 0)))

}

% quadrata =
% #(define-scheme-function
%   (x y width height) (number? number? (number? quadrata-width) (number? quadrata-height))
%   (let ((pitch-offset (+ (/ y 2) (* (random 0.0666) (if (zero? (random 2)) 1 -1)))))
%    (ly:stencil-rotate
%     (make-filled-box-stencil
%      (cons x (+ x width)) ; x x
%      (cons (- pitch-offset height) (+ pitch-offset height))) ; y y
%      0 0.5 0.5)))

tournai = {

    % \set notation = #'blackmensural
    \set early-style = #'tournai
    \set coloration = #'red
    \set colorationSecondary = ##f

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

    \override NoteHead.early-quadrata-corner = #(lambda (grob) '((0 0)))

}

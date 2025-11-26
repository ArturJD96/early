\version "2.24.4"

fbreak = {
    \tag #'(early:facsimile-breaks) \break
    \tag #'(early:diplomatic-edition) \bar "'" % just an idea...
}

stemU = \tag #'(early:stem-direction) \stemUp
stemD = \tag #'(early:stem-direction) \stemDown
stemN = \tag #'(early:stem-direction) \stemNeutral

oStemU = \tag #'(early:stem-direction) \once \stemUp
oStemD = \tag #'(early:stem-direction) \once \stemDown
oStemN = \tag #'(early:stem-direction) \once \stemNeutral


conjecture =
#(define-music-function
  (reason offset m-dubious m-edited)
  ((string?) (pair? '(1 . 1)) ly:music? ly:music?)

  (let* ((is-skip (music-is-of-type? m-dubious 'SkipEvent))
         (parenthesize (if is-skip parenthesize (lambda (m) m)))) ; this is dummy for now but should include a function that compares dubious and edited music and parenthesize all the differentiating elements.
    #{
        \tag #'early:dubious #m-dubious
        \tag #'early:conjecture $m-edited
        \tag #'early:conjecture-explicit #(if reason
         #{ \footnote #offset #reason #(parenthesize #{ $m-edited #}) #}
         #{ #(parenthesize #{ $m-edited #}) #}
        )
    #}
))

dubious =
#(define-music-function
  (reason offset dubious)
  ((string?) (pair? '(-1 . 2)) ly:music?)

  (conjecture reason offset dubious dubious)
)

% Editorials
facsimile = \keepWithTag #'(early:dubious early:facsimile-breaks early:stem-direction) \etc
fakesimile = \keepWithTag #'(early:conjecture early:facsimile-breaks early:stem-direction) \etc
diplomatic = \keepWithTag #'(early:conjecture-explicit early:stem-direction) \etc

tabulature = \keepWithTag #'() \etc
critical = \keepWithTag #'() \etc
modern = \removeWithTag #'() \etc

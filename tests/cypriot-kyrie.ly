\version "2.24.3"
\include "../early.ly"
\include "../mensural.ly"

% event functions?
div = {}
space = {}

#(define (string-or-numeric? arg)
  (or (number-or-string? arg)
      (pair? arg)))

signum =
#(define-music-function (mensura-code)
                        (string-or-numeric?)
  (let ((ms (if (string? mensura-code)
             mensura-code
             (number->string mensura-code)))
        (tempus '())
        (prolatio '())
        (proportio '()))
   (cond
    ((number-or-pair? mensura-code)
     (set! proportio mensura-code))
    ((string? mensura-code)
     '()))
   #{

    \context EarlyVoice
    \applyContext
    #(lambda (context)
      ;(display ms)
      (ly:context-set-property! context
                                'earlyMensurationSign
                                ms))

    \time 1/2

   #}))

triplum = \displayMusic \mensural #early:ars-subtilior \relative {

    \mensura "O"

    \clef soprano

    % Line 1

    %{\div%} c''\breve b1\div
    a2 e1 a2 a \space g2
    \space a2 g f e e d
    \space f2 g a1 b2 c d c1 b b a

    \mensura 2
    c1 d2 c b a g1 c b b a

    \mensura "O"
    c2 g1 e a2

    % \break

    \mensura 3
    a1 b2
    a1 g8 f
    e1 f8 g

    \mensura "O."
    a\breve f1
    e\breve d2 e\div
    f2 g g f f e
    g1 r g
    a\breve g1
    f2 \space a1 c2 b a
    g2 d'1 c d b

    \mensura 2
    c1 d2 c b a

    % line 2

}

\layout {

    indent = 0
    ragged-right = ##t

    \context { \Score

        \override SpacingSpanner.packed-spacing = ##t

    }

    \context { \EarlyVoice

        #(display "Raz!")

    }

}

\score {<<

    \new EarlyStaff \with {
        instrumentName = "E."
        shortInstrumentName = "E."
    } {
        \new EarlyVoice \triplum
    }

    \new PetrucciStaff \with {
        instrumentName = "P."
        shortInstrumentName = "P."
    } {
        \new PetrucciVoice \repeat unfold 120 { d'2 }
    }

    \new PetrucciStaff {
        \new PetrucciVoice \relative {
            d' d d d
        }
    }

>>}

\version "2.24.3"
\include "../early.ly"
\include "../mensural.ly"

% event functions?
div = {}
space = {}

#(define (string-or-numeric? arg)
  (or (number-or-string? arg)
      (pair? arg)))

triplum = \mensural \relative {

    \clef "petrucci-c1"
    \mensura "O"

    % Line 1

    c''\breve \pdiv b1 % backward punctum divisionis
    a2 e1 a2 a g2
    a2 g f e e d
    f2 g a1 b2 c
    d2 c1 b2 b a

    \proportio 2
    c1 d2 c b a
    g1 c2 b b a

    \mensura "O"
    c2 \[ g1 \flexa e \] g2

    \proportio 3
    a1 b2
    a1 g8*2 f
    e1 f8*2 g

    \mensura "O"
    a\breve f1
    e\breve d2 \pdiv e2
    f2 g g f f e
    g1 r g
    a\breve g1
    f2 a1 c2 b a
    g2 d'1 c2 b a

    \proportio 2
    c1 d2 c b a
    % line 2
    g2 a b a b g

    \proportio 3
    a1 b2
    c1 b8*2 a
    g1 f8*2 g

    \mensura "O"
    e1. a2 a g
    a2 g f e e d8*2 e
    f\maxima\fermata

}

% \layout {

%     indent = 0
%     ragged-right = ##t

%     \context { \Score

%         \override SpacingSpanner.packed-spacing = ##t

%     }

%     \context { \EarlyVoice

%         #(display "Raz!")

%     }

% }

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

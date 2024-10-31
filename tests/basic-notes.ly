\version "2.24.3"
\include "../early.ly"
\include "../mensural.ly"

#(set-global-staff-size 20)

\header {

    title = "Early basic notes"

}

basic_notes = {g'\maxima a g\longa a g\breve a g1 a g2 a g4 a g8 a g16 a16}

\layout {

    \context { \Score
        \override SpacingSpanner.packed-spacing = ##t
    }

}

\new PetrucciStaff \relative c' {

    % \clef tenor

    \mark "Default Petrucci"
    \basic_notes

}

\new EarlyStaff \mensural \relative {

    \mark "white mensural notation (Petrucci)"
    \whitemensural
    \basic_notes

}

\new EarlyStaff \mensural \relative{

    \mark "black mensural notation (Petrucci)"
    \blackmensural
    \basic_notes

}

\new EarlyStaff \mensural \relative{

    \mark "white hollow mensural notation (Petrucci)"
    \whitehollow
    \basic_notes

}

\new EarlyStaff \mensural \relative{

    \mark "blackmensural early noteheads"
    \whitemensural
    \basic_notes

}

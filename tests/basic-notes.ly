\version "2.24.3"
\include "../early.ly"

basic_notes = {c\maxima c\longa c\breve c1 c2 c4 c8}

\new PetrucciStaff \relative c' {

    \clef tenor

    \mark "Default Petrucci"
    \basic_notes

}

\new EarlyStaff \relative c' {

    \clef tenor

    \mark "Early: Basic Notes"
    s1^\markup \fontsize #-5 { white mensural notation }
    \basic_notes

    \bar "|"

    s1^\markup \fontsize #-5 { black mensural notation }
    \basic_notes

}

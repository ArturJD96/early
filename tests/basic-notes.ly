\version "2.24.3"
\include "../early.ly"

#(set-global-staff-size 30)

\header {

    title = "Early basic notes"

}

basic_notes = {a\maxima a\longa a\breve a1 a2 a4 a8}

\new PetrucciStaff \relative c' {

    % \clef tenor

    \mark "Default Petrucci"
    \basic_notes

}

\new EarlyStaff \relative c' {

    % \clef tenor

    \mark "Early: Basic Notes"
    s1^\markup \fontsize #-5 { white mensural notation }
    \basic_notes

    \bar "|"

    s1^\markup \fontsize #-5 { black mensural notation }
    \basic_notes

}
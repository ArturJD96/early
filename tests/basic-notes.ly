\version "2.24.3"
\include "../early.ly"

#(set-global-staff-size 60)

basic_notes = {a\maxima \longa \breve 1 2 4 8}

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

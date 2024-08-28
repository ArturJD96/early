\version "2.24.3"

\include "early_backend/early-interface.ly"
\include "early_backend/EarlyVoice/NoteHead.ly"

\layout {

    \context {

       	\PetrucciVoice

        %% Initialize

       	\name EarlyVoice
       	\alias PetrucciVoice
       	\description "..." % TODO

        %% Properties

       	% \consists Ligature_bracket_engraver
       	\remove Mensural_ligature_engraver
        \override NoteHead.style = #'tournai
        \override NoteHead.stencil = #early:note-head::print

    }

    \context {

       	\PetrucciStaff

        %% Initialize

       	\name EarlyStaff
       	\alias PetrucciStaff
       	\denies Voice
       	\defaultchild EarlyVoice
       	\accepts EarlyVoice
       	\description "..." % TODO

        %% Properties

        \override Stem.neutral-direction = #UP

    }

    \inherit-acceptability EarlyStaff PetrucciStaff
    \inherit-acceptability EarlyVoice PetrucciVoice

}

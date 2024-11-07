\version "2.24.3"

% \include "early_backend/early-interface.ly"
% \include "early_backend/EarlyVoice/NoteHead.ly"

% properties
\include "definitions/context-properties.ily"
\include "definitions/grob-properties.ily"
\include "definitions/early-styles.ily"

% stencils
\include "stencils/noteheads.ly"

% engravers
\include "engravers/Mensura_engraver.ly"
\include "engravers/Tactus_engraver.ly"
\include "engravers/Rest_position_engraver.ly"
\include "engravers/Note_engraver.ly"

% macra
\include "macra/early-staff.ly"


\layout {

    ragged-right = ##t

    \context { \PetrucciVoice

       	\name EarlyVoice
       	\alias PetrucciVoice

        \consists #early:Mensura_engraver
        \consists #early:Tactus_engraver
        \consists #early:Rest_position_engraver
        \consists #early:Note_engraver
        % \remove Mensural_ligature_engraver
       	% \consists Ligature_bracket_engraver

        % \override NoteHead.style = #'tournai
        \override NoteHead.stencil = #early:note-head::print

        \override Flag.stencil = #old-straight-flag

        % \override NoteHead.flag =

        mensura = #'()
        mensuraCompletion = #'()
        % I need this to check if the note has completed current mensura or not.

        tactusLength = #(ly:make-moment 0 0)
        tactusPosition = #(ly:make-moment 0 0)
        tactusStartNow = ##t

        notation = #'blackmensural
        coloration = #'black
        colorationSecondary = #'blue % for some obscure English manuscripts
        % hollow = ##f

       	\description "..." % TODO

    }

    \context { \PetrucciStaff

       	\name EarlyStaff
       	\alias PetrucciStaff
       	\denies Voice
       	\defaultchild EarlyVoice
       	\accepts EarlyVoice

        % \remove Custos_engraver

        % \override StaffSymbol.stencil = #(early-staff jagged-line)

        \override Stem.neutral-direction = #UP
        % \override LedgerLineSpanner.stencil = ##f

        \override TimeSignature.style = #'mensural

       	\description "..." % TODO
    }

    \inherit-acceptability EarlyStaff PetrucciStaff
    \inherit-acceptability EarlyVoice PetrucciVoice

}

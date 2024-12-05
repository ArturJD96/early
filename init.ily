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
\include "engravers/Notation_engraver.ly"
\include "engravers/Mensura_engraver.ly"
\include "engravers/Rest_position_engraver.ly"
\include "engravers/Augmentation_engraver.ly" % check native \shiftDurations

% macra
\include "macra/early-staff.ly"


\layout {

    ragged-right = ##t

    \context { \PetrucciVoice

       	\name EarlyVoice
       	\alias PetrucciVoice

        \consists #early:Notation_engraver
        \consists #early:Mensura_engraver
        \consists #early:Rest_position_engraver

        % \remove Mensural_ligature_engraver
       	% \consists Ligature_bracket_engraver

        \override NoteHead.stencil = #early:note-head::print

        \override Flag.stencil = #old-straight-flag

        mensura = #'()
        mensuraCompletion = #'()

        notation = #'blackmensural
        implicitColorAfterDurlog = 1
        coloration = #manuscript-red
        % colorationSecondary = #manuscript-blue % for some obscure English manuscripts

       	\description "..." % TODO

    }

    \context { \PetrucciStaff

       	\name EarlyStaff
       	\alias PetrucciStaff
       	\denies Voice
       	\defaultchild EarlyVoice
       	\accepts EarlyVoice

        \consists "Bar_engraver"

        % \remove Custos_engraver

        % \override StaffSymbol.stencil = #(early-staff jagged-line)

        \override Stem.neutral-direction = #UP
        % \override LedgerLineSpanner.stencil = ##f

        \override TimeSignature.style = #'mensural

       	\description "..." % TODO

        alterationGlyphs =
        #'((-1/2 . "accidentals.hufnagelM1")
	       (0 . "accidentals.vaticana0")
	       (1/2 . "accidentals.mensural1"))

    }

    \inherit-acceptability EarlyStaff PetrucciStaff
    \inherit-acceptability EarlyVoice PetrucciVoice

}

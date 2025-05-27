\version "2.24.3"

% \include "early_backend/early-interface.ly"
% \include "early_backend/EarlyVoice/NoteHead.ly"

%% properties
\include "definitions/context-properties.ily"
\include "definitions/grob-properties.ily"
\include "definitions/early-styles.ily"

%% stencils
\include "stencils/noteheads.ly"

%% engravers
\include "engravers/Notation_engraver.ly"
\include "engravers/Mensura_engraver.ly"
\include "engravers/Rest_position_engraver.ly"
\include "engravers/Augmentation_engraver.ly" % check native \shiftDurations

%% macra
\include "macra/early-staff.ly"
\include "macra/manuscript-colors.ly"


\layout {

    \context { \PetrucciVoice

       	\name EarlyVoice
       	\alias PetrucciVoice
       	\description "..." % TODO

        % \remove Mensural_ligature_engraver
       	% \consists Ligature_bracket_engraver

        %% Context properties
        %% from 'early' engravers
        \consists #early:Augmentation_engraver
            augmentation = 0
        \consists #early:Mensura_engraver
            mensura = #'()
            mensuraCompletion = #'()
        \consists #early:Notation_engraver
            notation = #'blackmensural
            earlyStyle = #'()
            implicitColorAfterDurlog = 1
            coloration = #black
            colorationSecondary = #'()
        \consists #early:Rest_position_engraver

        %% Grob properties
        \override NoteHead.stencil = #early:note-head::print
        \override Flag.stencil = #old-straight-flag
        \override Stem.neutral-direction = #UP

    }

    \context { \PetrucciStaff

       	\name EarlyStaff
       	\alias PetrucciStaff
       	\denies Voice
       	\defaultchild EarlyVoice
       	\accepts EarlyVoice
       	\description "..." % TODO

        % \remove Custos_engraver

        \consists "Bar_engraver"

        alterationGlyphs =
        #'((-1/2 . "accidentals.hufnagelM1")
	       (0 . "accidentals.vaticana0")
	       (1/2 . "accidentals.mensural1"))

        \override TimeSignature.style = #'mensural
        \override LedgerLineSpanner.stencil = ##f
        \override StaffSymbol.stencil = #(early-staff jagged-line)

    }

    \inherit-acceptability EarlyStaff PetrucciStaff
    \inherit-acceptability EarlyVoice PetrucciVoice

}

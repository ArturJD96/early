\version "2.24.3"

\include "early_backend/early-interface.ly"
\include "early_backend/EarlyVoice/NoteHead.ly"

% engravers
\include "engravers/Mensura_engraver.ly"
\include "engravers/Tactus_engraver.ly"
\include "engravers/Rest_position_engraver.ly"

% Context properties
#(set-object-property! 'mensura 'translation-type? alist?)
#(set-object-property! 'mensuraCompletion 'translation-type? alist?)

#(set-object-property! 'tactusLength 'translation-type? ly:moment?)
#(set-object-property! 'tactusPosition 'translation-type? ly:moment?)
#(set-object-property! 'tactusStartNow 'translation-type? boolean?)

% Check those again if they are still needed:
#(set-object-property! 'earlyBlackmensural 'translation-type? boolean?)
#(set-object-property! 'earlyColor 'translation-type? symbol?)
#(set-object-property! 'earlyHollow 'translation-type? boolean?)
#(set-object-property! 'earlyProportio 'translation-type? number-or-pair?)
#(set-object-property! 'earlyProlatio 'translation-type? symbol?)
#(set-object-property! 'earlyTempus 'translation-type? symbol?)
#(set-object-property! 'earlyModus 'translation-type? symbol?)
#(set-object-property! 'earlyMaximodus 'translation-type? symbol?)

#(set-object-property! 'earlyPerfection 'translation-type? alist?)
#(set-object-property! 'earlyPerfection 'translation-doc?
  "Alist of all possible durations and their default state if perfection is implied (perfect or imperfect)")

#(set-object-property! 'earlyPerfectAsTriplets 'translation-type? alist?)
#(set-object-property! 'earlyPerfectAsTriplets 'translation-doc?
"If notename is set to true, interpret the perfect division as triple. This is useful to reduce the effect of of duration accumulation from quicker notes (e.g. semifusae).")

#(set-object-property! 'earlyMensuraOff 'translation-type? boolean?)
#(set-object-property! 'earlyMensuraOff 'translation-doc?
"Turn off automatic duration mensural recalculation (make it default LilyPond WYSIWYG againg).")

#(define (string-or-numeric? arg)
  (or (number-or-string? arg)
      (pair? arg)))

#(set-object-property! 'earlyMensurationSign 'translation-type? string-or-numeric?)

% Grob properties
#(set-object-property! 'early:blackmensural 'backend-type? boolean?)
#(set-object-property! 'early:color 'backend-type? symbol?)
#(set-object-property! 'early:hollow 'backend-type? boolean?)
#(set-object-property! 'early:proportio 'backend-type? number-or-pair?)
#(set-object-property! 'early:prolatio 'backend-type? symbol?)
#(set-object-property! 'early:tempus 'backend-type? symbol?)

#(set-object-property! 'early:perfect-flag 'backend-type? boolean?)
#(set-object-property! 'early:altered-flag 'backend-type? boolean?)
#(set-object-property! 'early:punctum-divisionis 'backend-type? boolean?)


#(define (early:note-head::print grob)
  (ly:note-head::print grob))


\layout {

    ragged-right = ##t

    \context { \PetrucciVoice

       	\name EarlyVoice
       	\alias PetrucciVoice

        \consists #early:Mensura_engraver
        \consists #early:Tactus_engraver
        \consists #early:Rest_position_engraver
        % \remove Mensural_ligature_engraver
       	% \consists Ligature_bracket_engraver
        % \override NoteHead.style = #'tournai
        \override NoteHead.stencil = #early:note-head::print

        mensura = #'()
        mensuraCompletion = #'()
        % I need this to check if the note has completed current mensura or not.

        tactusLength = #(ly:make-moment 0 0)
        tactusPosition = #(ly:make-moment 0 0)
        tactusStartNow = ##t

        earlyBlackmensural = ##t
        earlyColor = #'white
        earlyHollow = ##f
        % earlyMaximodus = #'imperfectum
        % earlyModus = #'imperfectum
        % earlyTempus = #'imperfectum
        % earlyProlatio = #'maior
        % earlyProportio = ##f

        % earlyPerfection =
        % #'((maxima . #f)
        %    (longa . #f)
        %    (brevis . #f)
        %    (semibrevis . #f)
        %    (minima . #f)
        %    (semiminima . #f)
        %    (fusa . #f)
        %    (semifusa . #f))

        % earlyPerfectAsTriplets =
        % #'((maxima . #f)
        %     (longa . #f)
        %     (brevis . #f) ; tempus division
        %     (semibrevis . #f) ; prolatio division
        %     (minima . #f) ; below prolatio
        %     (semiminima . #f)
        %     (fusa . #t)
        %     (semifusa . #t))

        % \override NoteHead.stencil = #(lambda (grob) (display "DWA\n") ly:note-head::print)

       	\description "..." % TODO
    }

    \context { \PetrucciStaff

       	\name EarlyStaff
       	\alias PetrucciStaff
       	\denies Voice
       	\defaultchild EarlyVoice
       	\accepts EarlyVoice

        \remove Custos_engraver

        \override Stem.neutral-direction = #UP
        \override LedgerLineSpanner.stencil = ##f

        \override TimeSignature.style = #'mensural

        % early-color-black = color...

       	\description "..." % TODO
    }

    \inherit-acceptability EarlyStaff PetrucciStaff
    \inherit-acceptability EarlyVoice PetrucciVoice

}

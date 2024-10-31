\version "2.24.3"

% \include "early_backend/early-interface.ly"
% \include "early_backend/EarlyVoice/NoteHead.ly"

% tools
\include "macra/early-staff.ly"

% engravers
\include "engravers/Mensura_engraver.ly"
\include "engravers/Tactus_engraver.ly"
\include "engravers/Rest_position_engraver.ly"
\include "engravers/Note_engraver.ly"

% Context properties
#(set-object-property! 'mensura 'translation-type? alist?)
#(set-object-property! 'mensuraCompletion 'translation-type? alist?)

#(set-object-property! 'tactusLength 'translation-type? ly:moment?)
#(set-object-property! 'tactusPosition 'translation-type? ly:moment?)
#(set-object-property! 'tactusStartNow 'translation-type? boolean?)

% Check those again if they are still needed:
#(set-object-property! 'notation 'translation-type? symbol?)
#(set-object-property! 'coloration 'translation-type? symbol?)
#(set-object-property! 'colorationSecondary 'translation-type? symbol?)
% #(set-object-property! 'hollow 'translation-type? boolean?)

% ...!!! Those: implement in \mensural
#(set-object-property! 'earlyMensuraOff 'translation-type? boolean?)
#(set-object-property! 'earlyMensuraOff 'translation-doc?
"Turn off automatic duration mensural recalculation (make it default LilyPond WYSIWYG againg).")

% Grob properties
#(set-object-property! 'early:notation-type 'backend-type? symbol?)
#(set-object-property! 'early:color 'backend-type? symbol?)
#(set-object-property! 'early:hollow 'backend-type? boolean?)

#(define (early:note-head::print grob)
  ;(let ((context (ly:grob-property grob 'context)))
   ;(display context))
  (ly:note-head::print grob))


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

        \override StaffSymbol.stencil = #(early-staff jagged-line)

        \override Stem.neutral-direction = #UP
        % \override LedgerLineSpanner.stencil = ##f

        \override TimeSignature.style = #'mensural

       	\description "..." % TODO
    }

    \inherit-acceptability EarlyStaff PetrucciStaff
    \inherit-acceptability EarlyVoice PetrucciVoice

}


% Helpful commands

whitemensural = {
    \set notation = #'whitemensural
    \set coloration = #'fill
    \set colorationSecondary = ##f % for some obscure English manuscripts
}

blackmensural = {
    \set notation = #'blackmensural
    \set coloration = #'red
    \set colorationSecondary = #'blue % for some obscure English manuscripts
}

whitehollow = {
    \set notation = #'whitehollow
    \set coloration = #'fill
    \set colorationSecondary = ##f % for some obscure English manuscripts
}

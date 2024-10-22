\version "2.24.3"

\include "early_backend/early-interface.ly"
\include "early_backend/EarlyVoice/NoteHead.ly"

% Context properties
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

#(define (duration->name dur)
  (case (ly:duration-log dur)
   ((-3) 'maxima)
   ((-2) 'longa)
   ((-1) 'brevis)
   ((0) 'semibrevis)
   ((1) 'minima)
   ((2) 'semiminima)
   ((3) 'fusa)
   ((4) 'semifusa)))

% #(define (

testParser = #(define-music-function (m) (ly:music?)
 (music-map (lambda (m) m) m))

% early custom engraver
#(define Early_mensura_engraver
  (make-engraver
   ;((initialize engraver)
   ; (let* ((context (ly:translator-context engraver)))
   ;  (display "CHUJ ONCE!\n")
   ;))
   (listeners
   ; ((time-signature-event engraver event)
   ;  (let* ((context (ly:translator-context engraver))
   ;         (tempus (ly:context-property context 'earlyTempus))
   ;         (proportio (ly:context-property context 'earlyProportio)))
   ;   (display "CHUJ\n")))
    ((note-event engraver event)
     (let* ((cause (ly:event-property event 'music-cause))
            (dur (ly:event-property event 'duration))
            (dur-log (ly:duration-log dur))
            ;(dur-dotcount (ly:duration-dot-count dur))
            ;(dur-factor (ly:duration-factor dur))
            (dur-name (duration->name dur))

            ; early context properties
            (context (ly:translator-context engraver))
            (blackmensural (ly:context-property context 'earlyBlackmensural))
            (color (ly:context-property context 'earlyColor))
            (hollow (ly:context-property context 'earlyHollow))
            (proportio (ly:context-property context 'earlyProportio))
            (perfection (ly:context-property context 'earlyPerfection))

            (prolatio (ly:context-property context 'earlyProlatio))
            (tempus (ly:context-property context 'earlyTempus))
            (modus (ly:context-property context 'earlyModus))
            (maximodus (ly:context-property context 'earlyMaximodus))

            (mensura-allows-perfection (case dur-log
                                        ((-3) (eq? maximodus 'perfectum))
                                        ((-2) (eq? modus 'perfectum))
                                        ((-1) (eq? tempus 'perfectum))
                                        ((0)  (eq? prolatio 'maior))
                                        (else #t)))
            (color-allows-perfection (eq? color (if blackmensural 'black 'white)))

            (default-perfection (assoc-ref perfection dur-name))
            (perfect-flag (ly:event-property event 'early:perfect-flag))
            (imperfect-flag (ly:event-property event 'early:perfect-flag))

            (is-note-perfect (and mensura-allows-perfection
                                  color-allows-perfection
                                  (or perfect-flag
                                      (and default-perfection
                                           (not imperfect-flag)))))

            (as-triplets (ly:context-property context 'earlyPerfectAsTriplets))

            (altered-flag (ly:event-property event 'early:altered-flag))
            (div (ly:context-property context 'early:punctum-divisionis))
           )
      ;(display (ly:duration-compress dur 3/2))
      ; modify rythms changes here.
      ;(for-each
      ; (lambda (p) (display p)) perfection)
      ;(if blackmensural
      ; (begin
      ;  (display (null? is-note-perfect))
      ;  (if (and default-perfection
      ;           (or (null? is-note-perfect)
      ;               is-note-perfect))
      ;      ;; BUT ADD PROLATIO !!!
      ;(display-scheme-music cause)
      (ly:music-set-property! cause 'length (ly:make-moment 1/2))
      ;(when is-note-perfect
      ; (newline)
      ; (display (ly:event-property event 'length))
      ; (ly:event-set-property! event 'length 1))

       ;(display (ly:event-property event 'length)))
        ;'(duration-length (ly:event-property event 'duration))))
       ;
       ;(set! dur (ly:duration-compress dur 3/2))
    ))

   )
   (acknowledgers
    ((time-signature-interface engraver grob source-engraver)
     (let* ((context (ly:translator-context engraver))
            (proportio (ly:context-property context 'earlyProportio))
            (tempus (ly:context-property context 'earlyTempus)))
      (display tempus)
      (ly:grob-set-property! grob 'early:proportio proportio)
      (ly:grob-set-property! grob 'early:tempus tempus)))
    ((note-head-interface engraver grob source-engraver)
     ; (display "TRZY\n")
     (let* ((context (ly:translator-context engraver))
            (color (ly:context-property context 'earlyColor))
            (proportio (ly:context-property context 'earlyProportio))
            (tempus (ly:context-property context 'earlyTempus)))
      (case color
       ((white)
        (ly:grob-set-property! grob 'early:color 'white))
       ((black)
        (ly:grob-set-property! grob 'early:color 'black))
       (else ":("))))
    ;((early-interface engraver grob source-engraver)
    ; (display source-engraver)))))
)))

\layout {

    \context { \PetrucciVoice

       	\name EarlyVoice
       	\alias PetrucciVoice

        % \consists #testParser

        \remove Custos_engraver
        \consists #Early_mensura_engraver
        \remove Mensural_ligature_engraver
       	% \consists Ligature_bracket_engraver
        % \override NoteHead.style = #'tournai
        % \override NoteHead.stencil = #early:note-head::print

        earlyBlackmensural = ##t
        earlyColor = #'black
        earlyHollow = ##f
        earlyMaximodus = #'imperfectum
        earlyModus = #'imperfectum
        earlyTempus = #'imperfectum
        earlyProlatio = #'maior
        earlyProportio = ##f

        earlyPerfection =
        #'((maxima . #f)
           (longa . #f)
           (brevis . #f)
           (semibrevis . #f)
           (minima . #f)
           (semiminima . #f)
           (fusa . #f)
           (semifusa . #f))

        earlyPerfectAsTriplets =
        #'((maxima . #f)
            (longa . #f)
            (brevis . #f) ; tempus division
            (semibrevis . #f) ; prolatio division
            (minima . #f) ; below prolatio
            (semiminima . #f)
            (fusa . #t)
            (semifusa . #t))

        % \override NoteHead.stencil = #(lambda (grob) (display "DWA\n") ly:note-head::print)

       	\description "..." % TODO
    }

    \context { \PetrucciStaff

       	\name EarlyStaff
       	\alias PetrucciStaff
       	\denies Voice
       	\defaultchild EarlyVoice
       	\accepts EarlyVoice

        \override Stem.neutral-direction = #UP
        \override LedgerLineSpanner.stencil = ##f

        % early-color-black = color...
        \remove Custos_engraver

       	\description "..." % TODO
    }

    \inherit-acceptability EarlyStaff PetrucciStaff
    \inherit-acceptability EarlyVoice PetrucciVoice

}

\version "2.24.3"


% #(define (noteheads '(
%   (maxima . -3)
%   (longa . -2)
%   (breve . -1)
%   (


#(define (add-flag! engraver stem)
"
Add flag to stem grob
This procedure replicates flag grob creation
as found in stem-engraver.cc.
"
 (when (null? (ly:grob-object stem 'flag))
  (let ((flag (ly:engraver-make-grob engraver 'Flag stem)))
   (ly:grob-set-parent! flag X stem)
   (ly:grob-set-property! stem 'flag flag)
   flag))
)


#(define-public (early:Notation_engraver context)
"
This Engraver handles setting correct early grob
rhythmic-event properties based on event duration.

The rhythmic-event's 'duration property is modified
to accomodate appeance of a correct notehead, stems
and number of flags and then compensated by factor.

The original value of 'duration is retained in the
'early:duration property accessed by early:GROB::print
when needed.

Also, a relevant properties for choosing a right
note head (ink-color & hollow properties) are set.
There are all delegated to early:GROB::print functions.
"
 (let (;; Lilypond static info
       (first-ly-durlog-with-visible-stem 1) ;; not counting ly's longa and maxima stems
       (ly-implicit-color-after-durlog 1)
       (first-ly-durlog-with-flag 3))

  (make-engraver

   (acknowledgers

    ;((flag-interface engraver grob source)
    ; (display (ly:grob-property grob 'duration-log))
    ;)

    ((note-head-interface engraver grob source)
     (let* (;; context properties
            (notation (ly:context-property context 'notation))
            (early-style (ly:context-property context 'early-style))
            (coloration (ly:context-property context 'coloration))
            (coloration-secondary (ly:context-property context 'colorSecondary))
            (implicit-color-after-durlog (ly:context-property context 'implicitColorAfterDurlog))
            ;; grob related
            (style (ly:grob-property grob 'style))
            ; (dur-log (ly:grob-property grob 'duration-log)) ;; stops at '2'!
            ;; event related
            (event (ly:grob-property grob 'cause))
            (dur (ly:event-property event 'duration))
            (dur-log (ly:duration-log dur))
            (mensura-properties (ly:event-property event 'early:mensura-properties))
            ;; early mensura related
            (color (assoc-ref mensura-properties 'color))
            (color-minor (assoc-ref mensura-properties 'color-minor))
            (color-secondary (assoc-ref mensura-properties 'color-secondary))
            (hollow (assoc-ref mensura-properties 'hollow)))
            ;(style (ly:grob-property grob 'style))
            ;

      (unless mensura-properties
       (ly:error "EarlyVoice without \\mensural.\n(Note: This crashing error will be removed soon with intention to make \\early contexts independent of \\mensural calculations)."))

      ;; Set notehead properties
      (ly:grob-set-property! grob 'early-notation-type notation)
      (ly:grob-set-property! grob 'early-style early-style)
      (ly:grob-set-property! grob 'early-hollow hollow)
      (ly:grob-set-property! grob 'early-color
       (cond ((or color color-minor) coloration)
              (color-secondary coloration-secondary)))

      ;; correct note implicit diminution color.
      (cond
       ((null? implicit-color-after-durlog) '())
       ((not implicit-color-after-durlog) '())
       ((= implicit-color-after-durlog ly-implicit-color-after-durlog) '())
       ((> implicit-color-after-durlog ly-implicit-color-after-durlog) '())
        ;; This should not happend for a too fast values
       ((< implicit-color-after-durlog ly-implicit-color-after-durlog)
        (when (> dur-log implicit-color-after-durlog)
         (ly:grob-set-property! grob 'duration-log (1- dur-log)))))

      (case notation
       ((whitemensural)
        (when (and (eq? style 'petrucci)
                   implicit-color-after-durlog
                   (> dur-log implicit-color-after-durlog))
         (ly:grob-set-property! grob 'style 'blackpetrucci)))

       ((blackmensural)
        ;; Use native blackpetrucci if possible (important for ligatures!)
        (when (eq? style 'petrucci)
         (if (and (or implicit-color-after-durlog
                      (null? implicit-color-after-durlog))
                  (> dur-log implicit-color-after-durlog))
          (begin (ly:grob-set-property! grob 'style 'petrucci)
                 (ly:grob-set-property!
          (ly:grob-set-property! grob 'style 'blackpetrucci)

       )
       ((whitehollow)
        ;; Based on Attaingnant's "Tabulature pour le jeu d'orgues".
        (when (and (> dur-log 1) (< dur-log 5))
         (ly:grob-set-property! grob 'duration-log 1))
       )
      )

    ))

    ((stem-interface engraver grob source)

     (let (;; context properties
           (notation (ly:context-property context 'notation))
           (early-style (ly:context-property context 'early-style))
           (coloration (ly:context-property context 'coloration))
           (coloration-secondary (ly:context-property context 'colorSecondary))
           (implicit-color-after-durlog (ly:context-property context 'implicitColorAfterDurlog))
           ;; grob info
           (dur-log (ly:grob-property grob 'duration-log)))
      ;; Many types of notation display stem nad flags
      ;; at different moments of the note duration progression.
      ;;
      ;; Not only we need to adjust stem's 'duration-log property
      ;; to match it's appearance with notes', but also
      ;; we need to create flag object if it appears "earlier"
      ;; compared to the lilypond's default grob creation.
      ;;
      ;; The 'implicitColorAfterDurlog context property
      ;; governs on how the implicit coloration and stem
      ;; influence the note shape.
      (cond
       ((null? implicit-color-after-durlog) ;; prop not set.
        '())
       ((not implicit-color-after-durlog) ;; prop set to #f (no implicit color at all.)
        (when (> dur-log 1)
         (set! dur-log (1+ dur-log))
         (add-flag! engraver grob)
         (ly:grob-set-property! grob 'duration-log dur-log)
        ))
       ((= implicit-color-after-durlog ly-implicit-color-after-durlog) ;; prop same as default.
        '())
       ((< implicit-color-after-durlog ly-implicit-color-after-durlog) ;; coloring happens earlier in chain
        (set! dur-log (1- dur-log))
        (ly:grob-set-property! grob 'duration-log dur-log))
       ((> implicit-color-after-durlog ly-implicit-color-after-durlog)
        (set! dur-log (1+ dur-log))
        (ly:grob-set-property! grob 'duration-log dur-log))
       (else (display implicit-color-after-durlog) '()))
      )

    )) ;; end of stem-interface
)))

\version "2.24.3"

%{



%}

#(define first-ly-durlog-with-visible-stem 1) % not counting ly's longa and maxima stems
#(define implicit-color-default 1)
#(define last-ly-durlog-without-flag 2)
#(define first-ly-durlog-with-flag 3)
#(define max-dur-log -3)


#(define (add-flag! engraver stem)
"Add flag to stem grob
This procedure replicates flag grob creation
as found in stem-engraver.cc."
 (when (null? (ly:grob-object stem 'flag))
  (let ((flag (ly:engraver-make-grob engraver 'Flag stem)))
   (ly:grob-set-parent! flag X stem)
   (ly:grob-set-property! stem 'flag flag)
   flag))
)


#(define (adjust-petrucci-notehead! notation notehead dur-log implicit-color)

  (case notation
   ((whitemensural)
    (ly:grob-set-property! notehead 'style 'petrucci)
    (cond ((> dur-log implicit-color)
           (ly:grob-set-property! notehead 'style 'blackpetrucci)
           (when (>= implicit-color max-dur-log)
            (ly:grob-set-property! notehead 'duration-log (1- dur-log))))
          ((> dur-log implicit-color-default)
           (ly:grob-set-property! notehead 'duration-log 1)) ))
   ((blackmensural)
    (ly:grob-set-property! notehead 'style 'blackpetrucci)
    (cond ((> dur-log implicit-color)
           (ly:grob-set-property! notehead 'style 'petrucci)
           (if (> dur-log 0)
            (ly:grob-set-property! notehead 'duration-log 1)
            (ly:grob-set-property! notehead 'duration-log (1- dur-log))))
    ))
  )

)


#(define-public (early:Notation_engraver context)
"This Engraver handles setting correct early grob
rhythmic-event properties based on event duration.

The rhythmic-event's 'duration property is modified
to accomodate appeance of a correct notehead, stems
and number of flags and then compensated by factor.

The original value of 'duration is retained in the
'early:duration property accessed by early:GROB::print
when needed.

Also, a relevant properties for choosing a right
note head (ink-color & hollow properties) are set.
There are all delegated to early:GROB::print functions."
 (let (;; Lilypond static info
       (dupa 0))

  (make-engraver

   (acknowledgers

    ((note-head-interface engraver grob source)
     (let* (;; context properties
            (notation (ly:context-property context 'notation))
            (early-style (ly:context-property context 'early-style))
            (coloration (ly:context-property context 'coloration))
            (coloration-secondary (ly:context-property context 'colorSecondary))
            (implicit-color (ly:context-property context 'implicitColorAfterDurlog))
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

      ;; check out: select-head-glyph

      (unless mensura-properties
       (ly:error "EarlyVoice without \\mensural.\n(Note: This crashing error will be removed soon with intention to make \\early contexts independent of \\mensural calculations)."))

      ;; Set notehead grob properties
      (ly:grob-set-property! grob 'early-notation-type notation)
      (ly:grob-set-property! grob 'early-style early-style)
      (ly:grob-set-property! grob 'early-hollow hollow)
      (ly:grob-set-property! grob 'early-color
       (cond ((or color color-minor) coloration)
              (color-secondary coloration-secondary)))

      ;; correct note implicit diminution color.
      (when (not (or (null? implicit-color)))
       (apply
        (case style ((petrucci) adjust-petrucci-notehead!)
                    ((blackpetrucci) adjust-petrucci-notehead!)
                    (else (ly:error "Note head style (WHICH???) duration-log adjustment not yet implemented.")
                          adjust-petrucci-notehead!))
        (list notation grob dur-log implicit-color))
      )

    )) ;; end of notehead-interface

    ((stem-interface engraver grob source)

     (let (;; context properties
           (notation (ly:context-property context 'notation))
           (early-style (ly:context-property context 'early-style))
           (coloration (ly:context-property context 'coloration))
           (coloration-secondary (ly:context-property context 'colorSecondary))
           (implicit-color (ly:context-property context 'implicitColorAfterDurlog))
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

      (when (not (or (null? implicit-color)
                     (= implicit-color implicit-color-default)))

       (if (> dur-log 1)
        (set! dur-log (1+ dur-log)))

       (if (and (>= implicit-color max-dur-log)
                (> dur-log (1+ implicit-color)))
        (set! dur-log (1- dur-log)))

       (if (= implicit-color 0)
        (set! dur-log (1- dur-log)))

       (if (>= dur-log first-ly-durlog-with-flag)
        (add-flag! engraver grob))

       (ly:grob-set-property! grob 'duration-log dur-log)

      )


    )) ;; end of stem-interface

))))

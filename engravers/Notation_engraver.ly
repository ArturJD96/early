\version "2.24.3"


% #(define (log->shape '(
%   (-3 . 'maxima)
%   (-2 . 'longa)
%   (-1 . 'quadrata)
%   (0 . '

#(define ly-notehead-styles
  ;; Styles relevant to early music
  ;; found in select-head-glyph
  ;; (under note-head::calc-glyph-name)
  ;; relevant for notehead glyph selection.
  ;; TO DO: would be better to get them from
  ;; the source code automatically.
  '(mensural
    petrucci
    blackpetrucci
    semipetrucci
    neomensural)
)

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

% template for procedure adjusting noteheads using ly's styles
#(define (adjust-STYLE-notehead! notehead implicit-color)
  (let* ((dur-log (ly:grob-property notehead 'duration-log)))
   (case implicit-color
    ((()) '())
    ((1) '())
    ((#t) '()) ;; blackmensural
    ((#f) '()) ;; entirely white
    (else '()))
))

#(define (adjust-petrucci-notehead! notehead implicit-color)
  (let* ((dur-log (ly:grob-property notehead 'duration-log)))
   (case implicit-color
    ((()) '())
    ((1) '())
    ((#t) (ly:grob-set-property! notehead 'style 'blackpetrucci)
          (when (> dur-log 1)
           (ly:grob-set-property! notehead 'duration-log (1+ dur-log))))
    ((#f) (when (> dur-log 1)
           (ly:grob-set-property! notehead 'duration-log 1)))
    (else (cond
           ((> dur-log implicit-color)
            (ly:grob-set-property! notehead 'style 'blackpetrucci)
            (ly:grob-set-property! notehead 'duration-log (1- dur-log)))
           ((> dur-log -1)
            (ly:grob-set-property! notehead 'duration-log 1)))))
))

#(define (adjust-blackpetrucci-notehead! notehead implicit-color)
  (ly:grob-set-property! notehead 'style 'petrucci)
  (adjust-petrucci-notehead! notehead implicit-color)
)




% template for procedure adjusting stems using ly's styles
#(define (adjust-STYLE-notehead! notehead implicit-color)
  (let* ((dur-log (ly:grob-property notehead 'duration-log)))
   (case implicit-color
    ((()) '())
    ((1) '())
    ((#t) '()) ;; blackmensural
    ((#f) '()) ;; entirely white
    (else '()))
))


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
       (first-ly-durlog-with-visible-stem 1) ;; not counting ly's longa and maxima stems
       (implicit-color-default 1)
       (ly-last-durlog-without-flag 2)
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
      (case style
       ((petrucci) (adjust-petrucci-notehead! grob implicit-color))
       ((blackpetrucci) (adjust-blackpetrucci-notehead! grob implicit-color))
       (else (ly:warning "Note head style (WHICH???) duration-log adjustment not yet implemented."))
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

      ;(if (= dur-log -3) (display "\n"))
      ;(display dur-log)

      (when (not (null? implicit-color))

       ;; replace boolean values with numbers
       ;; too allow comparisons.
       (when (boolean? implicit-color)
        (set! implicit-color
         (if implicit-color -999 +inf.0)))

       (when (and (< implicit-color implicit-color-default)
                  (<= dur-log implicit-color))
        '()
       )

       (ly:grob-set-property! grob 'duration-log 2)

       ;(display (and (< -inf.0 1) (> -3 -inf.0)))

       ;(if (and (< implicit-color implicit-color-default)
       ;         (> dur-log implicit-color))
       ; (ly:grob-set-property! grob 'duration-log (- dur-log 0))
       ;)


      )


    )) ;; end of stem-interface

))))

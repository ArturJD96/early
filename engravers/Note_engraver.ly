\version "2.24.3"

%{
    This should be rewritten in such a way,
    that there is an "hollow" or "notehead-filling" (hollow/full/semi etc) property
    meaning when a smaller note becomes marked by filling it:
    e.g. in "modern" notation notes below half notes are black.
%}

#(define-public (early:Note_engraver context)
  (make-engraver

   (listeners
    ((note-event engraver event)
     (let* ((notation (ly:context-property context 'notation))
            (dur-correction
             (member notation '(blackmensural whitehollow)))
            ;; duration
            (dur (ly:event-property event 'duration))
            (dur-log (ly:duration-log dur))
            (dur-dots (ly:duration-dot-count dur))
            (dur-factor (ly:duration-scale dur)))

      ;; Correct dur-log logarhythms go compensate for the skipped note.
      ;; I need to do this, because dur-log above 3 kills the flag grob
      ;; and it needs to appear 'earlier' in some of the styles.
      (when (and dur-correction (> dur-log 0))
       (set! dur-log (1+ dur-log))
       (set! dur-factor (* dur-factor 2)))

     (ly:event-set-property! event 'duration
      (ly:make-duration dur-log dur-dots dur-factor))

    ))
   )


   (acknowledgers

    ((note-head-interface engraver grob source)
     (let* (;; context related
            (notation (ly:context-property context 'notation))
            (coloration (ly:context-property context 'coloration))
            (coloration-secondary (ly:context-property context 'colorSecondary))
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
            (hollow (assoc-ref mensura-properties 'hollow))
           )
            ;(style (ly:grob-property grob 'style))
            ;

      (unless mensura-properties
       (ly:error "EarlyVoice without \\mensural.\n(Note: This crashing error will be removed soon with intention to make \\early contexts independent of \\mensural calculations)."))

      (ly:grob-set-property! grob 'early:notation-type notation)
      (ly:grob-set-property! grob 'early:hollow hollow)
      (ly:grob-set-property! grob 'early:color
       (cond ((or color color-minor) coloration)
              (color-secondary coloration-secondary)))

      ;(ly:grob-set-property! grob 'flag #t)

      (case notation
       ((blackmensural)
        ;; Use native blackpetrucci if possible (important for ligatures!)
        (when (eq? style 'petrucci)
         (ly:grob-set-property! grob 'style 'blackpetrucci))
       )
       ((whitehollow)
        ;; Based on Attaingnant's "Tabulature pour le jeu d'orgues".
        (when (and (> dur-log 1) (< dur-log 5))
         (ly:grob-set-property! grob 'duration-log 1))
       )
      )

    ))

    ((stem-interface engraver grob source)

     (let ((notation (ly:context-property context 'notation))
           (dur-log (ly:grob-property grob 'duration-log)))

      (case notation
       ((whitehollow)
        ;; Remove redundant stem.
        (when (> dur-log 4)
         (ly:grob-set-property! grob 'duration-log (1- dur-log)))
       )
      )

    ))

   )
 )
)

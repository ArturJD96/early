#(define-public (early:X-extent mode context-name grob-name preset)
  "Change many grob's properties related to spacing
  at the same time using presets.

  Example #(early:X-extent 'NoteHead 'by-stencil)
  Does the same as:
  \\override NoteHead.extra-spacing-width = #'(0 . 0)
  \\override NoteHead.padding = 0
  ...etc."

  (unless (symbol? context-name)
   (ly:error "early:X-extent context-name must be a symbol"))
  (unless (symbol? grob-name)
   (ly:error "early:X-extent grob-name must be a symbol"))
  (unless (symbol? preset)
   (ly:error "early:X-extent preset name must be a symbol"))
  (unless (symbol? mode)
   (ly:error "early:X-extent mod must be 'override, 'temporar-override or 'once-override"))

  (define presets `(
   (by-stencil . ((extra-spacing-width . (0 . 0))
                  (padding . 0)
                  (forced-spacing . 0)
                  (minimum-X-extent . ,ly:grob::stencil-width)
                  (X-extent . ,ly:grob::stencil-width)))
   (as-nothing . ((extra-spacing-width . (0 . 0))
                  (padding . 0)
                  (forced-spacing . 0)
                  (minimum-X-extent . (+inf.0 . -inf.0))
                  (X-extent . (+inf.0 . -inf.0))))
  ))

  (define (override pair)
   (let ((preset (car pair))
         (val (cdr pair)))
    (make-music 'ContextSpeccedMusic
     'context-type context-name ;'Bottom
     'element (make-music 'OverrideProperty
               'pop-first (if (eq? mode 'temporary-override) '() #t)
               ; 'once (if (eq? mode 'once-override) #t '())
               'grob-value val
               'grob-property-path (list preset)
               'symbol grob-name))))

  (make-music
   'SequentialMusic
   'elements
   (map override (assoc-ref presets preset)))
)

#(define early:space-alist
  '((ambitus . (extra-space . 0))
    (breathing-sign . (extra-space . 0))
    (clef . (extra-space . 0))
    (cue-clef . (extra-space . 0))
    (cue-end-clef . (extra-space . 0))
    (custos . (extra-space . 0))
    (key-cancellation . (extra-space . 0))
    (key-signature . (extra-space . 0))
    (left-edge . (extra-space . 0))
    (signum-repetitionis . (extra-space . 0))
    (staff-bar . (extra-space . 0))
    (staff-ellipsis . (extra-space . 0))
    (time-signature . (extra-space . 0))
    (first-note . (fixed-space . 0))
    (next-note . (fixed-space . 0))
    (right-edge . (extra-space . 0))))

\layout {

    indent = 0
    ragged-right = ##t % behaves INTERESTING if set to false!

    \context { \Score

        #(display "\n🪷→🌺 Replacing default LilyPond's linebreak algorithm.")
        \consists #early:Line_break_engraver

        #(display "\n🪷→🌺 Modifying spacing routines.")

        \override SpacingSpanner.average-spacing-wishes = ##f
        \override SpacingSpanner.base-shortest-duration = #(ly:make-moment 0 0) % #<Mom 3/16>
        \override SpacingSpanner.common-shortest-duration = #(ly:make-moment 16 16) % maxima ??? use infinity?
        \override SpacingSpanner.shortest-duration-space = 1 % 2
        \override SpacingSpanner.spacing-increment = 0 % 1.2

        %{
            This allows for the LilyPond's spacing algorithm
            to reflect closer the grob's extends setting
            without additional spacing decisions.
        %}
        \override SpacingSpanner.strict-note-spacing = ##t

        %{
            Unused properties.
        %}
        % \override SpacingSpanner.packed-spacing = ##t
        % \override SpacingSpanner.uniform-stretching = ##t
        % \override SpacingSpanner.to-barline = ##t

        %{
            This allows for non-breaking staff.
        %}
        \override SpacingSpanner.stem-spacing-correction = 0

        %{
            This removes the factor by which all the "natural"
            line-breaks occur.
        %}
        #(early:X-extent 'override 'Score 'NonMusicalPaperColumn 'by-stencil)
        \override NonMusicalPaperColumn.padding = #0.00000001 % allowing skylines to overlap.
        \override NonMusicalPaperColumn.full-measure-extra-space = ##f
        \override NonMusicalPaperColumn.line-break-permission = ##f

    }

    \context { \EarlyStaff

        #(early:X-extent 'override 'EarlyStaff 'LeftEdge 'as-nothing)
        \override LeftEdge.space-alist = #early:space-alist

        #(early:X-extent 'override 'EarlyStaff 'Ambitus 'by-stencil)
        \override Ambitus.space-alist = #early:space-alist

        #(early:X-extent 'override 'EarlyStaff 'Clef 'by-stencil)
        \override Clef.space-alist = #early:space-alist
        \override Clef.break-align-anchor-alignment = 0
        \override Clef.break-align-anchor = 0

        #(early:X-extent 'override 'EarlyStaff 'KeySignature 'by-stencil)
        \override KeySignature.space-alist = #'(
          (ambitus extra-space . 0)
          (time-signature extra-space . 0)
          (signum-repetitionis extra-space . 0)
          (staff-bar extra-space . 0)
          (cue-clef extra-space . 0)
          (right-edge extra-space . 0)
          (first-note fixed-space . 0)
          (next-note extra-space . 0))

        #(early:X-extent 'override 'EarlyStaff 'TimeSignature 'by-stencil)
        \override TimeSignature.space-alist = #early:space-alist

        #(early:X-extent 'override 'EarlyStaff 'DotColumn 'by-stencil)
        #(early:X-extent 'override 'EarlyStaff 'RestColumn 'by-stencil)
        \override RestCollision.minimum-distance = 0

        % This was moved to 'barify' function
        % #(early:X-extent 'BarLine 'as-nothing)
        % \override BarLine.space-alist = #early:space-alist
        % \override BarLine.gap = 0

        #(early:X-extent 'override 'EarlyStaff 'Custos 'by-stencil)
        \override Custos.space-alist = #early:space-alist
        \override Custos.space-alist.right-edge = #'(extra-space . -1.333)
    }

    \context { \EarlyVoice

        %{
            Responsibilities of those engravers
            are taken by "early:Line-break-engraver".
        %}
        \remove Collision_engraver
        \remove Note_spacing_engraver

        #(early:X-extent 'override 'EarlyStaff 'Dots 'by-stencil)
        #(early:X-extent 'override 'EarlyStaff 'Flag 'as-nothing)
        #(early:X-extent 'override 'EarlyStaff 'NoteHead 'by-stencil)
        \override NoteHead.extra-spacing-height = #'(-inf.0 . +inf.0)
        #(early:X-extent 'override 'EarlyStaff 'Rest 'by-stencil)
        \override Rest.extra-spacing-height = #'(-inf.0 . +inf.0)
        #(early:X-extent 'override 'EarlyStaff 'Stem 'by-stencil)
        #(early:X-extent 'override 'EarlyStaff 'StemStub 'by-stencil)
        #(early:X-extent 'override 'EarlyStaff 'Script 'as-nothing)

    }

    \context { \Lyrics

        #(early:X-extent 'override 'EarlyStaff 'LyricText 'as-nothing)

    }

}

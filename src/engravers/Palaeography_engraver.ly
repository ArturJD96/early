\version "2.24.4"

% This should be replaced by the lilypond's ly:make-regex
#(use-modules (ice-9 regex))
% regexp-substitute/global port regexp target item…
%
% (regexp-substitute/global #f "[ \t]+"  "this   is   the text"
%                           'pre "-" 'post)
% ⇒ "this-is-the-text"
%
% ſ
%

%{
    Early Spelling Rules
%}

#(define-public early:spelling-rules '(

  (allographs . (
   (i-dotless . "i")
   (i-helper-dot . "[mnuwv]i[mnuwv]")
   (m-final . "m[\\.,:;\\?!]?$")
   (r-rotundum . "[OBPHDobphd]r") ; d only in fractur though.
   (s-long . "s[\\.,:;\\?!]?^$")
   (v-as-u . "v")
  ))
  (ligatures .  (
   (nasals . "[aeiou][mn]")
   (us-final . "us[\\.,:;\\?!]?$")
  ))

))


#(define-public early:supported-fonts '(

  ("__unicode__" . (
   (i-dotless . "ı")
   (i-helper-dot . "i")
   (m-final . "ɜ")
   (r-rotundum . "ꝛ")
   (s-long . "ſ")
   (nasals . "~")⁹
   (us-final . "⁹")
  ))
  ("Gothica Rotunda" . (
   (i-dotless . "ı")
   (i-helper-dot . "i")
   (m-final . "z") ; make hook: z or 3-like "" but more contracted.
   (r-rotundum . "")
   (s-long . "ſ")
   (v-as-u . "u")
   (nasals . "~") ; "append to letter" hook?
   (us-final . "")
  ))

))


#(define-public (early:Palaeography_engraver context)
  (make-engraver
   (acknowledgers
    ((lyric-syllable-interface engraver grob source)
     (let* ((text (ly:grob-property grob 'text))
            (font (ly:grob-property grob 'font-name))

            (font-config (ly:context-property context 'early-font-config))
            (allographs (ly:context-property context 'early-font-allographs))
            (ligatures (ly:context-property context 'early-font-ligatures))
            (glyphs (assoc-ref early:supported-fonts font))
            ;;

            ;(font-config (ly:grob-property grob '))
           )

      (when (assq-ref font-config 'allographs)
       (for-each
        (lambda (kv)
         (let* ((spelling-rule (car kv))
                (value (cdr kv))
                (allographs (assq-ref early:spelling-rules 'allographs))
                (regex (assq-ref allographs spelling-rule))
                (glyph (assq-ref glyphs spelling-rule))
               )

          (when (not regex)
           (ly:warning "🥀 Palaeography: unsupported allograph:")(display spelling-rule)(display " for font ")(display font)
           (newline))
          (when (not glyph)
           (ly:warning "🥀 Palaeography: unsupported glyph:")(display spelling-rule)(display " for font ")(display font)
           (newline))

          ;(display text)(display glyph)(display (string? text))(newline)
          (regexp-substitute/global #f regex text 'pre glyph 'post)

          (case value
           ((auto) '())
           ((indicated) '())
           ((never) '())
           (else '()))

        ))

        allographs)



      )



      (when (assq-ref font-config 'ligatures) '())
     )
))))

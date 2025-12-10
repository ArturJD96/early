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

    Note: the '*' used for handling scribal exceptions
    is already part of [:punct:] character class.
%}

#(define-public early:spelling-rules '(
  ;; (rule . auto (auto . indicated))
  (allographs . (
   (i-dotless . ("i" . "i*"))
   (i-helper-dot . ("[mnuwv]i[mnuwv]" . "[mnuwv]i[mnuwv]"))
   (m-final . ("m[[:punct:]]*(\\s|$)" . "m\\*")) ; tested.
   (r-rotundum . ("[OBPHDobphd]r" . "[OBPHDobphd]r"))
   (s-long . ("s\\B" . "s")) ; under testing.
   (v-as-u . ("v" . "v"))
  ))
  (ligatures .  (
   (nasals . ("[aeiou][mn]" . "[aeiou][mn]"))
   (us-final . ("us[\\.,:;\\?!]?$" . "us[\\.,:;\\?!]?$"))
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
     (let* ((unicode (ly:context-property context 'early-font-pure-unicode))
            (font-config (ly:context-property context 'early-font-config))
            (allographs (ly:context-property context 'early-font-allographs))
            (ligatures (ly:context-property context 'early-font-ligatures))

            (text (ly:grob-property grob 'text))
            (font (if unicode "__unicode__" (ly:grob-property grob 'font-name)))
            ;; has hyphen?
            (event (ly:grob-property grob 'cause))
            (music (ly:event-property event 'music-cause))
            (articulations (ly:music-property music 'articulations))
            (has-hyphen (any (lambda (a)
                              (eq? 'HyphenEvent (ly:music-property a 'name)))
                             articulations))
            (next-syllable-token "FOLLOWING-SYLLABLE::")

            (glyphs (assoc-ref early:supported-fonts font))
           )

      ;; This needs to be refactor and made shallow.

      (when (assq-ref font-config 'allographs)
       (for-each
        (lambda (kv)
         (let* ((spelling-rule (car kv))
                (value (cdr kv))
                (allographs (assq-ref early:spelling-rules 'allographs))
                (allograph (assq-ref allographs spelling-rule))
                (glyph (assq-ref glyphs spelling-rule))
               )
          (cond
           ((not allograph)
            (ly:warning "🥀 Palaeography: unsupported allograph:")(display spelling-rule)(display " for font ")(display font)(newline))
           ((not glyph)
            (ly:warning "🥀 Palaeography: unsupported glyph:")(display spelling-rule)(display " for font ")(display font)(newline)
            (set! glyph "???"))
           (else
            (let ((regex-auto (car allograph))
                  (regex-indicated (cdr allograph)))

             (set! text
              (regexp-substitute/global #f regex-auto (if has-hyphen (string-append text next-syllable-token) text) 'pre
               (lambda (m)
                (let* ((str (match:substring m))
                       (exception-symbol "\\*")
                       (asterisk-match (string-match exception-symbol str))
                      )
                (if asterisk-match
                 (string-append (match:prefix asterisk-match) (match:suffix asterisk-match))
                 (string-append glyph (match:suffix (string-match "\\w*" str))))
               ))
               'post)
             )

             (when has-hyphen
              (set! text
               (match:prefix (string-match next-syllable-token text))))

            )
           )
          )
        ))

        allographs)

      )

      (when (assq-ref font-config 'ligatures) '())

      (ly:grob-set-property! grob 'text text)
     )
))))

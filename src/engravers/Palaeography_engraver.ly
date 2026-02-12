\version "2.24.4"

%{
%
%  TO DO: change "early:" to "palaeography:" !!!
%
%
% %}

% This should be replaced by the lilypond's ly:make-regex
#(use-modules (ice-9 regex))

%{
    Early Spelling Rules
%}

#(define (define-rule format-regex make-processor) '())

#(define (define-substitution regex-list make-processor)
"Define a substitution rule.

In order to use substitution with palaeography engraver, you must define its factory:
(define (substitution-example (str-old)
 (define-substitution
  (list '^inside' str-old 'regex$') ;; <-- your regex formula building blocks.
  (lambda (str-new)
   (lambda (match-obj)
    (if (...here match-obj is being processed...)
     str-new
     str-old)
  ))
))

Args:
    regex-list (list of strings): list of strings to make regexp pattern for substituion.
    make-processor (lambda(str-new) -> lambda(match-obj)): function to be used as substitute's 'pre argument defining how str-new replaces str-old.
"
  (let ((next-syl-dummy "qQqQqQQqq")
        (regexp-pattern (make-regexp (apply string-append regex-list)))
       )
   (lambda (lyr str-new is-last-syllable)
    (let ((result (regexp-substitute/global #f
                    regexp-pattern
                    (if is-last-syllable lyr (string-append lyr next-syl-dummy))
                    'pre (make-processor str-new)
                    'post))
         )
     (if is-last-syllable
      result
      (substring result 0 (- (string-length result) (string-length next-syl-dummy)))
     )
))))


%{
%
%   Substitution Factories.
%
% %}

#(define (substitution-dummy str-old)
  (define-substitution
   '(,str-old)
   (lambda (str-new)
    (lambda (match-obj) str-old)
   )
))

#(define (substitution-except-last str-old)
"This procedure substitutes all 'str-old' except the last one in the word."
  (define-substitution
   `(,str-old "(\\B|\\b\\*([^[:alpha:]]+|$)|\\b\\[)")
   (lambda (str-new)
    (lambda (match-obj)
     (let ((next (match:substring match-obj 1)))
      (if (not (string=? "" next))
       (if (char=? #\* (string-ref next 0))
        (string-append str-new (substring next 1))
        (string-append str-new next))
       str-new
      )
   )))
))


%{
%
%   Description of rule modes:
%
%   "auto"
%
%   "indicated"
%
% %}
#(define-public early:spelling-rules `(
  ;; (rule . auto (auto . indicated))
  (allographs . (
   (i-dotless . ("i" . "i*"))
   (i-helper-dot . ("[mnuwv]i[mnuwv]" . "[mnuwv]i[mnuwv]"))
   (m-final . ("m[[:punct:]]*(\\s|$)" . "m\\*")) ; tested.
   (r-rotundum . ("[OBPHDobphd]r" . "[OBPHDobphd]r"))

   ; (s-long . ,(substitution-except-last "s"))
   ;; IMPLEMENT THIS THOUGH!
   (s-long . ((auto . ,(substitution-except-last "s")) ))
              ; (always . ,(substitution "s"))
              ; (indicated . ,(substitution-escaped "s")))) ;; adds \\*

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
   (nasals . "~")
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


%{
%
%   E N G R A V E R
%
% %}

#(define-public (early:Palaeography_engraver context)

  (define (is-last-syllable grob-lyric)
   "Finds out whether lyric is the last syllable in the word
    by finding if HyphenEvent exists on it.
    NOTE: is this the best way to do it?"
   (not
    (any (lambda (a) (eq? 'HyphenEvent (ly:music-property a 'name)))
        (ly:music-property
         (ly:event-property
          (ly:grob-property grob-lyric 'cause)
          'music-cause)
         'articulations)
    )
   )
  )

  (make-engraver
   (acknowledgers
    ((lyric-syllable-interface engraver grob source)
     (let* ((unicode (ly:context-property context 'early-font-pure-unicode))
            (font-config (ly:context-property context 'early-font-config))
            (allographs (ly:context-property context 'early-font-allographs))
            (ligatures (ly:context-property context 'early-font-ligatures)) ;; merge it?
            ;; from grob.
            (text (ly:grob-property grob 'text))
            (font (if unicode "__unicode__" (ly:grob-property grob 'font-name)))
            (glyphs (assoc-ref early:supported-fonts font))
           )

           ;; early:spelling-rules
           ; (s-long . ,(substitution-except-last "s"))
           ;; IMPLEMENT THIS THOUGH!
           ; (s-long . ((auto . ,(substitution-except-last "s")) ))


      (when (assq-ref font-config 'allographs)
       (for-each
        (lambda (kv)
         (let* ((spelling-rule (car kv))
                (rule-mode (cdr kv))
                (allographs (assq-ref early:spelling-rules 'allographs))
                (substitution (assq-ref (assq-ref allographs spelling-rule) rule-mode)) ;; or 'ligatures'
                (glyph (assq-ref glyphs spelling-rule))
               )

          (when (not glyph)
           (ly:warning (format #f "🥀 Palaeography: unsupported glyph: ~a for font ~a\n" spelling-rule font))
           (set! glyph "[~?~]")
          )

          (when (not substitution)
           (ly:warning (format #f "🥀 Palaeography: unsupported allograph rule: ~a for font ~a\n" spelling-rule font))
           (set! substitution ((substitution-dummy "[~?~]") glyph)) ;; WRONGGG
          )

          (set! text (substitution text glyph (is-last-syllable grob)))

        ))
        allographs)
      )

      (when (assq-ref font-config 'ligatures) '()) ;; Split between allographs and ligatures should be deprecated.

      ;; Finally, remove all the remaining asterisks
      ;; (unless they are escaped by "\\" <--- TO DO!)
      (set! text (regexp-substitute/global #f "\\*" text 'pre "" 'post))

      ;; Update the text for rendering.
      (ly:grob-set-property! grob 'text text)
     )
))))

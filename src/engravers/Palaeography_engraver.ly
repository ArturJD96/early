\version "2.24.4"

\include "../testing.ily"

%{
%
%  TO DO:
%  1) change "early:" to "palaeography:" !!!
%  2) replace ice-9 regex with lilypond's ly:make-regex
%  3) Check how POSIX ERE defined classes cover my "extended UNICODE" like "ꝛ" r rotundum (it should be seen as a letter)
%     – "ꝛ" is NOT included in [:alphanum:], but e.g. "ſ" is.
%     – replace [:alphanum:] with custom, tested character class
%       that explicitly shows the covered symbols (e.g. [a-zA-Zꝛſı])
%
% %}

% This should be replaced by the lilypond's ly:make-regex
#(use-modules (ice-9 regex))

%{
    Early Spelling Rules
%}

#(define (define-substitution regexp-list make-processor)
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
    regexp-list (list of strings): list of strings to make regexp pattern for substituion.
    make-processor (lambda(str-new) -> lambda(match-obj)): function to be used as substitute's 'pre argument defining how str-new replaces str-old.
"
  (let ((next-syl-dummy "qQqQqQQqq")
        (regexp-pattern (make-regexp (apply string-append regexp-list))))

   ;; Returns a substitution-performing function,
   ;; substituting str-old (with it's context) and str-new.
   ;; "make-processor" procedure makes sure that
   ;; the original context of str-old is restored
   ;; (e.g. by adding again caputred interpunction etc).
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

#(define (substitution-last str-old)
"This procedure substitutes all 'str-old' when they are the last letter."
  (define-substitution
   `(,str-old "($|[^]*[[:alpha:]])") ;; weird hack with ~not~ escaping ']' character?
   (lambda (str-new)
    (lambda (match-obj)
     (let ((next (match:substring match-obj 1)))
      (if (not (string=? "" next))
       (string-append str-new next)
       str-new
      )
 ))))
)

#(testing "substitution-last"
  (define sub (substitution-last "m"))
  (test-group "onset & middle stay"
   (test-equal "normal" "mamam" (sub "mamam" "ɜ" #f))
   (test-equal "near ommission" "m[n]m" (sub "m[n]m" "ɜ" #f))
   ; (test-equal "near ligature" "" (sub "" "ſ" #f)) ... To be decided.
  )
  (test-group "last is substituted"
   (test-equal "normal" "meɜ" (sub "mem" "ɜ" #t))
   (test-equal "one interpunction" "meɜ," (sub "mem," "ɜ" #t))
   (test-equal "many interpunction" "meɜ..." (sub "mem..." "ɜ" #t))
   (test-equal "after space" "meɜ " (sub "mem " "ɜ" #f))
  )
  (test-group "last escaped stays"
   (test-equal "normal" "mem*" (sub "mem*" "ɜ" #t))
   (test-equal "one interpunction" "mem*," (sub "mem*," "ɜ" #t))
   (test-equal "many interpunction" "mem*..." (sub "mem*..." "ɜ" #t))
   (test-equal "after space" "mem* " (sub "mem* " "ɜ" #f))
  )
)

#(define (substitution-except-last str-old)
"This procedure substitutes all 'str-old' except the last one in the word."
  (define-substitution
   `(,str-old "(\\B|\\*([^][[:alpha:]]+|$)|\\[)") ;; remove "\\b" – is it redundant?
   (lambda (str-new)
    (lambda (match-obj)
     (let ((next (match:substring match-obj 1)))
      (if (not (string=? "" next))
       (if (char=? #\* (string-ref next 0))
        (string-append str-new (substring next 1)) ;; put condition here.
        (string-append str-new next))
       str-new
      )
   )))
))


#(testing "substitution-except-last"
  (define sub (substitution-except-last "s"))
  (test-group "onset & middle is substituted"
   (test-equal "normal" "ſeſeſ" (sub "seses" "ſ" #f))
   (test-equal "near ommission" "ſ[n]ſ" (sub "s[n]s" "ſ" #f))
   ; (test-equal "near ligature" "ſ<n>ſ" (sub "" "ſ" #f)) ... To be decided.
  )
  (test-group "last stays"
   (test-equal "normal" "ſes" (sub "ses" "ſ" #t))
   (test-equal "one interpunction" "ſes," (sub "ses," "ſ" #t))
   (test-equal "many interpunction" "ſes..." (sub "ses..." "ſ" #t))
   (test-equal "after space" "ſes " (sub "ses " "ſ" #f))
  )
  (test-group "last escaped is substituted"
   (test-equal "normal" "eſ" (sub "es*" "ſ" #t))
   (test-equal "one interpunction" "eſ," (sub "es*," "ſ" #t))
   (test-equal "many interpunction" "eſ..." (sub "es*..." "ſ" #t))
   (test-equal "after space" "ſeſ " (sub "ses* " "ſ" #f))
  )
  (test-group "onset & middle escaped stay"
   (test-equal "normal" "s*es*es*" (sub "s*es*es*" "ſ" #f))
   (test-equal "near ommission" "s*[n]s*" (sub "s*[n]s*" "ſ" #f))
   ; (test-equal "near ligature" " " (sub " " "ſ" #f))
  )
  (test-group "capital stays"
   (test-equal "normal" "SaSaS" (sub "SaSaS" "ſ" #t))
  )
)

%{
%
%   Expose methods as a "palaeography" package.
%
% %}

% TO DO 1: test this interface in the Early Testing Suite.
% TO DO 2: move it to module (early palaeography)
#(define early-paleography:define-substitution define-substitution)
#(define early-paleography:substitution-last substitution-last)
#(define early-palaeography:substitution-except-last substitution-except-last)

%{
%
%   TO DO: descriptions
%
% %}

#(define early:spelling-rules `(
  ;; (rule . auto (auto . indicated))
  (allographs . (
   ; (i-dotless . ("i" . "i*"))
   ; (i-helper-dot . ("[mnuwv]i[mnuwv]" . "[mnuwv]i[mnuwv]"))
   (m-final . ((auto . ,(substitution-last "m"))))
   ; (r-rotundum . ("[OBPHDobphd]r" . "[OBPHDobphd]r"))
   (s-long . ((auto . ,(substitution-except-last "s")) ))
              ; (always . ,(substitution "s"))
              ; (indicated . ,(substitution-escaped "s")))) ;; adds \\*

   ; (v-as-u . ("v" . "v"))
  ))
  (ligatures .  (
   ; (nasals . ("[aeiou][mn]" . "[aeiou][mn]"))
   ; (us-final . ("us[\\.,:;\\?!]?$" . "us[\\.,:;\\?!]?$"))
  ))
))

%% TO DO
% #(define-public (early-palaeography:add-spelling-rule rule))

#(define-public early:supported-fonts '(

  ("__unicode__" . (
   (i-dotless . "ı")
   (i-helper-dot . "i")
   (m-final . "ɜ")
   (r-rotundum . "ꝛ")
   (s-long . "ſ")
   (nasals . "~") ;; adding *above* the vowel... OR better represent as dictionary?
   (us-final . "⁹")
   (abbreviation . "~") ;; added to the middle letter of a custom abbreviation..? A hook?
  ))
  ("Gothica Rotunda" . (
   (i-dotless . "ı")
   (i-helper-dot . "i")
   (m-final . "z") ; make hook: z or 3-like "" but more contracted.
   (r-rotundum . "")
   (s-long . "ſ")
   (v-as-u . "u")
   (nasals . "~") ; "append to letter" hook? OR a dictionary?
   (us-final . "")
  ))

))

%% TO DO
% #(define-public (early-palaeography:add-spelling-rule rule))


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

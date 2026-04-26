\version "2.24.4"
\include "./../definitions/events.ily" % TO DO: de-centralize and define early:MensurSetting and MensurEvent here?

#(define-public early:make-punctum-event ; TO DO: use & implement
  (early:define-constructable-music-event!
   'EarlyPunctumEvent
   "A point whose semantic function and layout differs vastly among early music editions."
   '(mensur-event post-event event StreamEvent) '()
   `(type . ,symbol?) ; TO DO: only valid punctum name.
   `(dot-count . ,integer-or-procedure?)
   `(subdivision . ,integer-or-symbol?) ; TO DO symbol only: 'not-null, which means: ;; Mensur context must have at least one complex relationship to allow the use of punctum divisionis.
   ; `(callback . ,procedure?) ; TO DO: remove it.
))

#(define-public (punctum:make-augmentationis)
  (early:make-punctum-event 'augmentationis positive? 2))

#(define-public (punctum:make-perfectionis)
  (early:make-punctum-event 'perfectionis 1 3))

#(define-public (punctum:make-divisionis)
  (early:make-punctum-event 'divisionis 0 'not-null)) % TO DO: rename symbol to 'complex-any

#(define early:puncta `(
  (augmentationis . ,punctum:make-augmentationis)
  (perfectionis . ,punctum:make-perfectionis)
  (divisionis . ,punctum:make-divisionis)
))

#(define-public (punctum:type punctum)
  (if punctum (ly:music-property punctum 'type) #f))
#(define-public (punctum:dot-count punctum)
  (if punctum (ly:music-property punctum 'dot-count) #f))
#(define-public (punctum:subdivision punctum)
  (if punctum (ly:music-property punctum 'subdivision) #f))

#(define-public (punctum:assume subdivision)
  ((case subdivision
    ((2) punctum:make-augmentationis)
    ((3) punctum:make-perfectionis)
    (else (ly:error "No punctum to assume with note subdivided to ~A parts." subdivision)))))

#(define (punctum:validate punctum mensur-context dots subdivision)
  "Check if rhythmic-event properties and context allow for applying punctum."
  (let ((required-dot-count (punctum:dot-count punctum))
        (required-subdivision (punctum:subdivision punctum)))
   (when (and (eq? required-subdivision 'not-null)
              (null? (mensur:subdivisions mensur-context)))
    (error "A punctum requiring complex mensuration cannot be used in simple mensuration."))
   (and (if (procedure? required-dot-count)
         (required-dot-count dots)
         (= required-dot-count dots))
        (if (symbol? required-subdivision)
         (case required-subdivision
          ((not-null)
           (when (null? (mensur:subdivisions mensur-context))
            (error "A punctum requiring complex mensuration cannot be used in simple mensuration."))
           #t)
          (else
           (ly:error "Unsupported required-subdivision symbol: ~A" required-subdivision)))
        (= required-subdivision subdivision)))))


#(define-public (punctum:append! punctum rhythmic-event)
  (ly:music-set-property! rhythmic-event 'articulations
   (cons punctum (ly:music-property rhythmic-event 'articulations)))
  punctum)

#(define-public (early:punctum rhythmic-event)
  (find-post-event rhythmic-event 'early-punctum-event))


% punctumAugmentationis = #(define-event-function () () (make-music 'EarlyPunctumEvent 'type 'augmentationis))
% punctumPerfectionis = #(define-event-function () () (make-music 'EarlyPunctumEvent 'type 'perfectionis))
punctumDivisionis = #(define-event-function () () (punctum:make-divisionis)) % TO DO: can be shallow, just #(punctum:make-divisionis)?
% %% TO DO: Punctum alterationis affects the last note in a group.
% punctumAlterationis = #(define-event-function () () (make-music 'EarlyPunctumEvent 'type 'alterationis))

%% Aliases
% paug = \punctumAugmentationis
% pperf = \punctumPerfectionis
pdiv = \punctumDivisionis
% palt = \punctumAlterationis

\version "2.24.4"
\include "./../definitions/events.ily" % TO DO: de-centralize and define early:MensurSetting and MensurEvent here?



#(define-public early:make-punctum-event ; TO DO: use & implement
  (early:define-constructable-music-event!
   'EarlyPunctumEvent
   "A point whose semantic function and layout differs vastly among early music editions."
   '(mensur-event post-event event StreamEvent) '()
   `(dot-count . integer-or-procedure?)
   `(subdivision . integer-or-symbol?) ; TO DO symbol only: 'not-null, which means: ;; Mensur context must have at least one complex relationship to allow the use of punctum divisionis.
   ; `(callback . ,procedure?) ; TO DO: remove it.
))

#(define-public (early:make-punctum-augmentationis)
  (early:make-punctum-event positive? 2))

#(define-public (early:make-punctum-perfectionis)
  (early:make-punctum-event 1 3))

#(define-public (early:make-punctum-divisionis)
  (early:make-punctum-event 0 'not-null)) % TO DO: rename symbol to 'complex-any

#(define %mensur:puncta `( ;; TO DO: REMOVE!!!
  (augmentationis . (
   (dot-count . ,positive?)
   (subdivision . 2)
   (callback . ,(lambda (rhythmic-event) rhythmic-event))
  ))
  (perfectionis . (
   (dot-count . 1)
   (subdivision . 3)
   (callback . ,(lambda (rhythmic-event) rhythmic-event))
  ))
  (divisionis . (
   (dot-count . 0)
   (subdivision . not-null)
   (callback . ,(lambda (rhythmic-event) rhythmic-event))
  ))
))

#(define-public (punctum:dot-count punctum)
  (ly:music-property punctum 'dot-count))
#(define-public (punctum:subdivision punctum)
  (ly:music-property punctum 'subdivision)

#(define (%mensur:punctum-property punctum-name prop-name)
  (let ((props (assoc-ref %mensur:puncta punctum-name)))
   (unless props
    (ly:error "Unrecognized punctum: ~A" props))
   (let ((prop (assoc-ref props prop-name)))
    (unless prop
     (ly:error "Unrecognized punctum property: ~A" prop-name))
    prop)))

#(define (%mensur:punctum-validate punctum-name mensur-context dots subdivision)
  "Check if rhythmic-event properties and context allow for applying punctum."
  (let ((required-dot-count (%mensur:punctum-property punctum-name 'dot-count))
        (required-subdivision (%mensur:punctum-property punctum-name 'subdivision)))
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

#(define (%mensur:punctum-apply! punctum-name rhythmic-event)
  "Apply punctum's callback to rhythmic-event. Note: validate first with %mensur:punctum-validate."
  (let ((apply-callback (%mensur:punctum-property punctum-name 'callback))
        (punctum (early:punctum rhythmic-event)))
   (early:punctum-add! rhythmic-event punctum-name)
   (apply-callback rhythmic-event)))


#(define-public (early:punctum music)
  "Find if event has a punctum and return it's type.
   If no punctum is present, return `#f`."
  (let ((punctum (find-post-event music 'early-punctum-event)))
   (if punctum
    (ly:music-property punctum 'type)
    #f)))

#(define-public (early:punctum-add! music punctum-type)
  (ly:music-set-property! music 'articulations
   (cons (make-music 'EarlyPunctumEvent 'type punctum-type)
         (ly:music-property music 'articulations))))

\version "2.24.3"

#(define-public (early:mensura-property music early-property)
  (let ((props (ly:music-property music 'early:mensura-properties)))
    (if props
     (assoc-ref props early-property)
     #f)))

#(define-public (early:mensura-set-property! music early-property value)
    (let ((props (ly:music-property music 'early:mensura-properties)))
    (ly:music-set-property! music 'early:mensura-properties
    (if props
        (assoc-set! props early-property value)
        (list (cons early-property value))))
    music))

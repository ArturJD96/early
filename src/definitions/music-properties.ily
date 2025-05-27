\version "2.24.3"

#(define-public (early:music-property music early-property)
  (let ((props (ly:music-property music 'early:music-properties)))
    (if props
     (assoc-ref props early-property)
     #f)))

#(define-public (early:music-set-property! music early-property value)
    (let ((props (ly:music-property music 'early:music-properties)))
    (ly:music-set-property! music 'early:music-properties
    (if props
        (assoc-set! props early-property value)
        (list (cons early-property value))))
    music))

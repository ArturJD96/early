\version "2.24.3"

%{
    "early:psalmus-property"
    — a single property for
      syllables of a psalmus.
      * getter
      * setter
%}

#(define early:psalmus-max-recit-chars 50)

#(define (early:get lyric-event)
  (ly:music-property lyric-event 'early:psalmus-property)
)
#(define (early:set! lyric-event val)
  (ly:music-set-property! lyric-event 'early:psalmus-property val)
  lyric-event
)

%{

    Lilypond macra

%}

#(define (early:format-proparoxytone lyr)
  (case (early:get lyr)
   ((ppx-short)
    (ly:music-set-property! lyr 'text
     (markup #:italic (ly:music-property lyr 'text)))))
  lyr
)

#(define (early:split-long-recit lyr)
  (case (early:get lyr)
   ((recit)
    (let* ((text (ly:music-property lyr 'text)))
      (ly:music-set-property! lyr 'text
       (markup ;#:vcenter
               #:raise 0
               #:override '(line-width . 100)
               #:override '(baseline-skip . 0)
               #:justify-string (markup->string text))
      )
      (ly:music-set-property! lyr 'X-offset -4)
    )
   )
  )
  lyr
)


#(define (early:format-early lyr)
  (early:split-long-recit lyr)
  (early:format-proparoxytone lyr)
)

#(define-public early:psalmus-text-format early:format-early)
% #(define-public early:psalmus-durlogs
%   '((recit -2)
%     (final -1)
%     (other -1))



ppx = % propaxotytone
#(define-music-function (syl-long syl-short) (ly:music? ly:music?)
  (early:set! syl-long 'ppx-long)
  (early:set! syl-short 'ppx-short)
  #{ #syl-long #syl-short #}
)

hemistich = #(define-music-function
(format-text! lyrs)
((procedure?) ly:music?)

  (let* (;; hemistich settings
         (recit-durlog -2)
         (final-durlog -1)
         (other-durlog -1)
         (ppx-durlog 1)
         ;; other
         (elems (ly:music-property lyrs 'elements))
         (first-elem (first elems))
         (last-elem (last elems))
        )
   (when (null? (early:get first-elem))
    (set! first-elem (early:set! first-elem 'recit)))
   (when (null? (early:get last-elem))
    (set! last-elem (early:set! last-elem 'final)))
   (music-map
    (lambda (lyr)
     (ly:music-set-property! lyr 'duration
      (case (early:get lyr)
       ((recit) (ly:make-duration recit-durlog))
       ((final) (ly:make-duration final-durlog))
       ((())    (ly:make-duration other-durlog))
       ((ppx-long)  (ly:make-duration ppx-durlog))
       ((ppx-short) (ly:make-duration ppx-durlog))
       (else (ly:music-property lyr 'duration))))
     (format-text! lyr))
    lyrs)))

#(define (procedure-not-music? arg)
  (and (not (ly:music? arg))
       (procedure? arg)) ;; this doesn't work :/
)

versus = #(define-music-function
(voice-name lambda-for-formating hemistich-1 hemistich-2)
((string?) (procedure-not-music? early:psalmus-text-format) ly:music? ly:music?)
#{
    \lyrics {
        \hemistich #lambda-for-formating #hemistich-1
        \hemistich #lambda-for-formating #hemistich-2
    }
#})



%{

    Testing

%}

% \score {<<

%     \new Staff \relative { a' b c }

%     \lyricmode <<
%     \versus { wiel -- ka -- du -- pa } { koś -- cio -- \ppx tru -- pa }
%     \versus { więk -- sza koś -- cio -- tru -- pa } { du -- pecz -- ka }
%     >>
%     \lyrics { bla bla bla }
%     \lyrics { tra la la }

% >>}

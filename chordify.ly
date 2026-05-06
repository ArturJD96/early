\version "2.24.4"
\include "src/testing.ily"

#(define (timeline:add! timeline rhythmic-event)
  (set! timeline
   (append timeline
    (list (cons (ly:music-length m)
                m))))
)

#(define (timeline:stack! timelines)

  (define (worker stack timelines)

   (if (every null? timelines)
    stack
    (let* ((moments (map caar timelines))
           (mom-shortest (apply min moments))
           (new-stack (map cdar timelines))
           (popped (map (lambda (timeline)

                         ; (let ((next (cdr timeline)))
                         ;  (when (and (not (null? next))
                         ;             (list? (cadr timeline)))
                         ;   (display timeline)
                         ;  )
                         ; )

                         (let ((mom-remaining (- (caar timeline) mom-shortest)))
                          (if (<= mom-remaining 0)
                           (cdr timeline)
                           (cons (cons mom-remaining (cdar timeline))
                                 (cdr timeline)))))
                    timelines)))
     (worker
      (append stack `((,mom-shortest . ,new-stack)))
      popped)
    )
   )
  )
  (worker '() timelines)
)



#(testing "timeline:stack!"
  (test-equal "Single stack."
   '( (2 . (a c)) (1 . (b c)) (3 . (b d)) )
   (timeline:stack!
    (list '((2 . a)(4 . b))
          '((3 . c)(3 . d))
  )))

  (test-equal "Many stacked."
   '((2 . (a c e))
     (1 . (b c e))
     (1 . (b d e))
     (2 . (b d f)))
   (timeline:stack!
    (list '((2 . a) (4 . b))
          '((3 . c) (3 . d))
          '((4 . e) (2 . f))
  )))

  ; (test-equal "Branching."
  ;  '((2 . (a))
  ;    (3 . (b c))
  ;    (1 . (b d)))
  ;  (timeline:stack!
  ;   (list '((2 . a) ( ((4 . b))
  ;                     ((3 . c) (1 . d)))))
  ; ))
)



% TO DO: start with some tests for music!




















#(define (sequential->timeline sequential-music)

  (let* ((timeline '())
         (timeline:add! (lambda (m)
                          (set! timeline
                           (append timeline
                            (list (cons (ly:music-length m)
                                        m)))))))
   (for-some-music
    (lambda (m)
     (cond ((music-is-of-type? m 'rhythmic-event)
            (timeline:add! m))
           ((music-is-of-type? m 'simultaneous-music)
            (display "GWNO"))
           (else #f))
    )
    sequential-music)

   timeline)

)

#(define (sequential->simultaneous . simultaneous-music)

  ; (display (ly:music? simultaneous-music))
  ; (display (ly:music-length simultaneous-music))
  ; (let ((length-total (ly:music-length simultaneous-music)))
  ; (display length-total))

  simultaneous-music
)


% #(newline)
% #(display-scheme-music
%   (map (lambda (t)
%         (cons (ly:moment-main (car t)) (ly:music-property (cdr t) 'pitch)))
%    (sequential->timeline #{ c1 d2 e4 f\breve g\longa #})))

% #(display-scheme-music (sequential->simultaneous #{ << { c1 } \\ { g2 e2 } >> #}))
% #(display-scheme-music (fold-some-music ly:music? (lambda (m prev) m) '() #{ << { c1 } \\ { g2 e2 } >> #}))
% #(display-scheme-music (extract-music (lambda (m) (music-is-of-type m 'rhythmic-event)) #{ << { c1 } \\ { g2 e2 } >> #}))






% #(testing "chordify-simultaneous-music"
%   (test-equal
%    #{ <c g>2 <c e>2 #}
%    (sequential->simultaneous #{ << { c1 } \\ { g2 e2 } >> #})
%   )
% )









chordify =
#(define-music-function (simultaneous-music) (ly:music?)
  ; (display-scheme-music simultaneous-music)
  (let ((pitches-at-mom '()))
   (for-some-music
    (lambda (m)  #f)
    simultaneous-music))
  simultaneous-music
)

topVoice = \relative { a'1 b c\breve. b1 c\breve }
middleVoices = \relative { << { d'2. d,8 f e2 e'2 } \\ { d1 e1 } >> c2. d8 e <<{ f1. e4 f d1 c\breve } \\ \relative { r1 c' g'2 f1 e4 d e1 } >> }
bassVoice = \relative { \clef F d2 d' g,2. f4 e4 a g2 a2 f1 a2 g1 c,\breve }

% \chordify <<
%     \topVoice
%     % \middleVoices
%     % \bassVoice
% >>

middleVoicesChordified = \relative {
    d'2.~ <d, d'~>8 <f d'>8
    <e e'>2 e'
    c2. d8 e
    f1~
    <c~ f>2 <c~ e>4 <c f>
    <d~ g>2 <d f~>
    <c~ f>2 <c~ e>4 <c~ d>
    <c e>1
}

% \new Staff \middleVoices
% \new Staff \middleVoice sChordified

% \new Staff \chordify \middleVoices
% \middleVoicesChordified


#(testing "chordify"
  '()
  ; (test-equal #{ \topVoice #} #{ \chordify \topVoice #} )
  ; (test-equal #{ << \topVoice >> #} #{ \chordify << \topVoice >> #} )

  ; (test-equal #{ << \middleVoicesChordified >> #} #{ \chordify << \middleVoices >> #} )

)

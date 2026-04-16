\version "2.24.4"
\include "./../testing.ily"
\include "./mensural.ly"
\include "./puncta.ly"
\include "./quality.ly"



%{
%       Helpers.
% %}

#(define (extract-duration-lengths music)
  (map (lambda (m)
        (duration-length
         (ly:music-property m 'duration)))
   (extract-typed-music music 'rhythmic-event)))

#(define (mensural-music-from-elems signum elems)
  (mensural (make-music 'SequentialMusic
             'elements
             (append (list (mensura signum)) elems))))

#(define (mensural-music-from-durlogs signum settings dur-logs)
  (let ((mensur (list (mensura signum)))
        (notes (map (lambda (dur-log)
                (make-music
                 'NoteEvent
                 'duration (ly:make-duration dur-log)))
                dur-logs)))
   (mensural-music-from-elems signum (append settings notes))))

#(define (durations-settings signum settings dur-logs)
  (extract-duration-lengths
   (mensural-music-from-durlogs signum settings dur-logs)))


#(define (dur->music dur)
  (make-music 'SequentialMusic 'elements
   (list (make-music 'NoteEvent 'duration dur))))

#(define (durs-dot-quality-reason signum music . options)
    (set! music
     (cond
      ((ly:duration? music) (dur->music music))
      ((music-is-of-type? music 'sequential-music) music)
      (else (make-music 'SequentialMusic 'elements (list music)))))
    (when (not (null? options))
     (ly:music-set-property! music 'elements
      (append options
              (ly:music-property music 'elements))))
    (let ((music (mensural-music-from-elems signum (ly:music-property music 'elements))))
     (map list
      (extract-duration-lengths music)
      (map early:punctum (extract-typed-music music 'rhythmic-event))
      (map (lambda (e) (mensur:quality (ly:music-property e 'mensur:quality))) (extract-typed-music music 'rhythmic-event))
      (map (lambda (e) (mensur:reason (ly:music-property e 'mensur:quality))) (extract-typed-music music 'rhythmic-event))
   )))

%{
%       Tests start here.
% %}

#(testing "Basic mensurations."

  (define (durations-explicit signum . dur-logs)
   (durations-settings signum '() dur-logs))

  (test-group "Explicit."
   (test-equal "C" '(2 1) (durations-explicit 'C -1 0))
   (test-equal "O" '(2 1) (durations-explicit 'O -1 0))
   (test-equal "C." '(3 1) (durations-explicit 'C. -1 0))
   (test-equal "O." '(3 1) (durations-explicit 'O. -1 0))
  )

  (define (durations-implicit signum . dur-logs)
   (durations-settings signum `(,mensuraImplicit) dur-logs))

  (test-group "Implicit."
   (test-equal "C" '(2 1) (durations-implicit 'C -1 0))
   (test-equal "O"  '(3 1) (durations-implicit 'O -1 0))
   (test-equal "C." '(3 3/2) (durations-implicit 'C. -1 0))
   (test-equal "O." '(9/2 3/2) (durations-implicit 'O. -1 0))
   ;; Only some subdivisions made implicit.
   (test-equal "O." '(9/2 1) (durations-settings 'O. `(,tempusImplicit) `(-1 0)))
   (test-equal "O." '(3 3/2) (durations-settings 'O. `(,prolatioImplicit) `(-1 0)))
  )

)

#(testing "early:punctum music"
  (test-equal 'divisionis (early:punctum #{ d \pdiv #}))
  (test-equal #f (early:punctum #{ d #}))
)

% ;; TO DO: "EarlyComplexityEvent" !!!

#(testing "Quality."

  (test-group "Implicit meter"
   (test-equal "complex" '((3/2 #f complex undocumented)) (durs-dot-quality-reason 'C. #{ 1\perf #}))
   (test-equal "simple (should do nothing)" '((1 #f simple position)) (durs-dot-quality-reason 'C. #{ 1\imp #}))
   (test-equal "partial" '((5/4 #f partial position)) (durs-dot-quality-reason 'C. #{ 1\part 5/6 #}))
   (test-equal "alter" '((1 #f altera position)) (durs-dot-quality-reason 'C. #{ 2\altera #}))
  )

  (test-group "Explicit meter"
   (test-equal "complex (should do nothing)" '((3/2 #f complex undocumented)) (durs-dot-quality-reason 'C. #{ 1\perf #} mensuraImplicit))
   (test-equal "simple" '((1 #f simple position)) (durs-dot-quality-reason 'C. #{ 1\imp #} mensuraImplicit))
   (test-equal "partial" '((5/4 #f partial position)) (durs-dot-quality-reason 'C. #{ 1\part 5/6 #} mensuraImplicit))
   (test-equal "alter" '((1 #f altera position)) (durs-dot-quality-reason 'C. #{ 2\altera #} mensuraImplicit))
  )

  (test-group "Complexity in simple meter is ignored."
   ;; This should allow for e.g. mensural canons from one staff.
   (test-equal "simple" '((3 #f simple simple-mensur)) (durs-dot-quality-reason 'C. #{ \breve\imp #}))
   (test-equal "complex" '((3 #f simple simple-mensur)) (durs-dot-quality-reason 'C. #{ \breve\perf #}))
   (test-equal "partial" '((3 #f simple simple-mensur)) (durs-dot-quality-reason 'C. #{ \breve\part 5/6  #}))
   (test-equal "altera" '((3 #f simple simple-mensur)) (durs-dot-quality-reason 'C. #{ \breve\altera #}))
  )

)

#(testing "Puncta."

  (test-group "Imperfect meter"
   (test-equal "Nothing." '((2 #f simple simple-mensur)) (durs-dot-quality-reason 'C #{ \breve #}))
   (test-equal "Assume punctum augmentationis." '((3 augmentationis simple simple-mensur)) (durs-dot-quality-reason 'C #{ \breve. #}))
   (test-error "Forbid puncta divisionis in simple mensur." #t (durs-dot-quality-reason 'C #{ \breve \pdiv #}))
  )

  (test-group "Explicit perfect meter"
   ;; Perfectionis
   (test-equal "Imperfect" '((2 #f simple position)) (durs-dot-quality-reason 'O #{ \breve #}))
   (test-equal "Assume p. perfectionis in complex division." '((3 perfectionis complex punctum-perfectionis)) (durs-dot-quality-reason 'O #{ \breve. #}))
   (test-equal "Assume p. augmentationis in simple division." '((3/2 augmentationis simple simple-mensur)) (durs-dot-quality-reason 'O #{ 1. #}))
   (test-equal "P. perfectionis and complexity event do not stack." '((3 perfectionis complex punctum-perfectionis)) (durs-dot-quality-reason 'O #{ \breve.\perf #}))
   (test-error "P. perfectionis and partial imperfection are exclusive." (durs-dot-quality-reason 'O #{ \breve.\part 5/6 #}))
   ;; Divisionis
   (test-equal "Divisionis by complex." '((2 divisionis simple position)) (durs-dot-quality-reason 'O #{ \breve \pdiv #}))
   (test-equal "Divisionis near simple." '((1 divisionis simple simple-mensur)) (durs-dot-quality-reason 'O #{ 1 \pdiv #}))
  )

  (test-group "Implicit perfect meter"
   ;; Perfectionis
   (test-equal "Perfect by default" '((3 #f complex position)) (durs-dot-quality-reason 'O #{ \breve #} mensuraImplicit))
   (test-equal "Assume punctum perfectionis." '((3 perfectionis complex punctum-perfectionis)) (durs-dot-quality-reason 'O #{ \breve. #} mensuraImplicit))
   (test-equal "P. perfectionis and complexity event do not stack." '((3 perfectionis complex punctum-perfectionis)) (durs-dot-quality-reason 'O #{ \breve.\perf #} mensuraImplicit))
   ;; Divisionis
   (test-equal "P. divisionis at complex." '((3 divisionis complex position)) (durs-dot-quality-reason 'O #{ \breve \pdiv #} mensuraImplicit))
   (test-equal "P. divisionis at simple." '((1 divisionis simple simple-mensur)) (durs-dot-quality-reason 'O #{ 1 \pdiv #} mensuraImplicit))
  )
)

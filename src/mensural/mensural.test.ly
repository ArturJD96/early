\version "2.24.4"
\include "./../testing.ily"
\include "./mensural.ly"

%{
%       Helpers.
% %}

#(define (extract-duration-lengths music)
  (map (lambda (m)
        (duration-length
         (ly:music-property m 'duration)))
   (extract-typed-music music 'rhythmic-event)))

#(define (mensural-music-from-elems elems)
  (mensural (make-music 'SequentialMusic 'elements elems)))

#(define (mensural-music-from-durations signum settings dur-logs)
  (let ((mensur (list (mensura signum)))
        (settings (map (lambda (setting) (apply (car setting) (cdr setting))) settings))
        (notes (map (lambda (dur-log)
                (make-music
                 'NoteEvent
                 'duration (ly:make-duration dur-log)))
                dur-logs)))
   (mensural-music-from-elems
    (apply append (list mensur settings notes)))))

#(define (durations-settings signum settings dur-logs)
  (extract-duration-lengths
   (mensural-music-from-durations signum settings dur-logs)))


%{
%       Tests start here.
% %}

#(testing "Basic mensurations."

  (define (durations-explicit signum . dur-logs)
   (durations-settings signum '() dur-logs))

  (test-group "Explicit."
   (test-equal '(2 1) (durations-explicit 'C -1 0))
   (test-equal '(2 1) (durations-explicit 'O -1 0))
   (test-equal '(3 1) (durations-explicit 'C. -1 0))
   (test-equal '(3 1) (durations-explicit 'O. -1 0))
  )

  (define (durations-implicit signum . dur-logs)
   (durations-settings signum `((,mensuraImplicit)) dur-logs))

  (test-group "Implicit."
   (test-equal '(2 1) (durations-implicit 'C -1 0))
   (test-equal '(3 1) (durations-implicit 'O -1 0))
   (test-equal '(3 3/2) (durations-implicit 'C. -1 0))
   (test-equal '(9/2 3/2) (durations-implicit 'O. -1 0))
   ;; Only some subdivisions made implicit.
   (test-equal '(9/2 1) (durations-settings 'O. `((,tempusImplicit)) `(-1 0)))
   (test-equal '(3 3/2) (durations-settings 'O. `((,prolatioImplicit)) `(-1 0)))
  )

)

#(testing "Puncta."

  (define (extract-note-mensur music)
   (map (lambda (m) (ly:music-property m 'mensur))
        (extract-typed-music music 'rhythmic-event)))

  (define (durs-dots signum music)
   (let ((music #{ \mensural { \mensura #signum #(if (ly:duration? music) (make-music 'NoteEvent 'duration music) music) } #}))
    (map cons
     (extract-duration-lengths music)
     (extract-note-mensur music))))

  (test-group "Implicit imperfect meter"
   (test-equal '((2)) (durs-dots 'C #{ \breve #})) ;; Nothing.
   (test-equal '((2)) (durs-dots 'C #{ \breve. #})) ;; Assume punctum augmentationis.
   (test-equal '(3) (durs-dots 'C #{ \pperf \breve. #})) ;; THROW
   (test-equal '(3) (durs-dots 'C #{ \pdiv \breve. #})) ;; THROW
   (test-equal '(3) (durs-dots 'C #{ \palt \breve. #})) ;; THROW
  )

  (test-group "Implicit perfect meter"
   ;; Normal dot.
   (test-equal '(3) (durs-dots 'O #{ \breve #})) ;; Imperfect.
   (test-equal '(3) (durs-dots 'O #{ \breve. #})) ;; assume punctum perfectionis.
   ;; Perfectionis
   (test-equal '(3) (durs-dots 'O #{ \pperf \breve. #})) ;; Perfectionis.
   (test-equal '(3) (durs-dots 'O #{ \pperf \breve #})) ;; THROW
   ;; Divisionis
   (test-equal '(3) (durs-dots 'O #{ \pdiv \breve #})) ;; THROW, because longa is imperfect (by default).
   (test-equal '(3) (durs-dots 'O #{ \pdiv 1 #})) ;; Divisionis.
   (test-equal '(3) (durs-dots 'O #{ \pdiv 1. #})) ;; THROW
   ;; Alterationis
   (test-equal '(3) (durs-dots 'O #{ \palt \breve 1 1 #})) ;; Second note gains alteration.
   (test-equal '(3) (durs-dots 'O #{ \palt \breve 1 \alt 1 #})) ;; Allowed but not stacked.
   (test-equal '(3) (durs-dots 'O #{ \palt \breve 1 1. #})) ;; THROW
   (test-equal '(3) (durs-dots 'O #{ \palt \breve \breve \breve #})) ;; THROW, because longa is imperfect (by default).
  )


  ; TO DO
  (test-group "Explicit imperfect meter"
   (test-equal '(3) (durs-dots 'C #{ \breve #})) ;; Nothing.
   (test-equal '(3) (durs-dots 'C #{ \breve. #})) ;; Assume punctum augmentationis.
   (test-equal '(3) (durs-dots 'C #{ \pperf \breve. #})) ;; THROW
   (test-equal '(3) (durs-dots 'C #{ \pdiv \breve. #})) ;; THROW
   (test-equal '(3) (durs-dots 'C #{ \palt \breve. #})) ;; THROW
  )
  (test-group "Explicit perfect meter"
   ;; Normal dot.
   (test-equal '(3) (durs-dots 'O #{ \breve #})) ;; Imperfect.
   (test-equal '(3) (durs-dots 'O #{ \breve. #})) ;; assume punctum perfectionis.
   ;; Perfectionis
   (test-equal '(3) (durs-dots 'O #{ \pperf \breve. #})) ;; Perfectionis.
   (test-equal '(3) (durs-dots 'O #{ \pperf \breve #})) ;; THROW
   ;; Divisionis
   (test-equal '(3) (durs-dots 'O #{ \pdiv \breve #})) ;; THROW, because longa is imperfect (by default).
   (test-equal '(3) (durs-dots 'O #{ \pdiv 1 #})) ;; Divisionis.
   (test-equal '(3) (durs-dots 'O #{ \pdiv 1. #})) ;; THROW
   ;; Alterationis
   (test-equal '(3) (durs-dots 'O #{ \palt \breve 1 1 #})) ;; Second note gains alteration.
   (test-equal '(3) (durs-dots 'O #{ \palt \breve 1 \alt 1 #})) ;; Allowed but not stacked.
   (test-equal '(3) (durs-dots 'O #{ \palt \breve 1 1. #})) ;; THROW
   (test-equal '(3) (durs-dots 'O #{ \palt \breve \breve \breve #})) ;; THROW, because longa is imperfect (by default).
  )
)

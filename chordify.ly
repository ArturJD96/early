\version "2.24.4"
\include "src/testing.ily"


#(define (logn base x)
  (let ((result (/ (log10 x) (log10 base))))
   result))

#(define (log2 x) (logn 2 x))


#(define (length->durations len)
  "Return list of (incrementally smaller) durations
   that sum up to the duration length len."

   ; TO DO: duration 'factor' NOT taken into account!
   ; ...maybe pass it as a separate argument?
   ; ...or pass the whole mensural context to calculate it within it?

  (define (next-durlog dur)
   (+ (ly:duration-log dur)
      (ly:duration-dot-count dur)
      1))

  (define (add-dot dur)
   (ly:make-duration
    (ly:duration-log dur)
    (1+ (ly:duration-dot-count dur))
    (ly:duration-scale dur)))


  (let loop ((durs '()) ;; Negative dur-logs.
             (len len)) ;; Remaining duration length to turn to durations.

   (if (= len 0)
    (reverse durs)
    (let* ((ndl (- (inexact->exact (floor (log2 len)))))
           (rem (- len (expt 1/2 ndl))))
     (cond ((null? durs)
            (loop (cons (ly:make-duration ndl) durs) rem))
           ((= ndl (next-durlog (car durs)))
            (loop (cons (add-dot (car durs)) (cdr durs)) rem))
           ((= rem 0)
            (reverse (cons (ly:make-duration ndl) durs)))
           ((>= ndl 7) ; Value is smaller than 128th note.
            (reverse (cons (ly:make-duration 7 0 (* rem (expt 2 ndl))) durs)))
           (else (loop (cons (ly:make-duration ndl) durs) rem)))
))))


#(testing "length-durations"

  (test-group "No scaling."

   (define dur (ly:make-duration 0))
   (define ddur (ly:make-duration 1 1))

   (test-equal "Duration is retrieved back."
    (list dur)
    (length->durations (duration-length dur)))

   (test-equal "Dotted duration is retrieved back."
    (list ddur)
    (length->durations (duration-length ddur)))

   (define durs
    (list (ly:make-duration -2 2) ;; \longa..
          (ly:make-duration 2 1)  ;; 4. <- dur not allowing longa to be triple-dotted.
          (ly:make-duration 5 0) ;; 32 <- dur not allowing 4ter to be double-dotted.
          (ly:make-duration 20)))

   (test-equal "Complex duration (no scaling) is retrieved back."
    durs
    (length->durations
     (apply + (map duration-length durs))))
  )

  ; TO DO: tests for the duration factor!
  ; (test-equal "Simple duration")
  ; (test-group "With scaling"
  ; )
)


chordify = #(define-music-function (remove-tied-notes music) ((boolean? #f) ly:music?)

 (define (music-first-rhythmic-events music)
  (fold-some-music
   (lambda (mus) (music-is-of-type? mus 'rhythmic-event))
   ;; We need to skip a note if it lasts no time (i.e. dur compress is 0).
   ;; This results from duration subtracting of the note to itself.
   (lambda (mus prev)
    (if prev prev
     (if (> (duration-length (ly:music-property mus 'duration)) 0)
      mus #f))
   )
   #f music))

 (define (duration=? dur1 dur2)
  (= (duration-length dur1)
     (duration-length dur2)))

 (define (music-add-tie! mus)
  (ly:music-set-property! mus 'articulations
   (append (ly:music-property mus 'articulations)
           (list (make-music 'TieEvent)))))


 (define (gather chords music) ;; music elements of the simultaneous music.

  (let ((first-rhythmic-events
         (filter-map
           music-first-rhythmic-events
           (ly:music-property music 'elements))))

   (if (null? first-rhythmic-events)

    chords

    (let* ((mom-lengths
            (map (lambda (mus) (ly:moment-main (ly:music-length mus)))
             first-rhythmic-events))

           (len-shortest
            (apply min mom-lengths))

           (durs-new
            (length->durations len-shortest)) ;; This is NOT a single duration but a LIST becaue a veeery complex moment can be expressed by many (tied) durations.

           (chords-new
            (map (lambda (dur) ;; New shortest duration.
                  (make-music 'EventChord 'elements
                   (map (lambda (fr)
                         ;; Subtract duration of current chord and repeat from the next note.
                         (ly:music-set-property! fr 'duration
                          (make-duration-of-length
                           (ly:make-moment
                            (- (duration-length (ly:music-property fr 'duration))
                                (duration-length dur)))))
                        (let ((copy (ly:music-deep-copy fr)))
                         ;; If duration of a note still lasts, we must append a tie.
                         (when (> (duration-length (ly:music-property copy 'duration)) 0)
                          (music-add-tie! copy))
                         (ly:music-set-property! copy 'duration dur)
                         copy))
                    first-rhythmic-events)))
            durs-new)))

     (gather (append chords chords-new) music)
 ))))

 ;; After merging, return sequence of chords.
 (music-map
  (lambda (mus)
   (cond
    ((music-is-of-type? mus 'simultaneous-music)
     (make-music 'SequentialMusic 'elements
      (map (lambda (chord)
            (let ((els (ly:music-property chord 'elements)))
             (if (= (length els) 1) (car els) chord)))
       (gather '() mus))))
    (else mus)))
  music)

)

#(testing "chordify"

  ; TO DO: this is extremely important!
  ; move it to 'test-music..?
  (define (normalize music)
   "Make sure all the keys of music object are sorted, allowing for comparison."
   (music-map
    (lambda (m)
     (if (music-is-of-type? m 'note-event)
      (let ((note-fresh (make-music 'NoteEvent))
            (sorted-keys
             (sort-list (ly:music-mutable-properties m)
              (lambda (c p)
               (let ((c-key (symbol->string (car c)))
                     (p-key (symbol->string (car p))))
                 (string<? c-key p-key))))))
       (set-mus-properties! note-fresh sorted-keys)
       note-fresh)
      m))
   music))

  (test-equal "Single event."
   (normalize #{ c1 #})
   (normalize #{ \chordify c1 #})
  )

  (test-equal "Sequential music."
   (normalize #{ c2 d1 c'2. g4 #})
   (normalize #{ \chordify { c2 d1 c'2. g4 } #})
  )

  (test-equal "Simultaneous music (single event vs sequential music)." (normalize #{
        <c'~ f>2
        <c' c>2
   #})
   (normalize #{ \chordify << c'1 \\ { f2 c } >> #})
  )

  (test-equal "Simultaneous music (simple)." (normalize #{
        <c' c~>2
        <d'~ c>4
        <d' g'>2.
   #})
   (normalize #{ \chordify << { c'2 d'1 } \\ { c2. g' } >> #})
  )

  (test-equal "Simultaneous music (more complex)." (normalize #{
        <c g~ c'~>2
        <d~ g c'~>4
        <d~ a~ c'>4
        <d a d'>2
   #})
   (normalize #{ \chordify << { c2 d1 } \\ { g2. a } \\ { c'1 d'2 } >> #})
  )

  (test-equal "Simultaneous music (branching)." (normalize #{
        a2
        {
            <b d~>2
            <c~ d>4
            <c~ e>4
            <c f>2
        }
   #})
   (normalize #{ \chordify { a2 << { b2 c1 } \\ { d2. e4 f2 } >> } #})
  )

  (test-equal "Simultaneous music (with dead branch)." (normalize #{
        a2
        {
            <b d~>2
            <c~ d>4
            <c~ e>4
            c2
        }
   #})
   (normalize #{ \chordify { a2 << { b2 c1 } \\ { d2. e4 %{ s2 %} } >> } #})
  )

  ; TO DO:
  ; (test-equal "Doubled pitch is removed"
  ;  (normalize #{ <c c'~>1 c1  #})
  ;  (normalize #{ \chordify << { c1 c'1} \\ { c'\breve } >> #})
  ; )

  ; (test-equal "Scaled music" (normalize #{
  ;       <a~ c>4*12/15
  ;       <a d~>4*8/15
  ;       <c'~ d>4*4/15
  ;       <c'~ e>4*12/15
  ;       <c' f~>4*4/15
  ;       <g~ f>4*8/15
  ;       <g c>4*12/15
  ;  #})
  ;  (normalize #{ \chordify << \scaleDurations 2/3 { a2 c' g } \\ \scaleDurations 4/5 { c4 d e f c } >> #}))

  ; (test-equal "Tuplet music" (normalize #{
  ;       % TO DO
  ;       <g d>4.
  ;       \tuplet 15 {
  ;           <a~ c>4*12
  ;           <a d~>4*8
  ;           <c'~ d>4*4
  ;           <c'~ e>4*12
  ;           <c' f~>4*4
  ;           <g~ f>4*8
  ;           <g c>4*12
  ;       }
  ;       \tuplet 3/2 c2

  ;  #})
  ;  (normalize #{ \chordify << \tuplet 3/2 { d'2 a2 c' g c } \\ { g4. \tuplet 5 { c4 d e f c } } >> #}))

)

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
   (let* ((ndl (- (inexact->exact (floor (log2 len)))))
          (rem (- len (expt 1/2 ndl))))
    (cond
     ((null? durs)
      (loop (cons (ly:make-duration ndl) durs) rem))
     ((= ndl (next-durlog (car durs)))
      (loop (cons (add-dot (car durs)) (cdr durs)) rem))
     ((= rem 0)
      (reverse (cons (ly:make-duration ndl) durs)))
     ((>= ndl 7) ; Value is smaller than 128th note.
      (reverse (cons (ly:make-duration 7 0 (* rem (expt 2 ndl))) durs)))
     (else (loop (cons (ly:make-duration ndl) durs) rem)))
)))


#(testing "length-durations"

  (define durs
   (list (ly:make-duration -2 2) ;; \longa..
         (ly:make-duration 2 1)  ;; 4. <- dur not allowing longa to be triple-dotted.
         (ly:make-duration 5 0) ;; 32 <- dur not allowing 4ter to be double-dotted.
         (ly:make-duration 20)))

  (test-equal "Complex duration is retrieved back."
   durs
   (length->durations
    (apply + (map duration-length durs))))

  ; TO DO: tests for the duration factor!
)


chordify = #(define-music-function (remove-tied-notes mus) ((boolean? #f) ly:music?)

 ; TO DO: first-rhythmic-events, removing repeated notes.

 (define (music-first-rhythmic-events music)
  (fold-some-music
   (lambda (m) (music-is-of-type? m 'rhythmic-event))
   ;; We need to skip a note if it lasts no time (i.e. dur compress is 0).
   ;; This results from duration subtracting of the note to itself.
   (lambda (m p)
    (if p p
     (if (> (duration-length (ly:music-property m 'duration)) 0)
      m #f))
   )
   #f music))

 (define (duration=? dur1 dur2)
  (= (duration-length dur1)
     (duration-length dur2)))

 (define (duration>? dur1 dur2)
  (> (duration-length dur1)
     (duration-length dur2)))


 (define (find-shortest-duration rhythmic-events)
  (reduce (lambda (c p)
           (cond ((ly:duration<? c p) c)
                 ((and (duration=? c p)
                       (> (ly:duration-log c)
                          (ly:duration-log p)))
                  c)
                 (else p)))
   #f
   (map (lambda (m) (ly:music-property m 'duration))
    rhythmic-events)))

 (define (music-add-tie! mus)
  (ly:music-set-property! mus 'articulations
   (append (ly:music-property mus 'articulations)
           (list (make-music 'TieEvent)))))

 ; This needs refinement! We should keep the shortest LOG, not the overall length.
 (define (duration-subtract dur1 dur2)

  (define (-durlog2 x)
   (if (= x 0)
    0
    (- (/ (log10 x) (log10 2)))))

  ;(define (closest-pow2 x)
   ;(let loop ((p 1))
  ;  (if (>

  (let* ((len1 (duration-length dur1))
         (len2 (duration-length dur2))
         (len (- len1 len2))
         (l (-durlog2 len))
         (n (numerator len))
         (d (denominator len)))
   ;; Very primitive way of deciding of note dur-log.
   ; TO DO: this doesn't work with mensural contexts!
   ; TO DO: grace notes are not supported.
   ; TO DO: tuplets are not supported!!!!!
   ; (display (integer? (/ len 3/4)))(newline)
   ; (display len)(display (-durlog2 len))(newline)
   ; (display
   ;  (ly:make-duration
   ;   (log2 d)
   ;   ; (floor (/ n 3))
   ;      ; (if (= (floor len) 0) 0 (ly:intlog2 (floor len)))
   ;  ))
   ; )(newline)
   ; (display len)
   ; (when (> len 0)
   ;  (display (ly:intlog2 4)))
   ; (newline)
   (make-duration-of-length (ly:make-moment len))))


 (define (gather chords music) ;; music elements of the simultaneous music.

  (let ((first-rhythmic-events (filter-map music-first-rhythmic-events (ly:music-property music 'elements))))
   (if (null? first-rhythmic-events)
    chords
    (let* ((shortest (find-shortest-duration first-rhythmic-events))
           (chord (make-music 'EventChord
                   'elements
                   (map (lambda (m)
                         (let ((m-copy (ly:music-deep-copy m)))
                          ;; If duration of a note is still going to last,
                          ;; we must append a tie.
                          (when (duration>? (ly:music-property m-copy 'duration) shortest)
                           (music-add-tie! m-copy))

                          (ly:music-set-property! m-copy 'duration shortest)
                         m-copy))
                    first-rhythmic-events))))

     ;; Subtract duration of current chord and repeat from the next note.
     ; TO DO: rewrite it using length->durations, for each duration...
     (map (lambda (m)
           (let ((new-duration (duration-subtract
                                (ly:music-property m 'duration)
                                shortest)))
            (ly:music-set-property! m 'duration new-duration)
            m))
      first-rhythmic-events)

     (gather (append chords (list chord)) music)
 ))))

 ;; After merging, return sequence of chords.
 (music-map
  (lambda (m)
   (cond ((music-is-of-type? m 'simultaneous-music)
          (make-music 'SequentialMusic
           'elements
           (gather '() mus)))
         (else m)))
  mus)
)




#(testing "chordify"

  ; TO DO: this is extremely important!
  ; move it to 'test-music..?
  (define (normalize music)
   "Make sure all the keys of music object are sorted."
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

  (test-equal "Sequential music."
   #{ c2 d1 c'2. g4 #}
   #{ \chordify { c2 d1 c'2. g4 } #}
  )

  ; (test-equal "Simultaneous music (single event vs sequential music)." (normalize #{
  ;       <c'~ f>2
  ;       <c' c>2
  ;  #})
  ;  (normalize #{ \chordify << c'1 \\ { f2 c } >> #})
  ; )

  ; (test-equal "Simultaneous music (simple)." (normalize #{
  ;       <c' c~>2
  ;       <d'~ c>4
  ;       <d' g'>2.
  ;  #})
  ;  (normalize #{ \chordify << { c'2 d'1 } \\ { c2. g' } >> #})
  ; )

  ; (test-equal "Simultaneous music (more complex)." (normalize #{
  ;       <c g~ c'~>2
  ;       <d~ g c'~>4
  ;       <d~ a~ c'>4
  ;       <d a d'>2
  ;  #})
  ;  (normalize #{ \chordify << { c2 d1 } // { g3 a } \\ { c'1 d'2 } >> #})
  ; )

  ; (test-equal "Simultaneous music (branching)." (normalize #{
  ;       a2
  ;       <b d~>2
  ;       <c~ d>4
  ;       <c~ e>4
  ;       c2
  ;  #})
  ;  (normalize #{ \chordify { a2 << { b2 c1 } \\ { d2. e4 } >> } #})
  ; )
)

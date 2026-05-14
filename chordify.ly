\version "2.24.4"
\include "src/testing.ily"


#(define (logn base x)
  (let ((result (/ (log10 x) (log10 base))))
   (if (integer? result)
    (inexact->exact result)
    result)))

#(define (moment->duration mom)
  "Based on the moment's length calculate
  negative dur-log, number of dots and scale factor
  that can be passed as args to ly:make-duration.

  This is complicated because we have three variables
  building a duration in temporal steps and using notation's idioms.

  I realized that moment is a function of duration such as:
  Mom(negdurlog, dots, factor) = factor * 2^negdurlog * sum(1/(2^i), 0<=i<=d).

  I procede by realizing that analyzing moment's:
  * denominator: what part of it can be described as 2^n (from note's rhythmical division);
  * numerator: what part of it can be described as 3^n (from dot multiplying by 3/2).
  ...and finding *remainder values* from which I can calculate the factor.

  I find first a 'basic moment':
  bmom = Mom(ndl, d, 1) such as Mom(ndl, d, f) = bmom + brem

  Then, I find the 'dotted moment':
  dmom = 2^negdurlog * sum(1/(2^i), 0<=i<=d) + drem

  This usually holds:
  Mom = dot0 + (dot1 + dot2 + dot3) + drem + brem,

  Factor is finally calculated as:
  f = dmom / mom (where mom = dmom + brem + drem)

  BEWARE: the amount of dots can be manipulated, so there are less dots but bigger residuals!
  For example: (1 1 1) <=> (1 0 3/2)

  TO DO: mensural flavour, where negdurlog becomes a product of note's complexities...
  "
  (let* ((mom (if (ly:moment? mom) (ly:moment-main mom) mom))
         (num (numerator mom))
         (denom (denominator mom))
         ;; Base moment.
         (n (let base ((d 1)) ;; Highest n such as 2^d < denom.
             (let ((d-new (* d 2)))
              (if (> d-new denom) d (base d-new)))))
         (bmom (/ (floor-quotient (* num n) denom) n))
         (brem (/ (floor-remainder (* num n) denom) (* denom n)))
         ;; Dots = log2(n+1)-1
         (dn (let base ((d 1)) ;; Highest dn such as 3^d < bmom's num (we need to know how many dots are there. HINT: a dot triples the numerator!).
              (let ((d-new (* d 3)))
               (if (> d-new (numerator bmom)) d (base d-new)))))
         (dmom (/ dn n)) ;; Dots are here.
         (drem (- bmom dmom)) ;; Remainder besides dots.
         (dots (logn 3 (numerator dmom))) ;; When we add a dot, we multiply by '3/2'. Thus, we need to retrieve information how many times we multiplied by 3/2.
         ;; Results.
         (negdurlog  (- (logn 2 (/ dmom (/ (- (expt 2 (+ dots 1)) 1) (expt 2 dots))))))
         (factor (/ dmom mom))
         (duration (ly:make-duration negdurlog dots factor))
        )

   ;; Because we do some heuristics here, better let us assert the result.
   (if (= mom (duration-length duration))
    duration
    (begin
     (ly:warning "moment->duration failed to correctly calculate duration from:\n* ~A: result is:\n* ~A = ~A.\nOutputting visually incorrect but durationaly reliable result:\n* ~A.\n" (ly:make-moment mom) duration (ly:duration-length duration) (make-duration-of-length (ly:make-moment mom)))
     (make-duration-of-length (ly:make-moment mom))))))

#(testing "mom->durargs"
  (define dur (ly:make-duration 2 2))
  (test-equal dur (moment->duration (ly:duration-length dur)))
  (test-equal (ly:make-duration 2 2) (moment->duration 57/77)) ;; Here, I verified negdurlog and dot-count by hand, but factor comes from the code and should be suspected if something goes wrong.
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

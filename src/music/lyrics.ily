\version "2.24.4"
% \include "../contexts.ily"

syl =
#(define-music-function (syllable music) (string? ly:music?)
  (ly:music-set-property! music 'early:lyrics syllable)
  music
)

subscribed =
#(define-music-function (music) (ly:music?)
"Turn all the lyrics from the \\syl command
into a proper Lyrics contexts."
  (let ((subscribed-lyrics '()))

   (define (one-rhythmic-event? music)
    (let ((count 0))
     (for-some-music
      (lambda (m)
       (if (music-is-of-type? m 'rhythmic-event)
        (set! count (1+ count))
        #f))
      music)
     (= count 1)))

   (define (append-lyric text dur monosyllabic)
    (set! subscribed-lyrics
     (append subscribed-lyrics
      (list
       (make-music 'LyricEvent
        'early:monosyllabic monosyllabic
        'text text
        'duration dur)))))

   ;; change it to "_" space.
   (define (append-empty-from-rhythmic-event m)
    (append-lyric "" (ly:music-property m 'duration) #f))

   (define (append-lyric-from-sequential-music m)
    (append-lyric
     (ly:music-property m 'early:lyrics) ;; Early's property set in \syl.
     (make-duration-of-length (ly:music-length m))
     (one-rhythmic-event? m)))

   ;; change music into lyrics
   (for-some-music
    (lambda (m)
     (let ((lyr (ly:music-property m 'early:lyrics)))
      (cond
       ((not (null? lyr))
        (append-lyric-from-sequential-music m))
       ((music-is-of-type? m 'rhythmic-event)
        (append-empty-from-rhythmic-event m))
       (else
        #f)
    )))
    music)

   ;; Does it mess-up note/lyric alignment?
   ;; try with \addlyrics.
   (make-music 'SimultaneousMusic
    'elements
    (list music
     (make-music 'ContextSpeccedMusic
      'create-new #t
      'property-operations '()
      'context-type 'EarlyLyrics
      'element
      (make-music 'SequentialMusic
       'elements
       subscribed-lyrics
   ))))
))

#(define-public (early:calc-x-offset-based-on-syllable-length grob)
  (let* ((offset (ly:self-alignment-interface::aligned-on-x-parent grob))
         (event (ly:grob-property grob 'cause))
         (music (ly:event-property event 'music-cause))
         (monosyllabic? (ly:music-property music 'early:monosyllabic)) ;; EARLY music property.
         (stencil (ly:grob-property grob 'stencil))
         (extent (ly:stencil-extent stencil X))
         (width (- (cdr extent) (car extent)))
         (mod (/ width 2)))
   (if monosyllabic?
    (- offset mod)
    offset
)))

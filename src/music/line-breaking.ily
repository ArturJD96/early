\version "2.24.4"

barify =
#(define-music-function (music) (ly:music?)
"
Appends a barline after each rhythmic event
allowing for line-breaking in Line_break_engraver.
"
  (music-map
   (lambda (m)
    (if (music-is-of-type? m 'rhythmic-event)
     #{
        #m
        #(early:X-extent 'once-override 'EarlyStaff 'BarLine 'as-nothing)
        \bar ""
     #} ; maybe make a custom line-breaking event? EarlyLineBreak?
     m))
   music))

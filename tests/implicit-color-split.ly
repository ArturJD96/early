\version "2.24.3"
\include "../early.ly"

music = \relative {
    g'\maxima \longa \breve 1 2 4 8 16 32 64 \bar "|"
}

\layout {
    indent = 0
    \override Score.SpacingSpanner.packed-spacing = ##t
}

\new EarlyStaff \new EarlyVoice {

    \mark "blackmensuralhollow"
    \blackmensuralhollow \music
    \set implicitColorAfterDurlog = #+inf.0 \music \break
    \set implicitColorAfterDurlog = 4 \music \break
    \mark "whitehollow"
    \whitehollow \music
    \set implicitColorAfterDurlog = 3 \music \break
    \set implicitColorAfterDurlog = 2 \music \break
    \mark "whitemensural"
    \whitemensural \music
    \set implicitColorAfterDurlog = 1 \music \break
    \set implicitColorAfterDurlog = 0 \music \break
    \set implicitColorAfterDurlog = -1 \music \break
    \set implicitColorAfterDurlog = -2 \music \break
    \set implicitColorAfterDurlog = -3 \music \break
    \mark "blackmensural"
    \set implicitColorAfterDurlog = -4 \music
    \set implicitColorAfterDurlog = #-inf.0 \music
    \blackmensural \music

}

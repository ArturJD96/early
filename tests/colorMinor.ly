\version "2.24.3"

\include "../early.ly"
\include "../mensural.ly"

expected-music = \mensural \relative d'' {
    % \override Stem.direction = #UP
    d1. d2 \bar "|"
    d1. d4 d \bar "|"
    d1.. d4 \bar "|"
    d\breve d1 d2 d \bar "|"
}

colorMinor-music = \mensural \relative d' {
    % \override Stem.direction = #DOWN
    \colorMinor { d\breve d1 } \break
    \colorMinor { d\breve d2 d2 } \break
    \colorMinor { d\breve d2 } \break
    d\breve d1 d2 d \bar "|"
}

\layout {
    indent = 0
    ragged-right = ##t
    \context { \Score
        \override SpacingSpanner.packed-spacing = ##t
    }
}

\new EarlyStaff <<
    \new EarlyVoice \voiceOne \expected-music
    \new EarlyVoice \voiceTwo \colorMinor-music
>>

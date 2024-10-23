\version "2.24.3"

\include "../early.ly"
\include "../mensural.ly"

perfectum-music = \mensural \relative d'' {
    % \modus #'imperfectum
    \voiceOne
    \mensura "O"
    \perfect
    d\breve c b
    \pperf a\breve
    g
    g\maxima \bar "|"
    \imperfect
    d'\breve c b
    \pperf a\breve
    g
    g\maxima \bar "|"
}

expected-music = \mensural \relative d' {
    \voiceTwo
    \time 3/2
    d\breve. c b a g g\maxima. \bar "|"
    d'\breve c b a g g\maxima \bar "|"
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
    \new EarlyVoice \voiceTwo \perfectum-music
>>

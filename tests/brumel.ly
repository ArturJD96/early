\version "2.24.3"

\include "../early.ly"
\include "../mensural.ly"

% note: longa/cup notehead is shorter

m = \melisma
mE = \melismaEnd

planus =
#(define-music-function (music) (ly:music?)
  music)

hollow =
#(define-music-function (music) (ly:music?)
  music)

tenor = \relative \mensural #(early:mensura-properties) {

    \clef "petrucci-c4"

    \planus {
        f\breve\m
        \[ f g\mE \]
        f\m f\mE
    }

    \bar "|"

    \time 2/2
    r\longa r
    % eternam
    r\breve \[ f\breve\m g a\mE \]
    a\breve\m
    \[ g \flexa f g\breve\mE \]
    f1\m r2 c'1 a2 g1\mE
    f1\breve
    % dona
    \[ f\breve\m g a\mE \]
    \[ a\longa\m g\mE \]
    % eis
    r1 g
    \[ a1\m b \]
    c\breve
    \colorMinor { c\breve b1 }
    \[ a1 \flexa g \]
    \[ b1 \flexa g \]
    g\breve\mE
    % domine
    r1 f1\m
    \[ f\breve g \]
    a\breve
    g1 c\breve.
    \[ a1 b g\breve \]
    f\breve
    % et lux
    a\breve
    \colorMinor { a\breve\m g4 f }
    \[ g1 \flexa f\mE \]
    % perpetua
    \[ a1\m g\mE \]
    \[ a\m bes!\mE \]
    g1 a2\m c1 b4 a g1
    f\breve\mE
    % luceat
    \[ a1\m g\mE \]
    a1 b\m
    c\longa
    \[ a\breve g \]
    bes\longa
    a\breve g
    \[ f\breve g a\longa \]
    \[ g1 \flexa f \]
    \[ e1 f\mE \]
    % eis
    g\longa\m
    \[ f1 e f\breve g\mE \]
    f\maxima

    \bar "||"

    % \break

    \planus {
        \[ f\breve\m g\mE \]
        \[ g\m f\mE \]
        \[ g\m a\mE \]
        \bar "|"
        a\m a\mE
        a\m a a\mE g
        bes g1\m g
        \hollow a\longa
    }

    \bar "|"

    \time 2/2
    % te decet
    a\breve
    \[ b\m a\mE \]
    a c\m c c\mE
    d\m \[ c d\mE \]
    d
    c1\m a\mE
    \[ b\breve a \]
    a\longa\fermata

    \bar "||"

    % exaudi...
    a\breve
    \[ b\m c\mE \]
    d1 d
    d\breve
    c1 c\m c\mE c\m
    c\breve\mE
    d c
    c\breve c1 c\m
    c\breve\mE
    % veniet
    a\breve
    \[ b \colorMinor { c \] g1 }
    \[ f1 \flexa e \]
    \[ f1 a g\breve f\longa \]

    \bar "||"

}

text = \lyricmode {

    E quiem

    E ter nam
    do na e is
    domi ne
    et lux
    per pe tu a
    lu ce at
    e is

    Te de cet
    ymnus deus
    in ſyon

    Et ti bi
    reddetur votum
    in hieru ſa lem

    E xau di
    o ra ti onem
    meam
    Ad te omnis
    caro veni et

}

\layout {
    indent = 0
    ragged-right = ##t
    \context { \Score
        \override SpacingSpanner.packed-spacing = ##t
    }
}

\score {<<
    \new EarlyStaff = "Tenor" {
        \new EarlyVoice \tenor \addlyrics \text
    }
>>}

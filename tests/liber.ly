\version "2.24.3"

\include "../early.ly"
\include "../mensural.ly"

% "Liber Scriptus" from Brumel's Dies Irae

% note: longa/cup notehead is shorter

m = \melisma
mE = \melismaEnd

hollow =
#(define-music-function (music) (ly:music?)
  music)

cantus = \mensural \relative a {

    \clef "petrucci-c2"
    \mensura "C|"
    c\longa\rest
    e\longa\rest
    r\longa^"*"
    % liber
    a\longa \[ g\breve\m f\mE \]
    g\breve\m a1. g2 f1 e1. d2 d\breve c1\mE
    d\breve
    % proferetur
    r\breve d c
    a1.\m b2 c1 d\breve c1\mE
    d\breve
    % in quo
    r\breve r1^"*" f1 \[ e\breve\m d\mE \] c\m a\mE
    r1 c1 d1.\m e2\mE
    f\breve\m e1 d\breve c1\mE
    d\breve
    % unde
    r\breve a'\breve\m f g d\mE
    r1 c1 d\m f e g f e\breve d c1
    d\longa
    \bar "||"

}

altus = \relative \mensural {

    \clef "petrucci-c4"
    \mensura "C|"
    c'\longa\rest
    f,\longa\rest
    r\longa^"*"
    % liber
    a1.\m b2\mE
    \[ c1\m d \]
    \[ b c \]
    d2 c4 b a1\mE
    % scriptus
    r1 g1\m c1. b2 a1 g
    \[ f1 g e\breve\mE \]
    % proferetur
    r1 d\breve\m g1\mE
    f1\m g
    e1 a1. g2 f1 e d2 f1 g2 e1\mE
    % in
    r1 d1 f
    g1\m d d' c2 a1 c2 b g1 b2
    a\breve f1 d e1\mE r1^"*"
    % continetur
    r1 g1\m d1. c4 b c1 d\mE % NOTE: line!
    e\breve d\longa
    % unde
    r1 d'1.\m c4 b a1\mE
    g1
    % mundum
    c1\m b g
    a1. g2 f e d1 c\mE
    % iudicetur
    e1 d\m g a f\mE
    e\breve d\longa
    \bar "||"

}

cantus_text = \lyricmode {

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

cantus_text = \lyricmode {
    I ber ſcrip tus po fe re tur
    in quo totum con ti ne tur
    "vne munus" iu ice tur
}

altus_text = \lyricmode {
    I ber ſcriptus pofe retur
    In quo totum conti ne tur
    Un e munus iu i ce tur
}

\layout {
    indent = 0
    ragged-right = ##t
    \context { \Score
        \override SpacingSpanner.packed-spacing = ##t
    }
    \context { \EarlyVoice
        % checking if order of engravers is not harming
        % the note-interface calls in acknowledgers.
        \remove Mensural_ligature_engraver
        \consists Mensural_ligature_engraver
    }
}

\score {<<
    \new EarlyStaff = "Cantus-Staff" {
        \new EarlyVoice = "Cantus-Voice" \cantus \addlyrics \cantus_text
    }
    \new EarlyStaff = "Altus-Staff" {
        \new EarlyVoice = "Altus-Voice" \altus \addlyrics \altus_text
    }
>>}

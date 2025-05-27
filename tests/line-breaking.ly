\version "2.24.4"

\include "early/early.ly"

#(set-global-staff-size 60) % ridiculously big to see differences.

#(define EXTRA 0.5)

\layout {

    indent = 0
    % short-indent = 80

    %% This needs to go together – otherwise no effect.
    \context { \EarlyStaff
        \override NoteColumn.extra-spacing-width = #`(0 . ,EXTRA)
    }
    \context { \EarlyVoice
        \override NoteHead.extra-spacing-width = #`(0 . ,EXTRA)
        \override Rest.extra-spacing-width = #`(0 . ,EXTRA)
    }

    \context { \Lyrics
        \override LyricText.font-size = -2
    }

}


fbreak = \tag #'facsimile-breaks \break

cantus = \early \relative g' {

    \whitemensural
    \clef "petrucci-c1"
    \mensura "C|"
    % \key d\minor

    \stemU

    r\longa
    \syl "ET" g1
    \syl "exulta" { g2 a2. g4 }
    a4 \stemN b c1
    b2. \once \stemU a8 g a1
    \syl "uit" g1 r1

    r2
    \syl "spiritus meus" { g2 \once \stemU a f g e \fbreak }
    f2. g4 e2
    \syl "spus" { c'2 b d1 }
    \syl "meus" { c b2 c\breve\fermata }

    % In Deo
    \syl "in" a\breve
    \syl "deo" { a1 g }
    \syl "salutari" { e2 f g e }
    \syl "meo" { d1 c2 }
    g'2 a b \fbreak
    c1 a
    g2. f4 e2 d
    c2 c'1 b4 a
    b1 r

    \syl "salutari" { a1. a2 g2 e }
    \syl "meo" { f1 e }
    \syl "salutari" { c'1 b2 g a }
    c2 b a1
    \syl "meo" { g1 f2 }
    \oStemD g\longa
    \bar "|||" \fbreak % does not display

}

\bookpart {
    \header {
        title = "Natural linebreaks"
        subtitle = "early:Line_break_engraver"
        subsubtitle = "Smijers, Magnificat VIII toni 2"
        composer = "ILVB 158"
        copyright = "Engraved with Early"
        tagline = ""
    }
    \score {
        \removeWithTag #'facsimile-breaks
        \new EarlyStaff <<
            \new EarlyVoice { \cantus }
        >>
    }
}
\bookpart {
    \header {
        title = "Forced linebreaks"
        subtitle = "according to manuscript"
        subsubtitle = "Smijers, Magnificat VIII toni 2"
        composer = "ILVB 158"
        copyright = "Engraved with Early"
        tagline = ""
    }
    \score {
        \keepWithTag #'facsimile-breaks
        \new EarlyStaff <<
            \new EarlyVoice { \cantus }
        >>
    }
}

\version "2.24.4"
\include "../early.ly"
\include "../src/stencils/quill.ly"

%{
%
%   This test is meant to check if the quill-backend doesn't throw.
%
%   Music source:
%   © Brno - Archiv města Brna - fond V 2 Svatojakubská knihovna, ms. 15/4 / Alamire Digital Lab
%   https://www.alamirefoundation.org/en/outreach/past-forward-reimagining-early-music-through-the-digital-medium/
%
% %}

\layout {

    % \earlyLayout
    \context { \Score
        \override SpacingSpanner.packed-spacing = ##t
    }

    \context { \EarlyStaff
        \override StaffSymbol.stencil = #(early-staff delicate-jagged-line)
    }

    \context { \EarlyVoice
        \override NoteHead.early-quill = #(early:quill 0.01 0.23)
        \override NoteHead.stencil = #early:note-head::quill
    }

}

\header {
    title = "Quill."
}

\score {
    \new EarlyStaff {
        \new EarlyVoice \early \relative c' { \whitemensural

            \clef "petrucci-c2"
            \key c\dorian
            \mensura "C"

            c\breve
            \syl "Kyrie" { es1. d4 c }
            d\breve c r
            c1. d2 es1 f
            g1. a2 bes1 bes
            c1. bes4 a g1
            c1 bes2. a4
            \fbreak

            g1 r
            f1 es2. d4 c2
            es2. d4 d1 c2
            d\breve. f
            g1 a bes
            es,1 es4 d c bes c1
            bes2 es2. f4 g2. f4 es d c2 es

            % c'1 d e f g a b c d e f g a
        }
    }
}

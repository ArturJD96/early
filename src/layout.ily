%% IMPORTANT: inform user about each change done to the layout.

\include "engravers/Line_break_engraver.ily"
\include "music/lyrics.ily"

\layout {

    ragged-right = ##t %% this is deliberate: we need to get around its limitations!

    \context { \Score

        #(display "\n🪷→🌺 Removing bar numbers.")
        \remove Bar_number_engraver

        #(display "\n🪷→🌺 Overriding StaffSymbol width.")
        \override StaffSymbol.width =
    	#(lambda (grob)
    	  (ly:output-def-lookup (ly:grob-layout grob) 'line-width))

    }

    \context { \Lyrics
        #(display "\n🪷→🌺 Overriding lyrics placement.")
        % \override LyricText.X-offset = #early:calc-x-offset-based-on-syllable-length
    }

}

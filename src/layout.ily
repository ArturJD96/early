%% IMPORTANT: inform user about each change done to the layout.

\include "engravers/Line_break_engraver.ily"

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

}

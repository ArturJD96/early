%% IMPORTANT: inform user about each change done to the layout.

\layout {

    % ragged-right = ##t %% this is deliberate: we need to get around its limitations!

    \context { \Score

        % \remove Forbid_line_break_engraver
        #(display "\n🌺 Removing bar numbers.")
        \remove Bar_number_engraver

        #(display "\n🌺 Overriding StaffSymbol width.")
        \override StaffSymbol.width =
    	#(lambda (grob)
    	  (ly:output-def-lookup (ly:grob-layout grob) 'line-width))

    }

}

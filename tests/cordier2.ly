\version "2.24.3"

\include "../mensural.ly"
\include "../early.ly"

% % % % % % % % %
%				 %
% T R I P L U M	 %
%				 %
% % % % % % % % %

pausa =
#(define-music-function (n m) (number? ly:music?) m)

coloratio =
#(define-music-function (n m) (symbol? ly:music?) m)

accidens =
#(define-music-function (m) (ly:music?) m)

superius = \mensural \relative e' {

    \blackmensural-chantilly
	\clef "mensural-c2"
    \mensura "O"

	\pausa #2 r\longa
	\pausa #2 r
	\pausa #3 r1 \pausa #3 r d
	\[ d1 c \] b1
	a\breve*2/3 e'2 f
	\[ g1 d \] e2 f

	\coloratio #'red \scaleDurations 2/3 {
		g1 f2
		e1 f2
		\pausa #3 r2 e d
	}


	\mensura "C."

	\scaleDurations 2/1 {
		f2 \pausa #3 r e4 f
		e2 d2*2
	}

	\coloratio #'white \scaleDurations 3/2 {
		\[ c1*2/3 f \]
		e2 d1*2/3 c2
	}

	\scaleDurations 2/1 {
		d1
		\pausa #1 r2 \pausa #1 r a
		a2 \accidens cis2*2
		d1*2/3 d2
		f1*2/3 a2
	}


	\mensura "C."

	\scaleDurations 2/3 {
		a1*2/3 g2.*2/3
		g2 \accidens fis\breve*2/3 e2
	}

	\coloratio #'white \scaleDurations 1/3 {
		g1 a b a
		c1 \[ b\breve a \] g\breve f1
	}

	\mensura "O|"

	\scaleDurations 2/1 {
		a1 \pausa #5 r a
		\[ g1 f \] e1
		d\breve*2/3 d2 e
	}

	\coloratio #'red \scaleDurations 4/3 {
		\[ c\breve f \] e
	}

	\scaleDurations 2/1 {
		d\breve*2/3 c1
		e1. c2 d e
		c1 d\breve*2/3
		\[ c1 b1*2 \]
		a\breve
		\pausa #1 r1 \pausa #1 r a1
		c\breve*2/3 e1
		f\breve*2/3 e1.*2/3
		d1 a'\breve*2/3
		\[ a1 g \] g2 f
		a1 \pausa #4 r e2 f
		g\breve*2/3 \pdiv e1
		c1 f\breve*2/3
		e1 d\breve*2/3
		c2 b\breve*2/3 c2
	}

	\mensura "C."
	\scaleDurations 2/1 { a2 \pausa #5 r e'4 f }

	\proportio 3
	\scaleDurations 2/3 {
		g1*2/3 f2
		e1*2/3 d2
		e1*2/3 f2
	}

	\proportio 8/9

	\scaleDurations 2/3 {
		d2 e
		c \[ d1*2/3 c \]
		b1*2/3

		d\longa
		\bar "||"
	}


}

% % % % % % % % %
%				%
%  C O N T R A	%
%				%
% % % % % % % % %

% contra = {

% \mensura #'((sign . #f)(modus . #f)(tempus . #t)(prolatio . #f)) \relative c' {

% 	\clavis #'c #4

% 	\pausa #3 r1 \pausa #3 r g
% 	\ligatura { g1 f } e1

% }

% \mensura #'((modus . #f)(tempus . #f)(prolatio . #t)) \relative c {

% 	\scaleDurations 2/1 {
% 		d2 d'1*2/3
% 		b2 \pausa #2 r g
% 		a1
% 		\pausa #1 r2 \pausa #1 r e
% 		f d \pausa #1 r
% 	}

% 	\coloratio #'red \scaleDurations 4/3 {
% 		\ligatura { d'1 c } b1
% 		\ligatura { c1 a } b1
% 	}

% 	\scaleDurations 2/1 {
% 		a2 f1*2/3
% 		a2 g1*2/3
% 		a2 r b
% 		a2. b4 c d
% 		e1*2/3 e2.*2/3
% 		a,2 a1*2/3
% 		d,\breve*5/6 \pausa #1 r2
% 		\accidens cis'1*2/3 b2.*2/3
% 		\pausa #4 r2 d2*2
% 	}

% 	\coloratio #'red \scaleDurations 4/3 {
% 		\ligatura { e1 c } a1
% 	}

% 	\scaleDurations 2/1 {
% 		\ligatura { d,1 f }
% 		\pausa #4 r2 \pausa #4 r2 c'2
% 		b2 a2*2
% 		\ligatura { b1 a }
% 		e1*2/3 g2.*2/3
% 		d2 c' d
% 		e
% 		  \ligatura { c1 b1*2/3 } % perfecta ante similem
% 		c2 \pausa #3 r2 a2
% 		a1*2/3 d,2.*2/3
% 		e2 g1*2/3
% 		d2 \accidens cis'1*2/3
% 		d2 b2*2
% 		a1*2/3 d,2.*2/3
% 		a'2 a2*2
% 		e1*2/3 \pausa #1 r2
% 	}

% 	\coloratio #'red \scaleDurations 4/3 {
% 		\ligatura { c'1 a } b1
% 	}

% 	\scaleDurations 2/1 {
% 		1*2/3 g2
% 		a\longa*1/2 % final note must concord with other voices.
% 	}

% 	\linea "||"

% }}

% % % % % % % % % %
% %				%
% %	T E N O R	%
% %				%
% % % % % % % % % %

% tenor = \relative {
% \mensura #'((sign . #f) (modus . #f)(tempus . #t)(prolatio . #f)) {

% 	\clavis #'c #4

% 	\pausa #1 r\longa
% 	\pausa #3 r1 \pausa #3 r1 g1
% 	\ligatura { g1 f } e1
% 	\ligatura { d\breve g a g\longa }
% 	\ligatura { f\breve g }

% 	\coloratio #'red \scaleDurations 2/3 \ligatura { a\breve f e }

% 	\ligatura { d\breve a' e d }

% 	d'\longa
% 	e\breve*2/3 d1.*2/3
% 	\ligatura { c1 b1*2 a\breve }

% 	\ligatura { \accidens cis\breve d a }

% 	\coloratio #'red \scaleDurations 2/3 \ligatura { g\breve a f }

% 	\ligatura { e\breve f g a\breve*2/3 } b1

% 	\coloratio #'red \scaleDurations 2/3{ a\longa g\breve }

% 	\ligatura { f1 a1*2 d,\breve*2/3 } d'1.*2/3

% 	\ligatura { \noobliqua c1 b1*2 \obliqua a\breve g a }

% 	\ligatura { d,\breve g a }

% 	\coloratio #'red \scaleDurations 2/3 \ligatura { g\breve f e }

% 	d\longa

% 	\linea "||"

% }}

% helper = \mensura #'((modus . #t)(tempus . #t)(prolatio . #f)) {

% 	\repeat unfold 46 { f\breve \linea "|" }
% 	\linea "||"

% }




% S C O R E


#(set-global-staff-size 26)


\paper {

  % #(set-default-paper-size "a4landscape")

  system-separator-markup = \slashSeparator

  top-margin = 15
  bottom-margin = 15
  left-margin = 20
  right-margin = 20
  indent = 15

  system-system-spacing =
    #'((basic-distance . 10)
       (minimum-distance . 10)
       (padding . 1)
       (stretchability . 20))

  #(define fonts
  (make-pango-font-tree "carolingia"
                        "carolingia"
                        "carolingia"
                        (/ staff-height pt 20)))

	ragged-last = ##t

}


\header{

	title = "Belle, Bone, Sage"
	composer = "Baude Cordier"

  arranger = \markup \italic { Transcription by Artur Jerzy Dobija }
  dedication = ""
  % copyright = \copyright
  enteredby = "arturdobija@gmail.com"
  subtitle = "SOMETHING VIRELAI OR WHAT"
  tagline = ""

}


\layout {

	ragged-right = ##f
	indent = 0

	\enablePolymeter

	% Trick to have the staff lines drawn till the end of line
	% but respecting 'ragged-last' of the music
	% (not stretching music till the end.
	\override Staff.StaffSymbol.width =
	#(lambda (grob)
	  (ly:output-def-lookup (ly:grob-layout grob) 'line-width))

	\context {\Score
		\override SpacingSpanner.packed-spacing = ##t
	}

	% \context {	\BlackMensuralStaff

 %    		\consists "Timing_translator"
	% 	\override Custos.style = #'medicaea

	% 	\override Clef #'space-alist =
	% 	#'((first-note minimum-fixed-space . 0)
	%    	(next-note minimum-fixed-space . 0))

	% 	\override TimeSignature #'extra-spacing-width = #'(0 . 0)
	% 	\override TimeSignature #'space-alist =
	% 	#'((first-note minimum-fixed-space . 0)
	%    	     (next-note minimum-fixed-space . 0))

	% 	\override BarLine #'extra-spacing-width = #'(0 . 0)
	% 	\override BarLine #'space-alist =
	% 	#'((first-note minimum-fixed-space . 0)
	%   	     (next-note minimum-fixed-space . 0))

	% 	\override NoteCollision #'extra-spacing-width = #'(0 . 0)
	% 	\override NoteCollision #'space-alist =
	% 	#'((first-note minimum-fixed-space . 0)
	%   	     (next-note minimum-fixed-space . 0))


	% }

	% \context {	\Voice

 %    		\remove "Forbid_line_break_engraver"
	% 	\revert Accidental.stencil
 %    		tupletFullLength = ##t

	% }

}



\score {<<

	\new EarlyStaff {
		\new EarlyVoice \superius
	}
	% \new BlackMensuralStaff {
	% 	\new BlackMensuralVoice {
	% 		\mensuralTightSetting
	% 		\contra
	% 	}
	% }
	% \new BlackMensuralStaff {
	% 	\new BlackMensuralVoice {
	% 		\mensuralTightSetting
	% 		\tenor
	% 	}
	% }

>>}

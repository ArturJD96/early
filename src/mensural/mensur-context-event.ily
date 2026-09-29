\version "2.24.4"
\include "./../definitions/events.ily" % TO DO: de-centralize and define early:MensurSetting and MensurEvent here?


#(define-public (mensur:make-subdivision dur-log subdivision)

  (unless (integer? dur-log)
   (ly:error "Wrong type: must be durlog, is ~A" dur-log))
  (unless (integer? subdivision)
   (ly:error "Wrong type: must be integer, is ~A" subdivision))
  (unless (>= subdivision 2)
   (ly:error "Subdivision of a note cannot be smaller than 2"))

  (cons dur-log subdivision)
)

%% TO DO: compare with MensurContextSetting... is it the same thing?
#(define-public (mensur:make-setting dur-log implicit as-tuplet)

  (unless (integer? dur-log)
   (ly:error "Wrong type: must be durlog, is ~A" dur-log))
  (unless (or (boolean? implicit) (eq? implicit 'all))
   (ly:error "Wrong type: 'implicit' must be boolean or symbol 'all', is ~A" implicit)) ; TO DO: symbol "all"???
  (unless (boolean? as-tuplet)
   (ly:error "Wrong type: 'as-tuplet' must be boolean, is ~A" as-tuplet))

  `(,dur-log . ((implicit . ,implicit)
                (as-tuplet . ,as-tuplet)))
)

#(define-public (mensur:make-default-setting)
  (cdr (mensur:make-setting 42 #f #f)))

#(define-public mensur:make-context
  (early:define-constructable-music-event!
   'MensurContextDefinition
   "All information needed for note mensuration (i.e. its duration recalculation)."
   '(mensur-context-event StreamEvent) '()
   `(subdivisions . ,alist?) ;; alist (dur-log . subdivision) ; TO DO: alist OF subdivisions
   `(proportio . ,rational?)
   `(settings . ,alist?) ;; alist (dur-log . mensur:settings)
))

#(define-public (mensur:default)
  (mensur:make-context '() 1 '()))

#(define-public early:make-mensur-setting ; TO DO: use & implement
  (early:define-constructable-music-event!
   'MensurContextSetting ;; rename to MensurContextUpdate?
   "Used to update mensuration context. Used in music processed with '\\mensural'. Mensuration setting are Lilypond and Early features that allow for modification of mensural music doration interpretation (e.g. interpreting a note as made of tuplets). Useful with 'oldschool' transcriptions of medieval music."
   '(mensur-context-event StreamEvent) '()
   `(subdivision . ,pair-or-alist?) ;; single or many subdivisions.
   `(implicit . ,pair-or-alist?)
   `(as-tuplet . ,pair-or-alist?)
   `(proportio . ,rational?)
))

#(define-public early:available-mensur-settings ; TO DO: use it with early:make-mensur-setting
  '(subdivision implicit as-tuplet proportio))

mensuraExplicit = #(make-music 'MensurContextSetting 'implicit '())
modusmaiorExplicit = #(make-music 'MensurContextSetting 'implicit '(-3 . #f))
modusExplicit = #(make-music 'MensurContextSetting 'implicit '(-2 . #f))
tempusExplicit = #(make-music 'MensurContextSetting 'implicit '(-1 . #f))
prolatioExplicit = #(make-music 'MensurContextSetting 'implicit '(0 . #f))

mensuraImplicit =
#(make-music 'MensurContextSetting
  'implicit
  (map (lambda (durlog) (cons durlog #t))
   '(-3 -2 -1 0 1 2 3 4 5 6 7 8)) ; I could have used `iota` but this is more explicit.
)
modusmaiorImplicit = #(make-music 'MensurContextSetting 'implicit '(-3 . #t))
modusImplicit = #(make-music 'MensurContextSetting 'implicit '(-2 . #t))
tempusImplicit = #(make-music 'MensurContextSetting 'implicit '(-1 . #t))
prolatioImplicit = #(make-music 'MensurContextSetting 'implicit '(0 . #t))

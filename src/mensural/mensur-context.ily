\version "2.24.4"
\include "./_mensur.ily"
\include "./_mensur-settings.ily"

#(define-public (early:mensur-context mensur settings)
  "Mensur context defines all the rules of how the duration of a note
   is adjusted (when using \\mensural command on the music). "
  `((mensur . ,mensur)
    (settings . ,settings)))

%{
%       Accessors.
%}

#(define-public (mensur-context:mensur context)
  (assq-ref context 'mensur))

#(define-public (mensur-context:settings context)
  (assq-ref context 'settings))

%{
%       Setters.
%}

#(define (mensur-set! mensur-context mensur-event)
  (let ((mensur (mensur-context:mensur mensur-context))
        (settings (mensur-context:settings mensur-context)))
   (case (ly:music-property mensur-event 'mensura-type)
    ((signum)
     (assq-set! mensur-context 'mensur
      `((complex-subdivisions . ,(ly:music-property mensur-event 'complex-subdivisions))
        (proportio . ,(ly:music-property mensur-event 'proportio))))))))


#(define (mensur-setting-set! mensur-context mensur-setting)
  (let* ((mensur (mensur-context:mensur mensur-context))
         (settings (assoc-ref mensur-context 'settings))
         (implicit-subdivisions (mensur-settings:implicit-subdivisions settings)))
   (case (ly:music-property mensur-setting 'implicit-subdivisions)
    ((all)
     (assq-set! mensur-context 'settings
      (early:mensur-settings
       (map (lambda (subd) `(,(car subd) #t))
            (mensur:complex-subdivisions mensur))
       (mensur-settings:as-tuplet settings))))
    ((none)
     (ly:error "Unsupported (yet)."))
    (else
     (for-each
      (lambda (subdivision)
       (let ((durlog (car subdivision))
             (value (cdr subdivision)))
        (assq-set! settings 'implicit-subdivisions
         (assq-set! implicit-subdivisions durlog value))))
      (ly:music-property mensur-setting 'implicit-subdivisions))))))

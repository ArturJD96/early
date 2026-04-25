\version "2.24.4"
\include "./../definitions/events.ily" % TO DO: de-centralize and define early:MensurSetting and MensurEvent here?

% TO DO: consult a good source on definitions of those terms.
#(define mensur:quality-reasons `(
  ;; Usual case.
  (simple-mensur .
   ((description . "Mensura is duplex so complex mensuration does not apply")
    (event . rhythmic-event)
    (qualities . (simple))))
  ;; Reasons for complex.
  (rest .
   ((description . "Rest in mensural music is compulsory complex in complex meters.")
    (event . rest-event)
    (qualities . (complex))))
  (position .
   ((description . "Note mensuration is deduced from position.")
    (event . note-event)
    (qualities . (simple complex partial altera))))
  (punctum-perfectionis .
   ((descritpion . "In complex mensura, note is complex (perfect) because it followed by an immediate dot.")
    (event . note-event)
    (qualities . (complex))))
  ;; For documentation purposes.
  (undocumented .
   ((description . "The reason for mensuration is not explicitly provided")
    (event . rhythmic-event)
    (qualities . (complex simple partial altera))))
  (exception .
   ((description . "A note defies mensural rules")
    (event . rhythmic-event)
    (qualities . (complex simple partial altera))))
))

#(define-public mensur:make-quality
  (early:define-constructable-music-event!
   'MensurQualityEvent
   "Note duration is recalculated using \\mensura."
   '(mensur-event post-event event StreamEvent)
   '()
   `(quality . ,(choice '(simple complex partial altera)))
   `(reason . ,(choice (map car mensur:quality-reasons)))
   `(fraction . ,(nullable fraction?))
))

#(define-public (mensur:quality quality-event) (ly:music-property quality-event 'quality))
#(define-public (mensur:reason quality-event) (ly:music-property quality-event 'reason))
#(define-public (mensur:fraction quality-event)
  (let ((fraction (ly:music-property quality-event 'fraction)))
   (if (null? fraction) 1 fraction)))

% Not needed?
% #(define-public (mensur:music-is-of-quality? rhythmic-event quality-type) ; TO DO: implement!
%   (eq? (mensur:quality (ly:music-property rhythmic-event 'mensur:quality))
%        quality-type))

#(define (mensur:music-set-quality! rhythmic-event quality)

  (unless (music-is-of-type? rhythmic-event 'rhythmic-event)
   (ly:error "Only rhythmic-events can have mensural quality, not ~A" rhythmic-event))
  (unless (music-is-of-type? quality 'mensur-quality-event)
   (ly:error "Wrong type of quality. Must be 'mensur-quality-event', is ~A" quality))

  (let* ((quality-type (mensur:quality quality))
         (reason (mensur:reason quality))
         (reason-data (assq-ref mensur:quality-reasons reason)))

   (unless reason-data
    (ly:error "Unrecognized mensur quality reason: \"~a\"." reason))
   (unless (memq quality-type (assq-ref reason-data 'qualities))
    (ly:error "\"~a\" is not a valid mensural quality reason for a \"~a\" quality. Valid reasons are: ~a." reason quality-type (assq-ref reason-data 'qualities)))
   (unless (music-is-of-type? rhythmic-event (assq-ref reason-data 'event))
    (ly:error "Event cannot have a mensur quality ~a of reason ~a." quality-type reason))

   (ly:music-set-property! rhythmic-event 'mensur:quality quality))
)


#(define-public (mensur:make-simple! rhythmic-event reason)
  (mensur:music-set-quality! rhythmic-event
   (mensur:make-quality 'simple reason)))

#(define-public (mensur:make-complex! rhythmic-event reason)
  (mensur:music-set-quality! rhythmic-event
   (mensur:make-quality 'complex reason)))

#(define-public (mensur:make-altera! note-event reason)
  (mensur:music-set-quality!
   (mensur:make-quality 'altera reason)))

#(define-public (mensur:make-partial! rhythmic-event reason fraction-pair) ;; In scheme, Lilypond's fraction is received as pair.
  (mensur:music-set-quality! rhythmic-event
   (mensur:make-quality 'partial reason
    (/ (car fraction-pair) (cdr fraction-pair)))))

perf = #(define-event-function () () (mensur:make-quality 'complex 'undocumented))
imp = #(define-event-function () () (mensur:make-quality 'simple 'position))
part = #(define-event-function (fraction) (fraction?) (mensur:make-quality 'partial 'position fraction))
altera = #(define-event-function () () (mensur:make-quality 'altera 'position))

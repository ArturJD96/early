\version "2.24.4"
\include "./../definitions/events.ily" % TO DO: de-centralize and define early:MensurSetting and MensurEvent here?
\include "./mensur-quality-event.ily"

% TO DO: this one is about mensur:quality,
% not quality-event in articulations!
% this should be removed and redone.
#(define (mensur:music-set-quality! rhythmic-event quality)

  (unless (music-is-of-type? rhythmic-event 'rhythmic-event)
   (ly:error "Only rhythmic-events can have mensural quality, not ~A" rhythmic-event))
  (unless (music-is-of-type? quality 'mensur-quality-event)
   (ly:error "Wrong type of quality. Must be 'mensur-quality-event', is ~A" quality))

  (let* ((quality-type (quality:type quality))
         (reason (quality:reason quality))
         (reason-data (assq-ref quality:reasons reason)))

   (unless reason-data
    (ly:error "Unrecognized mensur quality reason: \"~a\"." reason))
   (unless (memq quality-type (assq-ref reason-data 'qualities))
    (ly:error "\"~a\" is not a valid mensural quality reason for a \"~a\" quality. Valid reasons are: ~a." reason quality-type (assq-ref reason-data 'qualities)))
   (unless (music-is-of-type? rhythmic-event (assq-ref reason-data 'event))
    (ly:error "Event cannot have a mensur quality ~a of reason ~a." quality-type reason))

   (ly:music-set-property! rhythmic-event 'mensur:quality quality))
)

% This needs to be considered: quality of articulation (user-set) or mensur?

#(define-public (mensur:make-simple! rhythmic-event reason)
  (mensur:music-set-quality! rhythmic-event
   (mensur:make-quality-event 'simple reason)))

#(define-public (mensur:make-complex! rhythmic-event reason)
  (mensur:music-set-quality! rhythmic-event
   (mensur:make-quality-event 'complex reason)))

#(define-public (mensur:make-altera! note-event reason)
  (mensur:music-set-quality!
   (mensur:make-quality-event 'altera reason)))

#(define-public (mensur:make-partial! rhythmic-event reason fraction-pair) ;; In scheme, Lilypond's fraction is received as pair.
  (mensur:music-set-quality! rhythmic-event
   (mensur:make-quality-event 'partial reason
    (/ (car fraction-pair) (cdr fraction-pair)))))

perf = #(define-event-function () () (mensur:make-quality-event 'complex 'undocumented))
imp = #(define-event-function () () (mensur:make-quality-event 'simple 'position))
part = #(define-event-function (fraction) (fraction?) (mensur:make-quality-event 'partial 'position fraction))
altera = #(define-event-function () () (mensur:make-quality-event 'altera 'position))










% This is MORE actual code now:
%
% Quality definition is internal.
% For user-settable quality (via articulation-like event) see quality-event.
%
#(define-public mensur:make-quality
  (early:define-constructable-music-event!
   'MensurQualityDefinition
   "Note duration is recalculated using \\mensura."
   '(mensur-event post-event event StreamEvent) '()
   `(type . ,(choice '(simple complex partial altera))) ; TO DO: make independedt?
   `(reason . ,(choice (map car quality:reasons))) ; TO DO: make independent?
   `(fraction . ,(nullable fraction?))
))

#(define-public (mensur:type quality-definition)
  (ly:music-property quality-definition 'type))
#(define-public (quality:reason quality-definition)
  (ly:music-property quality-definition 'reason))
#(define-public (quality:fraction quality-definition)
  (let ((fraction (ly:music-property quality-definition 'fraction))) ; TO DO: pair satisfying (fraction?) or real fraction?
   (if (null? fraction) 1 fraction)))

#(define-public (mensur:quality rhythmic-event)
  (ly:music-property rhythmic-event 'mensur:quality))
#(define-public (mensur:quality! rhythmic-event quality-definition)
  (ly:music-set-property! rhythmic-event 'mensur:quality quality-definition))

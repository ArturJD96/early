\version "2.24.4"
\include "./../definitions/events.ily"
\include "./mensur-event.ily"
#(use-modules (ice-9 copy-tree))

%%
%% I create my own music iterator allowing
%% 1) mensural-context injection.
%% 2) scope-limited updates to mensural-context
%%    using MensurEvents and MensurSettings
%%
%% I am overriding 'for-some-music' and not 'music-map' because:
%% 1) it has shorter and shallower definition;
%% 2) it iterates from parents to children,
%%
#(define (for-some-mensural-music stop? music mensur-context)
  "Walk through @var{music}, process all elements calling @var{stop?}
   and only recurse if this returns @code{#f}.
   AJD: Based on @code{for-some-music} from 'music-functions.scm'."
  (define (worker mensur-context)
   (lambda (music)
    (when (not (stop? music mensur-context))
     (let ((elt (ly:music-property music 'element))
           (loop (worker (copy-tree mensur-context))))
      (when (ly:music? elt) (loop elt))
       (for-each loop (ly:music-property music 'elements))
       (for-each loop (ly:music-property music 'articulations))))))
  ((worker mensur-context) music)
)

%{
%       Mensural music context.
% %}

mensural = #(define-music-function (music) (ly:music?)

  "Wrap music within the mensural-context
   and recalculate all duration values."

  (for-some-mensural-music
   (lambda (m mensur-context)
    (cond
      ; ((music-is-of-type? m 'sequential-music)
      ;  (...)) ;; go further? Do not mensurate if indicated? Turn into modern notation?
     ((music-is-of-type? m 'early:mensur-event)
      (case (ly:music-property m 'name) ;; update the mensural context
       ((early:MensurEvent)
        (mensur-set! mensur-context m))
       ((early:MensurSetting)
        (mensur-setting-set! mensur-context m))))
     ((music-is-of-type? m 'rhythmic-event)
      (early:mensurate-event m mensur-context)) ;; append mensural properties, store old duration and modify duration.
     (else #f)
   ))
   music
   (early:mensur-context (early:mensur '()) ;; Related to mensur.
                         (early:mensur-settings '() '())) ;; Related to internal LilyPond and Early helpers.
  )
  music

)


mensura = #(define-music-function (signum) (symbol?)

 "Set the mensura of the music."

 (let ((mensur (early:signum->mensur signum)))
   (make-music
    'early:MensurEvent
    'mensura-type 'signum ;; or: color, hollow, proportion, divisio (Italian, see MEI)
    'signum signum
    'complex-subdivisions (mensur:complex-subdivisions mensur)
    'proportio (mensur:proportio mensur)))

)

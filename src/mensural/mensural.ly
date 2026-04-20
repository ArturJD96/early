\version "2.24.4"
\include "./../definitions/events.ily"
\include "./mensur.ily"
\include "./settings.ly"
\include "./signa.ily"
\include "./puncta.ly"

#(use-modules (ice-9 copy-tree))

%%
%% I create my own music iterator allowing
%% 1) mensural-context injection.
%% 2) scope-limited updates to mensural-context
%%    using EarlyMensuraEvent and MensurSettings
%%
%% I am overriding 'for-some-music' and not 'music-map' because:
%% 1) it has shorter and shallower definition;
%% 2) it iterates from parents to children,
%%
#(define (for-some-mensural-music stop? music mensur-context)
  "Walk through @var{music}, modifying its elements according to
  mensur-context. Early mensur-related events can modify this context.

  Based on @code{for-some-music} from 'music-functions.scm':
  \"walk through @var{music}, process all elements calling @var{stop?}
  and only recurse if this returns @code{#f}.\""
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
   (lambda (m mensur)
    (cond
      ; ((music-is-of-type? m 'sequential-music)
      ;  (...)) ;; go further? Do not mensurate if indicated? Turn into modern notation?
     ((music-is-of-type? m 'mensur-event)
      (case (ly:music-property m 'name) ;; update the mensural context
       ((EarlyMensuraEvent) (mensur:override! mensur m))
       ((MensurContextSetting) (mensur:update! mensur m))))
     ((music-is-of-type? m 'rhythmic-event)
      (mensur:mensurate-event! mensur m)) ;; append mensural properties, store old duration and modify duration.
     (else #f)
   ))
   music
   (mensur:default)
  )
  music

)


mensura = #(define-music-function (signum) (symbol?)

 "Set the mensura of the music."

 (early:signum->mensur-event signum)

 ;; OLD CODE:
 ; (let ((mensur (early:signum->mensur-event signum)))
 ;   (make-music
 ;    'EarlyMensuraEvent
 ;    'mensura-type 'signum ;; or: color, hollow, proportion, divisio (Italian, see MEI)
 ;    'signum signum
 ;    'relationships (mensur:relationships mensur)
 ;    'proportio (mensur:proportio mensur)))

 )

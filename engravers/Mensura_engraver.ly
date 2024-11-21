\version "2.24.3"

% Acknowledge music property of early:mensura-properties
% by the context

#(define (empty-completion)
  (let* ((min-log 7)  ;; neg dur-log
         (max-log -3) ;; neg dur-log
         (completions (let c ((i max-log)
                              (l '()))
                       (if (< i min-log)
                        (c (1+ i) (append l (list (cons i 0))))
                        l))))
   completions))



#(define-public (early:Mensura_engraver context)
  (let ((total-mom 0)) ;; reset each completion of maxima?
   (make-engraver

    (listeners

     ((rhythmic-event engraver event)

      (ly:context-set-property! context 'mensura
       (ly:event-property event 'early:mensura-properties))

      (let* ((mom (ly:moment-main (ly:event-property event 'length)))
             (dur (ly:event-property event 'duration))
             (dur-log (ly:duration-log dur))
             (completion (ly:context-property context 'mensuraCompletion))

             (mensural-properties (ly:event-property event 'early:mensura-properties))
             ;(ternary (assoc-ref

             ;; this note properties
             (proportion (assoc-ref mensural-properties 'proportio))
             (perfection (assoc-ref mensural-properties 'perfection))
             (alteration (assoc-ref mensural-properties 'altera))

             ;; decide if note is perfect
             (perfection-implicit (assoc-ref perfection dur-log))
             (perfect (if (pair? perfection-implicit) (cdr perfection-implicit) perfection-implicit))
             ;(pperf (assoc-ref mensural-properties 'punctum-perfectionis))

             (next-duration (assoc-ref perfection (1+ dur-log)))
             (expecting-perfect (if (pair? next-duration) (cdr next-duration) #f))
            )

       (when (null? completion)
        (set! completion (empty-completion)))

       (unless (assoc-ref completion dur-log)
        (ly:error "No duration provided for rhythmic-event. Perhaps a typing mistake or '128' set as a duration somewhere?"))

       (if perfect
        (ly:error "Perfect is not implemented yet")
        (assoc-set! completion dur-log
         (+ (assoc-ref completion dur-log)
           (if expecting-perfect
               (if alteration 1/3 2/3)
               1/2)
         )
        ))

       (ly:context-set-property! context 'mensuraCompletion completion)

       (set! total-mom (+ total-mom mom))

      )
      ;; now, check if the current level of mensura is completed.
     )
    )
)))

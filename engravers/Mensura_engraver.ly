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

      (let* ((dur (ly:event-property event 'duration))
             (dur-log (ly:duration-log dur))
             (mom (ly:moment-main (ly:event-property event 'length)))
             (mensural-properties (ly:event-property event 'early:mensura-properties))
             (proportion (assoc-ref mensural-properties 'proportio))
             (perfection (assoc-ref mensural-properties 'perfection))
             (completion (ly:context-property context 'mensuraCompletion))
            )

       (when (null? completion)
        (set! completion (empty-completion))
        (ly:context-set-property! context 'mensuraCompletion completion))

       (set! total-mom (+ total-mom mom))

       (newline)
       (display completion)
      )
      ;; now, check if the current level of mensura is completed.
     )
    )
)))

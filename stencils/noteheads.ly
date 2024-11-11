\version "2.24.3"

\include "point-transform.ly"

% Functions returning path (list of pairs representing points)

#(define (append-corner segment corner)
  (append segment
   (transform corner 0 (last segment))))

% #(define (early:quadrata::band grob) ;; side + corner
%   (let* ((side (ly:grob-property grob 'early-quadrata-side))
%          (corner (transform
%                   (ly:grob-property grob 'early-quadrata-corner)
%                   0
%                   (last side))))
%    (append side corner)
% ))

% #(define (early:quadrata::brim grob) ;; two bases
%   (let* ((b1 (early:quadrata::band grob))
%          (b2 (transform
%               (early:quadrata::band grob)
%               90
%               (last b1))))
%    (append b1 b2)
% ))

#(define (early:quadrata::brim grob)
  (let* ((base (ly:grob-property grob 'early-quadrata-base))
         (side (ly:grob-property grob 'early-quadrata-side))
         (corner (ly:grob-property grob 'early-quadrata-corner))
         (band-1 (append-corner base corner))
         (band-2 (append-corner side corner)))
   (append
    band-1
    (transform band-2 90 (last band-1)))))


#(define (early:quadrata::path grob) ;; two brims
  (let* ((brim1 (early:quadrata::brim grob))
         (brim2 (transform
                 (early:quadrata::brim grob)
                 -180
                 (last brim1))))
   (append brim1 brim2)
))

#(define-public (early:quadrata::note-head grob)
  (let* ((path (early:quadrata::path grob)))
   (make-connected-path-stencil path
    0.01 ; thickness
    1 1 ; xy scale
    #t  ; connect
    #t  ; fill
   )
))











#(define-public (early:pipeline->features grob pipeline)
  "Resolve pipeline into values represented as alist.

  TO DO: 'pipeline' is a wrong name for executing unrelated functions separately.

  Each key in pipeline alist refers to some grob contour feature.
  The order of keys represents the order of procedure execution.
  The resulting path of each feature IS NOT absolute and should be
  transformed according to the early:resolve-grob-path procedure
  (by default, transforming next feature path referencing the last point
  of the previous path."
  (fold (lambda (pair alist)
         (assoc-set! alist
          (car pair)
          ((cdr pair) grob))
        )
   '()
   (reverse pipeline)))

#(define-public (early:combine-features grob path-features-alist)
  "Position feature by the last point of the previous feature."

  (fold (lambda (feature path)
         ;(append path (cdr feature))
         (if (null? path)
          (cdr feature)
          (append path
           (transform (cdr feature) 0 (last path))))
         )
         '()
         path-features-alist)

)

#(define-public (early:make-stencil grob path-pipeline)
  (make-connected-path-stencil
   (early:combine-features grob
    (early:pipeline->features grob path-pipeline))
   0.05 ; thickness
   1 1 ; xy scale
   #f  ; connect
   #t  ; fill
))


#(define-public (early:note-head::print grob)
  (let* ((style (ly:grob-property grob 'early-style))
         (settings (assoc-ref early:all-styles style))
         (dur-log (ly:grob-property grob 'duration-log))
         (notehead (cond ((> dur-log 0) 'rhombus)
                         ((< dur-log -2) 'maxima)
                         (else 'quadrata)))
         (hollow (ly:grob-property grob 'hollow))
         (warn-if-default (assoc-ref settings 'warn-if-default))
         ; TO DO: choose hollow variant (otherwise choose from default)?
         (notehead-settings (assoc-ref settings notehead))
         (path-pipeline (if notehead-settings (assoc-ref notehead-settings 'path-pipeline) #f))
        )

   (if warn-if-default
    ; TO DO: better warning message including style name and notehead symbol + variant).
    (ly:warning "Current style does not support the notehead."))

   ;; print default style if the chosen one is not defined.
   (cond
    (path-pipeline (early:make-stencil grob path-pipeline))
    ;(notehead-settings (ly:note-head::print grob))
    (else (ly:note-head::print grob)))
))

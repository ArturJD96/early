\version "2.24.3"

#(define (bezier-list->points bezier-list)
  (let ((x0 (list-ref bezier-list 0))
        (y0 (list-ref bezier-list 1))
        (x1 (list-ref bezier-list 2))
        (y1 (list-ref bezier-list 3))
        (x2 (list-ref bezier-list 4))
        (y2 (list-ref bezier-list 5)))
   (list (list x0 y0) (list x1 y1) (list x2 y2))
))

#(define (points->bezier-list points)
  (fold append '() points)
)

#(define (rotate-point point angle-deg)
  (if (= angle-deg 0) ;; optimized a bit
   point
   (let* ((x (list-ref point 0))
          (y (list-ref point 1))
          (angle-rad (degrees->radians angle-deg))
          (cos-angle (cos angle-rad))
          (sin-angle (sin angle-rad)))
     (list (+ (* x cos-angle) (* (- y) sin-angle))
           (+ (* x sin-angle) (* y cos-angle))))))

#(define (translate-point point t-point)
  (let ((x (list-ref point 0))
        (y (list-ref point 1))
        (tx (list-ref t-point 0))
        (ty (list-ref t-point 1)))
    (list (+ x tx) (+ y ty))))

#(define-public (transform points angle t-point)
  (map (lambda (point-or-bl)
        (if (= (length point-or-bl) 6)
         (points->bezier-list
          (transform
           (bezier-list->points point-or-bl)
           angle
           t-point))
         (translate-point (rotate-point point-or-bl angle) t-point)))
       points))

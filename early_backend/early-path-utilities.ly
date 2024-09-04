\version "2.24.3"

#(define (rotate-path path-commands angle) ; ChatGPT]
    "path-commands: list of lists like (('l x1 x2)('c x1 y1 x2 y2 x3 y3))"

    (define (rotate-point x y angle) ; ChatGPT
      (let* ((phi (degrees->radians angle))
             (cos-phi (cos phi))
             (sin-phi (sin phi)))
       (list (+ (* x cos-phi) (* (- y) sin-phi))
             (+ (* x sin-phi) (* y cos-phi)))))

    (define (rotate-points points angle) ; ChatGPT
      (map (lambda (point)
            (rotate-point (car point) (cadr point) angle))
       points))

    (define (rotate-line command angle)
      (let ((i (list-ref command 0))
            (x (list-ref command 1))
            (y (list-ref command 2)))
       (flatten-list (cons (list i) (rotate-points (list (list x y)) angle)))))

    (define (rotate-curve command angle)
      (let ((c (list-ref command 0))
            (x1 (list-ref command 1))
            (y1 (list-ref command 2))
            (x2 (list-ref command 3))
            (y2 (list-ref command 4))
            (x3 (list-ref command 5))
            (y3 (list-ref command 6)))
        (flatten-list
          (cons (list c)
                (rotate-points (list (list x1 y1)
                                     (list x2 y2)
                                     (list x3 y3))
                               angle)))))

    (map (lambda (command)
          (if (= (length command) 7)
           (rotate-curve command angle)
           (rotate-line command angle)))
      path-commands))

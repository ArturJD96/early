\version "2.24.4"
%% Copied from 2.25's lily-library.
%% This should be REMOVED in the next version
%% when the code becomes native.
#(define-syntax-public assert
  (lambda (sintax)
    (syntax-case sintax ()
      ((assert condition)
       #'(when (not condition)
           (error (format #f "assertion ~s failed"
                          'condition))))
      ((assert condition message)
       #'(when (not condition)
           (error (format #f "assertion ~s failed with message: ~a"
                          'condition message)))))))
%% Here ends this shameless copy-paste.
#(define (assert-equal actual expected)
  (let ((result (equal? actual expected)))
   (when (not result)
    (error
     (format #f "\n🥀 Assertion failed.\n* expected : ~a\n* actual   : ~a\n"
      expected actual)))))

%
% Code begins.
%

#(define (point x y)
  "Makes a 2d point."
  `(,x . ,y))
#(assert-equal (point 2/5 1.2) '(2/5 . 1.2))

#(define (points . coords)
  "Makes a list of coordinates used as arguments
   for make-path-stencil's commands (e.g. moveto).
   Note: 'coord' is a list of consecutive x and y values."
  ; ... additional type checks should go here.
  coords)
#(define (points:list points)
  "Returns points as list of lists (used e.g. in
   make-connected-path-stencil's pointlist)."
  (if (null? points) '()
   (cons (list (car points) (cadr points))
         (points:list (cddr points)))))
#(define (points:pairs points)
  "Returns points as list of lists (used e.g. in
  make-connected-path-stencil's pointlist)."
  (if (null? points) '()
   (cons (cons (car points) (cadr points))
         (points:pairs (cddr points)))))
#(assert-equal (points 1 2 3 4) '(1 2 3 4))
% #(assert-error (points 1 2 3))
#(assert-equal (points:list (points 1 2 3 4 5 6))
               '((1 2)(3 4)(5 6)))
#(assert-equal (points:pairs (points 1 2 3 4 5 6))
               '((1 . 2)(3 . 4)(5 . 6)))


%% Here I recreate postscript-like commands
%% used for the make-path-stencil path.
#(define (postscript-command cmd point-or-points . coords)
  (cond
   ((number? point-or-points)
    (append (list cmd point-or-points) (car coords)))
   ((list? point-or-points)
    (append (list cmd) point-or-points))
   ((pair? point-or-points)
    `(,cmd ,(car point-or-points) ,(cdr point-or-points)))
   (else (ly:error (format #f "Wrong argument: ~a" point-or-points))))
)

#(define-syntax define-postscript-commands
  (syntax-rules ()
    ((_ name ...)
     (begin
       (define (name point-or-points . coords)
         (postscript-command 'name point-or-points coords))
       ...))))

#(define-postscript-commands moveto rmoveto lineto rlineto curveto rcurveto closepath)
#(assert-equal (moveto (point 2 3)) '(moveto 2 3))
% #(assert-equal (moveto 1 2) `(moveto 1 2))
#(assert-equal (moveto 1 2 3 4) '(moveto 1 2 3 4))
% #(assert-error (moveto 1 2 3))
#(assert-equal (rmoveto (points 1 2 3 4)) '(rmoveto 1 2 3 4))
#(assert-equal (curveto (points 1 2 3 4 5 6 7 8)) '(curveto 1 2 3 4 5 6 7 8))
% #(assert-error (curveto (points 1 2 3 4))) ???

#(define (path . commands-or-pathargs)
  "Create a path from many make-path-stencil commands."
  (fold
   (lambda (cmd-or-parg prev)
    (if (list? cmd-or-parg)
     (append prev cmd-or-parg) ;; command, e.g. (moveto 1 2)
     (append prev (list cmd-or-parg)))  ;; patharg, e.g. moveto or '1'
   )
   '() commands-or-pathargs)
)
#(assert-equal (path 'moveto 1 2 (lineto 3 4) (curveto 5 6 7 8))
               '(moveto 1 2 lineto 3 4 curveto 5 6 7 8))


% #(make-path-stencil
%   (path 'moveto 1 2); path
%   1 ; thickness
%   1 1; x,y-scale
%   #t ; fill
%   ; #:line-cap-style line-cap-style
%   ; #:line-join-style line-join-style
% )











#(define (point-bezier x1 y1 x2 y2 x3 y3)
  (list ;; place of curve's starting point (x0 y0)
        ;; takes the point that preceeds this object.
        (point x1 y1)
        (point x2 y2)
        (point x3 y3))
)













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

% #(define-public (flip-x points)
%   (map (lambda (point-firsty point-lasty)
%         (newline)
%         (display point-firsty)
%         (display point-lasty)
%         (display (cadr point-firsty))

%         (list (- (car point-lasty))
%               (cadr point-firsty)))
%    points
%    (reverse points))
% )

% #(define-public (flip-y points)
%   (map (lambda (point-firsty point-lasty)
%         (list (car point-firsty)
%               (cadr point-lasty)))
%    points
%    (reverse points))
% )

#(define (get-1d-size 1d-coords)
  (- (apply max 1d-coords)
     (apply min 1d-coords)))

#(define-public (flip-x points)

  (let* (
   (n (+ (length points) 1))
   (xs (cons 0 (map car points)))
   (width (get-1d-size xs))
   (xs-flipped (map - xs (make-list n width)))
   (y-last (cadr (last points)))
   (ys (cons 0 (map cadr points)))
   (ys-pulled (map - ys (make-list n y-last)))
  )

  (cdr (reverse (map list xs-flipped ys-pulled)))

))

#(define-public (flip-y points)

  (let* (
   (n (+ (length points) 1))
   (ys (cons 0 (map cadr points)))
   (height (get-1d-size ys))
   (ys-flipped (map - ys (make-list n height)))
   (x-last (car (last points)))
   (xs (cons 0 (map car points)))
   (xs-pulled (map - xs (make-list n x-last)))
  )

  (cdr (reverse (map list xs-pulled ys-flipped)))

))

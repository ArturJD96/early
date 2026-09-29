\version "2.24.4"
\include "../testing.ily"

%{
%
%   Point and Curve.
%
%   Basic postscript coordinate units.
%
% %}

#(define (point x y)
  "Makes a 2d point."
  `(,x . ,y))

#(testing "point"
  (test-equal '(2/5 . 1.2) (point 2/5 1.2) )
)

#(define (curve x1 y1 x2 y2 x3 y3)
  "Returns a list of coordinates for
   a lilypond-supported bezier-curve.
   Note: the first point of the curve
   will be either (0 . 0) or the last point
   provided within the path."
  (list x1 y1 x2 y2 x3 y3))

#(testing "curve"
  (test-equal '(1 2 3 4 5 6) (curve 1 2 3 4 5 6) )
  ; (test-error (curve 1 2 3 4))
)

%{
%
%   Points – a list of postscript coordinates (points & curves).
%
% %}

#(define (points . coords)
  "Makes a list of coordinates used as arguments
   for make-path-stencil's commands (e.g. moveto).
   Note: 'coord' is a list of consecutive x and y values."
  ; ... additional type checks should go here.
  (when (odd? (length coords))
   (ly:error "Number of point coordinates must be even."))
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

#(testing "points:list"
  (test-equal '(1 2 3 4) (points 1 2 3 4))
  ; (test-error (points 1 2 3)) TO DO !!!!
  (test-equal '((1 2)(3 4)(5 6)) (points:list (points 1 2 3 4 5 6)) )
  (test-equal '((1 . 2)(3 . 4)(5 . 6)) (points:pairs (points 1 2 3 4 5 6)))
)


%% Here I recreate postscript-like commands
%% used for the make-path-stencil path.
#(define (postscript-command cmd . points/point/coords)

  (define (append-as-list x lst)
   (cond ((number? x) (append lst (list x)))
         ((list? x) (append lst x))
         ((pair? x) (append lst (list (car x) (cdr x))))))

  (fold
   (lambda (coords/point prev)
    (fold
     append-as-list
     prev coords/point))
   (list cmd) points/point/coords)
)

#(define-syntax define-postscript-commands
  (syntax-rules ()
    ((_ name ...)
     (begin
       (define (name . points/point/coords)
         (postscript-command 'name points/point/coords))
       ...))))

#(define-postscript-commands moveto rmoveto lineto rlineto curveto rcurveto closepath)

#(testing "postscript commands"
  (test-group "moveto"
   (test-equal '(moveto 1 2) (moveto (point 1 2)))
   (test-equal '(moveto 3 4) (moveto (points 3 4)))
   (test-equal `(moveto 5 6) (moveto 5 6))
   ; (test-error (moveto 1 2 3))
   ; (test-error (moveto 1 2 3 4))
   ; (test-error (moveto (points 1 2 3 4)))
   ; (test-error (moveto (curve 1 2 3 4 5 6))
  )
  (test-group "curveto"
   (test-equal '(curveto 1 2 3 4 5 6) (curveto (points 1 2 3 4 5 6)) )
   (test-equal '(curveto 1 2 3 4 5 6) (curveto (curve 1 2 3 4 5 6)) )
   (test-equal '(curveto 1 2 3 4 5 6) (curveto 1 2 3 4 5 6) )
   (test-equal '(curveto 1 2 3 4 5 6) (curveto 1 2 (point 3 4) (points 5 6)) )
   ; #(test-error (curveto 1 2 3 4)) ???
   ; #(test-equal (curveto 1 2 3 4 5 6 7 8)))
  )
)

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

#(testing "postscript path"
 (test-equal '(moveto 1 2 lineto 3 4 curveto 5 6 7 8)
             (path 'moveto 1 2
                   (lineto 3 4)
                   (curveto 5 6 7 8)))
)



% #(make-path-stencil
%   (path 'moveto 1 2); path
%   1 ; thickness
%   1 1; x,y-scale
%   #t ; fill
%   ; #:line-cap-style line-cap-style
%   ; #:line-join-style line-join-style
% )



%{
%
%   The code below is a legacy thing used in "styles" directory
%   (which by far becomes more and more legacy).
%
%   It is left here until quill backend is finished.
%   From then on, styles should be defined using quill backend:
%
%   \override NoteHead.stencil = #early:note-head::quill
%
% %}







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

\version "2.24.4"
\include "../early/src/testing.ily"
#(use-modules (ice-9 textual-ports)
              ;(sxml ssax)
              (sxml xpath)
              ;(sxml fold)
              (sxml match))


#(define (sxml->xml-obj node)
"Transforms an sxml tree to a json-like data structure,
where attributes and children are explicitly distinguished."
  (match node
    ;; Elements with attributes.
    ((tag ('@ attrs ...) children ...)
     `((tag . ,tag)
       (attributes . ,attrs)
       (children . ,(map sxml->xml-obj children))))
    ;; Element without attributes.
    ((tag children ...)
     `((tag . ,tag)
       (attributes . ())
       (children . ,(map sxml->xml-obj children))))
    ;; Leaf.
    (x x)))

#(testing "sxml->xml-obj"
  (test-equal "Transforms correctly."
   '((tag . parent)
     (attributes . ((attr1 a) (attr2 b)))
     (children . (((tag . child1)
                   (attributes . ((x 1)))
                   (children . ()))
                  ((tag . child2)
                   (attributes . ())
                   (children . (((tag . grandchild)
                                 (attributes . ((y 2)))
                                 (children . ()))))))))
   (sxml->xml-obj
    '(parent (@ (attr1 a) (attr2 b))
      (child1 (@ (x 1)))
      (child2 (grandchild (@ (y 2))))))
 )
)


#(define (prepare-compatibility-requirements rng)
"Outputs a list of all the definitions from rng."
  (map (lambda (def)
        (sxml-match def (
         (rng:define (@ (name ,name) (combine (,combine '()))) . ,definition)
         `((name . ,name)
           (combine . ,combine)
           (definition . ,(map sxml->xml-obj definition) ))
       )))
   ((sxpath '(// rng:define)) rng)
))


#(define-public (early:report-compatibility rng performer-handlers engravers)
"Reports (?) how much Early covers definitions from rng.
The coverage is checked by looking at an official Early registers
of rng performer handlers for rng tags (i.e. procedures preparing xml nodes from lilypond smobs)
and engravers."
  (let ((compatibility-requirements (prepare-compatibility-requirements rng)))
   (string-append
    "\n%% Compatibility Report %%\n"
    "This is a prototype of compatibility report of an RNG with Early.\n")))


% #(define-public (prepare-compatibility-requirements rng)








%{
%
%   IMPORTANT! Now it works only with MEI 5.1 rng file.
%
%   By now, unfortunately, the namespace naming of the functions
%   depend on symbols defined in the 'mei-compatibility.ly'.
%
% %}

%{
%
%   Read MEI mensural odd file as SXML.
%
% %}

% #(define (sub-@ sxml)
%   "We need to substitute '@' symbol for my custom rng parser
%    because Scheme interpreter thinks it is a special syntax for reading modules.
%    Example from docs: (define unixy:pipe-open (@ (ice-9 popen) open-pipe))."
%   (match sxml
%     (('@ . rest)
%      (cons '@:attrs (map sub-@ rest)))
%     ((a . d)
%      (cons (sub-@ a) (sub-@ d)))
%     (_ sxml)))


% #(define-syntax @:attrs
%   (syntax-rules ()
%     ((_ x ...) (list 'x ...))))

% #(define (attr attrs name)
%   (car (assoc-ref attrs name)))

% #(define (a:documentation . d) `(documentation . ,d))
% #(define (xhtml:a attrs . value)
%   `(a . ((href . ,(attr attrs 'href))
%          (text . value))))
% #(define (xhtml:code . values) `(code . ,values))

% #(define (sch:pattern . values) `(sch:pattern . ,values))
% #(define (sch:rule . values) `(sch:rule . ,values))
% #(define (sch:assert . values) `(assert . ,values))
% #(define (sch:let . values) `(let . ,values))
% #(define (sch:value-of . values) `(value-of . ,values))

% #(define (rng:choice . values) `(choice . ,values))
% #(define (rng:ref attrs) (cons 'reference (assoc-ref attrs 'name)))
% #(define (rng:except . values) `(except . ,values))
% #(define (rng:group . values) `(group . ,values))
% #(define (rng:list . values) `(list . ,values))
% #(define (rng:zeroOrMore . values) `(zeroOrMore . values))
% #(define (rng:oneOrMore . values) `(oneOrMore . values))
% #(define (rng:notAllowed . values) `(notAllowed . values))

% #(define (rng:optional . values) `(optional . values))
% #(define (rng:element attrs . values) `(element . values)) % TO DO: attrs!
% #(define (rng:attribute attrs . values) `(attribute . values)) % TO DO: attrs!

% #(define (rng:value . v) v)
% #(define (rng:text) 'text)
% #(define (rng:empty) 'empty)
% #(define (rng:anyName . values) `anyName)
% #(define (rng:nsName . values) `nsName)

% %% Note: data types come from the datatypeLibrary
% %% defined within the <div/> in rng.
% #(define (rng:data attrs . params)
%   (let ((type (attr attrs 'type)))
%    ; (apply
%    ;  (string->symbol
%    ;   (string-append "data:" type))
%    ;  params)))
%    `(,type . ,params)))


% #(define (rng:param attrs . value)
%   (let ((name (attr attrs 'name)))
%    `(,name . value)))


% #(define (parse-rng-definition def-list)
%   ; (display-scheme-music def-list)(newline)
%   ; (map primitive-eval (sub-@ def-list))
%   (map (lambda (def)
%         (let ((result (eval def (interaction-environment))))
%          result))
%    (sub-@ def-list))
% )

% #(define-public (parse-rng rng)
%   (let ((name-path (sxpath '(@ name *text*)))
%         (combine-path (sxpath '(@ combine *text*)))
%         (child-path (sxpath '(*))))
%    (map
%     (lambda (def)
%      (sxml-match def (
%       (rng:define (@ (name ,name) (combine (,combine '()))) . ,definition)
%       `((name . ,name)
%         (combine . ,combine)
%         (definition . ,(parse-rng-definition definition)))
%     )))
%     ((sxpath '(// rng:define)) rng))
% ))

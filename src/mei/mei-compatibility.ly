\version "2.24.4"
\include "compatibility-report.ly"
#(use-modules
  (ice-9 textual-ports)
  (sxml simple))

#(define mei-mensural-rng
  (xml->sxml
   (call-with-input-file "mei-Mensural.rng" get-string-all) ;"mei-Mensural.odd"
   #:namespaces  '((rng . "http://relaxng.org/ns/structure/1.0")
                   (tei . "http://www.tei-c.org/ns/1.0")
                   (teix . "http://www.tei-c.org/ns/Examples")
                   (xlink . "http://www.w3.org/1999/xlink")
                   (datatypeLibrary . "http://www.w3.org/2001/XMLSchema-datatypes")
                   (ns . "http://www.music-encoding.org/ns/mei")
                   (sch . "http://purl.oclc.org/dsdl/schematron")
                   (a . "http://relaxng.org/ns/compatibility/annotations/1.0")
                   (xhtml . "http://www.w3.org/1999/xhtml")
                  )
   #:trim-whitespace? #true
))

% Dummies:
#(define early:mei-mensural-compatible-performer-handlers '())
#(define early:mei-mensural-compatible-engravers '())

#(define-public early:mei-mensural-compatibility-report
  (early:report-compatibility
   mei-mensural-rng
   early:mei-mensural-compatible-performer-handlers
   early:mei-mensural-compatible-engravers))

#(display early:mei-mensural-compatibility-report)

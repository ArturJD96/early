\version "2.24.3"

\include "../early_backend/early-interface.ly"

#(when (not (early:has-style 'toulouse))
  (error "Style 'toulouse not found."))

#(when (early:has-style 'non-existent-style-dummy))
  (error "Dummy style does't exist!"))

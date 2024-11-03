\version "2.24.3"

\include "init.ily"

whitemensural = {
    \set notation = #'whitemensural
    \set coloration = #'fill
    \set colorationSecondary = ##f % for some obscure English manuscripts
}

blackmensural = {
    \set notation = #'blackmensural
    \set coloration = #'red
    \set colorationSecondary = #'blue % for some obscure English manuscripts
}

whitehollow = {
    \set notation = #'whitehollow
    \set coloration = #'fill
    \set colorationSecondary = ##f % for some obscure English manuscripts
}

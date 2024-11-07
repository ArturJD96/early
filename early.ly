\version "2.24.3"

\include "init.ily"

whitemensural = {
    \set notation = #'whitemensural
    \set early-style = ##f
    \set coloration = #'fill
    \set colorationSecondary = ##f % for some obscure English manuscripts
}

blackmensural = {
    \set notation = #'blackmensural
    \set early-style = ##f
    \set coloration = #'red
    \set colorationSecondary = #'blue % for some obscure English manuscripts
}

whitehollow = {
    \set notation = #'whitehollow
    \set early-style = ##f
    \set coloration = #'fill
    \set colorationSecondary = ##f % for some obscure English manuscripts
}

blackmensural-chantilly = {
    \set notation = #'blackmensural
    \set early-style = #'chantilly
    \set coloration = #'red
    \set colorationSecondary = ##f % for some obscure English manuscripts
}

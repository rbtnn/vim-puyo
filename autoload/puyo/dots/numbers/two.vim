
let s:colors = puyo#dots#colors()

function! puyo#dots#numbers#two#data()
  let w = s:colors.wall.text
  let b = s:colors.white.text
  return [
        \ [ w, w, w, b, b, b, b, w, w, w],
        \ [ w, w, w, w, w, w, b, w, w, w],
        \ [ w, w, w, w, w, w, b, w, w, w],
        \ [ w, w, w, b, b, b, b, w, w, w],
        \ [ w, w, w, b, w, w, w, w, w, w],
        \ [ w, w, w, b, w, w, w, w, w, w],
        \ [ w, w, w, b, b, b, b, w, w, w],
        \ ]
endfunction




let s:colors = puyo#dots#colors()

function! puyo#dots#numbers#zero#data()
  let w = s:colors.wall.value
  let b = s:colors.white.value
  return [
        \ [ w, w, w, w, b, b, w, w, w, w],
        \ [ w, w, w, b, w, w, b, w, w, w],
        \ [ w, w, w, b, w, w, b, w, w, w],
        \ [ w, w, w, b, w, w, b, w, w, w],
        \ [ w, w, w, b, w, w, b, w, w, w],
        \ [ w, w, w, b, w, w, b, w, w, w],
        \ [ w, w, w, w, b, b, w, w, w, w],
        \ ]
endfunction



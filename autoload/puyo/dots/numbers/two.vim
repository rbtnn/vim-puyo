
let s:colors = puyo#dots#colors()

function! puyo#dots#numbers#two#data()
  let w = s:colors.wall.value
  let b = s:colors.white.value
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




let s:colors = puyo#dots#colors()

function! puyo#dots#numbers#one#data()
  let w = s:colors.wall.value
  let b = s:colors.white.value
  return [
        \ [ w, w, w, w, w, b, w, w, w, w],
        \ [ w, w, w, w, b, b, w, w, w, w],
        \ [ w, w, w, w, w, b, w, w, w, w],
        \ [ w, w, w, w, w, b, w, w, w, w],
        \ [ w, w, w, w, w, b, w, w, w, w],
        \ [ w, w, w, w, w, b, w, w, w, w],
        \ [ w, w, w, w, b, b, b, w, w, w],
        \ ]
endfunction



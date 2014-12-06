
let s:colors = puyo#dots#colors()

function! puyo#dots#numbers#three#data()
  let w = s:colors.Wall.text
  let b = s:colors.White.text
  return [
        \ [ w, w, w, w, b, b, b, w, w, w],
        \ [ w, w, w, w, w, w, b, w, w, w],
        \ [ w, w, w, w, w, w, b, w, w, w],
        \ [ w, w, w, w, b, b, b, w, w, w],
        \ [ w, w, w, w, w, w, b, w, w, w],
        \ [ w, w, w, w, w, w, b, w, w, w],
        \ [ w, w, w, w, b, b, b, w, w, w],
        \ ]
endfunction



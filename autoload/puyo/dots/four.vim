

" Puyo colors
let s:colors = puyo#dots#colors()
let s:R = s:colors.red.value
let s:G = s:colors.green.value
let s:B = s:colors.blue.value
let s:Y = s:colors.yellow.value
let s:P = s:colors.purple.value
let s:F = s:colors.field.value
let s:W = s:colors.wall.value
let s:E = s:colors.eye.value
let s:H = s:colors.white.value

function! puyo#dots#four#data()
  let w = s:colors.white.value
  let b = s:colors.black.value
  return [
        \ [ w, w, w, w, w, w, b, w, w, w],
        \ [ w, w, w, w, w, b, b, w, w, w],
        \ [ w, w, w, w, b, w, b, w, w, w],
        \ [ w, w, w, w, b, w, b, w, w, w],
        \ [ w, w, w, b, b, b, b, b, w, w],
        \ [ w, w, w, w, w, w, b, w, w, w],
        \ [ w, w, w, w, w, w, b, w, w, w],
        \ ]
endfunction





" Puyo colors
let s:colors = puyo#dots#colors()
let s:R = s:colors.red.text
let s:G = s:colors.green.text
let s:B = s:colors.blue.text
let s:Y = s:colors.yellow.text
let s:P = s:colors.purple.text
let s:F = s:colors.field.text
let s:W = s:colors.wall.text
let s:E = s:colors.eye.text

function! puyo#dots#wall#data()
  let me = s:W
  return [
        \ [ me, me, me, me, me, me, me, me, me, me],
        \ [ me, me, me, me, me, me, me, me, me, me],
        \ [ me, me, me, me, me, me, me, me, me, me],
        \ [ me, me, me, me, me, me, me, me, me, me],
        \ [ me, me, me, me, me, me, me, me, me, me],
        \ [ me, me, me, me, me, me, me, me, me, me],
        \ [ me, me, me, me, me, me, me, me, me, me],
        \ ]
endfunction



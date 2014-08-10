
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
let s:H = s:colors.white.text

function! puyo#dots#puyos#yellow#data()
  let me = s:Y
  return [
        \ [s:F,s:F,s:F, me, me, me, me,s:F,s:F,s:F],
        \ [s:F,s:F, me, me, me, me, me, me,s:F,s:F],
        \ [s:F, me,s:H,s:H,s:H,s:H,s:H,s:H, me,s:F],
        \ [ me, me,s:H,s:E,s:H,s:H,s:E,s:H, me, me],
        \ [ me, me, me,s:H, me, me,s:H, me, me, me],
        \ [s:F, me, me, me, me, me, me, me, me,s:F],
        \ [s:F,s:F, me, me, me, me, me, me,s:F,s:F],
        \ ]
endfunction



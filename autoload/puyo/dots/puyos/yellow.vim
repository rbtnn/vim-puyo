
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



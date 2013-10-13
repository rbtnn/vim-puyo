

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

function! puyo#dots#red#data()
  let me = s:R
  return [
        \ [s:F,s:F, me, me, me, me, me, me,s:F,s:F],
        \ [s:F,s:F, me, me, me, me, me, me,s:F,s:F],
        \ [s:F, me,s:F,s:F, me, me,s:F,s:F, me,s:F],
        \ [ me,s:F,s:E,s:E,s:F,s:F,s:E,s:E,s:F, me],
        \ [ me, me,s:F,s:F, me, me,s:F,s:F, me, me],
        \ [s:F, me, me, me, me, me, me, me, me,s:F],
        \ [s:F,s:F, me, me, me, me, me, me,s:F,s:F],
        \ ]
endfunction


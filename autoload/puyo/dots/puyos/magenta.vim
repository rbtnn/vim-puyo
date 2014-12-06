
" Puyo colors
let s:colors = puyo#dots#colors()
let s:R = s:colors.Red.text
let s:G = s:colors.Green.text
let s:B = s:colors.Blue.text
let s:Y = s:colors.Yellow.text
let s:P = s:colors.Magenta.text
let s:F = s:colors.Field.text
let s:W = s:colors.Wall.text
let s:E = s:colors.Eye.text
let s:H = s:colors.White.text

function! puyo#dots#puyos#magenta#data()
  let me = s:P
  return [
        \ [s:F,s:F, me, me, me, me, me, me,s:F,s:F],
        \ [s:F,s:F, me, me, me, me, me, me,s:F,s:F],
        \ [s:F, me,s:H,s:H, me, me,s:H,s:H, me,s:F],
        \ [ me,s:H,s:E,s:E,s:H,s:H,s:E,s:E,s:H, me],
        \ [ me, me,s:H,s:H, me, me,s:H,s:H, me, me],
        \ [s:F, me, me, me, me, me, me, me, me,s:F],
        \ [s:F,s:F, me, me, me, me, me, me,s:F,s:F],
        \ ]
endfunction



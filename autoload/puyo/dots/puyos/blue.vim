
" Puyo colors
let s:colors = puyo#dots#colors()
let s:B = s:colors.Blue.text
let s:E = s:colors.Eye.text
let s:F = s:colors.Field.text
let s:G = s:colors.Green.text
let s:H = s:colors.White.text
let s:P = s:colors.Magenta.text
let s:R = s:colors.Red.text
let s:W = s:colors.Wall.text
let s:Y = s:colors.Yellow.text

function! puyo#dots#puyos#blue#data()
  let me = s:B
  return [
        \ [s:F,s:F,s:F, me, me, me, me,s:F,s:F,s:F],
        \ [s:F,s:F, me, me, me, me, me, me, me,s:F],
        \ [s:F, me, me, me,s:H,s:H, me, me, me, me],
        \ [ me, me,s:H,s:E,s:H,s:H,s:E,s:H, me, me],
        \ [ me, me, me,s:H, me, me,s:H, me, me, me],
        \ [s:F, me, me, me, me, me, me, me,s:F,s:F],
        \ [s:F,s:F, me, me, me, me, me, me, me,s:F],
        \ ]
endfunction



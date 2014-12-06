

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

function! puyo#dots#field#data()
  let me = s:F
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



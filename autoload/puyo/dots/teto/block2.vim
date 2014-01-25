

" Teto colors
let s:colors = puyo#dots#colors()
let s:B = s:colors.red.value
let s:F = s:colors.field.value

function! puyo#dots#teto#block2#data()
  let me = s:B
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



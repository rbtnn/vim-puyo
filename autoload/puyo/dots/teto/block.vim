

" Teto colors
let s:colors = puyo#dots#colors()
let s:B = s:colors.black.value
let s:F = s:colors.field.value

function! puyo#dots#teto#block#data()
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



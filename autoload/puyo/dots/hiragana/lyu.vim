
let s:colors = puyo#dots#colors()
let s:F = s:colors.Wall.text

function! puyo#dots#hiragana#lyu#data()
  let me = s:colors.White.text
  return [
        \ [s:F,s:F,s:F,s:F,s:F,s:F,s:F,s:F,s:F,s:F],
        \ [s:F,s:F,s:F,s:F,s:F, me,s:F,s:F,s:F,s:F],
        \ [s:F,s:F, me,s:F, me, me, me, me,s:F,s:F],
        \ [s:F,s:F, me, me,s:F, me,s:F, me,s:F,s:F],
        \ [s:F,s:F, me,s:F, me, me,s:F, me,s:F,s:F],
        \ [s:F,s:F, me,s:F,s:F, me, me,s:F,s:F,s:F],
        \ [s:F,s:F,s:F,s:F, me,s:F,s:F,s:F,s:F,s:F],
        \ ]
endfunction



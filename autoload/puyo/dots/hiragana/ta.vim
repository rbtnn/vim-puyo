
let s:colors = puyo#dots#colors()
let s:F = s:colors.field.value

function! puyo#dots#hiragana#ta#data()
  let me = s:colors.black.value
  return [
        \ [s:F,s:F,s:F, me,s:F,s:F,s:F,s:F,s:F,s:F],
        \ [s:F, me, me, me, me,s:F,s:F,s:F,s:F,s:F],
        \ [s:F,s:F,s:F, me,s:F,s:F, me, me, me,s:F],
        \ [s:F,s:F, me, me,s:F,s:F,s:F,s:F,s:F,s:F],
        \ [s:F,s:F, me,s:F,s:F,s:F,s:F,s:F,s:F,s:F],
        \ [s:F, me, me,s:F,s:F, me, me,s:F,s:F,s:F],
        \ [s:F, me,s:F,s:F,s:F,s:F, me, me, me,s:F],
        \ ]
endfunction



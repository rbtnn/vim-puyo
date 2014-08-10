
let s:colors = puyo#dots#colors()
let s:F = s:colors.wall.text

function! puyo#dots#hiragana#re#data()
  let me = s:colors.white.text
  return [
        \ [s:F,s:F,s:F, me,s:F,s:F,s:F,s:F,s:F,s:F],
        \ [s:F, me, me, me, me,s:F,s:F,s:F, me,s:F],
        \ [s:F,s:F,s:F, me,s:F, me, me, me, me,s:F],
        \ [s:F,s:F, me, me, me,s:F,s:F, me,s:F,s:F],
        \ [s:F, me, me, me,s:F,s:F, me, me,s:F,s:F],
        \ [s:F,s:F,s:F, me,s:F,s:F,s:F, me,s:F, me],
        \ [s:F,s:F,s:F, me,s:F,s:F,s:F, me, me,s:F],
        \ ]
endfunction



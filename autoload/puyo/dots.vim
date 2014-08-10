
function! puyo#dots#width()
  return 10
endfunction
function! puyo#dots#height()
  return 7
endfunction

function! puyo#dots#all()
  if !exists('s:dots')
    let s:dots = {
          \   'puyo#dots#puyos#red#data' : puyo#dots#puyos#red#data(),
          \   'puyo#dots#puyos#blue#data' : puyo#dots#puyos#blue#data(),
          \   'puyo#dots#puyos#yellow#data' : puyo#dots#puyos#yellow#data(),
          \   'puyo#dots#puyos#green#data' : puyo#dots#puyos#green#data(),
          \   'puyo#dots#puyos#purple#data' : puyo#dots#puyos#purple#data(),
          \   'puyo#dots#numbers#zero#data' : puyo#dots#numbers#zero#data(),
          \   'puyo#dots#numbers#one#data' : puyo#dots#numbers#one#data(),
          \   'puyo#dots#numbers#two#data' : puyo#dots#numbers#two#data(),
          \   'puyo#dots#numbers#three#data' : puyo#dots#numbers#three#data(),
          \   'puyo#dots#numbers#four#data' : puyo#dots#numbers#four#data(),
          \   'puyo#dots#numbers#five#data' : puyo#dots#numbers#five#data(),
          \   'puyo#dots#numbers#six#data' : puyo#dots#numbers#six#data(),
          \   'puyo#dots#numbers#seven#data' : puyo#dots#numbers#seven#data(),
          \   'puyo#dots#numbers#eight#data' : puyo#dots#numbers#eight#data(),
          \   'puyo#dots#numbers#nine#data' : puyo#dots#numbers#nine#data(),
          \   'puyo#dots#hiragana#__#data' : puyo#dots#hiragana#__#data(),
          \   'puyo#dots#hiragana#ba#data' : puyo#dots#hiragana#ba#data(),
          \   'puyo#dots#hiragana#ki#data' : puyo#dots#hiragana#ki#data(),
          \   'puyo#dots#hiragana#lyu#data' : puyo#dots#hiragana#lyu#data(),
          \   'puyo#dots#hiragana#nn#data' : puyo#dots#hiragana#nn#data(),
          \   'puyo#dots#hiragana#re#data' : puyo#dots#hiragana#re#data(),
          \   'puyo#dots#hiragana#sa#data' : puyo#dots#hiragana#sa#data(),
          \   'puyo#dots#hiragana#ta#data' : puyo#dots#hiragana#ta#data(),
          \   'puyo#dots#field#data' : puyo#dots#field#data(),
          \   'puyo#dots#wall#data' : puyo#dots#wall#data(),
          \ }
  endif
  return s:dots
endfunction

function! puyo#dots#puyo_colors()
  return [
        \ 'puyo#dots#puyos#red#data',
        \ 'puyo#dots#puyos#blue#data',
        \ 'puyo#dots#puyos#yellow#data',
        \ 'puyo#dots#puyos#green#data',
        \ 'puyo#dots#puyos#purple#data',
        \ ]
endfunction
function! puyo#dots#gameover_chars()
  return [
        \ 'puyo#dots#hiragana#ba#data',
        \ 'puyo#dots#hiragana#ta#data',
        \ 'puyo#dots#hiragana#nn#data',
        \ 'puyo#dots#hiragana#ki#data',
        \ 'puyo#dots#hiragana#lyu#data',
        \ 'puyo#dots#hiragana#__#data',
        \ ]
endfunction
function! puyo#dots#chain_chars()
  return [
        \ 'puyo#dots#hiragana#re#data',
        \ 'puyo#dots#hiragana#nn#data',
        \ 'puyo#dots#hiragana#sa#data',
        \ ]
endfunction
function! puyo#dots#numbers()
  return [
        \ 'puyo#dots#numbers#zero#data',
        \ 'puyo#dots#numbers#one#data',
        \ 'puyo#dots#numbers#two#data',
        \ 'puyo#dots#numbers#three#data',
        \ 'puyo#dots#numbers#four#data',
        \ 'puyo#dots#numbers#five#data',
        \ 'puyo#dots#numbers#six#data',
        \ 'puyo#dots#numbers#seven#data',
        \ 'puyo#dots#numbers#eight#data',
        \ 'puyo#dots#numbers#nine#data',
        \ ]
endfunction

function! puyo#dots#colors()
  if !exists('s:colors')
    let s:colors = game_engine#syntax()
    let s:colors['eye'] = s:colors['black']
    let s:colors['field'] =  s:colors['gray']
    let s:colors['wall'] = s:colors['black']
  endif
  return s:colors
endfunction

function! puyo#dots#image2color_for_cui(img)
  let colors = puyo#dots#colors()
  if 'puyo#dots#puyos#red#data' is a:img
    return colors.red.text
  elseif 'puyo#dots#puyos#green#data' is a:img
    return colors.green.text
  elseif 'puyo#dots#puyos#yellow#data' is a:img
    return colors.yellow.text
  elseif 'puyo#dots#puyos#blue#data' is a:img
    return colors.blue.text
  elseif 'puyo#dots#puyos#purple#data' is a:img
    return colors.purple.text
  elseif 'puyo#dots#field#data' is a:img
    return colors.field.text
  elseif 'puyo#dots#wall#data' is a:img
    return colors.wall.text
  else
    return colors.wall.text
  endif
endfunction


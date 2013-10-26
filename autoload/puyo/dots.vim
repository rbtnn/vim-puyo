
" let s:dir = expand('%:p:r')

let s:colors = {
      \   'red'    : { 'value' : '@R' },
      \   'green'  : { 'value' : '@G' },
      \   'blue'   : { 'value' : '@B' },
      \   'yellow' : { 'value' : '@Y' },
      \   'purple' : { 'value' : '@P' },
      \   'field'  : { 'value' : '@F' },
      \   'wall'   : { 'value' : '@W' },
      \   'eye'    : { 'value' : '@e' },
      \   'white'  : { 'value' : '@w' },
      \   'black'  : { 'value' : '@b' },
      \  }

let s:images = {
      \   'puyos' : {
      \     'red'    : function('puyo#dots#puyos#red#data'),
      \     'blue'   : function('puyo#dots#puyos#blue#data'),
      \     'yellow' : function('puyo#dots#puyos#yellow#data'),
      \     'green'  : function('puyo#dots#puyos#green#data'),
      \     'purple' : function('puyo#dots#puyos#purple#data'),
      \   },
      \   'numbers' : {
      \     'zero'  : function('puyo#dots#numbers#zero#data'),
      \     'one'   : function('puyo#dots#numbers#one#data'),
      \     'two'   : function('puyo#dots#numbers#two#data'),
      \     'three' : function('puyo#dots#numbers#three#data'),
      \     'four'  : function('puyo#dots#numbers#four#data'),
      \     'five'  : function('puyo#dots#numbers#five#data'),
      \     'six'   : function('puyo#dots#numbers#six#data'),
      \     'seven' : function('puyo#dots#numbers#seven#data'),
      \     'eight' : function('puyo#dots#numbers#eight#data'),
      \     'nine'  : function('puyo#dots#numbers#nine#data'),
      \   },
      \   'wallpapers' : {
      \     'defaut' : function('puyo#dots#wallpapers#default#data'),
      \   },
      \   'hiragana' : {
      \     '__'  : function('puyo#dots#hiragana#__#data'),
      \     'ba'  : function('puyo#dots#hiragana#ba#data'),
      \     'ki'  : function('puyo#dots#hiragana#ki#data'),
      \     'lyu' : function('puyo#dots#hiragana#lyu#data'),
      \     'nn'  : function('puyo#dots#hiragana#nn#data'),
      \     're'  : function('puyo#dots#hiragana#re#data'),
      \     'sa'  : function('puyo#dots#hiragana#sa#data'),
      \     'ta'  : function('puyo#dots#hiragana#ta#data'),
      \   },
      \   'field' : function('puyo#dots#field#data'),
      \   'wall'  : function('puyo#dots#wall#data'),
      \ }

function! puyo#dots#width() " {{{
  return 10
endfunction " }}}
function! puyo#dots#height() " {{{
  return 7
endfunction " }}}
function! puyo#dots#images() " {{{
  return s:images
endfunction " }}}
function! puyo#dots#colors() " {{{
  return s:colors
endfunction " }}}

function! puyo#dots#image2color_for_cui(img_fref) " {{{
  if s:images.puyos.red == a:img_fref
    return s:colors.red.value
  elseif s:images.puyos.green == a:img_fref
    return s:colors.green.value
  elseif s:images.puyos.yellow == a:img_fref
    return s:colors.yellow.value
  elseif s:images.puyos.blue == a:img_fref
    return s:colors.blue.value
  elseif s:images.puyos.purple == a:img_fref
    return s:colors.purple.value
  elseif s:images.field == a:img_fref
    return s:colors.field.value
  elseif s:images.wall == a:img_fref
    return s:colors.wall.value
  else
    return s:colors.wall.value
  endif
endfunction " }}}

function! puyo#dots#substitute_for_syntax(row) " {{{
  return join(a:row,"")
endfunction " }}}

"  vim: set ts=2 sts=2 sw=2 ft=vim fdm=marker ff=unix :

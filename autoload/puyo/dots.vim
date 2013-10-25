
" let s:dir = expand('%:p:r')

function! puyo#dots#width() " {{{
  return 10
endfunction " }}}
function! puyo#dots#height() " {{{
  return 7
endfunction " }}}

function! puyo#dots#images() " {{{
  return {
      \   'puyos' : {
      \     'red'    : function('puyo#dots#red#data'),
      \     'blue'   : function('puyo#dots#blue#data'),
      \     'yellow' : function('puyo#dots#yellow#data'),
      \     'green'  : function('puyo#dots#green#data'),
      \     'purple' : function('puyo#dots#purple#data'),
      \   },
      \   'numbers' : {
      \     'zero'  : function('puyo#dots#zero#data'),
      \     'one'   : function('puyo#dots#one#data'),
      \     'two'   : function('puyo#dots#two#data'),
      \     'three' : function('puyo#dots#three#data'),
      \     'four'  : function('puyo#dots#four#data'),
      \     'five'  : function('puyo#dots#five#data'),
      \     'six'   : function('puyo#dots#six#data'),
      \     'seven' : function('puyo#dots#seven#data'),
      \     'eight' : function('puyo#dots#eight#data'),
      \     'nine'  : function('puyo#dots#nine#data'),
      \   },
      \   'wallpapers' : {
      \     'defaut' : function('puyo#dots#wallpaper#data'),
      \   },
      \   'hiragana' : {
      \     'ba' : function('puyo#dots#field#data'),
      \     'ta' : function('puyo#dots#field#data'),
      \     'nn' : function('puyo#dots#field#data'),
      \     'ki' : function('puyo#dots#field#data'),
      \     'lyu' : function('puyo#dots#field#data'),
      \     '__' : function('puyo#dots#field#data'),
      \   },
      \   'field' : function('puyo#dots#field#data'),
      \   'wall'  : function('puyo#dots#wall#data'),
      \ }
endfunction " }}}
function! puyo#dots#colors() " {{{
  return {
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
endfunction " }}}

function! puyo#dots#substitute_for_syntax(row) " {{{
  return join(a:row,"")
endfunction " }}}

"  vim: set ts=2 sts=2 sw=2 ft=vim fdm=marker ff=unix :

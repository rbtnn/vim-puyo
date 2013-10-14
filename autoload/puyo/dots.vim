
" let s:dir = expand('%:p:r')

let s:colors = {
      \   'red'    : { 'value' : '@R', 'data' : function('puyo#dots#red#data') },
      \   'blue'   : { 'value' : '@B', 'data' : function('puyo#dots#blue#data') },
      \   'yellow' : { 'value' : '@Y', 'data' : function('puyo#dots#yellow#data') },
      \   'green'  : { 'value' : '@G', 'data' : function('puyo#dots#green#data') },
      \   'purple' : { 'value' : '@P', 'data' : function('puyo#dots#purple#data') },
      \   'field'  : { 'value' : '@F', 'data' : function('puyo#dots#field#data') },
      \   'wall'   : { 'value' : '@W', 'data' : function('puyo#dots#wall#data') },
      \   'zero'   : { 'value' : '@0', 'data' : function('puyo#dots#zero#data') },
      \   'one'    : { 'value' : '@1', 'data' : function('puyo#dots#one#data') },
      \   'two'    : { 'value' : '@2', 'data' : function('puyo#dots#two#data') },
      \   'three'  : { 'value' : '@3', 'data' : function('puyo#dots#three#data') },
      \   'four'   : { 'value' : '@4', 'data' : function('puyo#dots#four#data') },
      \   'five'   : { 'value' : '@5', 'data' : function('puyo#dots#five#data') },
      \   'six'    : { 'value' : '@6', 'data' : function('puyo#dots#six#data') },
      \   'seven'  : { 'value' : '@7', 'data' : function('puyo#dots#seven#data') },
      \   'eight'  : { 'value' : '@8', 'data' : function('puyo#dots#eight#data') },
      \   'nine'   : { 'value' : '@9', 'data' : function('puyo#dots#nine#data') },
      \   'eye'    : { 'value' : '@e' },
      \   'white'  : { 'value' : '@w' },
      \   'black'  : { 'value' : '@b' },
      \ }

function! puyo#dots#width() " {{{
  return 10
endfunction " }}}
function! puyo#dots#height() " {{{
  return 7
endfunction " }}}

function! puyo#dots#colors() " {{{
  return deepcopy(s:colors)
endfunction " }}}
function! puyo#dots#data(value) " {{{
  for key in keys(s:colors)
    if s:colors[key].value == a:value
      return s:colors[key].data()
    endif
  endfor
  return s:colors['wall'].data()
endfunction " }}}
function! puyo#dots#substitute_for_syntax(row) " {{{
  return join(a:row,"")
endfunction " }}}

"  vim: set ts=2 sts=2 sw=2 ft=vim fdm=marker ff=unix :

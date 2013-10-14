
" let s:dir = expand('%:p:r')

let s:colors = {
      \   'red'    : { 'value' : '@R', 'data' : function('puyo#dots#red#data') },
      \   'blue'   : { 'value' : '@B', 'data' : function('puyo#dots#blue#data') },
      \   'yellow' : { 'value' : '@Y', 'data' : function('puyo#dots#yellow#data') },
      \   'green'  : { 'value' : '@G', 'data' : function('puyo#dots#green#data') },
      \   'purple' : { 'value' : '@P', 'data' : function('puyo#dots#purple#data') },
      \   'field'  : { 'value' : '@F', 'data' : function('puyo#dots#field#data') },
      \   'wall'   : { 'value' : '@W', 'data' : function('puyo#dots#wall#data') },
      \   'one'    : { 'value' : '@1', 'data' : function('puyo#dots#one#data') },
      \   'eye'    : { 'value' : '@2' },
      \   'white'  : { 'value' : '@3' },
      \   'black'  : { 'value' : '@4' },
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

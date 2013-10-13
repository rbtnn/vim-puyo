
" let s:dir = expand('%:p:r')

let s:colors = {
      \   'red'    : { 'value' : 0, 'data' : function('puyo#dots#red#data') },
      \   'blue'   : { 'value' : 1, 'data' : function('puyo#dots#blue#data') },
      \   'yellow' : { 'value' : 2, 'data' : function('puyo#dots#yellow#data') },
      \   'green'  : { 'value' : 3, 'data' : function('puyo#dots#green#data') },
      \   'purple' : { 'value' : 4, 'data' : function('puyo#dots#purple#data') },
      \   'field'  : { 'value' : 5, 'data' : function('puyo#dots#field#data') },
      \   'wall'   : { 'value' : 6, 'data' : function('puyo#dots#wall#data') },
      \   'eye'    : { 'value' : 7, 'data' : function('puyo#dots#wall#data') },
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
  let str = join(a:row,"")
  let str = substitute(str,s:colors.red.value,"@R","g")
  let str = substitute(str,s:colors.green.value,"@G","g")
  let str = substitute(str,s:colors.blue.value,"@B","g")
  let str = substitute(str,s:colors.yellow.value,"@Y","g")
  let str = substitute(str,s:colors.purple.value,"@P","g")
  let str = substitute(str,s:colors.field.value,"@F","g")
  let str = substitute(str,s:colors.wall.value,"@W","g")
  let str = substitute(str,s:colors.eye.value,"@E","g")
  return str
endfunction " }}}

"  vim: set ts=2 sts=2 sw=2 ft=vim fdm=marker ff=unix :

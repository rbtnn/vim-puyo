
function! puyo#buffer#nrlist() " {{{
  return  filter(range(1, bufnr("$")),"bufexists(v:val) && buflisted(v:val)")
endfunction " }}}
function! puyo#buffer#escape(bname) " {{{
  return '^' . join(map(split(a:bname, '\zs'), '"[".v:val."]"'), '') . '$'
endfunction " }}}
function! puyo#buffer#nr(bname) " {{{
  return bufnr(puyo#buffer#escape(a:bname))
endfunction " }}}
function! puyo#buffer#winnr(bname) " {{{
  return bufwinnr(puyo#buffer#escape(a:bname))
endfunction " }}}
function! puyo#buffer#uniq_open(bname,lines,mode) " {{{
  let curr_bufname = bufname('%')

  if ! bufexists(a:bname)
    execute printf('split %s',a:bname)
    setlocal bufhidden=hide buftype=nofile noswapfile nobuflisted
  elseif puyo#buffer#winnr(a:bname) != -1
    execute puyo#buffer#winnr(a:bname) 'wincmd w'
  else
    execute 'split'
    execute 'buffer' puyo#buffer#nr(a:bname)
  endif

  if a:mode ==# 'w'
    let i = 1
    for line in a:lines
      if getline(i) !=# line
        call setline(i,line)
      endif
      let i += 1
    endfor
  elseif a:mode ==# 'a'
    call append('$',a:lines)
  endif

  execute bufwinnr(curr_bufname) 'wincmd w'
endfunction " }}}

"  vim: set ts=2 sts=2 sw=2 ft=vim fdm=marker ff=unix :

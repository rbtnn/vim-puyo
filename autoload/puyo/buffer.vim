
function! puyo#buffer#nrlist()
  return  filter(range(1, bufnr("$")),"bufexists(v:val) && buflisted(v:val)")
endfunction
function! puyo#buffer#escape(bname)
  return '^' . join(map(split(a:bname, '\zs'), '"[".v:val."]"'), '') . '$'
endfunction
function! puyo#buffer#nr(bname)
  return bufnr(puyo#buffer#escape(a:bname))
endfunction
function! puyo#buffer#winnr(bname)
  return bufwinnr(puyo#buffer#escape(a:bname))
endfunction
function! puyo#buffer#uniq_open(bname,lines,mode)
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

  if a:mode is# 'w'
    let i = 1
    for line in a:lines
      if getline(i) isnot# line
        call setline(i,line)
      endif
      let i += 1
    endfor
  elseif a:mode is# 'a'
    call append('$',a:lines)
  endif

  execute bufwinnr(curr_bufname) 'wincmd w'
endfunction


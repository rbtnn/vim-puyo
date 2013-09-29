
scriptencoding utf-8

let s:V = vital#of('puyo.vim')
let s:Random = s:V.import('Random.Xor128')
call s:Random.srand()

" Puyo colors
let s:R = 0
let s:G = 1
let s:B = 2
let s:Y = 3

" field(not exist puyo)
let s:F = 4
" wall
let s:W = 5

let s:FIELD_COL = 6
let s:FIELD_ROW = 13

let s:chain_voices = [
\ 'えいっ',
\ 'ファイヤー',
\ 'アイスストーム',
\ 'ダイアキュート',
\ 'ブレインダムド',
\ 'ジュゲム',
\ 'ばよえ～ん',
\ ]

function! s:buffer_nrlist()
  return  filter(range(1, bufnr("$")),"bufexists(v:val) && buflisted(v:val)")
endfunction
function! s:buffer_escape(bname)
  return '^' . join(map(split(a:bname, '\zs'), '"[".v:val."]"'), '') . '$'
endfunction
function! s:buffer_nr(bname)
  return bufnr(s:buffer_escape(a:bname))
endfunction
function! s:buffer_winnr(bname)
  return bufwinnr(s:buffer_escape(a:bname))
endfunction
function! s:buffer_uniq_open(bname,lines,mode) " {{{
  let curr_bufname = bufname('%')

  if ! bufexists(a:bname)
    execute printf('split %s',a:bname)
    setlocal bufhidden=hide buftype=nofile noswapfile nobuflisted
  elseif s:buffer_winnr(a:bname) != -1
    execute s:buffer_winnr(a:bname) 'wincmd w'
  else
    execute 'split'
    execute 'buffer' s:buffer_nr(a:bname)
  endif

  if a:mode ==# 'w'
    silent % delete _
    call append(0,a:lines)
  elseif a:mode ==# 'a'
    call append('$',a:lines)
  endif

  execute bufwinnr(curr_bufname) 'wincmd w'
endfunction " }}}

function! s:make_field_array(contained_dropping) " {{{
  let f = [repeat([s:W],s:FIELD_COL+2)]
  for h in range(1,s:FIELD_ROW)
    let f += [[s:W]+repeat([s:F],s:FIELD_COL)+[s:W]]
  endfor
  let f += [repeat([s:W],s:FIELD_COL+2)]

  for puyo in (a:contained_dropping ? b:session.dropping : []) + b:session.puyos
    let f[puyo.row][puyo.col] = puyo.kind
  endfor
  return f
endfunction " }}}
function! s:movable(puyos,row,col) " {{{
  let f = s:make_field_array(0)
  for puyo in a:puyos
    if s:FIELD_ROW < puyo.row + a:row || puyo.row + a:row <= 0
      return 0
    endif
    if s:FIELD_COL < puyo.col + a:col || puyo.col + a:col <= 0
      return 0
    endif
    if f[puyo.row + a:row][puyo.col + a:col] != s:F
      return 0
    endif
  endfor
  return 1
endfunction " }}}

function! s:next_puyo() " {{{
  " s:R ~ s:Y
  let p1 = s:Random.rand() % 4
  let p1 = p1 < 0 ? -p1 : p1
  let p2 = s:Random.rand() % 4
  let p2 = p2 < 0 ? -p2 : p2
  return [
  \   { 'row' : 0, 'col' : 3, 'kind' : p1 },
  \   { 'row' : 0, 'col' : 4, 'kind' : p2 },
  \ ]
endfunction " }}}
function! s:redraw(do_init) " {{{
  if a:do_init
    call s:buffer_uniq_open("[puyo]",[],"w")
    execute printf("%dwincmd w",s:buffer_winnr("[puyo]"))
    setlocal filetype=puyo

    let b:session = {
          \   'puyos' : [
          \   ],
          \   'text' : '',
          \   'dropping' : s:next_puyo(),
          \   'next1' : s:next_puyo(),
          \   'next2' : s:next_puyo(),
          \ }

    nnoremap <buffer> j :call <sid>key_down() \| call <sid>check()<cr>
    " nnoremap <buffer> k :call <sid>key_up()<cr>
    nnoremap <buffer> h :call <sid>key_left()<cr>
    nnoremap <buffer> l :call <sid>key_right()<cr>
    nnoremap <buffer> z :call <sid>key_turn(0)<cr>
    nnoremap <buffer> x :call <sid>key_turn(1)<cr>

    augroup Puyo
      autocmd!
      autocmd CursorHold,CursorHoldI * call s:auto()
    augroup END
  endif

  let rtn = []
  let field = s:make_field_array(1)
  let field[1] += [s:W,s:W                    ,s:W,s:W                    ,s:W]
  let field[2] += [s:W,b:session.next1[0].kind,s:W,s:W                    ,s:W]
  let field[3] += [s:W,b:session.next1[1].kind,s:W,b:session.next2[0].kind,s:W]
  let field[4] += [s:W,s:W                    ,s:W,b:session.next2[1].kind,s:W]
  let field[5] += [s:W,s:W                    ,s:W,s:W                    ,s:W]
  for row in field
    let str = join(row,"")
    let str = substitute(str,s:R,"@R","g")
    let str = substitute(str,s:G,"@G","g")
    let str = substitute(str,s:B,"@B","g")
    let str = substitute(str,s:Y,"@Y","g")
    let str = substitute(str,s:F,"@F","g")
    let str = substitute(str,s:W,"@W","g")
    let rtn += [str]
  endfor
  let rtn += [b:session.text]

  call s:buffer_uniq_open("[puyo]",rtn,"w")
  execute printf("%dwincmd w",s:buffer_winnr("[puyo]"))
  redraw!
endfunction " }}}
function! s:drop() " {{{
  let f = []
  for r in range(1,s:FIELD_ROW+2)
    let f += [repeat([s:F],s:FIELD_COL+2)]
  endfor
  for puyo in b:session.puyos
    let f[puyo.row][puyo.col] = puyo.kind
  endfor
  for c in range(s:FIELD_COL,1,-1)
    while 1
      let b = 0
      for r in range(1,s:FIELD_ROW-1)
        if f[r+1][c] == s:F && f[r][c] != s:F
          let f[r+1][c] = f[r][c]
          let f[r][c] = s:F
          let b = 1
        endif
      endfor
      if ! b
        break
      endif
    endwhile
  endfor
  let new_puyos = []
  for c in range(1,s:FIELD_COL)
    for r in range(1,s:FIELD_ROW)
      if f[r][c] != s:F
        let new_puyos += [ { 'row' : r, 'col' : c, 'kind' : f[r][c] } ]
      endif
    endfor
  endfor
  let b:session.puyos = new_puyos
endfunction " }}}
function! s:recur_chin(puyos,row,col,kind) " {{{
  let cnt = 0
  if a:kind != s:F
    for i in range(0,len(a:puyos)-1)
      if a:puyos[i].kind == a:kind && a:puyos[i].row == a:row && a:puyos[i].col == a:col
        let cnt += 1
        let a:puyos[i].kind = s:F
      endif
      if a:puyos[i].kind == a:kind && a:puyos[i].row == a:row && a:puyos[i].col == a:col - 1
        let cnt += s:recur_chin(a:puyos,a:row,a:col-1,a:kind)
      endif
      if a:puyos[i].kind == a:kind && a:puyos[i].row == a:row && a:puyos[i].col == a:col + 1
        let cnt += s:recur_chin(a:puyos,a:row,a:col+1,a:kind)
      endif
      if a:puyos[i].kind == a:kind && a:puyos[i].row == a:row - 1 && a:puyos[i].col == a:col
        let cnt += s:recur_chin(a:puyos,a:row-1,a:col,a:kind)
      endif
      if a:puyos[i].kind == a:kind && a:puyos[i].row == a:row + 1 && a:puyos[i].col == a:col
        let cnt += s:recur_chin(a:puyos,a:row+1,a:col,a:kind)
      endif
    endfor
  endif
  return cnt
endfunction " }}}
function! s:chain() " {{{
  let score = 0
  let chain_count = 0

  call s:drop()
  while 1
    let prev_ps = deepcopy(b:session.puyos)
    let curr_ps = deepcopy(prev_ps)
    let is_chained = 0
    let total = 0

    for puyo in prev_ps
      let n = s:recur_chin(curr_ps,puyo.row,puyo.col,puyo.kind)
      if 4 <= n
        let is_chained = 1
        let total += n
        let prev_ps = curr_ps
      endif
      let curr_ps = deepcopy(prev_ps)
    endfor

    if is_chained
      let chain_count += 1
      let b:session.puyos = curr_ps
      sleep 1
      call s:drop()
      let b:session.text = get(s:chain_voices,chain_count,s:chain_voices[-1])
      call s:redraw(0)
    else
      call s:drop()
      call s:redraw(0)
      break
    endif
  endwhile
  return chain_count
endfunction " }}}
function! s:check() " {{{
  if ! s:movable(b:session.dropping,1,0)
    let b:session.puyos += b:session.dropping
    let b:session.dropping = b:session.next1
    let b:session.next1 = b:session.next2
    let b:session.next2 = s:next_puyo()
    call s:chain()
  endif
endfunction " }}}

function! s:key_turn(is_right) " {{{
  let state = [ b:session.dropping[0].row - b:session.dropping[1].row,
        \       b:session.dropping[0].col - b:session.dropping[1].col ]

  let saved_dropping_puyos = deepcopy(b:session.dropping)

  if state == [0,-1]
    let b:session.dropping[1].row = b:session.dropping[0].row + (a:is_right ? 1 : -1)
    let b:session.dropping[1].col = b:session.dropping[0].col
  elseif state == [-1,0]
    let b:session.dropping[1].row = b:session.dropping[0].row
    let b:session.dropping[1].col = b:session.dropping[0].col + (a:is_right ? -1 : 1)
  elseif state == [0,1]
    let b:session.dropping[1].row = b:session.dropping[0].row + (a:is_right ? -1 : 1)
    let b:session.dropping[1].col = b:session.dropping[0].col
  elseif state == [1,0]
    let b:session.dropping[1].row = b:session.dropping[0].row
    let b:session.dropping[1].col = b:session.dropping[0].col + (a:is_right ? 1 : -1)
  endif

  if ! s:movable(b:session.dropping,0,0)
    let b:session.dropping = saved_dropping_puyos
  endif

  call s:redraw(0)
endfunction " }}}
function! s:move_puyo(row,col,puyos) " {{{
  if ! s:movable(a:puyos,a:row,a:col)
    return 0
  endif
  for puyo in a:puyos
    let puyo.row += a:row
    let puyo.col += a:col
  endfor
  return 1
endfunction " }}}
function! s:key_down() " {{{
  call s:move_puyo(1,0,b:session.dropping)
  call s:redraw(0)
endfunction " }}}
function! s:key_up() " {{{
  call s:move_puyo(-1,0,b:session.dropping)
  call s:redraw(0)
endfunction " }}}
function! s:key_right() " {{{
  call s:move_puyo(0,1,b:session.dropping)
  call s:redraw(0)
endfunction " }}}
function! s:key_left() " {{{
  call s:move_puyo(0,-1,b:session.dropping)
  call s:redraw(0)
endfunction " }}}

function! s:auto() " {{{
  if &filetype ==# "puyo"
    try
      call s:key_down()
      call s:check()
    catch
    endtry
    call feedkeys(mode() ==# 'i' ? "\<C-g>\<ESC>" : "g\<ESC>", 'n')
  endif
endfunction " }}}
function! puyo#new() " {{{
  call s:redraw(1)
endfunction " }}}


"  vim: set ft=vim fdm=marker ff=unix :


scriptencoding utf-8

let s:V = vital#of('puyo.vim')
let s:Random = s:V.import('Random.Xor128')
let s:List = s:V.import('Data.List')
call s:Random.srand()

let s:unix_p = has('unix') && ! has('mac')
let s:windows_p = has('win95') || has('win16') || has('win32') || has('win64')
let s:cygwin_p = has('win32unix')
let s:mac_p = ! s:windows_p
      \ && ! s:cygwin_p
      \ && (
      \       has('mac')
      \    || has('macunix')
      \    || has('gui_macvim')
      \    || (  ! executable('xdg-open')
      \       && system('uname') =~? '^darwin'
      \       )
      \    )


let s:clrs = puyo#dots#colors()
let s:imgs = puyo#dots#images()
" {{{
let s:wallpaper = s:imgs.wallpapers.defaut
let s:W = s:imgs.wall
let s:F = s:imgs.field
let s:numbers = [
      \ s:imgs.numbers.zero,
      \ s:imgs.numbers.one,
      \ s:imgs.numbers.two,
      \ s:imgs.numbers.three,
      \ s:imgs.numbers.four,
      \ s:imgs.numbers.five,
      \ s:imgs.numbers.six,
      \ s:imgs.numbers.seven,
      \ s:imgs.numbers.eight,
      \ s:imgs.numbers.nine,
      \ ]
let s:puyo_colors = [
      \ s:imgs.puyos.red,
      \ s:imgs.puyos.blue,
      \ s:imgs.puyos.yellow,
      \ s:imgs.puyos.green,
      \ s:imgs.puyos.purple,
      \ ]
" }}}

let s:HIDDEN_ROW = 2
let s:FIELD_WIDTH = 6
let s:FIELD_HEIGHT = 13
let s:DROPPING_POINT = 3

let s:gameover_voice = 'ばたんきゅー'
let s:print_chain_format = '%d連鎖'

let s:MAX_FLOATTING_COUNT = 5000
let s:floatting_count = 0

function! s:make_field_array(contained_dropping) " {{{
  let f = []
  for h in range(1,s:FIELD_HEIGHT+s:HIDDEN_ROW)
    let f += [[s:W]+repeat([s:F],s:FIELD_WIDTH)+[s:W]]
  endfor
  let f += [repeat([s:W],s:FIELD_WIDTH+2)]

  for puyo in (a:contained_dropping ? b:session.dropping : []) + b:session.puyos
    if 0 <= puyo.row && 0 <= puyo.col
      let f[puyo.row][puyo.col] = puyo.kind
    endif
  endfor
  return f
endfunction " }}}
function! s:movable(puyos,row,col) " {{{
  let f = s:make_field_array(0)

  let is_gameover = 1
  for n in range(s:HIDDEN_ROW,s:FIELD_HEIGHT)
    if f[n][s:DROPPING_POINT] == s:F
      let is_gameover = 0
    endif
  endfor
  if is_gameover
    return -1
  endif

  for puyo in a:puyos
    if s:FIELD_HEIGHT + s:HIDDEN_ROW < puyo.row + a:row || puyo.row + a:row < 0
      return 0
    endif
    if s:FIELD_WIDTH < puyo.col + a:col || puyo.col + a:col <= 0
      return 0
    endif

    if f[puyo.row + a:row][puyo.col + a:col] != s:F
      if f[puyo.row + a:row][puyo.col + a:col] == s:W && puyo.row + a:row < s:HIDDEN_ROW
        return 1
      endif
      return 0
    endif
  endfor

  return 1
endfunction " }}}

function! s:next_puyo() " {{{
  return [
        \   {
        \     'row' : 0,
        \     'col' : s:DROPPING_POINT,
        \     'kind' : s:puyo_colors[ abs(s:Random.rand()) % b:session.number_of_colors ],
        \   },
        \   {
        \     'row' : 1,
        \     'col' : s:DROPPING_POINT,
        \     'kind' : s:puyo_colors[ abs(s:Random.rand()) % b:session.number_of_colors ],
        \   },
        \ ]
endfunction " }}}

function! s:redraw(do_init) " {{{
  let field = s:make_field_array(1)

  for i in range(0,s:HIDDEN_ROW-1)
    let field[i] = repeat([s:W], s:FIELD_WIDTH+2)
  endfor

  let field[1] += [s:W                    ,s:W,s:W                    ,s:W]
  let field[2] += [b:session.next1[0].kind,s:W,s:W                    ,s:W]
  let field[3] += [b:session.next1[1].kind,s:W,b:session.next2[0].kind,s:W]
  let field[4] += [s:W                    ,s:W,b:session.next2[1].kind,s:W]
  let field[5] += [s:W                    ,s:W,s:W                    ,s:W]

  let test_field = []

  if has('gui_running')
    let score_ary = []
    for c in split(printf('%08d',b:session.score),'\zs')
      let score_ary += [ s:numbers[str2nr(c)] ]
    endfor

    for row in field + [score_ary]
      let data = map(deepcopy(row),'v:val()')
      let test_field += map(call(s:List.zip, data), 's:List.concat(v:val)')
    endfor

    let wallpaper = s:wallpaper()
    let row_idx = 0
    for _row in wallpaper
      let col_idx = 0
      for dot in _row
        if test_field[s:HIDDEN_ROW * puyo#dots#height() + row_idx][1 * puyo#dots#width() + col_idx] == s:clrs.field.value
          let test_field[s:HIDDEN_ROW * puyo#dots#height() + row_idx][1 * puyo#dots#width() + col_idx] = dot
        endif
        let col_idx += 1
      endfor
      let row_idx += 1
    endfor
  else
    let test_field = field
  endif

  let rtn = []
  for row in test_field
    let rtn += [puyo#dots#substitute_for_syntax(row)]
  endfor
  let rtn += [b:session.n_chain_text]
  let rtn += [b:session.voice_text]
  if !has('gui_running')
    let rtn += [ 'score:' . printf('%08d',b:session.score) ]
  endif

  if has('gui_running')
    let &titlestring = b:session.voice_text
  endif

  call puyo#buffer#uniq_open("[puyo]",rtn,"w")
  execute printf("%dwincmd w",puyo#buffer#winnr("[puyo]"))
  redraw

  " consume key strokes.
  " while getchar(0)
  " endwhile
endfunction " }}}
" Algo {{{
function! s:drop() " {{{
  " initialize a field for setting puyos.
  let f = []
  for r in range(1,s:HIDDEN_ROW+s:FIELD_HEIGHT+1)
    let f += [repeat([s:F],s:FIELD_WIDTH+2)]
  endfor
  for puyo in b:session.puyos
    let f[puyo.row][puyo.col] = puyo.kind
  endfor

  " drop
  for c in range(s:FIELD_WIDTH,1,-1)
    while 1
      let b = 0
      for r in range(0,s:FIELD_HEIGHT)
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

  " rebuild puyos
  let new_puyos = []
  for c in range(1,s:FIELD_WIDTH)
    for r in range(1,s:FIELD_HEIGHT+s:HIDDEN_ROW)
      if f[r][c] != s:F
        let new_puyos += [ { 'row' : r, 'col' : c, 'kind' : f[r][c] } ]
      endif
    endfor
  endfor
  let b:session.puyos = new_puyos
endfunction " }}}
function! s:recur_chain(puyos,row,col,kind) " {{{
  let cnt = 0
  if a:kind != s:F
    for i in range(0,len(a:puyos)-1)
      if a:puyos[i].kind == a:kind && a:puyos[i].row == a:row && a:puyos[i].col == a:col
        let cnt += 1
        let a:puyos[i].kind = s:F
      endif
      if a:puyos[i].kind == a:kind && a:puyos[i].row == a:row && a:puyos[i].col == a:col - 1
        let cnt += s:recur_chain(a:puyos,a:row,a:col-1,a:kind)
      endif
      if a:puyos[i].kind == a:kind && a:puyos[i].row == a:row && a:puyos[i].col == a:col + 1
        let cnt += s:recur_chain(a:puyos,a:row,a:col+1,a:kind)
      endif
      if a:puyos[i].kind == a:kind && a:puyos[i].row == a:row - 1 && a:puyos[i].col == a:col
        let cnt += s:recur_chain(a:puyos,a:row-1,a:col,a:kind)
      endif
      if a:puyos[i].kind == a:kind && a:puyos[i].row == a:row + 1 && a:puyos[i].col == a:col
        let cnt += s:recur_chain(a:puyos,a:row+1,a:col,a:kind)
      endif
    endfor
  endif
  return cnt
endfunction " }}}
function! s:chain() " {{{
  let chain_bonuses = [0, 8, 16, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 388, 416, 448, 480, 512]
  let connect_bonuses = [0,2,3,4,5,6,7,10,10,10,10,10,10,10,10,10,10,10]
  let color_bonuses = [0,3,6,12,24]

  let score = 0
  let chain_count = 0

  call s:drop()
  while 1
    let prev_ps = deepcopy(b:session.puyos)
    let curr_ps = deepcopy(prev_ps)
    let is_chained = 0

    " use score
    let total = 0
    let connect_bonus = 0
    let color_bonus = {}

    for puyo in prev_ps
      let n = s:recur_chain(curr_ps,puyo.row,puyo.col,puyo.kind)
      if 4 <= n
        let is_chained = 1
        let prev_ps = curr_ps

        let total += n
        let color_bonus[string(puyo.kind)] = 1
        let connect_bonus += connect_bonuses[n - 4]
      endif
      let curr_ps = deepcopy(prev_ps)
    endfor

    if is_chained
      let chain_count += 1
      let b:session.puyos = curr_ps
      let tmp = (chain_bonuses[chain_count-1] + connect_bonus + color_bonuses[len(keys(color_bonus))-1])
      let b:session.score += total * (tmp == 0 ? 1 : tmp ) * 10
      if 99999999 < b:session.score
        let b:session.score = 99999999
      endif
      sleep 800m
      call s:drop()
      let b:session.voice_text = get( b:session.chain_voices, chain_count-1, b:session.chain_voices[-1])
      let b:session.n_chain_text = printf(s:print_chain_format,chain_count)
      call s:redraw(0)
    else
      call s:drop()
      call s:redraw(0)
      break
    endif
  endwhile

  " consume key strokes.
  while getchar(0)
  endwhile

  return chain_count
endfunction " }}}
function! s:check() " {{{
  let status = s:movable(b:session.dropping,1,0)
  if status == 0
    let b:session.voice_text = ''
    let b:session.n_chain_text = ''
    let b:session.puyos += b:session.dropping
    let b:session.dropping = b:session.next1
    let b:session.next1 = b:session.next2
    let b:session.next2 = s:next_puyo()
    call s:chain()
  endif
endfunction " }}}
function! s:turn_puyo2(is_right) " {{{
  let state = [ b:session.dropping[1].row - b:session.dropping[0].row,
        \       b:session.dropping[1].col - b:session.dropping[0].col ]
  if state == [0,-1]
    let b:session.dropping[0].row = b:session.dropping[1].row + (a:is_right ? 1 : -1)
    let b:session.dropping[0].col = b:session.dropping[1].col
  elseif state == [-1,0]
    let b:session.dropping[0].row = b:session.dropping[1].row
    let b:session.dropping[0].col = b:session.dropping[1].col + (a:is_right ? -1 : 1)
  elseif state == [0,1]
    let b:session.dropping[0].row = b:session.dropping[1].row + (a:is_right ? -1 : 1)
    let b:session.dropping[0].col = b:session.dropping[1].col
  elseif state == [1,0]
    let b:session.dropping[0].row = b:session.dropping[1].row
    let b:session.dropping[0].col = b:session.dropping[1].col + (a:is_right ? 1 : -1)
  endif
endfunction " }}}

function! s:key_turn(is_right) " {{{
  let saved_dropping_puyos = deepcopy(b:session.dropping)

  call s:turn_puyo2(a:is_right)

  if ! s:movable(b:session.dropping,0,0)
    let b:session.dropping = saved_dropping_puyos

    " left
    if 1 == s:move_puyo(0,-1,b:session.dropping)
      call s:turn_puyo2(a:is_right)
      if ! s:movable(b:session.dropping,0,0)
        let b:session.dropping = saved_dropping_puyos
      endif

      " right
    elseif 1 == s:move_puyo(0,1,b:session.dropping)
      call s:turn_puyo2(a:is_right)
      if ! s:movable(b:session.dropping,0,0)
        let b:session.dropping = saved_dropping_puyos
      endif

    else
      call s:turn_puyo2(a:is_right)
      call s:turn_puyo2(a:is_right)
      if ! s:movable(b:session.dropping,0,0)
        let b:session.dropping = saved_dropping_puyos
      endif

    endif

  endif

  let s:floatting_count += 1000
  if s:MAX_FLOATTING_COUNT < s:floatting_count
    call s:key_down()
    call s:check()
  endif
  call s:redraw(0)
endfunction " }}}
function! s:move_puyo(row,col,puyos) " {{{
  let status = s:movable(a:puyos,a:row,a:col)
  if status == 1
    for puyo in a:puyos
      let puyo.row += a:row
      let puyo.col += a:col
    endfor
  endif
  return status
endfunction " }}}
function! s:key_down() " {{{
  let status = s:movable(b:session.dropping,1,0)
  if 0 == status
    let s:floatting_count = s:MAX_FLOATTING_COUNT
  else
    let status = s:move_puyo(1,0,b:session.dropping)
    if -1 == status
      let b:session.voice_text = s:gameover_voice
    endif
    " reset
    let s:floatting_count = 0
  endif
  call s:redraw(0)
endfunction " }}}
function! s:key_none() " {{{
  call s:redraw(0)
  " reset
  let s:floatting_count = 0
endfunction " }}}
function! s:key_quickdrop() " {{{
  while 1
    let status = s:move_puyo(1,0,b:session.dropping)
    if -1 == status
      let b:session.voice_text = s:gameover_voice
      break
    elseif 0 == status
      break
    endif
  endwhile
  call s:redraw(0)
  " reset
  let s:floatting_count = 0
endfunction " }}}
function! s:key_right() " {{{
  call s:move_puyo(0,1,b:session.dropping)
  let s:floatting_count += 1000
  if s:MAX_FLOATTING_COUNT < s:floatting_count
    call s:key_down()
  endif
  call s:redraw(0)
endfunction " }}}
function! s:key_left() " {{{
  call s:move_puyo(0,-1,b:session.dropping)
  let s:floatting_count += 1000
  if s:MAX_FLOATTING_COUNT < s:floatting_count
    call s:key_down()
  endif
  call s:redraw(0)
endfunction " }}}
" }}}
function! s:key_quit() " {{{
  if &filetype ==# "puyo"
    augroup Puyo
      autocmd!
    augroup END

    let &maxfuncdepth = b:session.backup.maxfuncdepth
    let &guifont = b:session.backup.guifont
    let &updatetime = b:session.backup.updatetime
    let &titlestring = b:session.backup.titlestring
    if has('gui_running')
      let &columns = b:session.backup.columns
      let &lines = b:session.backup.lines
    endif
    bdelete!
  endif
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
  call puyo#buffer#uniq_open("[puyo]",[],"w")
  execute printf("%dwincmd w",puyo#buffer#winnr("[puyo]"))
  setlocal filetype=puyo
  only

  let b:session = {
        \   'puyos' : [],
        \   'n_chain_text' : '',
        \   'score' : 0,
        \   'voice_text' : '',
        \   'number_of_colors' : get(g:,'puyo#number_of_colors',4),
        \   'chain_voices' : get(g:,'puyo#chain_voices',[
        \     'えいっ',
        \     'ファイヤー',
        \     'アイスストーム',
        \     'ダイアキュート',
        \     'ブレインダムド',
        \     'ジュゲム',
        \     'ばよえ～ん',
        \     ]),
        \   'backup' : {
        \     'guifont' : &guifont,
        \     'updatetime' : &updatetime,
        \     'maxfuncdepth' : &maxfuncdepth,
        \     'titlestring' : &titlestring,
        \     'columns' : &columns,
        \     'lines' : &lines,
        \   },
        \ }
  let b:session['dropping'] = s:next_puyo()
  let b:session['next1'] = s:next_puyo()
  let b:session['next2'] = s:next_puyo()


  let &l:updatetime = get(g:,'puyo#updatetime',500)
  let &l:maxfuncdepth = 1000

  if exists('g:puyo#guifont')
    let &l:guifont = g:puyo#guifont
  elseif s:windows_p
    setlocal guifont=Consolas:h4:cSHIFTJIS
  elseif s:mac_p
    setlocal guifont=Menlo\ Regular:h5
  elseif s:unix_p
    setlocal guifont=Monospace\ 2
  else
  endif

  nnoremap <silent><buffer> j :call <sid>key_down() \| call <sid>check()<cr>
  nnoremap <silent><buffer> k :call <sid>key_quickdrop() \| call <sid>check()<cr>
  " nnoremap <silent><buffer> k :call <sid>key_none() \| call <sid>check()<cr>
  nnoremap <silent><buffer> h :call <sid>key_left()<cr>
  nnoremap <silent><buffer> l :call <sid>key_right()<cr>
  nnoremap <silent><buffer> z :call <sid>key_turn(0)<cr>
  nnoremap <silent><buffer> x :call <sid>key_turn(1)<cr>
  nnoremap <silent><buffer> q :call <sid>key_quit()<cr>

  augroup Puyo
    autocmd!
    autocmd CursorHold,CursorHoldI * call s:auto()
  augroup END

  call s:redraw(1)

  if has('gui_running')
    let &columns = 9999
    let &lines = 999
  endif

endfunction " }}}

"  vim: set ts=2 sts=2 sw=2 ft=vim fdm=marker ff=unix :

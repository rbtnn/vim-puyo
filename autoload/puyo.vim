
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
let s:teto_colors = [
      \ s:imgs.teto.block1,
      \ s:imgs.teto.block2,
      \ ]
let s:gameover_chars = [
      \ s:imgs.hiragana.ba,
      \ s:imgs.hiragana.ta,
      \ s:imgs.hiragana.nn,
      \ s:imgs.hiragana.ki,
      \ s:imgs.hiragana.lyu,
      \ s:imgs.hiragana.__,
      \ ]
let s:chain_chars = [
      \ s:imgs.hiragana.re,
      \ s:imgs.hiragana.nn,
      \ s:imgs.hiragana.sa,
      \ ]
" }}}

let s:HIDDEN_ROW = 2
let s:FIELD_WIDTH = 6
let s:FIELD_HEIGHT = 13
let s:DROPPING_POINT = 3

let s:MAX_FLOATTING_COUNT = 5000
let s:floatting_count = 0

function! s:is_puyo(kind) " {{{
  return -1 isnot index(s:puyo_colors,a:kind)
endfunction " }}}
function! s:is_teto(kind) " {{{
  return -1 isnot index(s:teto_colors,a:kind)
endfunction " }}}

function! s:make_field_array(contained_dropping) " {{{
  let f = []
  for h in range(1,s:FIELD_HEIGHT+s:HIDDEN_ROW)
    let f += [[s:W]+repeat([s:F],s:FIELD_WIDTH)+[s:W]]
  endfor
  let f += [repeat([s:W],s:FIELD_WIDTH+2)]

  for puyo in
        \ (a:contained_dropping ? s:dropping2list() : []) + b:session.puyos
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
    if f[n][s:DROPPING_POINT] is s:F
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

    if f[puyo.row + a:row][puyo.col + a:col] isnot s:F
      if f[puyo.row + a:row][puyo.col + a:col] is s:W && puyo.row + a:row < s:HIDDEN_ROW
        return 1
      endif
      return 0
    endif
  endfor

  return 1
endfunction " }}}

function! s:next_puyo() " {{{
  if b:session.is_puyoteto && (abs(s:Random.rand()) % 2)
    " teto
    let i = abs(s:Random.rand()) % len(s:teto_colors)
    let pivot = {
          \   'id' : b:session.id,
          \   'row' : 0,
          \   'col' : s:DROPPING_POINT,
          \   'kind' : s:teto_colors[i],
          \ }
    let patturn = [
          \   [[1,0],[1,1],[0,-1]],
          \   [[1,0],[0,-1],[0,1]],
          \   [[1,0],[1,1],[0,1]],
          \ ] 
    let children = []
    for p in patturn[abs(s:Random.rand()) % len(patturn)]
      let children += [{
            \  'id' : b:session.id,
            \  'row' : pivot.row + p[0],
            \  'col' : pivot.col + p[1],
            \  'kind' : s:teto_colors[i],
            \ }]
    endfor
  else
    " puyo
    let pivot = {
          \   'id' : b:session.id,
          \   'row' : 0,
          \   'col' : s:DROPPING_POINT,
          \   'kind' : s:puyo_colors[ abs(s:Random.rand()) % b:session.number_of_colors ],
          \ }
    let children = [{
          \  'id' : b:session.id,
          \  'row' : pivot.row + 1,
          \  'col' : pivot.col + 0,
          \  'kind' : s:puyo_colors[ abs(s:Random.rand()) % b:session.number_of_colors ],
          \ }]
  endif

  let b:session.id += 1

  return { 'pivot' : pivot, 'children' : children }
endfunction " }}}
function! s:dropping2list() " {{{
  return [b:session.dropping.pivot] + b:session.dropping.children
endfunction " }}}

function! s:redraw_cui(field) " {{{
  let field = []
  for row_ in a:field
    let field += [map(deepcopy(row_),'puyo#dots#image2color_for_cui(v:val)')]
  endfor

  let rtn = []
  for row in field
    let rtn += [puyo#dots#substitute_for_syntax(row)]
  endfor

  if b:session.is_gameover
    let rtn[9] .= 'ばたんきゅー'
  else
    let rtn[9] .= printf('%d連鎖',b:session.n_chain_count)
  endif
  let rtn[11] .= 'score:' . printf('%08d',b:session.score)

  " let rtn += [b:session.voice_text]

  return rtn
endfunction " }}}
function! s:redraw_gui(field) " {{{
  let field = a:field

  let n_chain_ary = []
  if 0 < b:session.n_chain_count
    for c in split(printf('%02d',b:session.n_chain_count),'\zs')
      let n_chain_ary += [ s:numbers[str2nr(c)] ]
    endfor
    let n_chain_ary += s:chain_chars
  endif

  let score_ary = []
  for c in split(printf('%08d',b:session.score),'\zs')
    let score_ary += [ s:numbers[str2nr(c)] ]
  endfor

  let field[8] += repeat([s:W],8)
  if b:session.is_gameover
    let field[9] += s:gameover_chars + repeat([s:W],8-len(s:gameover_chars))
  else
    let field[9] += n_chain_ary + repeat([s:W],8-len(n_chain_ary))
  endif
  let field[10] += repeat([s:W],8)
  let field[11] += score_ary
  let field[12] += repeat([s:W],8)


  let test_field = []
  for row in field
    let data = map(deepcopy(row),'v:val()')
    let test_field += map(call(s:List.zip, data), 's:List.concat(v:val)')
  endfor


  let wallpaper = s:wallpaper()
  let row_idx = 0
  for _row in wallpaper
    let col_idx = 0
    for dot in _row
      if test_field[s:HIDDEN_ROW * puyo#dots#height() + row_idx][1 * puyo#dots#width() + col_idx] is s:clrs.field.value
        let test_field[s:HIDDEN_ROW * puyo#dots#height() + row_idx][1 * puyo#dots#width() + col_idx] = dot
      endif
      let col_idx += 1
    endfor
    let row_idx += 1
  endfor

  let rtn = []
  for row in test_field
    let rtn += [puyo#dots#substitute_for_syntax(row)]
  endfor

  let &titlestring = b:session.voice_text

  return rtn
endfunction " }}}
function! s:redraw() " {{{
  let field = s:make_field_array(1)

  for i in range(0,s:HIDDEN_ROW-1)
    let field[i] = repeat([s:W], s:FIELD_WIDTH+2)
  endfor

  let next1 = [b:session.next1.pivot] + b:session.next1.children
  let next2 = [b:session.next2.pivot] + b:session.next2.children

  let field[1] += [s:W          ,s:W,s:W                    ,s:W]
  let field[2] += [next1[0].kind,s:W,s:W                    ,s:W]
  let field[3] += [next1[1].kind,s:W,next2[0].kind,s:W]
  let field[4] += [s:W          ,s:W,next2[1].kind,s:W]
  let field[5] += [s:W          ,s:W,s:W                    ,s:W]

  if has('gui_running')
    let rtn = s:redraw_gui(field)
  else
    let rtn = s:redraw_cui(field)
  endif

  call puyo#buffer#uniq_open("[puyo]",rtn,"w")
  execute printf("%dwincmd w",puyo#buffer#winnr("[puyo]"))
  redraw
endfunction " }}}

function! puyo#play_chain_sound(chain_count) " {{{
  " Example: [[ 'C:/SEGA/PuyoF_ver2.0/SE/000RENSA1.WAV', 'C:/SEGA/PuyoF_ver2.0/VOICE/CH00VO00.WAV' ],...]
  let g:puyo#chain_sounds = get(g:,'puyo#chain_sounds', [])
  if ! empty(g:puyo#chain_sounds)
    try
      for v in get(g:puyo#chain_sounds,a:chain_count,g:puyo#chain_sounds[-1])
        call sound#play_wav(v)
      endfor
    catch
    endtry
  endif
endfunction " }}}
function! puyo#play_land_sound() " {{{
  " Example: ['C:/SEGA/PuyoF_ver2.0/SE/009PUYOCHAKUTI.WAV']
  let g:puyo#land_sound = get(g:,'puyo#land_sound', [])
  if ! empty(g:puyo#land_sound)
    try
      call sound#play_wav(g:puyo#land_sound)
    catch
    endtry
  endif
endfunction " }}}

" Algo {{{

function! s:drop() " {{{
  " initialize a field for setting puyos.
  let f = []
  for r in range(0,s:HIDDEN_ROW+s:FIELD_HEIGHT+1)
    let f += [[]]
    for c in range(0,1+s:FIELD_WIDTH+1)
      let f[r] += [ {
            \   'id' : -1,
            \   'row' : r,
            \   'col' : c,
            \   'kind' : s:F,
            \ } ]
    endfor
  endfor
  for puyo in b:session.puyos
    let f[puyo.row][puyo.col] = puyo
  endfor

  " drop teto & bubbling puyo
  for c in range(s:FIELD_WIDTH,1,-1)
    while 1
      let b = 0
      for r in range(0,s:FIELD_HEIGHT)
        if ! s:is_teto((f[r+1][c]).kind) && s:is_teto((f[r][c]).kind)
          let tmp = f[r+1][c]
          let f[r+1][c] = f[r][c]
          let f[r][c] = tmp
          let b = 1
        endif
      endfor
      if ! b
        break
      endif
    endwhile
  endfor

  " drop puyo
  for c in range(s:FIELD_WIDTH,1,-1)
    while 1
      let b = 0
      for r in range(0,s:FIELD_HEIGHT)
        if (f[r+1][c]).kind is s:F && s:is_puyo((f[r][c]).kind)
          let tmp = f[r][c]
          let f[r][c] = f[r+1][c]
          let f[r+1][c] = tmp
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
      if (f[r][c]).kind isnot s:F
        let new_puyos += [ {
              \   'id' : (f[r][c]).id,
              \   'row' : r,
              \   'col' : c,
              \   'kind' : (f[r][c]).kind,
              \ } ]
      endif
    endfor
  endfor
  let b:session.puyos = new_puyos
endfunction " }}}

" puyo
function! s:recur_chain_puyo(puyos,row,col,kind) " {{{
  let cnt = 0
  if a:kind isnot s:F
    for i in range(0,len(a:puyos)-1)
      if s:is_puyo(a:puyos[i].kind)
        if a:puyos[i].kind is a:kind && a:puyos[i].row is a:row && a:puyos[i].col is a:col
          let cnt += 1
          let a:puyos[i].kind = s:F
        endif
        if a:puyos[i].kind is a:kind && a:puyos[i].row is a:row && a:puyos[i].col is a:col - 1
          let cnt += s:recur_chain_puyo(a:puyos,a:row,a:col-1,a:kind)
        endif
        if a:puyos[i].kind is a:kind && a:puyos[i].row is a:row && a:puyos[i].col is a:col + 1
          let cnt += s:recur_chain_puyo(a:puyos,a:row,a:col+1,a:kind)
        endif
        if a:puyos[i].kind is a:kind && a:puyos[i].row is a:row - 1 && a:puyos[i].col is a:col
          let cnt += s:recur_chain_puyo(a:puyos,a:row-1,a:col,a:kind)
        endif
        if a:puyos[i].kind is a:kind && a:puyos[i].row is a:row + 1 && a:puyos[i].col is a:col
          let cnt += s:recur_chain_puyo(a:puyos,a:row+1,a:col,a:kind)
        endif
      endif
    endfor
  endif
  return cnt
endfunction " }}}
function! s:chain_puyo() " {{{
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
      let n = s:recur_chain_puyo(curr_ps,puyo.row,puyo.col,puyo.kind)
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
      let b:session.score += total * (tmp is 0 ? 1 : tmp ) * 10
      if 99999999 < b:session.score
        let b:session.score = 99999999
      endif
      sleep 700m
      call s:drop()
      let b:session.voice_text = get( b:session.chain_voices, chain_count-1, b:session.chain_voices[-1])
      let b:session.n_chain_count = chain_count

      call puyo#play_chain_sound(chain_count)

      call s:redraw()
    else
      call s:drop()
      call s:redraw()
      break
    endif
  endwhile

  " consume key strokes.
  while getchar(0)
  endwhile

  return chain_count
endfunction " }}}
" teto
function! s:recur_chain_teto(puyos,row,col,kind) " {{{
  let cnt = 0
  if a:kind isnot s:F
    for i in range(0,len(a:puyos)-1)
      if s:is_teto(a:puyos[i].kind)
        if a:puyos[i].row is a:row && a:puyos[i].col is a:col
          let cnt += 1
          let a:puyos[i].kind = s:F
        endif
        if a:puyos[i].row is a:row && a:puyos[i].col is a:col - 1
          let cnt += s:recur_chain_teto(a:puyos,a:row,a:col-1,a:kind)
        endif
        if a:puyos[i].row is a:row && a:puyos[i].col is a:col + 1
          let cnt += s:recur_chain_teto(a:puyos,a:row,a:col+1,a:kind)
        endif
      endif
    endfor
  endif
  return cnt
endfunction " }}}
function! s:chain_teto() " {{{
  let chain_count = 0
  let score = 0

  call s:drop()
  let prev_ps = deepcopy(b:session.puyos)
  let curr_ps = deepcopy(prev_ps)
  let is_chained = 0

  " use score
  let total = 0

  for puyo in prev_ps
    let n = s:recur_chain_teto(curr_ps,puyo.row,puyo.col,puyo.kind)
    if s:FIELD_WIDTH is n
      let is_chained = 1
      let prev_ps = curr_ps
      let total += n
    endif
    let curr_ps = deepcopy(prev_ps)
  endfor

  if is_chained
    let chain_count += 1
    let b:session.puyos = curr_ps
    let b:session.score += 1000 * total
    if 99999999 < b:session.score
      let b:session.score = 99999999
    endif
    sleep 700m
    call s:drop()
    call s:redraw()
  endif

  " consume key strokes.
  while getchar(0)
  endwhile

  return chain_count
endfunction " }}}

function! s:check(is_auto_drop) " {{{
  let status = s:movable(s:dropping2list(),1,0)
  if status is 0 && (a:is_auto_drop ? (s:floatting_count >= s:MAX_FLOATTING_COUNT) : 1)
    call puyo#play_land_sound()

    let b:session.voice_text = ''
    let b:session.n_chain_count = 0
    let b:session.puyos += s:dropping2list()
    let b:session.dropping = b:session.next1
    let b:session.next1 = b:session.next2
    let b:session.next2 = s:next_puyo()

    while (s:chain_puyo() + s:chain_teto())
    endwhile
  endif
endfunction " }}}
function! s:turn_dropping(is_right) " {{{
  for child in b:session.dropping.children
    let state = [ child.row - b:session.dropping.pivot.row,
          \       child.col - b:session.dropping.pivot.col ]
    if     state == [ 0,-1]
      let child.row = b:session.dropping.pivot.row + (a:is_right ? -1 :  1)
      let child.col = b:session.dropping.pivot.col
    elseif state == [-1, 0]
      let child.row = b:session.dropping.pivot.row
      let child.col = b:session.dropping.pivot.col + (a:is_right ?  1 : -1)
    elseif state == [ 0, 1]
      let child.row = b:session.dropping.pivot.row + (a:is_right ?  1 : -1)
      let child.col = b:session.dropping.pivot.col
    elseif state == [ 1, 0]
      let child.row = b:session.dropping.pivot.row
      let child.col = b:session.dropping.pivot.col + (a:is_right ? -1 :  1)
    elseif state == [ 1, 1]
      let child.row = b:session.dropping.pivot.row + (a:is_right ?  1 : -1)
      let child.col = b:session.dropping.pivot.col + (a:is_right ? -1 :  1)
    elseif state == [ 1,-1]
      let child.row = b:session.dropping.pivot.row + (a:is_right ? -1 :  1)
      let child.col = b:session.dropping.pivot.col + (a:is_right ? -1 :  1)
    elseif state == [-1,-1]
      let child.row = b:session.dropping.pivot.row + (a:is_right ? -1 :  1)
      let child.col = b:session.dropping.pivot.col + (a:is_right ?  1 : -1)
    elseif state == [-1, 1]
      let child.row = b:session.dropping.pivot.row + (a:is_right ?  1 : -1)
      let child.col = b:session.dropping.pivot.col + (a:is_right ?  1 : -1)
    endif
  endfor
endfunction " }}}

function! s:key_turn(is_right) " {{{
  let saved_dropping_puyos = deepcopy(b:session.dropping)

  call s:turn_dropping(a:is_right)

  if ! s:movable(s:dropping2list(),0,0)
    let b:session.dropping = saved_dropping_puyos

    " left
    if 1 is s:move_puyo(0,-1,s:dropping2list())
      call s:turn_dropping(a:is_right)
      if ! s:movable(s:dropping2list(),0,0)
        let b:session.dropping = saved_dropping_puyos
      endif

      " right
    elseif 1 is s:move_puyo(0,1,s:dropping2list())
      call s:turn_dropping(a:is_right)
      if ! s:movable(s:dropping2list(),0,0)
        let b:session.dropping = saved_dropping_puyos
      endif

    else
      call s:turn_dropping(a:is_right)
      call s:turn_dropping(a:is_right)
      if ! s:movable(s:dropping2list(),0,0)
        let b:session.dropping = saved_dropping_puyos
      endif

    endif

  endif

  let s:floatting_count += 1000
  if s:MAX_FLOATTING_COUNT < s:floatting_count
    call s:key_down()
    call s:check(0)
  endif
  call s:redraw()
endfunction " }}}
function! s:move_puyo(row,col,puyos) " {{{
  let status = s:movable(a:puyos,a:row,a:col)
  if status is 1
    for puyo in a:puyos
      let puyo.row += a:row
      let puyo.col += a:col
    endfor
  endif
  return status
endfunction " }}}
function! s:key_down() " {{{
  let status = s:movable(s:dropping2list(),1,0)
  if 0 is status
    let s:floatting_count = s:MAX_FLOATTING_COUNT
  else
    let status = s:move_puyo(1,0,s:dropping2list())
    if -1 is status
      let b:session.is_gameover = 1
    endif
    " reset
    let s:floatting_count = 0
    " consume key strokes.
    while getchar(0)
    endwhile
  endif
  call s:redraw()
endfunction " }}}
function! s:key_none() " {{{
  call s:redraw()
  " reset
  let s:floatting_count = 0
endfunction " }}}
function! s:key_quickdrop() " {{{
  while 1
    let status = s:move_puyo(1,0,s:dropping2list())
    if -1 is status
      let b:session.is_gameover = 1
      break
    elseif 0 is status
      break
    endif
  endwhile
  call s:redraw()
  " reset
  let s:floatting_count = 0
endfunction " }}}
function! s:key_right() " {{{
  call s:move_puyo(0,1,s:dropping2list())
  let s:floatting_count += 1000
  if s:MAX_FLOATTING_COUNT < s:floatting_count
    call s:key_down()
  endif
  call s:redraw()
endfunction " }}}
function! s:key_left() " {{{
  call s:move_puyo(0,-1,s:dropping2list())
  let s:floatting_count += 1000
  if s:MAX_FLOATTING_COUNT < s:floatting_count
    call s:key_down()
  endif
  call s:redraw()
endfunction " }}}
" }}}

function! s:key_quit() " {{{
  if &filetype is# "puyo"
    augroup Puyo
      autocmd!
    augroup END

    let &maxfuncdepth = b:session.backup.maxfuncdepth
    let &guifont = b:session.backup.guifont
    let &updatetime = b:session.backup.updatetime
    let &titlestring = b:session.backup.titlestring
    let &spell = b:session.backup.spell
    if has('gui_running')
      let &columns = b:session.backup.columns
      let &lines = b:session.backup.lines
    endif
    bdelete!
  endif
endfunction " }}}
function! s:auto() " {{{
  if &filetype is# "puyo"
    try
      call s:key_down()
      call s:check(1)
    catch
    endtry
    call feedkeys(mode() is# 'i' ? "\<C-g>\<ESC>" : "g\<ESC>", 'n')
  endif
endfunction " }}}

function! puyo#new(...) " {{{
  let is_puyoteto = 0 < a:0

  call puyo#buffer#uniq_open("[puyo]",[],"w")
  execute printf("%dwincmd w",puyo#buffer#winnr("[puyo]"))
  setlocal filetype=puyo
  only

  let b:session = {
        \   'is_puyoteto' : is_puyoteto,
        \   'puyos' : [],
        \   'n_chain_count' : 0,
        \   'score' : 0,
        \   'id' : 0,
        \   'voice_text' : '',
        \   'is_gameover' : 0,
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
        \     'spell' : &spell,
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
  let &l:spell = 0

  if exists('g:puyo#guifont')
    let &l:guifont = g:puyo#guifont
  elseif s:windows_p
    setlocal guifont=Consolas:h2:cSHIFTJIS
  elseif s:mac_p
    setlocal guifont=Menlo\ Regular:h5
  elseif s:unix_p
    setlocal guifont=Monospace\ 2
  else
  endif

  nnoremap <silent><buffer> j :call <sid>key_down() \| call <sid>check(0)<cr>
  nnoremap <silent><buffer> k :call <sid>key_quickdrop() \| call <sid>check(0)<cr>
  nnoremap <silent><buffer> h :call <sid>key_left()<cr>
  nnoremap <silent><buffer> l :call <sid>key_right()<cr>
  nnoremap <silent><buffer> z :call <sid>key_turn(0)<cr>
  nnoremap <silent><buffer> x :call <sid>key_turn(1)<cr>
  nnoremap <silent><buffer> q :call <sid>key_quit()<cr>

  augroup Puyo
    autocmd!
    autocmd CursorHold,CursorHoldI * call s:auto()
  augroup END

  call s:redraw()

  if has('gui_running')
    let &columns = 9999
    let &lines = 999
  endif

endfunction " }}}

"  vim: set ts=2 sts=2 sw=2 ft=vim fdm=marker ff=unix :

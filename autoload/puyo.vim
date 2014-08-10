
scriptencoding utf-8

let s:W = 'puyo#dots#wall#data'
let s:F = 'puyo#dots#field#data'
let s:numbers = puyo#dots#numbers()
let s:puyo_colors = puyo#dots#puyo_colors()
let s:gameover_chars = puyo#dots#gameover_chars()
let s:chain_chars = puyo#dots#chain_chars()

let s:HIDDEN_ROW = 2
let s:FIELD_WIDTH = 6
let s:FIELD_HEIGHT = 13
let s:DROPPING_POINT = 3

let s:MAX_FLOATTING_COUNT = 5000
let s:floatting_count = 0

function! s:make_field_array(contained_dropping)
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
endfunction
function! s:movable(puyos,row,col)
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
endfunction

function! s:next_puyo()
  return [
        \   {
        \     'row' : 0,
        \     'col' : s:DROPPING_POINT,
        \     'kind' : s:puyo_colors[ game_engine#rand(b:session.number_of_colors) ],
        \   },
        \   {
        \     'row' : 1,
        \     'col' : s:DROPPING_POINT,
        \     'kind' : s:puyo_colors[ game_engine#rand(b:session.number_of_colors) ],
        \   },
        \ ]
endfunction

function! s:redraw_cui(field)
  let field = []
  for row_ in a:field
    let field += [ join(map(deepcopy(row_),'puyo#dots#image2color_for_cui(v:val)'), "") ]
  endfor

  if b:session.is_gameover
    let field[9] .= 'ばたんきゅー'
  else
    let field[9] .= printf('%d連鎖', b:session.n_chain_count)
  endif
  let field[11] .= 'score:' . printf('%08d', b:session.score)

  return field
endfunction
function! s:redraw_gui(field)
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

  return map(game_engine#scale2d(deepcopy(field[1:]), puyo#dots#all(), puyo#dots#wall#data()), 'join(v:val, "")')
endfunction
function! s:map2lines()
  let field = s:make_field_array(1)

  for i in range(0,s:HIDDEN_ROW-1)
    let field[i] = repeat([s:W], s:FIELD_WIDTH+2)
  endfor

  let field[1] += [s:W                    ,s:W,s:W                    ,s:W]
  let field[2] += [b:session.next1[0].kind,s:W,s:W                    ,s:W]
  let field[3] += [b:session.next1[1].kind,s:W,b:session.next2[0].kind,s:W]
  let field[4] += [s:W                    ,s:W,b:session.next2[1].kind,s:W]
  let field[5] += [s:W                    ,s:W,s:W                    ,s:W]

  if has('gui_running')
    let rtn = s:redraw_gui(field)
  else
    let rtn = s:redraw_cui(field)
  endif

  return rtn
endfunction

function! puyo#play_chain_sound(chain_count)
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
endfunction
function! puyo#play_land_sound()
  " Example: ['C:/SEGA/PuyoF_ver2.0/SE/009PUYOCHAKUTI.WAV']
  let g:puyo#land_sound = get(g:,'puyo#land_sound', [])
  if ! empty(g:puyo#land_sound)
    try
      call sound#play_wav(g:puyo#land_sound)
    catch
    endtry
  endif
endfunction

function! s:drop()
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
        if f[r+1][c] is s:F && f[r][c] isnot s:F
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
      if f[r][c] isnot s:F
        let new_puyos += [ { 'row' : r, 'col' : c, 'kind' : f[r][c] } ]
      endif
    endfor
  endfor
  let b:session.puyos = new_puyos
endfunction
function! s:recur_chain(puyos,row,col,kind)
  let cnt = 0
  if a:kind isnot s:F
    for i in range(0,len(a:puyos)-1)
      if a:puyos[i].kind is a:kind && a:puyos[i].row is a:row && a:puyos[i].col is a:col
        let cnt += 1
        let a:puyos[i].kind = s:F
      endif
      if a:puyos[i].kind is a:kind && a:puyos[i].row is a:row && a:puyos[i].col is a:col - 1
        let cnt += s:recur_chain(a:puyos,a:row,a:col-1,a:kind)
      endif
      if a:puyos[i].kind is a:kind && a:puyos[i].row is a:row && a:puyos[i].col is a:col + 1
        let cnt += s:recur_chain(a:puyos,a:row,a:col+1,a:kind)
      endif
      if a:puyos[i].kind is a:kind && a:puyos[i].row is a:row - 1 && a:puyos[i].col is a:col
        let cnt += s:recur_chain(a:puyos,a:row-1,a:col,a:kind)
      endif
      if a:puyos[i].kind is a:kind && a:puyos[i].row is a:row + 1 && a:puyos[i].col is a:col
        let cnt += s:recur_chain(a:puyos,a:row+1,a:col,a:kind)
      endif
    endfor
  endif
  return cnt
endfunction
function! s:chain()
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
      let b:session.score += total * (tmp is 0 ? 1 : tmp ) * 10
      if 99999999 < b:session.score
        let b:session.score = 99999999
      endif
      sleep 700m
      call s:drop()
      let b:session.n_chain_count = chain_count

      call puyo#play_chain_sound(chain_count)

      call b:session.redraw(s:map2lines())
    else
      call s:drop()
      call b:session.redraw(s:map2lines())
      break
    endif
  endwhile

  " consume key strokes.
  while getchar(0)
  endwhile

  return chain_count
endfunction
function! s:check(is_auto_drop)
  let status = s:movable(b:session.dropping,1,0)
  if status is 0 && (a:is_auto_drop ? (s:floatting_count >= s:MAX_FLOATTING_COUNT) : 1)
    call puyo#play_land_sound()

    let b:session.n_chain_count = 0
    let b:session.puyos += b:session.dropping
    let b:session.dropping = b:session.next1
    let b:session.next1 = b:session.next2
    let b:session.next2 = s:next_puyo()
    call s:chain()
  endif
endfunction
function! s:turn_puyo2(is_right)
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
endfunction

function! s:key_turn(is_right)
  let saved_dropping_puyos = deepcopy(b:session.dropping)

  call s:turn_puyo2(a:is_right)

  if ! s:movable(b:session.dropping,0,0)
    let b:session.dropping = saved_dropping_puyos

    " left
    if 1 is s:move_puyo(0,-1,b:session.dropping)
      call s:turn_puyo2(a:is_right)
      if ! s:movable(b:session.dropping,0,0)
        let b:session.dropping = saved_dropping_puyos
      endif

      " right
    elseif 1 is s:move_puyo(0,1,b:session.dropping)
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
    call s:check(0)
  endif
  call b:session.redraw(s:map2lines())
endfunction
function! s:move_puyo(row,col,puyos)
  let status = s:movable(a:puyos,a:row,a:col)
  if status is 1
    for puyo in a:puyos
      let puyo.row += a:row
      let puyo.col += a:col
    endfor
  endif
  return status
endfunction
function! s:key_down()
  let status = s:movable(b:session.dropping,1,0)
  if 0 is status
    let s:floatting_count = s:MAX_FLOATTING_COUNT
  else
    let status = s:move_puyo(1,0,b:session.dropping)
    if -1 is status
      let b:session.is_gameover = 1
    endif
    " reset
    let s:floatting_count = 0
    " consume key strokes.
    while getchar(0)
    endwhile
  endif
  call b:session.redraw(s:map2lines())
endfunction
function! s:key_none()
  call b:session.redraw(s:map2lines())
  " reset
  let s:floatting_count = 0
endfunction
function! s:key_quickdrop()
  while 1
    let status = s:move_puyo(1,0,b:session.dropping)
    if -1 is status
      let b:session.is_gameover = 1
      break
    elseif 0 is status
      break
    endif
  endwhile
  call b:session.redraw(s:map2lines())
  " reset
  let s:floatting_count = 0
endfunction
function! s:key_right()
  call s:move_puyo(0,1,b:session.dropping)
  let s:floatting_count += 1000
  if s:MAX_FLOATTING_COUNT < s:floatting_count
    call s:key_down()
  endif
  call b:session.redraw(s:map2lines())
endfunction
function! s:key_left()
  call s:move_puyo(0,-1,b:session.dropping)
  let s:floatting_count += 1000
  if s:MAX_FLOATTING_COUNT < s:floatting_count
    call s:key_down()
  endif
  call b:session.redraw(s:map2lines())
endfunction

function! s:auto()
  call s:key_down()
  call s:check(1)
endfunction

function! puyo#start_game()
  call game_engine#start_game('[puyo]', function('s:auto'))

  call extend(b:session, {
        \   'puyos' : [],
        \   'n_chain_count' : 0,
        \   'score' : 0,
        \   'is_gameover' : 0,
        \   'number_of_colors' : get(g:,'puyo#number_of_colors', 4),
        \ })
  let b:session['dropping'] = s:next_puyo()
  let b:session['next1'] = s:next_puyo()
  let b:session['next2'] = s:next_puyo()

  let &l:updatetime = get(g:,'puyo#updatetime',500)
  let &l:maxfuncdepth = 1000

  if exists('g:puyo#guifont')
    let &l:guifont = g:puyo#guifont
  endif

  nnoremap <silent><buffer><nowait> j       :call <sid>key_down() \| call <sid>check(0)<cr>
  nnoremap <silent><buffer><nowait> k       :call <sid>key_quickdrop() \| call <sid>check(0)<cr>
  nnoremap <silent><buffer><nowait> h       :call <sid>key_left()<cr>
  nnoremap <silent><buffer><nowait> l       :call <sid>key_right()<cr>
  nnoremap <silent><buffer><nowait> z       :call <sid>key_turn(0)<cr>
  nnoremap <silent><buffer><nowait> x       :call <sid>key_turn(1)<cr>
  nnoremap <silent><buffer><nowait> q       :call game_engine#exit_game()<cr>
  nnoremap <silent><buffer><nowait> S       :call game_engine#save_game('[puyo]', 1)<cr>
  nnoremap <silent><buffer><nowait> L       :call game_engine#load_game('[puyo]', 1)<cr>

  call b:session.redraw(s:map2lines())
endfunction


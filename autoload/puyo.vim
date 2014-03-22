
scriptencoding utf-8

let s:V = vital#of('puyo.vim')
let s:Random = s:V.import('Random.Xor128')
let s:List = s:V.import('Data.List')
call s:Random.srand()

let s:puyo_obj = {}
function! s:puyo_obj.is_puyo(kind) " {{{
  return -1 isnot index(self.puyo_colors, a:kind)
endfunction " }}}
function! s:puyo_obj.is_teto(kind) " {{{
  return -1 isnot index(self.teto_colors, a:kind)
endfunction " }}}

function! s:puyo_obj.drop_puyo() " {{{
  " drop puyo
  for c in self.enable_range_of_field_width
    while 1
      let b = 0
      for r in reverse(self.enable_range_of_field_height)
        if self.puyogrid.get(r+1, c) is self.F && self.is_puyo(self.puyogrid.get(r, c))
          call self.puyogrid.swap(r+1, c, r, c)
          let b = 1
        endif
      endfor
      if ! b
        break
      endif
    endwhile
  endfor
endfunction " }}}
function! s:puyo_obj.recur_chain_puyo(puyogrid, row, col, kind) " {{{
  let cnt = 0
  if a:kind isnot self.F
    for row in self.enable_range_of_field_height
      for col in self.enable_range_of_field_width
        if self.is_puyo(a:puyogrid.get(row, col))
          if a:puyogrid.get(row, col) is a:kind && row is a:row && col is a:col
            let cnt += 1
            call a:puyogrid.set(row, col, self.F)
          endif
          if a:puyogrid.get(row, col) is a:kind && row is a:row && col is a:col - 1
            let cnt += self.recur_chain_puyo(a:puyogrid, a:row, a:col - 1, a:kind)
          endif
          if a:puyogrid.get(row, col) is a:kind && row is a:row && col is a:col + 1
            let cnt += self.recur_chain_puyo(a:puyogrid, a:row, a:col + 1, a:kind)
          endif
          if a:puyogrid.get(row, col) is a:kind && row is a:row - 1 && col is a:col
            let cnt += self.recur_chain_puyo(a:puyogrid, a:row - 1, a:col, a:kind)
          endif
          if a:puyogrid.get(row, col) is a:kind && row is a:row + 1 && col is a:col
            let cnt += self.recur_chain_puyo(a:puyogrid, a:row + 1, a:col, a:kind)
          endif
        endif
      endfor
    endfor
  endif
  return cnt
endfunction " }}}
function! s:puyo_obj.chain_puyo() " {{{
  let chain_bonuses = [0, 8, 16, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 388, 416, 448, 480, 512]
  let connect_bonuses = [0,2,3,4,5,6,7,10,10,10,10,10,10,10,10,10,10,10]
  let color_bonuses = [0,3,6,12,24]

  let score = 0
  let chain_count = 0

  call self.drop_puyo()
  while 1
    let prev_ps = deepcopy(self.puyogrid)
    let curr_ps = deepcopy(prev_ps)
    let is_chained = 0

    " use score
    let total = 0
    let connect_bonus = 0
    let color_bonus = {}

    for row in self.enable_range_of_field_height
      for col in self.enable_range_of_field_width
        if self.is_puyo(curr_ps.get(row, col))
          let n = self.recur_chain_puyo(curr_ps, row, col, curr_ps.get(row, col))
          if 4 <= n
            let is_chained = 1
            let prev_ps = curr_ps

            let total += n
            let color_bonus[string(curr_ps.get(row, col))] = 1
            let connect_bonus += connect_bonuses[n - 4]
          endif
          let curr_ps = deepcopy(prev_ps)
        endif
      endfor
    endfor

    if is_chained
      let chain_count += 1
      let self.puyogrid = curr_ps
      let tmp = (chain_bonuses[chain_count-1] + connect_bonus + color_bonuses[len(keys(color_bonus))-1])
      let self.score += total * (tmp is 0 ? 1 : tmp ) * 10
      if 99999999 < self.score
        let self.score = 99999999
      endif
      sleep 700m
      call self.drop_puyo()
      let self.voice_text = get( self.chain_voices, chain_count-1, self.chain_voices[-1])
      let self.n_chain_count = chain_count

      call self.redraw()
    else
      call self.drop_puyo()
      call self.redraw()
      break
    endif
  endwhile

  " consume key strokes.
  while getchar(0)
  endwhile

  return chain_count
endfunction " }}}

function! s:puyo_obj.movable(dropping_puyos,row,col) " {{{
  " return -1 if gameover.
  " return 0 if can not move.
  " return 1 if can move.

  let is_gameover = 1
  for n in range(self.HIDDEN_ROW,self.field_height)
    if self.puyogrid.get(n, self.DROPPING_POINT) is self.F
      let is_gameover = 0
    endif
  endfor
  if is_gameover
    return -1
  endif

  " let &titlestring = string(a:dropping_puyos)

  for puyo in a:dropping_puyos
    if -1 is index(self.enable_range_of_field_height, puyo.row + a:row)
      return 0
    endif
    if -1 is index(self.enable_range_of_field_width, puyo.col + a:col)
      return 0
    endif

    if self.puyogrid.get(puyo.row + a:row, puyo.col + a:col) is self.F
      " continue
    elseif self.puyogrid.get(puyo.row + a:row, puyo.col + a:col) is self.W
      if self.HIDDEN_ROW <= puyo.row + a:row
        return 0
      endif
    else
      return 0
    endif
  endfor

  return 1
endfunction " }}}
function! s:puyo_obj.check(is_auto_drop) " {{{
  let status = self.movable(self.dropping2list(),1,0)
  if status is 0 && (a:is_auto_drop ? (self.floatting_count >= self.MAX_FLOATTING_COUNT) : 1)

    let self.voice_text = ''
    let self.n_chain_count = 0

    for x in self.dropping2list()
      call self.puyogrid.set(x.row, x.col, x.kind)
    endfor

    let self.dropping = self.next1
    let self.next1 = self.next2
    let self.next2 = self.next()

    while (self.chain_puyo())
    endwhile
  endif
endfunction " }}}
function! s:puyo_obj.turn_dropping(is_right) " {{{
  for child in self.dropping.children
    let state = [ child.row - self.dropping.pivot.row,
          \       child.col - self.dropping.pivot.col ]
    if     state == [ 0,-1]
      let child.row = self.dropping.pivot.row + (a:is_right ? -1 :  1)
      let child.col = self.dropping.pivot.col
    elseif state == [-1, 0]
      let child.row = self.dropping.pivot.row
      let child.col = self.dropping.pivot.col + (a:is_right ?  1 : -1)
    elseif state == [ 0, 1]
      let child.row = self.dropping.pivot.row + (a:is_right ?  1 : -1)
      let child.col = self.dropping.pivot.col
    elseif state == [ 1, 0]
      let child.row = self.dropping.pivot.row
      let child.col = self.dropping.pivot.col + (a:is_right ? -1 :  1)
    elseif state == [ 1, 1]
      let child.row = self.dropping.pivot.row + (a:is_right ?  1 : -1)
      let child.col = self.dropping.pivot.col + (a:is_right ? -1 :  1)
    elseif state == [ 1,-1]
      let child.row = self.dropping.pivot.row + (a:is_right ? -1 :  1)
      let child.col = self.dropping.pivot.col + (a:is_right ? -1 :  1)
    elseif state == [-1,-1]
      let child.row = self.dropping.pivot.row + (a:is_right ? -1 :  1)
      let child.col = self.dropping.pivot.col + (a:is_right ?  1 : -1)
    elseif state == [-1, 1]
      let child.row = self.dropping.pivot.row + (a:is_right ?  1 : -1)
      let child.col = self.dropping.pivot.col + (a:is_right ?  1 : -1)
    endif
  endfor
endfunction " }}}

function! s:puyo_obj.key_turn(is_right) " {{{
  let saved_dropping_puyos = deepcopy(self.dropping)

  try

    " turn
    call self.turn_dropping(a:is_right)
    if self.movable(self.dropping2list(),0,0)
      throw 1
    else
      let self.dropping = saved_dropping_puyos
    endif

    " move left and turn if right-side.
    call self.move_puyo(0,-1,self.dropping2list())
    call self.turn_dropping(a:is_right)
    if self.movable(self.dropping2list(),0,0)
      throw 1
    else
      let self.dropping = saved_dropping_puyos
    endif

    " move right and turn if left-side.
    call self.move_puyo(0,1,self.dropping2list())
    call self.turn_dropping(a:is_right)
    if self.movable(self.dropping2list(),0,0)
      throw 1
    else
      let self.dropping = saved_dropping_puyos
    endif

    " quick-turn
    call self.turn_dropping(a:is_right)
    call self.turn_dropping(a:is_right)
    if self.movable(self.dropping2list(),0,0)
      throw 1
    else
      let self.dropping = saved_dropping_puyos
    endif

  catch
    " do nothing
  finally
    let self.floatting_count += 1000
    if self.MAX_FLOATTING_COUNT < self.floatting_count
      call self.key_down()
      call self.check(0)
    endif
    call self.redraw()
  endtry
endfunction " }}}
function! s:puyo_obj.key_down() " {{{
  let status = self.movable(self.dropping2list(),1,0)
  if 0 is status
    let self.floatting_count = self.MAX_FLOATTING_COUNT
  else
    let status = self.move_puyo(1,0,self.dropping2list())
    if -1 is status
      let self.game_status = 'gameover'
    endif
    " reset
    let self.floatting_count = 0
    " consume key strokes.
    while getchar(0)
    endwhile
  endif
  call self.redraw()
endfunction " }}}
function! s:puyo_obj.key_quickdrop() " {{{
  while 1
    let status = self.move_puyo(1,0,self.dropping2list())
    if -1 is status
      let self.game_status = 'gameover'
      break
    elseif 0 is status
      break
    endif
  endwhile
  call self.redraw()
  " reset
  let self.floatting_count = 0
endfunction " }}}
function! s:puyo_obj.key_right() " {{{
  call self.move_puyo(0,1,self.dropping2list())
  let self.floatting_count += 1000
  if self.MAX_FLOATTING_COUNT < self.floatting_count
    call self.key_down()
  endif
  call self.redraw()
endfunction " }}}
function! s:puyo_obj.key_left() " {{{
  call self.move_puyo(0,-1,self.dropping2list())
  let self.floatting_count += 1000
  if self.MAX_FLOATTING_COUNT < self.floatting_count
    call self.key_down()
  endif
  call self.redraw()
endfunction " }}}
function! s:puyo_obj.key_pause() " {{{
  if self.game_status is# 'playing'
    let self.game_status = 'pausing'
  elseif self.game_status is# 'pausing'
    let self.game_status = 'playing'
  endif
  call self.redraw()
endfunction " }}}
function! s:puyo_obj.key_none() " {{{
  call self.redraw()
  " reset
  let self.floatting_count = 0
endfunction " }}}

function! s:puyo_obj.move_puyo(row,col,puyos) " {{{
  let status = self.movable(a:puyos,a:row,a:col)
  if status is 1
    for puyo in a:puyos
      let puyo.row += a:row
      let puyo.col += a:col
    endfor
  endif
  return status
endfunction " }}}

function! s:puyo_obj.dropping2list() " {{{
  return [self.dropping.pivot] + self.dropping.children
endfunction " }}}

function! s:puyo_obj.initialize(is_puyoteto, is_restart) " {{{
  let unix_p = has('unix') && ! has('mac')
  let windows_p = has('win95') || has('win16') || has('win32') || has('win64')
  let cygwin_p = has('win32unix')
  let mac_p = ! windows_p
        \ && ! cygwin_p
        \ && (
        \       has('mac')
        \    || has('macunix')
        \    || has('gui_macvim')
        \    || (  ! executable('xdg-open')
        \       && system('uname') =~? '^darwin'
        \       )
        \    )

  let imgs = puyo#dots#images()

  let self['clrs'] = puyo#dots#colors()
  let self['W'] = imgs.wall
  let self['F'] = imgs.field
  let self['wallpaper_puyo'] = imgs.wallpapers.defaut_puyo
  let self['wallpaper_puyoteto'] = imgs.wallpapers.defaut_puyoteto
  let self['numbers'] = [
        \ imgs.numbers.zero,
        \ imgs.numbers.one,
        \ imgs.numbers.two,
        \ imgs.numbers.three,
        \ imgs.numbers.four,
        \ imgs.numbers.five,
        \ imgs.numbers.six,
        \ imgs.numbers.seven,
        \ imgs.numbers.eight,
        \ imgs.numbers.nine,
        \ ]
  let self['puyo_colors'] = [
        \ imgs.puyos.red,
        \ imgs.puyos.blue,
        \ imgs.puyos.yellow,
        \ imgs.puyos.green,
        \ imgs.puyos.purple,
        \ ]
  let self['teto_colors'] = [
        \ imgs.teto.block1,
        \ imgs.teto.block2,
        \ ]
  let self['pause_chars'] = [
        \ imgs.alphabet.capital_p,
        \ imgs.alphabet.capital_a,
        \ imgs.alphabet.capital_u,
        \ imgs.alphabet.capital_s,
        \ imgs.alphabet.capital_e,
        \ ]
  let self['gameover_chars'] = [
        \ imgs.hiragana.ba,
        \ imgs.hiragana.ta,
        \ imgs.hiragana.nn,
        \ imgs.hiragana.ki,
        \ imgs.hiragana.lyu,
        \ imgs.hiragana.__,
        \ ]
  let self['chain_chars'] = [
        \ imgs.hiragana.re,
        \ imgs.hiragana.nn,
        \ imgs.hiragana.sa,
        \ ]

  let self['DROPPING_POINT'] = 3
  let self['HIDDEN_ROW'] = 2
  let self['MAX_FLOATTING_COUNT'] = 8000
  let self['floatting_count'] = 0

  " playing, gameover, pausing
  let self['game_status'] = 'playing'

  let self['field_width'] = a:is_puyoteto ? 8 : 6
  let self['field_height'] = a:is_puyoteto ? 13 : 13

  let height = self.field_height + self.HIDDEN_ROW + 1
  let width = self.field_width + 2

  let self['enable_range_of_field_width'] = range(1, self.field_width)
  let self['enable_range_of_field_height'] = range(0, self.field_height + self.HIDDEN_ROW - 1)

  let self['puyogrid'] = puyo#grid#new(height, width, [], self.F)

  for i in range(0, height - 1)
    call self.puyogrid.set(i,         0, self.W)
    call self.puyogrid.set(i, width - 1, self.W)
  endfor

  for i in range(0, width - 1)
    call self.puyogrid.set(height - 1, i, self.W)
  endfor


  let self['score'] = 0
  let self['filetype'] = 'puyo'
  let self['id'] = 0
  let self['n_chain_count'] = 0
  let self['is_puyoteto'] = a:is_puyoteto
  let self['voice_text'] = ''
  let self['number_of_colors'] = get(g:,'puyo#number_of_colors',4)
  let self['chain_voices'] = get(g:,'puyo#chain_voices',[
        \     'えいっ',
        \     'ファイヤー',
        \     'アイスストーム',
        \     'ダイアキュート',
        \     'ブレインダムド',
        \     'ジュゲム',
        \     'ばよえ～ん',
        \     ])
  if a:is_restart
    let self['backup'] = self['backup']
  else
    let self['backup'] = {
          \     'guifont' : &guifont,
          \     'list' : &list,
          \     'number' : &number,
          \     'spell' : &spell,
          \     'updatetime' : &updatetime,
          \     'maxfuncdepth' : &maxfuncdepth,
          \     'titlestring' : &titlestring,
          \     'columns' : &columns,
          \     'lines' : &lines,
          \     'wrap' : &wrap,
          \     'laststatus' : &laststatus,
          \ }
  endif

  let self['dropping'] = self.next()
  let self['next1'] = self.next()
  let self['next2'] = self.next()

  let &l:updatetime = get(g:,'puyo#updatetime',500)
  let &l:maxfuncdepth = 1000
  let &l:spell = 0
  let &l:wrap = 0
  let &l:number = 0
  let &l:list = 0
  let &l:laststatus = 0

  if exists('g:puyo#guifont')
    let &l:guifont = g:puyo#guifont
  elseif windows_p
    setlocal guifont=Consolas:h2:cSHIFTJIS
  elseif mac_p
    setlocal guifont=Menlo\ Regular:h5
  elseif unix_p
    setlocal guifont=Monospace\ 2
  else
  endif

  if has('gui_running')
    let &columns = 9999
    let &lines = 999
  endif
endfunction " }}}
function! s:puyo_obj.finalize() " {{{
  augroup Puyo
    autocmd!
  augroup END
  let &maxfuncdepth = self.backup.maxfuncdepth
  let &guifont = self.backup.guifont
  let &updatetime = self.backup.updatetime
  let &titlestring = self.backup.titlestring
  let &spell = self.backup.spell
  let &wrap = self.backup.wrap
  let &number = self.backup.number
  let &list = self.backup.list
  let &laststatus = self.backup.laststatus
  if has('gui_running')
    let &columns = self.backup.columns
    let &lines = self.backup.lines
  endif
endfunction " }}}

function! s:puyo_obj.autoevent() " {{{
  if &filetype is# self.filetype
    try
      if self.game_status is# 'playing'
        call self.key_down()
        call self.check(1)
      endif
    catch
    endtry
    call feedkeys(mode() is# 'i' ? "\<C-g>\<ESC>" : "g\<ESC>", 'n')
  else
    call self.finalize()
  endif
endfunction " }}}

function! s:puyo_obj.redraw_cui(field) " {{{
  let field = []
  for row_ in a:field
    let field += [map(deepcopy(row_),'puyo#dots#image2color_for_cui(v:val)')]
  endfor

  let rtn = []
  for row in field
    let rtn += [puyo#dots#substitute_for_syntax(row)]
  endfor

  if self.game_status is# 'gameover'
    let rtn[9] .= 'ばたんきゅー'
  else
    let rtn[9] .= printf('%d連鎖',self.n_chain_count)
  endif
  let rtn[11] .= 'score:' . printf('%08d',self.score)

  " let rtn += [self.voice_text]

  return rtn
endfunction " }}}
function! s:puyo_obj.redraw_gui(field) " {{{
  let field = a:field

  let n_chain_ary = []
  if 0 < self.n_chain_count
    for c in split(printf('%02d',self.n_chain_count),'\zs')
      let n_chain_ary += [ self.numbers[str2nr(c)] ]
    endfor
    let n_chain_ary += self.chain_chars
  endif

  let score_ary = []
  for c in split(printf('%08d',self.score),'\zs')
    let score_ary += [ self.numbers[str2nr(c)] ]
  endfor

  let field[8] += repeat([self.W],8)
  if self.game_status is# 'gameover'
    let field[9] += self.gameover_chars + repeat([self.W],8-len(self.gameover_chars))
  elseif self.game_status is# 'pausing'
    for i in range(0, len(self.pause_chars) - 1)
      let field[7][i + 1] = self.pause_chars[i]
    endfor
  else
    let field[9] += n_chain_ary + repeat([self.W],8-len(n_chain_ary))
  endif
  let field[10] += repeat([self.W],8)
  let field[11] += score_ary
  let field[12] += repeat([self.W],8)

  let test_field = []
  for row in field
    let data = map(deepcopy(row),'v:val()')
    let test_field += map(call(s:List.zip, data), 's:List.concat(v:val)')
  endfor

  " let wallpaper = self.is_puyoteto ? self.wallpaper_puyoteto() : self.wallpaper_puyo()
  " let row_idx = 0
  " for _row in wallpaper
  "   let col_idx = 0
  "   for dot in _row
  "     if test_field[self.HIDDEN_ROW * puyo#dots#height() + row_idx][1 * puyo#dots#width() + col_idx] is self.clrs.field.value
  "       let test_field[self.HIDDEN_ROW * puyo#dots#height() + row_idx][1 * puyo#dots#width() + col_idx] = dot
  "     endif
  "     let col_idx += 1
  "   endfor
  "   let row_idx += 1
  " endfor

  let rtn = []
  for row in test_field
    let rtn += [puyo#dots#substitute_for_syntax(row)]
  endfor

  let &titlestring = self.voice_text

  return rtn
endfunction " }}}
function! s:puyo_obj.redraw() " {{{
  let grid = self.puyogrid.clone()
  for x in self.dropping2list()
    call grid.set(x.row, x.col, x.kind)
  endfor
  let field = grid.get_data(self.F)

  for i in range(0,self.HIDDEN_ROW - 1)
    let field[i] = repeat([self.W], self.field_width + 2)
  endfor

  let next1 = [self.next1.pivot] + self.next1.children
  let next2 = [self.next2.pivot] + self.next2.children

  let field[1] += [self.W        ,self.W,self.W        ,self.W]
  let field[2] += [next1[0].kind ,self.W,self.W        ,self.W]
  let field[3] += [next1[1].kind ,self.W,next2[0].kind ,self.W]
  let field[4] += [self.W        ,self.W,next2[1].kind ,self.W]
  let field[5] += [self.W        ,self.W,self.W        ,self.W]

  if has('gui_running')
    let rtn = self.redraw_gui(field)
  else
    let rtn = self.redraw_cui(field)
  endif

  call puyo#buffer#uniq_open("[puyo]",rtn,"w")
  execute printf("%dwincmd w",puyo#buffer#winnr("[puyo]"))
  redraw
endfunction " }}}

function! s:puyo_obj.next_puyo() " {{{
  let pivot = {
        \   'id' : self.id,
        \   'row' : 0,
        \   'col' : self.DROPPING_POINT,
        \   'kind' : self.puyo_colors[ abs(s:Random.rand()) % self.number_of_colors ],
        \ }
  let children = [{
        \  'id' : self.id,
        \  'row' : pivot.row + 1,
        \  'col' : pivot.col + 0,
        \  'kind' : self.puyo_colors[ abs(s:Random.rand()) % self.number_of_colors ],
        \ }]
  let self.id += 1
  return { 'pivot' : pivot, 'children' : children }
endfunction " }}}
function! s:puyo_obj.next_teto() " {{{
  let i = abs(s:Random.rand()) % len(self.teto_colors)
  let pivot = {
        \   'id' : self.id,
        \   'row' : 0,
        \   'col' : self.DROPPING_POINT,
        \   'kind' : self.teto_colors[i],
        \ }
  let patturn = [
        \   [[1,0],[1,1],[0,-1]],
        \   [[1,0],[0,-1],[0,1]],
        \   [[1,0],[1,1],[0,1]],
        \ ] 
  let children = []
  for p in patturn[abs(s:Random.rand()) % len(patturn)]
    let children += [{
          \  'id' : self.id,
          \  'row' : pivot.row + p[0],
          \  'col' : pivot.col + p[1],
          \  'kind' : self.teto_colors[i],
          \ }]
  endfor
  let self.id += 1
  return { 'pivot' : pivot, 'children' : children }
endfunction " }}}
function! s:puyo_obj.next() " {{{
  if self.is_puyoteto && (abs(s:Random.rand()) % 2)
    return self.next_teto()
  else
    return self.next_puyo()
  endif
endfunction " }}}

function! s:puyo_obj.open(is_puyoteto) " {{{
  call puyo#buffer#uniq_open("[puyo]",[],"w")
  execute printf("%dwincmd w",puyo#buffer#winnr("[puyo]"))
  call self.initialize(a:is_puyoteto, 0)
  let &l:filetype = self.filetype
  only
  call self.redraw()
  return self
endfunction " }}}
function! s:puyo_obj.close() " {{{
  if &filetype is# self.filetype
    call self.finalize()
    bdelete!
  endif
endfunction " }}}
function! s:puyo_obj.sendkey(keyname) " {{{

  if a:keyname is# 'nop'
  elseif a:keyname is# 'quit'
    call self.close()
  elseif a:keyname is# 'restart'
    call self.initialize(self.is_puyoteto,1)

  elseif self.game_status is# 'playing'
    if a:keyname is# 'quickdrop'
      call self.key_quickdrop()
      call self.check(0)
    elseif a:keyname is# 'left'
      call self.key_left()
    elseif a:keyname is# 'right'
      call self.key_right()
    elseif a:keyname is# 'turnright'
      call self.key_turn(1)
    elseif a:keyname is# 'turnleft'
      call self.key_turn(0)
    elseif a:keyname is# 'down'
      call self.key_down()
      call self.check(0)
    elseif a:keyname is# 'pause'
      call self.key_pause()
    endif

  elseif self.game_status is# 'pausing'
    if a:keyname is# 'pause'
      call self.key_pause()
    endif

  endif
endfunction " }}}

function! puyo#new(...) " {{{
  let g:puyo_session = deepcopy(s:puyo_obj).open(0 < a:0 ? a:1 : 0)

  nnoremap <silent><buffer> i       :<C-u>call g:puyo_session.sendkey('nop')<cr>
  nnoremap <silent><buffer> a       :<C-u>call g:puyo_session.sendkey('nop')<cr>
  nnoremap <silent><buffer> I       :<C-u>call g:puyo_session.sendkey('nop')<cr>
  nnoremap <silent><buffer> A       :<C-u>call g:puyo_session.sendkey('nop')<cr>
  nnoremap <silent><buffer> j       :<C-u>call g:puyo_session.sendkey('down')<cr>
  nnoremap <silent><buffer> k       :<C-u>call g:puyo_session.sendkey('quickdrop')<cr>
  nnoremap <silent><buffer> h       :<C-u>call g:puyo_session.sendkey('left')<cr>
  nnoremap <silent><buffer> l       :<C-u>call g:puyo_session.sendkey('right')<cr>
  nnoremap <silent><buffer> z       :<C-u>call g:puyo_session.sendkey('turnleft')<cr>
  nnoremap <silent><buffer> x       :<C-u>call g:puyo_session.sendkey('turnright')<cr>
  nnoremap <silent><buffer> q       :<C-u>call g:puyo_session.sendkey('quit')<cr>
  nnoremap <silent><buffer> r       :<C-u>call g:puyo_session.sendkey('restart')<cr>
  nnoremap <silent><buffer> <space> :<C-u>call g:puyo_session.sendkey('pause')<cr>

  augroup Puyo
    autocmd!
    autocmd CursorHold,CursorHoldI * call g:puyo_session.autoevent()
  augroup END
endfunction " }}}

"  vim: set ts=2 sts=2 sw=2 ft=vim fdm=marker ff=unix :

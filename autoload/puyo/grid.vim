
let s:grid_obj = {}
function! s:grid_obj.get(row,col) " {{{
  if self.bounds_check(a:row,a:col)
    return self._data[(a:row)][(a:col)]
  else
    return self._out_of_bounds
  endif
endfunction " }}}
function! s:grid_obj.set(row,col,value) " {{{
  if self.bounds_check(a:row,a:col)
    let self._data[(a:row)][(a:col)] = a:value
  endif
endfunction " }}}
function! s:grid_obj.width() " {{{
  return self._width
endfunction " }}}
function! s:grid_obj.height() " {{{
  return self._height
endfunction " }}}
function! s:grid_obj.bounds_check(row,col) " {{{
  if a:row < 0 || self.height() <= a:row
    return 0
  endif
  if a:col < 0 || self.width() <= a:col
    return 0
  endif
  return 1
endfunction " }}}
function! s:grid_obj.data(data,default) " {{{
  let self['_data'] = []
  for _row in range(0,self.height()-1)
    let tmp = []
    for _col in range(0,self.width()-1)
      let tmp += [ get(get(a:data,_row,[]), _col, a:default) ]
    endfor
    let self['_data'] += [tmp]
  endfor
endfunction " }}}
function! s:grid_obj.get_data(default) " {{{
  let data = []
  for _row in range(0,self.height()-1)
    let row = []
    for _col in range(0,self.width()-1)
      let row += [ get(get(self._data,_row,[]), _col, a:default) ]
    endfor
    let data += [row]
  endfor
  return data
endfunction " }}}
function! s:grid_obj.clone() " {{{
  return deepcopy(self)
endfunction " }}}
function! s:grid_obj.swap(row1,col1,row2,col2) " {{{
  let Tmp = self.get(a:row1, a:col1)
  call self.set(a:row1, a:col1, self.get(a:row2, a:col2) )
  call self.set(a:row2, a:col2, Tmp )
endfunction " }}}
function! s:grid_obj.print() " {{{
  for row in range(0,self.height()-1)
    let str = ''
    for col in range(0,self.width()-1)
      let str .= self.get(row,col) . ', '
    endfor
    echo str
  endfor
endfunction " }}}
function! s:grid_obj.split(pred,default) " {{{
  let grid1 = puyo#grid#new(self.height(),self.width(),[],0)
  let grid2 = puyo#grid#new(self.height(),self.width(),[],0)
  for row in range(0,self.height()-1)
    for col in range(0,self.width()-1)
      let x = self.get(row,col)
      call grid1.set(row,col, (  a:pred(self,row,col) ? x : a:default) )
      call grid2.set(row,col, (! a:pred(self,row,col) ? x : a:default) )
    endfor
  endfor
  return [grid1,grid2]
endfunction " }}}
function! s:grid_obj.size(height,width) " {{{
  let self['_width'] = a:width
  let self['_height'] = a:height
endfunction " }}}

function! puyo#grid#new(height,width,data,default) " {{{
  let obj = deepcopy(s:grid_obj)
  let obj['_out_of_bounds'] = -1
  " initialize data
  call obj.size(a:height,a:width)
  call obj.data(a:data, a:default)
  return obj
endfunction " }}}


function! puyo#grid#is_overlap(grid1,grid2,default) " {{{
  for col in range(0,a:grid1.width()-1)
    for row in range(0,a:grid1.height()-1)
      if   a:grid1.get(row,col) isnot a:default
            \ && a:grid2.get(row,col) isnot a:default
        return 1
      endif
    endfor
  endfor
  return 0
endfunction " }}}
function! puyo#grid#hoge(teto,puyo,default) " {{{
  let out = a:teto.clone()
  let height = out.height()
  let width = out.width()
  for col in range(0,width-1)
    let i = height - 1
    for row in range(height-1,0,-1)
      if out.get(row,col) is a:default
        for x in range(i,0,-1)
          if a:puyo.get(row,x) isnot a:default
            call out.set(row,col,a:puyo.get(row,x))
            let i = x - 1
            break
          endif
        endfor
      endif
    endfor
  endfor
  return out
endfunction " }}}

function! s:pred(obj,row,col) " {{{
  let x = a:obj.get(a:row,a:col)
  return x is 2
endfunction " }}}

function! puyo#grid#test() " {{{
  let grid1 = puyo#grid#new(6,4,[
        \   [1,1,1,1],
        \   [1,1,1,1],
        \   [1,1,1,1],
        \   [1,2,2,2],
        \   [1,3,2,3],
        \   [1,1,5,6],
        \ ])
  let grid2 = puyo#grid#new(6,4,[
        \   [0,0,0,0],
        \   [0,2,0,0],
        \   [2,2,0,0],
        \   [2,0,0,0],
        \   [0,0,0,0],
        \   [0,0,0,0],
        \ ])
  let grid3 = puyo#grid#new(6,4,[
        \   [0,0,0,0],
        \   [0,0,0,0],
        \   [0,0,0,0],
        \   [0,0,0,0],
        \   [0,2,2,2],
        \   [0,0,2,0],
        \ ])
  let gs = grid1.split(function('s:pred'),0)
  " echo puyo#grid#is_overlap(gs[0],gs[1])
  " call gs[0].set(0,0,1)
  " echo puyo#grid#is_overlap(gs[0],gs[1])
  " call gs[0].print()
  " call gs[0].print()
  call puyo#grid#hoge(gs[1],grid3,0).print()
endfunction " }}}

" call puyo#grid#test()

"  vim: set ts=8 sts=2 sw=2 ft=vim fdm=marker ff=unix :

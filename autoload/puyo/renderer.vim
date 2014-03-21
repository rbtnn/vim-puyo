
scriptencoding utf-8

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"         =============
"          Puyo Layout
"         =============
"
" b:puyo_session.field_width(6)--------------------+
"                                                  |
"                                            +--+--+--+--+--+
"                                            |  |  |  |  |  |
"                                            v  v  v  v  v  v
"                                         0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
" s:HIDDEN_ROW(2)-+------------------> 0 [W][H][H][H][H][H][H][W]
"                 +------------------> 1 [W][H][H][H][H][H][H][W][W][W][W][W][W]
"                                +---> 2 [W][F][F][F][F][F][F][W][W][.][W][W][W]
"                                +---> 3 [W][F][F][F][F][F][F][W][W][.][W][.][W]
"                                +---> 4 [W][F][F][F][F][F][F][W][W][W][W][.][W]
"                                +---> 5 [W][F][F][F][F][F][F][W][W][W][W][W][W]
"                                +---> 6 [W][F][F][F][F][F][F][W]
"                                +---> 7 [W][F][F][F][F][F][F][W]
" b:puyo_session.field_width(13)-+---> 8 [W][F][F][F][F][F][F][W][W][W][W][W][W][W][W][W]
"                                +---> 9 [W][F][F][F][F][F][F][W][W][W][W][W][W][W][W][W]
"                                +--->10 [W][F][F][F][F][F][F][W][W][W][W][W][W][W][W][W]
"                                +--->11 [W][F][F][F][F][F][F][W][0][0][0][0][0][0][0][0]
"                                +--->12 [W][F][F][F][F][F][F][W][W][W][W][W][W][W][W][W]
"                                +--->13 [W][F][F][F][F][F][F][W]
"                                +--->14 [W][F][F][F][F][F][F][W]
"                                     15 [W][W][W][W][W][W][W][W]
"                                                  ^
"                                                  |
" s:DROPPING_POINT(3)------------------------------+
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! puyo#renderer#redraw(grid_obj) " {{{
  " a:grid_obj is a grid object whitch has 6 * 13 or 8 * 20 matrix.
  
endfunction " }}}
"  vim: set ts=2 sts=2 sw=2 ft=vim fdm=marker ff=unix :

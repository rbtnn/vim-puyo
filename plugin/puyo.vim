
let g:loaded_puyo = 1
function! s:start_game()
  try
    call game_engine#version()
    call puyo#start_game()
  catch '.*'
    throw 'Please install https://github.com/rbtnn/game_engine.vim'
  endtry
endfunction
command! -nargs=0 Puyo  :call <sid>start_game()


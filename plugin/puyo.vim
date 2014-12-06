
let g:loaded_puyo = 1
function! s:start_game()
  try
    call game_engine#version()
    try
      call puyo#start_game()
    catch '.*'
      call game_engine#exit_game()
      echohl Error
      echomsg v:exception
      echomsg v:throwpoint
      echohl None
    endtry
  catch '.*'
    echohl Error
    echomsg 'Please install https://github.com/rbtnn/game_engine.vim'
    echohl None
  endtry
endfunction
command! -nargs=0 Puyo  :call <sid>start_game()


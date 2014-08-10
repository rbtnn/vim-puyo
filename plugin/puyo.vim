
let g:loaded_puyo = 1
function! s:start_game()
  try
    call game_engine#version()
    call puyo#start_game()
  catch 'E117'
    throw 'Please install https://github.com/rbtnn/game_engine.vim'
  catch '\[game_engine.vim\]'
    echohl Error
    echomsg v:exception
    echohl None
  catch '.*'
    echohl Error
    echomsg v:exception
    echomsg v:throwpoint
    echohl None
  endtry
endfunction
command! -nargs=0 Puyo  :call <sid>start_game()


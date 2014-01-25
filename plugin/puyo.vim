

scriptencoding utf-8
"
if exists("g:loaded_puyo")
  finish
endif
let g:loaded_puyo = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists(":Puyo")
  command! -nargs=0 Puyo :call puyo#new()
endif
if !exists(":PuyoTeto")
  command! -nargs=0 PuyoTeto :call puyo#new(1)
endif

let &cpo = s:save_cpo
finish

"  vim: set ft=vim fdm=marker ff=unix :

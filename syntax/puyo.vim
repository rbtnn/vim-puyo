
if exists ("b:current_syntax")
    finish
endif

syntax match   puyoRed "@R"
syntax match   puyoGreen "@G"
syntax match   puyoBlue "@B"
syntax match   puyoYellow "@Y"
syntax match   puyoField "@F"
syntax match   puyoWall "@W"


highlight puyoRedHi  guifg=#FF0000 guibg=#FF0000 ctermfg=red ctermbg=red
highlight puyoGreenHi  guifg=#00FF00 guibg=#00FF00 ctermfg=green ctermbg=green
highlight puyoBlueHi  guifg=#0000FF guibg=#0000FF ctermfg=blue ctermbg=blue
highlight puyoYellowHi  guifg=#FFFF00 guibg=#FFFF00 ctermfg=yellow ctermbg=yellow
highlight puyoFieldHi  guifg=#DDDDDD guibg=#DDDDDD ctermfg=gray ctermbg=gray
highlight puyoWallHi  guifg=#333333 guibg=#333333 ctermfg=black ctermbg=black

hi def link puyoRed  puyoRedHi
hi def link puyoGreen  puyoGreenHi
hi def link puyoBlue  puyoBlueHi
hi def link puyoYellow  puyoYellowHi
hi def link puyoField  puyoFieldHi
hi def link puyoWall  puyoWallHi

let b:current_syntax = "puyo"


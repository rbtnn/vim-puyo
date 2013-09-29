if exists ("b:current_syntax")
    finish
endif

syntax match   puyoRed "@R"
syntax match   puyoGreen "@G"
syntax match   puyoBlue "@B"
syntax match   puyoYellow "@Y"
syntax match   puyoField "@F"
syntax match   puyoWall "@W"


highlight puyoRedHi  guifg=#FF0000 guibg=#FF0000
highlight puyoGreenHi  guifg=#00FF00 guibg=#00FF00
highlight puyoBlueHi  guifg=#0000FF guibg=#0000FF
highlight puyoYellowHi  guifg=#FFFF00 guibg=#FFFF00
highlight puyoFieldHi  guifg=#DDDDDD guibg=#DDDDDD
highlight puyoWallHi  guifg=#333333 guibg=#333333

hi def link puyoRed  puyoRedHi
hi def link puyoGreen  puyoGreenHi
hi def link puyoBlue  puyoBlueHi
hi def link puyoYellow  puyoYellowHi
hi def link puyoField  puyoFieldHi
hi def link puyoWall  puyoWallHi

let b:current_syntax = "puyo"


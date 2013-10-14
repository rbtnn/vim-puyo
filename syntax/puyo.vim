
if exists ("b:current_syntax")
    finish
endif

syntax match   puyoRed    "@R"
syntax match   puyoBlue   "@B"
syntax match   puyoYellow "@Y"
syntax match   puyoGreen  "@G"
syntax match   puyoPurple "@P"
syntax match   puyoField  "@F"
syntax match   puyoWall   "@W"
syntax match   puyoEye    "@2"
syntax match   puyoBlack  "@4"
syntax match   puyoWhite  "@3"


highlight puyoRedHi     guifg=#FF0000 guibg=#FF0000 ctermfg=red ctermbg=red
highlight puyoGreenHi   guifg=#00FF00 guibg=#00FF00 ctermfg=green ctermbg=green
highlight puyoBlueHi    guifg=#0000FF guibg=#0000FF ctermfg=blue ctermbg=blue
highlight puyoYellowHi  guifg=#FFFF00 guibg=#FFFF00 ctermfg=yellow ctermbg=yellow
highlight puyoPurpleHi  guifg=#8B008B guibg=#8B008B ctermfg=DarkMagenta ctermbg=DarkMagenta

highlight puyoFieldHi   guifg=#DDDDDD guibg=#DDDDDD ctermfg=gray ctermbg=gray
highlight puyoWallHi    guifg=#333333 guibg=#333333 ctermfg=black ctermbg=black
highlight puyoEyeHi     guifg=#000000 guibg=#000000 ctermfg=black ctermbg=black
highlight puyoBlackHi   guifg=#000000 guibg=#000000 ctermfg=black ctermbg=black
highlight puyoWhiteHi   guifg=#FFFFFF guibg=#FFFFFF ctermfg=white ctermbg=white

hi def link puyoRed     puyoRedHi
hi def link puyoGreen   puyoGreenHi
hi def link puyoBlue    puyoBlueHi
hi def link puyoYellow  puyoYellowHi
hi def link puyoPurple  puyoPurpleHi

hi def link puyoField  puyoFieldHi
hi def link puyoWall  puyoWallHi
hi def link puyoEye  puyoEyeHi
hi def link puyoWhite  puyoWhiteHi
hi def link puyoBlack  puyoBlackHi

let b:current_syntax = "puyo"


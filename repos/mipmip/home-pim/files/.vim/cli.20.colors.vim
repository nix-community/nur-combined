"execute 'colorscheme blue'
"let &t_ut='' "kitty kleuren probleem

"set t_Co=265

"let g:solarized_termtrans = 0 "0 | 1
"let g:solarized_termcolors = 256
"highlight SpecialKey term=bold cterm=bold ctermfg=251 ctermbg=230 guifg=Blue

"let g:solarized_termcolors= 16 "16 | 256
"let g:solarized_degrade = 1 "0 | 1
"let g:solarized_bold = 1 "1 | 0
"let g:solarized_underline = 1 " 1 | 0
"let g:solarized_italic = 1 "1 | 0
"let g:solarized_contrast = "normal"
"let g:solarized_visibility = "normal"

set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set background=light
colorscheme solarized8


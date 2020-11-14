let g:lightline = {}
let g:lightline.active = {}
let g:lightline.active.left = [ ['mode', 'paste'], ['readonly', 'filename', 'modified'] ]
let g:lightline.component = {}

com! Dosify set ff=dos

" Clipboard:
map gy "+y
map gp "+p
map gd "+d

" Tirar highlight da última pesquisa
noremap <C-n> :nohl<CR>

set encoding=utf-8 " Sempre usar utf-8 ao salvar os arquivos
set nu " Linhas numeradas
set showmatch " Highlight de parenteses e chaves
set path+=** " Busca recursiva

" Indentação
set autoindent " Mantem os niveis de indentação
set tabstop=4 " Tab de 4 espaços
set softtabstop=4
set shiftwidth=4
set shiftround
set expandtab " Tabs viram espaços
set list " Ilustra a identação

set nobackup " Desativar backup

set nocompatible " Desativando retrocompatibilidade com o vi
set mouse=a " Ativar mouse
set completeopt=menuone,noinsert,noselect " Customizações no menu de autocomplete, :help completeopt para mais info
" janela de preview que mostra algumas coisas dos comandos
" set completeopt+=preview " Ativa
set previewheight=3 " Altura máxima do preview
set winfixheight " Mantém

" Wildmenu: autocomplete para modo de comando
set wildmenu
set wildmode=list:longest,full

" Wildmenu: ignorar quem?
set wildignore+=*.pyc " Python
set wildignore+=*.o " C
set wildignore+=*.class " Java

syntax on " Ativa syntax highlight
filetype plugin on " Plugins necessitam disso
tab ball " Deixa menos bagunçado colocando um arquivo por aba


" Colorscheme:
" autocmd VimEnter * colorscheme onedark
" let g:lightline.colorscheme = 'wombat'
autocmd VimEnter * colorscheme embark
let g:lightline.colorscheme = 'embark'


" Echodoc: 
let g:echodoc#enable_at_startup=1
set noshowmode
let g:echodoc#type = "virtual"

" Startify:
" IndentLines:
" Commentary:
" Nix:

" Markdown
au! BufRead,BufNewFile *.markdown set filetype=mkd
au! BufRead,BufNewFile *.md       set filetype=mkd

" Disable conceallevel
autocmd VimEnter * set conceallevel=0

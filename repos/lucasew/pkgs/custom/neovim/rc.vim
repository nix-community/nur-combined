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

let mapleader=","

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
let g:dark_mode = 1
function! HandleTheming()
    if g:dark_mode
        colorscheme embark
    else
        colorscheme paper
    endif
endfunction

function! ToggleTheme()
    let g:dark_mode = !g:dark_mode
    call HandleTheming()
endfunction
autocmd VimEnter * call HandleTheming()
command! ThemeToggle call ToggleTheme()

" AutoPairs
let g:AutoPairsMultilineClose=0

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
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_fenced_languages = ['c++=cpp', 'viml=vim', 'bash=sh', 'ini=dosini']
let g:vim_markdown_math = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_new_list_item_indent = 1
let g:vim_markdown_no_extensions_in_markdown = 1

" Disable conceallevel
autocmd VimEnter * set conceallevel=0

" F-Sharp remapping
autocmd BufNewFile,BufRead *.fs,*.fsx,*.fsi set filetype=fsharp

" Fennel
let g:fennel_nvim_auto_init = v:false

" COQ
let g:coq_settings = { 'xdg': v:true, "keymap.recommended": v:true, "auto_start": "shut-up" }

" Omnifunc
set omnifunc=v:lua.vim.lsp.omnifunc

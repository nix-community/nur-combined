" Basic configuration {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use UTF-8
set encoding=utf-8
set fileencodings=utf-8

" Allow unsaved buffers when switching windows
set hidden

" Allow command completion in command-line
set wildmenu

" Enable syntax high-lighting and file-type specific plugins
syntax on
filetype plugin indent on

" Map leader to space (needs the noremap trick to avoid moving the cursor)
nnoremap <Space> <Nop>
let mapleader=" "

" Map localleader to '!' (if I want to filter text, I use visual mode)
let maplocalleader="!"
" }}}

" Indentation configuration {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use space by default
set expandtab
" Indent and align to 4 spaces by default
set shiftwidth=4
" -1 means the same as shiftwidth
set softtabstop=-1
" Always indent by multiples of shiftwidth
set shiftround
" You shouldn't change the default tab width of 8 characters
set tabstop=8
" }}}

" File parameters {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Disable swap files
set noswapfile
" Enable undo files
set undofile
" }}}

" UI and UX parameters {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set the minimal amount of lignes under and above the cursor for context
set scrolloff=5
" Always show status line
set laststatus=2
" Enable Doxygen highlighting
let g:load_doxygen_syntax=1
" Make backspace behave as expected
set backspace=eol,indent,start
" Use the visual bell instead of beeping
set visualbell
" Disable bell completely by resetting the visual bell's escape sequence
set t_vb=

" Color the 80th column
set colorcolumn=80
" Show whitespace
set list
" Show a tab as an arrow, trailing spaces as ¤, non-breaking spaces as dots
set listchars=tab:>─,trail:·,nbsp:¤

" Use patience diff
set diffopt+=algorithm:patience

" Don't redraw when executing macros
set lazyredraw

" Timeout quickly on shortcuts, I can't wait two seconds to delete in visual
set timeoutlen=500

" Timeout quickly for CursorHold events (and also swap file)
set updatetime=250

" Disable all mouse integrations
set mouse=

" Setup some overrides for gruvbox
lua << EOF
local gruvbox = require("gruvbox")
local colors = gruvbox.palette

gruvbox.setup({
    overrides = {
        -- Only URLs should be underlined
        ["@string.special.path"] = { link = "GruvboxOrange" },
        -- Revert back to the better diff highlighting
        DiffAdd = { fg = colors.green, bg = "NONE" },
        DiffChange = { fg = colors.aqua, bg = "NONE" },
        DiffDelete = { fg = colors.red, bg = "NONE" },
        DiffText = { fg = colors.yellow, bg = colors.bg0 },
        -- Directories "pop" better in blue
        Directory = { link = "GruvboxBlueBold" },
    },
    italic = {
        -- Comments should not be italic, for e.g: box drawing
        comments = false,
    },
})
EOF
" Use my preferred colorscheme
colorscheme gruvbox
" }}}

" Search parameters {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable search high-lighting while the search is on-going
set hlsearch
" Ignore case on search
set ignorecase
" Ignore case unless there is an uppercase letter in the pattern
set smartcase
" }}}

" Project-local settings {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Securely read `.nvim.lua` or `.nvimrc`.
set exrc
" }}}

" vim: foldmethod=marker

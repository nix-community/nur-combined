" Basic configuraion {{{
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
" Disable backups, we have source control for that
set nobackup
" Disable swapfiles too
set noswapfile
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

" Don't redraw when executing macros
set lazyredraw

" Timeout quickly on shortcuts, I can't wait two seconds to delete in visual
set timeoutlen=500

" Timeout quickly for CursorHold events (and also swap file)
set updatetime=250

" Set dark mode by default
set background=dark

" Include plug-in integration
let g:gruvbox_plugin_hi_groups=1
" Include filetype integration
let g:gruvbox_filetype_hi_groups=1
" 24 bit colors
set termguicolors
" Use my preferred colorscheme
colorscheme gruvbox8
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

" Import settings when inside a git repository {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let git_settings=system("git config --get vim.settings")
if strlen(git_settings)
    exe "set" git_settings
endif
" }}}

" vim: foldmethod=marker

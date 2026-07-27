set nocompatible

" Prevent nesting

if $NEOVIM == 'true'
	echo 'Nesting is disabled.'
	q!
endif
let $NEOVIM = 'true'

" Plugin polyglot (nix-plugin-manager and vim-plug)

if !empty(glob('~/.vim/autoload/plug.vim')) || !empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
	call plug#begin('~/.vim-plug')
	" Deoplete doesn't work in other installations I've tested,
	" unfortunately.
	" Plug 'Shougo/deoplete.nvim'
	Plug 'tpope/vim-vinegar'
	Plug 'tpope/vim-surround'
	Plug 'ctrlpvim/ctrlp.vim'
	Plug 'sheerun/vim-polyglot'
	Plug 'itchyny/lightline.vim'
	Plug 'easymotion/vim-easymotion'
	Plug 'ntpeters/vim-better-whitespace'
	Plug 'tpope/vim-commentary'
	Plug 'luochen1990/rainbow'
	Plug 'vim-pandoc/vim-pandoc-syntax'
	Plug 'rhysd/vim-clang-format'
	Plug 'drmikehenry/vim-headerguard'
	Plug 'rhysd/git-messenger.vim'
	call plug#end()
endif

" Swap and backup file directory

if !has('nvim')
	set directory=$HOME/.vim/swap//
	set backupdir=$HOME/.vim/backup//
	execute 'silent :!mkdir -p' shellescape(&directory)
	execute 'silent :!mkdir -p' shellescape(&backupdir)
endif

" File type extension registry

au BufNewFile,BufRead *.inc setlocal ft=cpp

" File type presets

autocmd FileType css :setlocal ts=4 sw=4
autocmd FileType c,cpp,cs,php,python,julia,Dockerfile :setlocal et ts=4 sw=4
autocmd FileType lisp,arduino,haskell,cabal,lua,typescript,javascript,json,html,xml,cmake :setlocal et ts=2 sw=2
autocmd FileType markdown,text,plaintex :setlocal foldcolumn=4 colorcolumn=79 textwidth=79 et ts=2 sw=2
autocmd FileType nix,plantuml :setlocal indentexpr=

" GUI and colors

set mouse=a guicursor= nu rnu noshowmode background=dark tabpagemax=999
hi Statement ctermfg=yellow
hi LineNr ctermfg=darkgrey
hi CursorLineNr ctermfg=grey
hi ColorColumn ctermbg=black
hi FoldColumn ctermbg=none
hi Pmenu ctermbg=darkgrey
hi MatchParen cterm=bold ctermbg=darkgrey ctermfg=none
hi gitmessengerPopupNormal term=None ctermfg=255 ctermbg=234

" Keyboard mappings

nmap <C-w> :w<CR>
nmap <C-q> :q<CR>
nmap <C-j> :CF<CR>
imap <C-w> <ESC>:w<CR>i
imap <C-q> <ESC>:q<CR>
imap <C-b> <ESC>diwi
tnoremap <Esc> <C-\><C-n>
vnoremap p "_dP

for dirkey in ['h', 'j', 'k', 'l']
	execute 'nnoremap <A-' . dirkey . '> <C-w>' . dirkey
	execute 'inoremap <A-' . dirkey . '> <ESC><C-w>' . dirkey . 'i'
	execute 'tnoremap <A-' . dirkey . '> <C-\><C-n><C-w>' . dirkey . 'i'
endfor

" Searching

set ignorecase smartcase

" CtrlP

let g:ctrlp_regexp = 1
set wildignore+=*/venv/*

" EasyMotion

let g:EasyMotion_do_mapping = 0 " Disable default mappings
nmap W <Plug>(easymotion-w)
nmap B <Plug>(easymotion-b)

" Autocomplete

let g:deoplete#enable_at_startup = 1
let g:deoplete#on_insert_enter = 0
autocmd VimEnter * call deoplete#custom#option('max_list', 7)

" Enable markdown section folding without the line characters.
let g:markdown_folding = 1
autocmd FileType markdown :setlocal foldcolumn=0 numberwidth=7

" Clang-Format

let g:clang_format#code_style = 'llvm'

" Rainbow parentheses

let g:rainbow_conf = {
\	'separately': {
\		'*': 0,
\		'lisp': {
\			'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
\			'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
\			'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
\		}
\	}
\}
let g:rainbow_active = 1

" Status bar

let g:lightline = {
\	'active': {
\		'left': [ [ 'mode', 'paste' ],
\			  [ 'readonly', 'buffername', 'modified' ] ],
\		'right': [ [ 'lineinfo' ], [ 'percent' ],
\			   [ 'fileformat', 'fileencoding', 'filetype', 'totallines' ] ],
\	},
\	'inactive':{
\		'left': [ [ 'buffername' ] ],
\		'right': [ [ 'lineinfo' ], [ 'percent' ] ]
\	},
\	'component': {
\		'totallines': '%{line("$")}L',
\	},
\	'component_function': {
\		'buffername': 'BufName',
\	},
\}

let g:bufname_cache = {}
function BufName()
	let name = expand('%:p')
	if !has_key(g:bufname_cache, name)
		if name == ''
			let g:bufname_cache[name] = '[new]'
		elseif name =~ 'term:\/\/'
			let g:bufname_cache[name] = expand('%:t')
		else
			let parts = split(name, '/')
			let homeparts = split($HOME, '/')
			let nhparts = len(homeparts)

			let ishome = parts[:nhparts - 1] == homeparts

			if ishome
				call remove(parts, 0, nhparts - 1)
				call insert(parts, '~')
			endif

			let nparts = len(parts)
			let shortparts = []

			for part in parts
				if strpart(part, 0, 1) == '.'
					call add(shortparts, strpart(part, 0, 2))
				else
					call add(shortparts, strpart(part, 0, 1))
				endif
			endfor

			let shortparts[nparts - 1] = parts[nparts - 1]

			let g:bufname_cache[name] = (ishome ? '' : '/') . join(shortparts, '/')
		endif
	endif
	return g:bufname_cache[name]
endfunction

" Auto-load changes from disk

if !exists('g:CheckUpdateStarted')
    let g:CheckUpdateStarted = 1
    call timer_start(1, 'CheckUpdate')
endif
function! CheckUpdate(timer)
    silent! checktime
    call timer_start(1000, 'CheckUpdate')
endfunction

" Commands

command Term :belowright new | :terminal
command CF :ClangFormat
command CFA :bufdo execute ':CF' | w
command CH :HeaderguardAdd
command QE :%bd|e#
command C :w | :execute 'silent :!compiler' shellescape(bufname('%')) '&'
command CO :w | :execute 'silent :!compiler' shellescape(bufname('%')) '--open' '&'

" Misc functions

function Chomp(str)
	return substitute(a:str, '\n\+$', '', '')
endfunction

function TempPath(...)
	let ext = (a:0 >= 1) ? a:1 : fnamemodify(bufname('%'), ':e')
	let random = Chomp(system('bash -c "echo \$RANDOM"'))
	return '/tmp/' . random . '.' . ext
endfunction

" Workaround: Disable clipboard support until wl-clipboard
" doesn't create new windows with wlroots compositors.

if !empty($WAYLAND_DISPLAY)
	let g:clipboard = {
		  \   'name': 'myClipboard',
		  \   'copy': {
		  \      '+': ':',
		  \      '*': ':',
		  \    },
		  \   'paste': {
		  \      '+': ':',
		  \      '*': ':',
		  \   },
		  \   'cache_enabled': 1,
		  \ }
endif

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
	call plug#end()
endif

" Filetype extension registery

au BufNewFile,BufRead *.inc setlocal ft=cpp

" Lazy plugins

autocmd FileType lisp :packadd rainbow | :RainbowToggleOn
autocmd FileType c,cpp :packadd vim-clang-format | :packadd vim-headerguard
autocmd FileType markdown :packadd vim-pandoc-syntax


" Autocomplete

let g:deoplete#enable_at_startup = 1
let g:deoplete#on_insert_enter = 0
let g:deoplete#max_list = 7


" Disable clipboard support until wl-clipboard doesn't create new
" windows with wlroots compositors.

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


" GUI and colors

set mouse=a guicursor= nu rnu noshowmode background=dark tabpagemax=999
highlight Statement ctermfg=yellow
highlight LineNr ctermfg=darkgrey
highlight CursorLineNr ctermfg=grey
highlight ColorColumn ctermbg=black
highlight FoldColumn ctermbg=none
highlight Pmenu ctermbg=darkgrey
highlight MatchParen cterm=bold ctermbg=darkgrey ctermfg=none


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


" EasyMotion

let g:EasyMotion_do_mapping = 0 " Disable default mappings
nmap W <Plug>(easymotion-w)
nmap B <Plug>(easymotion-b)


" Searching

set ignorecase smartcase

" File type presets

autocmd FileType lisp,arduino,haskell,cabal,cpp,lua,typescript :setlocal et ts=2 sw=2
autocmd FileType cs,php,Dockerfile :setlocal ts=4 sw=4 et
autocmd FileType markdown,text,plaintex :setlocal foldcolumn=4 colorcolumn=79 textwidth=79 et ts=2 sw=2
autocmd FileType nix,plantuml :setlocal indentexpr=


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
\			   [ 'fileformat', 'fileencoding', 'filetype', "totallines" ] ],
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

" Clang-Format

let g:clang_format#code_style = "llvm"

" Commands

command Term :belowright new | :terminal
command Upload :call UploadBuffer()
command Pan :call Pandoc()
command CF :ClangFormat
command CFA :bufdo execute ":CF" | w
command CH :HeaderguardAdd
command C :w | :execute 'silent :!compiler' bufname('%') '&'
command CO :w | :execute 'silent :!compiler' bufname('%') '--open' '&'

function UploadBuffer()
	let sourcepath = TempPath()
	execute 'w' fnameescape(sourcepath)
	execute 'silent :!upload' fnameescape(sourcepath)
	execute 'silent :!rm' fnameescape(sourcepath)
endfunction


" Misc functions

function Chomp(str)
	return substitute(a:str, '\n\+$', '', '')
endfunction

function TempPath(...)
	let ext = (a:0 >= 1) ? a:1 : fnamemodify(bufname('%'), ':e')
	let random = Chomp(system('bash -c "echo \$RANDOM"'))
	return '/tmp/' . random . '.' . ext
endfunction

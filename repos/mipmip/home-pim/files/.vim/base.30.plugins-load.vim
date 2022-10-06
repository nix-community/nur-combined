call plug#begin('~/.vim/plugged')

" MY PLUGINS
"Plug 'mipmip/vim-fluid'
"Plug 'mipmip/vim-petra'
Plug 'mipmip/vim-hotpop'
Plug 'mipmip/panelmanager.vim'
Plug 'mipmip/vim-show-in-filemanager', { 'branch': 'main' }
Plug 'mipmip/vim-open-mip', { 'branch': 'main' }

if filereadable($HOME."/.i-am-second-brain")
  Plug 'mipmip/vim-scimark'
  Plug 'linden-project/linny.vim'
  "Plug 'mipmip/linny-wikitag-github'

  " writing
  Plug 'junegunn/goyo.vim'
  Plug 'reedes/vim-pencil'
  Plug 'vim-voom/VOoM'

  Plug 'tyru/open-browser.vim'

  " MARKDOWN/YAML/ETC
  Plug 'aserebryakov/vim-todo-lists'
  Plug 'dhruvasagar/vim-table-mode'
"  Plug 'pedrohdz/vim-yaml-folds'

  " SNIPPETS
  if v:version >= 800 && (has('python') || has('python3'))
    Plug 'SirVer/ultisnips'
    " Snippets are separated from the engine. Add this if you want them:
    Plug 'honza/vim-snippets'
  endif

endif

" VIM IDE & TWEAKS
"Plug 'vifm/vifm.vim'
Plug 'airblade/vim-rooter'
Plug 'vim-scripts/delview'
Plug 'vim-airline/vim-airline'
Plug 'scrooloose/nerdtree'
Plug 'skywind3000/asyncrun.vim'
"Plug 'severin-lemaignan/vim-minimap'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
"Plug 'vim-syntastic/syntastic'
Plug 'editorconfig/editorconfig-vim'
"Plug 'majutsushi/tagbar'
"Plug 'simnalamburt/vim-mundo'
"Plug 'junkblocker/git-time-lapse'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-eunuch'
"Plug 'jpalardy/vim-slime', { 'branch': 'main' }

" VIM TEXT TOOLS
Plug 'bronson/vim-trailing-whitespace'
Plug 'junegunn/vim-easy-align'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-surround'
"Plug 'thiagoalessio/rainbow_levels.vim'
Plug 'vim-scripts/argtextobj.vim'
Plug 'scrooloose/nerdcommenter'


" SPECIAL PURPOSE TOOLS
"Plug 'hrj/vim-DrawIt'
"Plug 'stevearc/vim-arduino'
"Plug 'christoomey/vim-tmux-navigator'

" SYNTAX FILES
Plug 'fatih/vim-go'
Plug 'LnL7/vim-nix'
Plug 'posva/vim-vue'
"Plug 'elmar-hinz/vim.typoscript'
Plug 'hashivim/vim-terraform'
Plug 'vim-ruby/vim-ruby'
Plug 'evanleck/vim-svelte'
Plug 'cakebaker/scss-syntax.vim'

Plug 'pangloss/vim-javascript'
Plug 'maxmellon/vim-jsx-pretty'

Plug 'rhysd/vim-crystal'
"Plug 'arrufat/vala.vim'
Plug 'leafgarland/typescript-vim'
Plug 'groenewege/vim-less'
Plug 'chr4/nginx.vim'
Plug 'ledger/vim-ledger'

Plug 'ap/vim-css-color'
"Plug 'RRethy/vim-hexokinase'

"Plug 'morhetz/gruvbox'
"
"Plug 'gko/vim-coloresque'
"Plug 'elzr/vim-json'
"Plug 'ruby-formatter/rufo-vim'
"Plug 'kchmck/vim-coffee-script'
"Plug 'lumiliet/vim-twig'
"Plug 'mboughaba/i3config.vim'

" SPELLING
Plug 'rhysd/vim-grammarous'

" COLORS
"Plug 'altercation/vim-colors-solarized'
Plug 'lifepillar/vim-solarized8'

"Plug 'vim-scripts/Cleanroom'
"Plug 'sonph/onehalf', { 'rtp': 'vim' }
Plug 'logico/typewriter-vim'
Plug 'mipmip/vim-whitewriter', { 'branch': 'main' }

"Plug 'pbrisbin/vim-colors-off', { 'branch': 'main' }


call plug#end()



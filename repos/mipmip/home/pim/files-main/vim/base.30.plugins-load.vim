call plug#begin('~/.vim/plugged')

  Plug 'mipmip/panelmanager.vim'
  Plug 'mipmip/vim-hotpop',                     { 'branch': 'main' }

if filereadable($HOME."/.i-am-second-brain")

  " MY PLUGINS
  Plug 'mipmip/vim-fluid'
  Plug 'mipmip/vim-run-in-blender'
  Plug 'mipmip/vim-whitewriter',                { 'branch': 'main' }
  Plug 'mipmip/vim-petra'

  Plug 'mipmip/linny-wikitag-github'
  Plug 'linden-project/linny.vim',              { 'branch': 'main' }

  Plug 'mipmip/vim-show-in-filemanager',        { 'branch': 'main' }
  Plug 'mipmip/vim-open-mip',                   { 'branch': 'main' }

  Plug 'mipmip/vim-scimark'
  Plug 'git@github.com:mipmip/vim-nomisa.git',  { 'branch': 'main' }

  " OTHER DESKTOP PLUGINS

  Plug 'junegunn/goyo.vim'
  Plug 'reedes/vim-pencil'
  Plug 'vim-voom/VOoM'
  Plug 'tyru/open-browser.vim'
  Plug 'dhruvasagar/vim-table-mode'
  Plug 'SidOfc/mkdx'
  Plug 'https://git.sr.ht/~soywod/himalaya-vim'

  " SNIPPETS
  if v:version >= 800 && (has('python') || has('python3'))
    Plug 'SirVer/ultisnips'
    " Snippets are separated from the engine. Add this if you want them:
    Plug 'honza/vim-snippets'
  endif

endif

"" VIM IDE & TWEAKS
Plug 'airblade/vim-rooter'
Plug 'vim-scripts/delview'
Plug 'itchyny/lightline.vim'
Plug 'scrooloose/nerdtree'
Plug 'mcchrish/nnn.vim'
Plug 'skywind3000/asyncrun.vim'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-eunuch'
Plug 'bkad/camelcasemotion'
Plug 'szw/vim-maximizer'

" VIM TEXT TOOLS
Plug 'bronson/vim-trailing-whitespace'
Plug 'junegunn/vim-easy-align'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/argtextobj.vim'

" SYNTAX FILES
Plug 'smerrill/vcl-vim-plugin'
Plug 'fatih/vim-go'
Plug 'LnL7/vim-nix'
Plug 'hashivim/vim-terraform'
Plug 'vim-ruby/vim-ruby'
Plug 'evanleck/vim-svelte',  { 'branch': 'main' }

Plug 'cakebaker/scss-syntax.vim'
Plug 'rodjek/vim-puppet'
Plug 'google/vim-jsonnet'

Plug 'pangloss/vim-javascript'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'leafgarland/typescript-vim'

Plug 'rhysd/vim-crystal'
Plug 'nickel-lang/vim-nickel', { 'branch': 'main' }
Plug 'groenewege/vim-less'
Plug 'chr4/nginx.vim'
Plug 'ledger/vim-ledger'

Plug 'ap/vim-css-color'

" SPELLING
Plug 'rhysd/vim-grammarous'

" COLORS
Plug 'lifepillar/vim-solarized8'
Plug 'logico/typewriter-vim'

" ----------------off
"Plug 'vifm/vifm.vim'
"Plug 'severin-lemaignan/vim-minimap'
"Plug 'vim-syntastic/syntastic'
"Plug 'majutsushi/tagbar'
"Plug 'simnalamburt/vim-mundo'
"Plug 'junkblocker/git-time-lapse'
"Plug 'jpalardy/vim-slime', { 'branch': 'main' }
"Plug 'thiagoalessio/rainbow_levels.vim'
"Plug 'scrooloose/nerdcommenter'
"Plug 'hrj/vim-DrawIt'
"Plug 'stevearc/vim-arduino'
"Plug 'christoomey/vim-tmux-navigator'
"Plug 'posva/vim-vue'
"Plug 'elmar-hinz/vim.typoscript'
"Plug 'vmchale/dhall-vim'
"Plug 'arrufat/vala.vim'
"Plug 'RRethy/vim-hexokinase'
"Plug 'morhetz/gruvbox'
"Plug 'gko/vim-coloresque'
"Plug 'elzr/vim-json'
"Plug 'ruby-formatter/rufo-vim'
"Plug 'kchmck/vim-coffee-script'
"Plug 'lumiliet/vim-twig'
"Plug 'mboughaba/i3config.vim'
"Plug 'vim-scripts/Cleanroom'
"Plug 'sonph/onehalf', { 'rtp': 'vim' }
"Plug 'altercation/vim-colors-solarized'
"Plug 'pbrisbin/vim-colors-off', { 'branch': 'main' }
"Plug 'vim-airline/vim-airline'

call plug#end()



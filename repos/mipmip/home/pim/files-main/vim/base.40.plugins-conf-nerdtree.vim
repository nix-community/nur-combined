"autocmd! AuNERDTreeCmd FocusGained
let NERDTreeShowBookmarks=1
let NERDTreeShowHidden=1
let NERDTreeIgnore = ['^\.DS_Store$', '\.dat.nosync', '\.swp', '\.repl_history', '\.cxx', '\.cxx_parameters' ]
let NERDTreeChDirMode=2
"let g:NERDTreeWinSize=50
let NERDTreeAutoDeleteBuffer = 1
let NERDTreeMinimalUI = 1

function! VimInNerdTree()
  call panelmanager#PMPrepareToggleView('nerdtree')
  exe 'NERDTree' $HOME ."/.vim/vimrc"
  call panelmanager#PMSetCurrentViewForIdentifier('nerdtree')
endfunction


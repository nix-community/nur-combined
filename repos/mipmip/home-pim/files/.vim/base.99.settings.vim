set nocompatible " be iMproved
set belloff=all                   " No bell

filetype plugin on
syntax enable                     " Turn on syntax highlighting allowing local overrides

set nonumber                      " Show line numbers
set ruler                         " Show line and column number
set encoding=utf-8                " Set default encoding to UTF-8
set nowrap                        " don't wrap lines
set tabstop=2                     " a tab is two spaces
set shiftwidth=2                  " an autoindent (with <<) is two spaces
set expandtab                     " use spaces, not tabs
set backspace=indent,eol,start    " backspace through everything in insert mode

set list                          " Show invisible characters
set listchars=""                  " Reset the listchars
"set listchars=tab:\>\            " a tab should display as "  ", trailing whitespace as "."
set listchars=tab:·\ ,trail:.
"set listchars+=trail:.            " show trailing spaces as dots
set listchars+=extends:>          " The character to show in the last column when wrap is
                                  " off and the line continues beyond the right of the screen
set listchars+=precedes:<         " The character to show in the last column when wrap is
                                  " off and the line continues beyond the left of the screen

set hlsearch    " highlight matches
"set incsearch   " incremental searching
set ignorecase  " searches are case insensitive...
set smartcase   " ... unless they contain at least one capital letter

set undofile " Maintain undo history between sessions
set undodir=~/.vim_temp/undodir

filetype plugin indent on " Turn on filetype plugins (:help filetype-plugin)
au FileType python setlocal tabstop=4 shiftwidth=4

"" Wild settings
set wildignore+=*.o,*.out,*.obj,.git,*.rbc,*.rbo,*.class,.svn,*.gem
set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz
set wildignore+=*/vendor/gems/*,*/vendor/cache/*,*/.bundle/*,*/.sass-cache/*
set wildignore+=*/tmp/librarian/*,*/.vagrant/*,*/.kitchen/*,*/vendor/cookbooks/*
set wildignore+=*/tmp/cache/assets/*/sprockets/*,*/tmp/cache/assets/*/sass/*
set wildignore+=*.swp,*~,._*

"" Backup and swap files
set backupdir^=~/.vim_temp/_backup//,/tmp    " where to put backup files.
set directory^=~/.vim_temp/_temp//,/tmp      " where to put swap files.
set viewdir=~/.vim_temp/views

"" Hoofdletter w mag nu ook gebruikt worden om op te slaan
cnoreabbrev W w

set autoread
au CursorHold * checktime
set autowriteall
set nobackup

set linebreak

set nofoldenable

" add yaml stuffs
"au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml foldmethod=indent
"autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

"au! BufNewFile,BufReadPost *.{md, markdown} set filetype=markdown foldmethod=indent

augroup remember_folds
  autocmd!
  au BufWinLeave *.{md,yaml,yml} mkview
  au BufWinEnter *.{md,yaml,yml} silent! loadview
augroup END

"augroup remember_folds
"  autocmd!
"  autocmd BufWinLeave * mkview
"  autocmd BufWinEnter * silent! loadview
"augroup END

let $PYTHONUNBUFFERED=1

" void-packages template file
autocmd BufNewFile,BufRead template set ft=sh sts=0 sw=0 noet

function DetectGoHtmlTmpl()
    if search("{{") != 0
        set filetype=gohtmltmpl
    endif
endfunction

augroup filetypedetect
    au! BufRead,BufNewFile *.{html,json} call DetectGoHtmlTmpl()
augroup END

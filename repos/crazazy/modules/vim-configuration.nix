{ config, pkgs, ... }:
let
  myVim = pkgs.vim_configurable.customize {
    name = "vi";
    vimrcConfig.customRC = ''
      "
      " A (not so) minimal vimrc.
      "

      " You want Vim, not vi. When Vim finds a vimrc, 'nocompatible' is set anyway.
      " We set it explicitely to make our position clear!
      set nocompatible

      filetype plugin indent on  " Load plugins according to detected filetype.
      syntax on                  " Enable syntax highlighting.

      set autoindent             " Indent according to previous line.
      set expandtab              " Use spaces instead of tabs.
      set softtabstop =4         " Tab key indents by 4 spaces.
      set shiftwidth  =4         " >> indents by 4 spaces.
      set shiftround             " >> indents to next multiple of 'shiftwidth'.

      set backspace   =indent,eol,start  " Make backspace work as you would expect.
      set hidden                 " Switch between buffers without having to save first.
      set laststatus  =2         " Always show statusline.
      set display     =lastline  " Show as much as possible of the last line.
      set relativenumber         " Show line numbers relative to the cursor

      set showmode               " Show current mode in command-line.
      set showcmd                " Show already typed keys when more are expected.

      set incsearch              " Highlight while searching with / or ?.
      set hlsearch               " Keep matches highlighted.

      set ttyfast                " Faster redrawing.
      set lazyredraw             " Only redraw when necessary.

      set splitright             " Open new windows right of the current window.

      set wrapscan               " Searches wrap around end-of-file.
      set report      =0         " Always report changed lines.

      set list                   " Show non-printable characters.
      if has('multi_byte') && &encoding ==# 'utf-8'
        let &listchars = 'tab:▸ ,extends:❯,precedes:❮,nbsp:±'
      else
        let &listchars = 'tab:> ,extends:>,precedes:<,nbsp:.'
      endif
      " use <tab> for trigger completion and navigate to the next complete item
      function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~ '\s'
      endfunction

      inoremap <silent><expr> <Tab>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<Tab>" :
            \ coc#refresh()
    '';
    vimrcConfig.packages.myVimPackage = with pkgs.vimPlugins; {
      start = [
        vim-polyglot
        coc-nvim
        coc-css
        coc-emmet
        coc-html
        coc-java
        coc-json
        coc-lists
        coc-prettier
        coc-python
        coc-r-lsp
        coc-tslint
        coc-tsserver
        coc-vetur
        coc-vimtex
        coc-wxml
      ];
    };
  };
in
{
  environment.systemPackages = [ myVim ];
}

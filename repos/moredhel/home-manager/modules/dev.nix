{ config, pkgs, lib, ... }:
with lib;

let
  cfg = config.programs.dev;
in {
  options.programs.dev = with types; {
    enable = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
  # TODO: figure out why Emacs is not working properly...
  programs.emacs = {
    enable = true;
    extraPackages = (epkgs: (with epkgs.melpaStablePackages; [
      company
      counsel
      flycheck
      ivy
      magit
      projectile
      use-package
    ]));
  };

  programs.vim = {
    enable = true;
    plugins = [
      "typescript-vim"
      "vim-airline"
      "ultisnips"
      "vim-snippets"
      "nerdtree"
      "vim-better-whitespace"
      "fugitive"
    ];
    settings = {
      ignorecase = true;
      background = "dark";
      expandtab = true;
      history = 700;
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      smartcase = true;
      tabstop = 2;

    };
    extraConfig = ''
      " leader bindings
      let mapleader=" "
      nnoremap <leader>w :w<enter>
      nnoremap <leader>pd :NERDTreeToggle<enter>

      " airline
      let g:airline#extensions#tabline#enabled = 1

      " ultisnips
      let g:UltiSnipsExpandTrigger="<tab>"
      let g:UltiSnipsJumpForwardTrigger="<c-n>"
      let g:UltiSnipsJumpBackwardTrigger="<c-p>"

      " vim-better-whitespace
      highlight ExtraWhitespace ctermbg=red
      let g:better_whitespace_enabled=1
      let g:strip_whitespace_on_save=1

      " legacy
      set fileformat=unix
      set encoding=utf-8
      set scrolloff=5
      set timeoutlen=100
      set nowildmenu
      autocmd FileType text set spell
      autocmd Filetype html setlocal ts=2 sts=2 sw=2
      autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
      autocmd Filetype javascript setlocal ts=4 sts=4 sw=4
      au BufRead,BufNewFile *.coffee set filetype=ruby
      au BufRead,BufNewFile *.jinja set filetype=jinja
      " runtime /usr/share/vim/vim72/syntax/syntax.vim " TODO: fixme
      syntax on
      " set sts=2
      set hls
      set undolevels=700
      set shiftround
      set nobackup
      set noswapfile
      set laststatus=1

      " allow backspacing over everything in insert mode
      set backspace=indent,eol,start
      set incsearch   " do incremental searching
      map Q gq
      inoremap <C-U> <C-G>u<C-U>
      set autoindent    " always set autoindenting on

      " moving between panes
      map <c-j> <c-w>j
      map <c-k> <c-w>k
      map <c-l> <c-w>l
      map <c-h> <c-w>h
      set foldmethod=indent
      set showmatch " Show matching braces.
    '';

  };
  };
}

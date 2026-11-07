{ config, lib, ... }:
{
  options.programs.ideavim.enable = lib.mkEnableOption "Weather to enable ideavim config for Jetbrains IDEs ideavim plugin";
  config = lib.mkIf config.programs.ideavim.enable {
    xdg.configFile = {
      "ideavim/ideavimrc".text = ''
        set clipboard=unnamedplus
        set history=10000
        set hlsearch
        set ignorecase
        set iskeyword+=-
        set incsearch
        set matchpairs=(:),{:},[:]
        set maxmapdepth=1000
        set more
        set nrformats=bin,hex
        set number
        set relativenumber
        set scrolljump=1
        set scrolloff=8
        set selection=inclusive
        set showcmd
        set showmode
        set sidescroll=1
        set sidescrolloff=8
        set smartcase
        set timeout
        set timeoutlen=100
        set undolevels=1000
        set visualbell
        set wrapscan
        set ideajoin

        let mapleader = " "

        set highlightedyank
        set NERDTree

        nnoremap Y y$
        vnoremap p "_dP
        imap <C-v> <Esc><Action>($Paste)i
        vmap <C-c> <Action>($Copy)<Esc>
        nmap <leader>/ <Action>(Find)
        nmap <C-w>q <Action>(CloseContent)
      '';
    };
  };
}

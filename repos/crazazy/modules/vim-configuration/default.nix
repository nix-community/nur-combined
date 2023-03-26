{ config, pkgs, ... }:
let
  js = (import ../../pkgs { inherit pkgs; }).js;
  myVim = pkgs.neovim.override {
    viAlias = true;
    configure.customRC = builtins.readFile ./vimrc;
    configure.packages.myVimPackage = with pkgs.vimPlugins; {
      start = [
        vim-polyglot
        coc-nvim
        LanguageClient-neovim
        emmet-vim
        # coc-css
        # coc-emmet
        # coc-html
        # coc-java
        # coc-json
        # coc-lists
        # coc-prettier
        # coc-python
        # coc-r-lsp
        # coc-tslint
        # coc-tsserver
        # coc-vetur
        # coc-vimtex
        # coc-wxml
      ];
    };
    withNodeJs = true;
  };
in
{

  environment.systemPackages = [
    myVim
    pkgs.python-lsp-server
    js.typescript
  ];
  environment.variables.EDITOR = "nvim";
}

{ config, pkgs, ... }:
let
  myVim = pkgs.neovim.override {
    viAlias = true;
    configure.customRC = builtins.readFile ./vimrc;
    configure.packages.myVimPackage = with pkgs.vimPlugins; {
      start = [
        vim-polyglot
        coc-nvim
        LanguageClient-neovim
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
  environment.systemPackages = [ myVim ];
  environment.variables.EDITOR = "nvim";
}

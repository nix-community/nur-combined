{ config, lib, pkgs, pkgs-2211, unstable, ... }:

{
  environment.sessionVariables = {
    EDITOR = "vim";
  };

  environment.systemPackages = with pkgs; [

    ctags
    sc-im

    git-sync
    gitFull


    #language servers
    sqls
    gopls
    #rnix-lsp
    unstable.nixd
    marksman
    terraform-ls
    nodePackages.bash-language-server
    sumneko-lua-language-server


    unstable.neovim
    unstable.nil
    unstable.tree-sitter

    rust-analyzer
    cargo
    rustc
    vscode-langservers-extracted
    nodejs

    sox

    # Language Server Dependencies
#nodePackages.pyright
    nodePackages.tailwindcss

    # Formatters
    nixfmt-classic
    rustfmt
    nodePackages.prettier

    ruby # for Linny
  ];
}

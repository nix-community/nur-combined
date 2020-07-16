{ config, lib, pkgs, options,
home, modulesPath
}:

with lib;

let
  cfg = config.myvim;
  MyVimConfig = pkgs.callPackage ./../pkgs/MyVimConfig { };
  vim-async = with pkgs.vimUtils; pkgs.callPackage ./../pkgs/vim-async {
    inherit buildVimPluginFrom2Nix;
  };
  vim-asyncomplete = with pkgs.vimUtils; pkgs.callPackage ./../pkgs/vim-asyncomplete {
    inherit buildVimPluginFrom2Nix;
  };
  vim-asyncomplete-lsp = with pkgs.vimUtils; pkgs.callPackage ./../pkgs/vim-asyncomplete-lsp {
    inherit buildVimPluginFrom2Nix;
  };
  vim-lsp = with pkgs.vimUtils; pkgs.callPackage ./../pkgs/vim-lsp {
    inherit buildVimPluginFrom2Nix vim-async;
  };
  vim-lsp-settings = with pkgs.vimUtils; pkgs.callPackage ./../pkgs/vim-lsp-settings {
    inherit buildVimPluginFrom2Nix vim-async vim-lsp vim-asyncomplete vim-asyncomplete-lsp;
  };
  vim-myftplugins = with pkgs.vimUtils; pkgs.callPackage ./../pkgs/vim-myftplugins {
    inherit buildVimPluginFrom2Nix;
  };
  vim-vala = with pkgs.vimUtils; pkgs.callPackage ./../pkgs/vim-vala {
    inherit buildVimPluginFrom2Nix;
  };
in 
{

  options.myvim = {
    enable = mkEnableOption "My vim config from https://github.com/SCOTT-HAMILTON/vimconfig";
  };
  config = mkIf cfg.enable (mkMerge ([
    {
      programs.vim.enable = true;
      programs.vim.extraConfig = builtins.readFile "${MyVimConfig}/vimrc";
      programs.vim.plugins = [
        pkgs.vimPlugins.commentary
        pkgs.vimPlugins.vim-colorschemes
        pkgs.vimPlugins.vim-qml
        vim-myftplugins
        vim-lsp
        vim-lsp-settings
        vim-vala
      ];
    }
  ]));
}

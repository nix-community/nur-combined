{ MyVimConfig
, kotlin-vim
, vim-lsp
, vim-lsp-settings
, vim-myftplugins
, vim-super-retab
, vim-vala
}:
{ config, lib, pkgs, options,
home, modulesPath, specialArgs
}:
with lib;

let
  cfg = config.myvim;
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
        pkgs.vimPlugins.vim-abolish
        pkgs.vimPlugins.commentary
        pkgs.vimPlugins.vim-colorschemes
        pkgs.vimPlugins.vim-qml
        kotlin-vim
        vim-lsp
        vim-lsp-settings
        vim-myftplugins
        vim-super-retab
        vim-vala
      ];
    }
  ]));
}

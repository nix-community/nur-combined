{ config, pkgs, ...}:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.useGlobalPkgs = true;

  home-manager.users.root = {
    programs.zsh = {
      enable = true;
      autocd = true;
      enableAutosuggestions = false;

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins=["git" "tmux" "docker" "python" "vi-mode" "systemd" ];
      };
    };

    programs.vim = {
      enable = true;
      settings = {
        relativenumber = false;
        number = false;
      };
      plugins = with pkgs.vimPlugins; [
        vim-nix
      ];
    };
  };


}

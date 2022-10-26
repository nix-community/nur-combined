{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;
  home.username = "pim";
  home.homeDirectory = "/home/pim";
  home.stateVersion = "22.05";

  imports = [
    /home/pim/nixos/home-pim/files-main

    /home/pim/nixos/home-pim/programs/fzf.nix
    /home/pim/nixos/home-pim/programs/git.nix
    /home/pim/nixos/home-pim/programs/tmux.nix
    /home/pim/nixos/home-pim/programs/vim.nix
    /home/pim/nixos/home-pim/programs/zsh.nix
  ];
}

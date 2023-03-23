{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;
  home.username = "pim";
  home.homeDirectory = "/home/pim";
  home.stateVersion = "22.05";

  imports = [
    /home/pim/nixos/home-manager/files-main
    /home/pim/nixos/home-manager/programs/fzf.nix
    /home/pim/nixos/home-manager/programs/git.nix
    /home/pim/nixos/home-manager/programs/tmux.nix
    /home/pim/nixos/home-manager/programs/vim.nix
    /home/pim/nixos/home-manager/programs/zsh.nix
  ];
}

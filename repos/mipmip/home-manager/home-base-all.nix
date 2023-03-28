{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;
  home.username = "pim";
  home.homeDirectory = "/home/pim";
  home.stateVersion = "22.05";

  imports = [
    ./files-main
    ./programs/fzf.nix
    ./programs/git.nix
    ./programs/tmux.nix
    ./programs/vim.nix
    ./programs/zsh.nix
  ];
}

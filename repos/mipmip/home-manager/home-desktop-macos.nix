{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;
  home.username = "pim";
  home.homeDirectory = "/Users/pim";
  home.stateVersion = "22.05";

  imports = [
    /Users/pim/nixos/home-manager/files-main
    /Users/pim/nixos/home-manager/files-macos
    /Users/pim/nixos/home-manager/programs/fzf.nix
    /Users/pim/nixos/home-manager/programs/git.nix
    /Users/pim/nixos/home-manager/programs/tmux.nix
    /Users/pim/nixos/home-manager/programs/macos-bundle.nix
    /Users/pim/nixos/home-manager/programs/vim.nix
    /Users/pim/nixos/home-manager/programs/zsh.nix
  ];


}

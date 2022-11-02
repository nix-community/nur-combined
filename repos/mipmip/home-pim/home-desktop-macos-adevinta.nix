{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;
  home.username = "pim";
  home.homeDirectory = "/Users/pim";
  home.stateVersion = "22.05";

  imports = [
    /Users/pim.snel/nixos/home-pim/files-main
    /Users/pim.snel/nixos/home-pim/files-macos
    /Users/pim.snel/nixos/home-pim/files-secondbrain
    /Users/pim.snel/nixos/home-pim/programs/fzf.nix
    /Users/pim.snel/nixos/home-pim/programs/git.nix
    /Users/pim.snel/nixos/home-pim/programs/tmux.nix
    /Users/pim.snel/nixos/home-pim/programs/macos-bundle.nix
    /Users/pim.snel/nixos/home-pim/programs/vim.nix
    /Users/pim.snel/nixos/home-pim/programs/zsh.nix
  ];


}

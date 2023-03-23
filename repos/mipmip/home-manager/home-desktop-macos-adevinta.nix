{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;
  home.username = "pim.snel";
  home.homeDirectory = "/Users/pim.snel";
  home.stateVersion = "22.05";

  imports = [
    /Users/pim.snel/nixos/home-manager/files-main
    /Users/pim.snel/nixos/home-manager/files-macos
    /Users/pim.snel/nixos/home-manager/files-secondbrain
    /Users/pim.snel/nixos/home-manager/files-i-am-desktop
    /Users/pim.snel/nixos/home-manager/programs/fzf.nix
    /Users/pim.snel/nixos/home-manager/programs/git.nix
    /Users/pim.snel/nixos/home-manager/programs/tmux.nix
    /Users/pim.snel/nixos/home-manager/programs/macos-bundle.nix
    /Users/pim.snel/nixos/home-manager/programs/vim.nix
    /Users/pim.snel/nixos/home-manager/programs/zsh.nix
    /Users/pim.snel/nixos/home-manager/programs/zsh_macos_adevinta.nix

    /Users/pim.snel/nixos/private/adevinta/home-manager/files-main
  ];


}

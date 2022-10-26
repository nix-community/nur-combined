{ config, pkgs, ... }:

{

  imports = [
    ../modules/base-minimal.nix
    ../modules/common-pkg.nix
    ../modules/crystal-dev.nix
    ../modules/texlive.nix
    ../modules/vim-large.nix
    ../modules/workstation-pkg.nix
  ];

  environment.systemPackages = with pkgs; [
  ];

  programs.zsh.enable = true;

  system.stateVersion = 4;
}


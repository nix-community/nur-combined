{ pkgs, ... }:

{
  imports = [
    ../common/alacritty.nix
  ];

  programs.alacritty.enable = true;
}

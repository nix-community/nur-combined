{ config, lib, pkgs, ... }: {
  imports = [
    ./fonts.nix
    ./gnome.nix
    ./zsh.nix
  ];
}
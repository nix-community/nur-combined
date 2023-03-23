{ lib, ... }:

{
  imports = [
    ./dconf-gnome-desktop.nix
    ./dconf-gnome-shell.nix
    ./gnome-shell-extensions.nix
  ];
}

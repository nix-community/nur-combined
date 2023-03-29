{ lib, ... }:

{
  imports = [
    ./gnome-desktop.nix
    ./gnome-shell.nix
    ./ext-init.nix
  ];
}

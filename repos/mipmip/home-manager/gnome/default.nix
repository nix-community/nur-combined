{ lib, ... }:

{
  imports = [
    ./desktop.nix
    ./desktop-shortcuts.nix
    ./shell.nix
    ./shell-ext.nix
  ];
}

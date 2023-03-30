{ lib, ... }:

{
  imports = [
    ./desktop.nix
    ./shell.nix
    ./shell-ext.nix
  ];
}

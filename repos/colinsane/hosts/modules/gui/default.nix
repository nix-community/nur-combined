{ lib, config, ... }:

let
  inherit (lib) mkDefault mkIf mkOption types;
  cfg = config.sane.gui;
in
{
  imports = [
    ./gnome.nix
    ./phosh.nix
    ./plasma.nix
    ./plasma-mobile.nix
    ./sway.nix
  ];
}

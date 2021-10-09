{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  vim-noctu = pkgs.callPackage ./pkgs/vim-noctu { };
  comma = pkgs.callPackage ./pkgs/comma { };
  minicava = pkgs.callPackage ./pkgs/minicava { };
  pass-wofi = pkgs.callPackage ./pkgs/pass-wofi { };
  swayfader = pkgs.callPackage ./pkgs/swayfader { };
  # Need I2C support on NixOS before this is useful
  # argononed = pkgs.callPackage ./pkgs/argononed { };
}

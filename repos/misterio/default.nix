{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  comma = pkgs.callPackage ./pkgs/comma { };
  minicava = pkgs.callPackage ./pkgs/minicava { };
  pass-wofi = pkgs.callPackage ./pkgs/pass-wofi { };
  rustlings = pkgs.callPackage ./pkgs/rustlings { };
  swayfader = pkgs.callPackage ./pkgs/swayfader { };
  # Need I2C support on NixOS before this is useful
  argononed = pkgs.callPackage ./pkgs/argononed { };
}

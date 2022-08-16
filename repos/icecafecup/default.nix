{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  fcitx5-nord = pkgs.callPackage ./pkgs/fcitx5-nord { };
  watt-toolkit = pkgs.callPackage ./pkgs/watt-toolkit { };
  apple-fonts = pkgs.callPackage ./pkgs/apple-fonts { };
}

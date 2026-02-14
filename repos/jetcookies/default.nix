# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  dectalk = pkgs.callPackage ./pkgs/dectalk { };
  x4-xmldiff = pkgs.callPackage ./pkgs/x4-xmldiff { };
  rime-lmdg = pkgs.callPackage ./pkgs/rime-lmdg { };
  v2dat = pkgs.callPackage ./pkgs/v2dat { };
  pico-fido = pkgs.callPackage ./pkgs/pico-fido { };
  picoforge = pkgs.callPackage ./pkgs/picoforge { };
  typewords = pkgs.callPackage ./pkgs/typewords { };
  libtinycbor = pkgs.callPackage ./pkgs/libtinycbor { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}

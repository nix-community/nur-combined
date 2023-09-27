# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  vivado-2017-4-1 = pkgs.callPackage ./pkgs/vivado-2017-4-1 { };
  vivado-2017-4 = pkgs.callPackage ./pkgs/vivado-2017-4 { };
  sweet-theme = pkgs.callPackage ./pkgs/sweet-theme { };
  utterly-round-plasma-style =
    pkgs.callPackage ./pkgs/utterly-round-plasma-style { };
  utterly-sweet-plasma-theme =
    pkgs.callPackage ./pkgs/utterly-sweet-plasma-theme { };
  #example-package = pkgs.callPackage ./pkgs/example-package { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}

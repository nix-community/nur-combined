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

  act = pkgs.callPackage ./pkgs/act { };
  case-cli = pkgs.callPackage ./pkgs/case-cli { };
  deck = pkgs.callPackage ./pkgs/deck { };
  hexo-cli = pkgs.callPackage ./pkgs/hexo-cli { };
  kong-portal-cli = pkgs.callPackage ./pkgs/kong-portal-cli { };
  nuclei = pkgs.callPackage ./pkgs/nuclei { };
  ov = pkgs.callPackage ./pkgs/ov { };
  spruce = pkgs.callPackage ./pkgs/spruce { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}

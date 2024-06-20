# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { }, ... }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  listen1 = pkgs.callPackage ./pkgs/listen1 { };
  idris2 = pkgs.callPackage ./pkgs/idris2 { };
  idris2-pack = pkgs.callPackage ./pkgs/idris2-pack { };
  postman = pkgs.callPackage ./pkgs/postman { };
  anytype = pkgs.callPackage ./pkgs/anytype { };
  pinentry-rbw = pkgs.callPackage ./pkgs/pinentry-rbw { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}

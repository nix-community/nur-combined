# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  neovim-gtk = pkgs.callPackage ./pkgs/neovim-gtk { };
  avr8-burn-omat = pkgs.callPackage ./pkgs/avr8-burn-omat { };
  simulavr = pkgs.callPackage ./pkgs/simulavr { };
  
  python36Packages = pkgs.python36Packages.callPackage ./pkgs/python-pkgs { };
  
  python37Packages = pkgs.recurseIntoAttrs (
    pkgs.python37Packages.callPackage ./pkgs/python-pkgs { }
  );

  python3Packages = python37Packages;
  SpriteSheetPacker = pkgs.qt5.callPackage ./pkgs/SpriteSheetPacker { };
  # example-package = pkgs.callPackage ./pkgs/example-package { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}


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

  # hyfetch = pkgs.callPackage ./pkgs/hyfetch { }; Nixpkgs 有了
  
  # hmcl-bin = pkgs.callPackage ./pkgs/hmcl-bin { }; Nixpkgs 也有了
  MoeKoeMusic = pkgs.callPackage ./pkgs/MoeKoeMusic { };
  # devtools-riscv64 = pkgs.callPackage ./pkgs/devtools-riscv64 { }; 坏了
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}

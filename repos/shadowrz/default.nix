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

  kose-font = pkgs.callPackage ./pkgs/kose-font { };
  adw-gtk3 = pkgs.callPackage ./pkgs/adw-gtk3 { };
  sddm-lain-wired-theme = pkgs.callPackage ./pkgs/sddm-lain-wired-theme { };
  sddm-sugar-candy = pkgs.callPackage ./pkgs/sddm-sugar-candy { };
  mkxp-z = pkgs.callPackage ./pkgs/mkxp-z { };
  rvpacker = pkgs.callPackage ./pkgs/rvpacker { };
  klassy = pkgs.libsForQt5.callPackage ./pkgs/klassy { };
}

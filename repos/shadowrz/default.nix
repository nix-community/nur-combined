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
  sddm-lain-wired-theme = pkgs.callPackage ./pkgs/sddm-lain-wired-theme { };
  sddm-sugar-candy = pkgs.callPackage ./pkgs/sddm-sugar-candy { };
  klassy = pkgs.libsForQt5.callPackage ./pkgs/klassy { };
  # Iosevka Builds
  iosevka-minoko = pkgs.callPackage ./pkgs/iosevka-minoko { };
  iosevka-aile-minoko = pkgs.callPackage ./pkgs/iosevka-aile-minoko { };
  iosevka-minoko-e = pkgs.callPackage ./pkgs/iosevka-minoko-e { };
  iosevka-minoko-term = pkgs.callPackage ./pkgs/iosevka-minoko-term { };
}

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
  hmModules = import ./modules/home-manager; # Home Manager modules
  overlays = import ./overlays; # nixpkgs overlays

  # Packages
  dosage = pkgs.callPackage ./pkgs/dosage {};
  exercise-timer = pkgs.callPackage ./pkgs/exercise-timer {};
  jogger = pkgs.callPackage ./pkgs/jogger {};
  my-gnu-health = pkgs.callPackage ./pkgs/my-gnu-health {};
  upscaler = pkgs.callPackage ./pkgs/upscaler {};
  vvmd = pkgs.callPackage ./pkgs/vvmd {};
  vvmplayer = pkgs.callPackage ./pkgs/vvmplayer {};
}

# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  potracer = pkgs.python3Packages.callPackage ./pkgs/potracer { };
in
{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  bb-imager = pkgs.callPackage ./pkgs/bb-imager-rs { withGui = true; };
  bb-imager-cli = pkgs.callPackage ./pkgs/bb-imager-rs { withGui = false; };
  cst = pkgs.callPackage ./pkgs/cst { };
  inherit potracer;
  supernote-tool = pkgs.python3Packages.callPackage ./pkgs/supernote-tool { inherit potracer; };
  trigger = pkgs.callPackage ./pkgs/trigger { };
}

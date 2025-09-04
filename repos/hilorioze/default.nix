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

  rtl8852cu = pkgs.linuxPackages.callPackage ./pkgs/rtl8852cu { };
  gpu-screen-recorder-notification = pkgs.callPackage ./pkgs/gpu-screen-recorder-notification { };
  gpu-screen-recorder-ui = pkgs.callPackage ./pkgs/gpu-screen-recorder-ui { };
}

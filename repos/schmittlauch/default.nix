# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  lolcommits = pkgs.callPackage ./pkgs/lolcommits { mplayer = mplayerV4l; };
  mplayerV4l = pkgs.mplayer.override { v4lSupport = true; };
  vollkorn = pkgs.callPackage ./pkgs/vollkorn { };
  numptyphysics = pkgs.callPackage ./pkgs/numptyphysics { };
}

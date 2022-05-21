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

  dtn7-go = pkgs.callPackage ./pkgs/dtn7-go/stable.nix { };
  dtn7-go-unstable = pkgs.callPackage ./pkgs/dtn7-go/unstable.nix { };

  dtn7-rs = pkgs.callPackage ./pkgs/dtn7-rs { };
}

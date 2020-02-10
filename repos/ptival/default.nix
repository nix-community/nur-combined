# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Not sure how to override `coqPackages`, so these are defined at the top-level
  coq-extensible-records = pkgs.callPackage ./pkgs/coq/coq-extensible-records {};
  coq-plugin-lib         = pkgs.callPackage ./pkgs/coq/coq-plugin-lib {};

  meslo-nerd-powerlevel10k = pkgs.callPackage ./pkgs/meslo-nerd-powerlevel10k {};
}

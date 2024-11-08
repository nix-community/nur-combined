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

  misans = pkgs.callPackage ./pkgs/misans { };
  hmcl-bin = pkgs.callPackage ./pkgs/hmcl-bin { };
  qq = pkgs.callPackage ./pkgs/qq { };
  fluent-cursors-theme = pkgs.callPackage ./pkgs/fluent-cursors-theme { };
  # caddy-with-plugins = pkgs.callPackage ./pkgs/caddy-with-plugins { };
}

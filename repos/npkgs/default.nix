# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import /nix/var/nix/profiles/per-user/root/channels/nixos-unstable {} }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # package listing begins here
  pista = pkgs.callPackage ./pkgs/pista { };
  xcursorlocate = pkgs.callPackage ./pkgs/xcursorlocate { };
  delta = pkgs.callPackage ./pkgs/delta { };
  motd = pkgs.callPackage ./pkgs/motd { };
  shlide = pkgs.callPackage ./pkgs/shlide { };
  isostatic = pkgs.callPackage ./pkgs/isostatic { };
}


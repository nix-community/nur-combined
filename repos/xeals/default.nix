# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs) lib;

  autoPackages = lib.pipe ./pkgs [
    builtins.readDir
    builtins.attrNames
    (map (pkg: {
      name = pkg;
      value = pkgs.callPackage "${./pkgs}/${pkg}/package.nix" { };
    }))
    builtins.listToAttrs
  ];
in

autoPackages //
{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
}

# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:

let
  modules = import ./modules;
in
{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  inherit modules; # modules
  overlays = import ./overlays; # nixpkgs overlays

  # ... as well as `xxxModules`, see: https://github.com/nix-community/NUR/pull/1101
  flakeModules = modules.flake;
  homeModules = modules.homeManager;
  nixosModules = modules.nixos;
}
// import ./packages.nix { inherit pkgs; }

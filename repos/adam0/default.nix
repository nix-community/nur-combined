# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}, ...}: let
  inherit (pkgs) lib;

  normalizePackage = v:
    if lib.isDerivation v
    then v
    else if builtins.isAttrs v && v ? default && lib.isDerivation v.default
    then v.default
    else v;

  discoveredPackages = lib.filesystem.packagesFromDirectoryRecursive {
    inherit (pkgs) callPackage newScope;
    directory = ./pkgs;
  };

  allPackages = lib.filterAttrs (_: lib.isDerivation) (
    lib.mapAttrs (_: normalizePackage) discoveredPackages
  );
in
  {
    # The `lib`, `modules`, and `overlays` names are special
    lib = import ./lib {inherit pkgs;}; # functions
    modules = import ./modules; # NixOS modules
    overlays = import ./overlays; # nixpkgs overlays
    hmModules = import ./hm-modules; # Home Manager modules.

    yaziPlugins = lib.recurseIntoAttrs (pkgs.callPackage ./pkgs/yazi/plugins {});
  }
  // allPackages

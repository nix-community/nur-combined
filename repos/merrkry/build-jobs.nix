{ pkgs }:

let
  inherit (pkgs) lib;
  nurLib = import ./lib { inherit pkgs; };

  packages = lib.filterAttrs (_: lib.isDerivation) (import ./default.nix { inherit pkgs; });

  buildablePackages = lib.filterAttrs (_: nurLib.isBuildable) packages;
in
lib.recurseIntoAttrs buildablePackages

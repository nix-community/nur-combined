{ pkgs }:

let
  inherit (pkgs) lib;
  nurLib = import ./lib { inherit pkgs; };

  packages = nurLib.getPackages (import ./default.nix { inherit pkgs; });

  buildablePackages = lib.filterAttrs (_: nurLib.isBuildable) packages;
in
lib.recurseIntoAttrs buildablePackages

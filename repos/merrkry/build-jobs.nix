{ pkgs }:

let
  inherit (pkgs) lib;
  nurLib = import ./lib { inherit pkgs; };

  repository = import ./default.nix { inherit pkgs; };
  packages = nurLib.getPackages repository;

  buildablePackages = lib.filterAttrs (_: nurLib.isBuildable) packages;
in
lib.recurseIntoAttrs (buildablePackages // { inherit (repository) repo-sources; })

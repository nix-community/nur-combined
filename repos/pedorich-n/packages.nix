{
  pkgs,
  lib ? pkgs.lib,
}:
lib.filesystem.packagesFromDirectoryRecursive {
  inherit (pkgs) callPackage;
  directory = ./pkgs;
}

{
  pkgs,
  lib ? pkgs.lib,
  ...
}:
lib.packagesFromDirectoryRecursive {
  inherit (pkgs) callPackage;
  directory = ./by-path;
}

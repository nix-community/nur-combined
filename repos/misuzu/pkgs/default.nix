{ pkgs }:
let
  scope = pkgs.lib.filesystem.packagesFromDirectoryRecursive {
    callPackage = pkgs.newScope scope;
    directory = ./by-name;
  };
in
scope

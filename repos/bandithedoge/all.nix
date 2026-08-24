{ pkgs }:
let
  all = pkgs.lib.packagesFromDirectoryRecursive {
    callPackage = callPackage';
    directory = ./pkgs;
  };

  callPackage' =
    pkg: args:
    pkgs.lib.recurseIntoAttrs (
      pkgs.lib.callPackageWith ((pkgs.lib.recursiveUpdate pkgs all) // { inherit callPackage'; }) pkg args
    );
in
all

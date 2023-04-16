{ pkgs, lib, callPackage }:

let
  filterFiles =
    lib.filterAttrs (name: value: value == "regular" && name != "default.nix");
  files = lib.attrNames (filterFiles (builtins.readDir ./.));
  fileMap = file: import (./. + "/${file}") { inherit pkgs lib callPackage; };
in lib.foldr lib.recursiveUpdate { } (map fileMap files)

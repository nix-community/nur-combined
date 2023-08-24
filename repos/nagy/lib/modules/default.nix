{ pkgs, lib, callPackage }:

{
  modules =
    let
      filterFiles = lib.filterAttrs (name: _: name != "default.nix");
      files = lib.attrNames (filterFiles (builtins.readDir ./.));
      fileMap = file: {
        "${lib.removeSuffix ".nix" file}" =
          import (./. + "/${file}") { inherit pkgs lib callPackage; };
      };
      mappedFiles = map fileMap files;
    in
    lib.foldr lib.recursiveUpdate { } mappedFiles;

}

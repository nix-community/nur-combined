{ pkgs }:
let
  lib = pkgs.lib;
  globNixFiles = import ./globNixFiles.nix lib;
  getFilenameNoSuffix = import ./getFilenameNoSuffix.nix lib;
in
builtins.listToAttrs (
  map (file: {
    name = getFilenameNoSuffix file;
    value = import file lib;
  }) (globNixFiles ./.)
)
{ systems ? [ builtins.currentSystem ] }:

# this mainly lets me build all the packages manually for macOS
let
  # flatten is taken from nixpkgs lib
  flatten = x:
    if builtins.isList x
    then builtins.concatMap (y: flatten y) x
    else [x];
  getPkgs = cursys: import (builtins.getFlake (builtins.toString ./.)).inputs.nixpkgs { system = cursys; };
  getCacheOutputs = cursys: (import ./ci.nix { pkgs = getPkgs cursys; }).cacheOutputs;
in flatten (map getCacheOutputs systems)

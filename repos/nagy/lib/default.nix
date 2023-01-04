{ pkgs, lib, callPackage }:

lib.foldr lib.recursiveUpdate { } [
  (import ./import.nix { inherit pkgs lib; })
  (import ./convert.nix { inherit pkgs lib callPackage; })
]

{ pkgs, lib ? pkgs.lib }:

lib.foldr lib.recursiveUpdate { } [
  (import ./import.nix { inherit pkgs; })
]

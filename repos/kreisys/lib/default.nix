{ pkgs }:

with pkgs.lib; rec {
  grid = import ./grid.nix { inherit pkgs; };
}


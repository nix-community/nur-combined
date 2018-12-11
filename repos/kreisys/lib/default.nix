{ pkgs }:

with pkgs.lib; rec {
  grid    = import ./grid.nix    { inherit pkgs strings; };
  strings = import ./strings.nix { inherit pkgs;         };
}


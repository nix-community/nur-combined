{ pkgs }:
with pkgs.lib; {
  wrapWine = import ./wrapWine.nix { inherit pkgs; };
}

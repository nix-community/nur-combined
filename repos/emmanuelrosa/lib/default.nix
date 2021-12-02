{ pkgs }:

with pkgs.lib; {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};

  wrapWine = import ./wrapWine.nix { inherit pkgs; };
}

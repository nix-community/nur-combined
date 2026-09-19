{ pkgs }:

with pkgs.lib; {
  # Maintainers of the packages in ./pkgs, see ./maintainers.nix
  maintainers = import ./maintainers.nix;

  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
}

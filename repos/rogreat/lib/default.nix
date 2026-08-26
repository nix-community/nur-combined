{ pkgs }:

with pkgs.lib;
{
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
  mozilla = import ./mozilla.nix { inherit (pkgs) lib; };
}

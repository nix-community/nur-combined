{ pkgs }:

{
  lib = pkgs.lib;
  mozilla = import ./mozilla.nix { lib = pkgs.lib; };
}

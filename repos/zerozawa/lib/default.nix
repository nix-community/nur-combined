{ pkgs }:
{
  fetchPixiv = pkgs.callPackage ./fetchPixiv/default.nix { };
}

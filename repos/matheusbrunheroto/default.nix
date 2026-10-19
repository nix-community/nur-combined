{ pkgs }:
{
  gorace = pkgs.callPackage ./pkgs/gorace.nix { };
}

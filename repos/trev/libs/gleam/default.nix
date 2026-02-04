{ pkgs }:
{
  inherit (pkgs.callPackage ./build.nix { }) build;
}

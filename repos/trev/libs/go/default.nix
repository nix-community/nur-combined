{ pkgs }:
{
  inherit (pkgs.callPackage ./compile.nix { }) compile;
}

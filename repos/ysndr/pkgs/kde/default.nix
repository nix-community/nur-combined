{ pkgs }:
{
  breeze-blur = pkgs.libsForQt5.callPackage ./breeze-blur {};
  round-corners = pkgs.libsForQt5.callPackage ./round-corners {};
}

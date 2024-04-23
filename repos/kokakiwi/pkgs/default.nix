{ pkgs, callPackage }:
{
  cryptpad = callPackage ./cryptpad {};
  paru = callPackage ./paru {};
}

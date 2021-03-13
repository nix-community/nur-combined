# My personal NUR repo
{ pkgs ? import <nixpkgs> {} }:
{
  build-sh = pkgs.callPackage ./build.sh {};
  lmt = pkgs.callPackage ./lmt {};
}

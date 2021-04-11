{ pkgs ? import <nixpkgs> { } }:

{
  gn = pkgs.callPackage ./pkgs/tools/build-managers/gn { };
}

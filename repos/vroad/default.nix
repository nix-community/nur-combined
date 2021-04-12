{ pkgs ? import <nixpkgs> { } }:

{
  gn = pkgs.callPackage ./pkgs/development/tools/build-managers/gn { };
}

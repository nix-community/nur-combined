{ pkgs ? import <nixpkgs> { } }:

{
  depot-tools = pkgs.callPackage ./pkgs/development/tools/depot-tools { };
  gn = pkgs.callPackage ./pkgs/development/tools/build-managers/gn { };
}

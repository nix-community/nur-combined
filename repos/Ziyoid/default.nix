{ pkgs ? import <nixpkgs> { } }:

{
  palera1n = pkgs.callPackage ./pkgs/palera1n { };
  checkra1n-all-binaries = pkgs.callPackage ./pkgs/checkra1n-all-binaries { };
}

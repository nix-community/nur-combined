{ pkgs ? import <nixpkgs> { } }:

{
  palera1n = pkgs.callPackage ./pkgs/palera1n { };
}

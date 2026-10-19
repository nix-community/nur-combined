{ pkgs ? import <nixpkgs> { } }:

{
  nostromo = pkgs.callPackage ./nostromo { };
}

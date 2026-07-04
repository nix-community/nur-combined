{ pkgs ? import <nixpkgs> {} }:

{
  katifetch = pkgs.callPackage ./katifetch/package.nix { };
}

{ pkgs ? import <nixpkgs> { } }:
{
  tdesktop-bin = pkgs.callPackage ./pkgs/tdesktop-bin { };
}

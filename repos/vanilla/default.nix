{ pkgs ? import <nixpkgs> { } }:
{
  fastfetch = pkgs.callPackage ./pkgs/fastfetch { };
  tdesktop-bin = pkgs.callPackage ./pkgs/tdesktop-bin { };
}

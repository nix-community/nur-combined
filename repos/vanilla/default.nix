{ pkgs ? import <nixpkgs> { } }:
{
  fastfetch = pkgs.callPackage ./pkgs/fastfetch { };
  freshfetch = pkgs.callPackage ./pkgs/freshfetch { };
  tdesktop-bin = pkgs.callPackage ./pkgs/tdesktop-bin { };
}

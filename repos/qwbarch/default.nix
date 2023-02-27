{ pkgs ? import <nixpkgs> { } }:
{
  arcanists2 = pkgs.callPackage ./arcanists2 { };
}


{ pkgs ? import <nixpkgs> { } }:

{
  aeroflare = pkgs.callPackage ./pkgs/aeroflare { };
}

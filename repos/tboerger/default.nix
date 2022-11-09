{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  readarr = pkgs.callPackage ./pkgs/readarr { };
  jellyseerr = pkgs.callPackage ./pkgs/jellyseerr { };
}

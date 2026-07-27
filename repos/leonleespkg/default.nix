
{ pkgs ? import <nixpkgs> { } }:

{

  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./nixos-modules; # NixOS modules

  overlays = import ./overlays; # nixpkgs overlays


  zcode = pkgs.callPackage ./pkgs/zcode { };

}

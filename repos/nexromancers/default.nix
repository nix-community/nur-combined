{ pkgs ? import <nixpkgs> {} }:

{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  hacksaw = pkgs.callPackage ./pkgs/hacksaw { };
  shotgun = pkgs.callPackage ./pkgs/shotgun { };
}

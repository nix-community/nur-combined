{ pkgs ? import <nixpkgs> {} }:

{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  dwdiff = pkgs.callPackage ./pkgs/dwdiff { };
  just = pkgs.callPackage ./pkgs/just {  };
  xcolor = pkgs.callPackage ./pkgs/xcolor { };
}

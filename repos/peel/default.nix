{ pkgs ? import <nixpkgs> {} }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  darwin-modules = import ./darwin-modules;
  overlays = import ./overlays;
} // import ./pkgs { inherit pkgs; }

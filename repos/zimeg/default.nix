{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  zsh-wd = pkgs.callPackage ./pkgs/zsh-wd { };
}

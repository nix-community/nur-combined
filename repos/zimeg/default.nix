{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  etime = pkgs.callPackage ./pkgs/etime { };
  gon = pkgs.callPackage ./pkgs/gon { };
  zsh-wd = pkgs.callPackage ./pkgs/zsh-wd { };
}

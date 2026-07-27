# This file describes your repository contents.
{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  clinvk = pkgs.callPackage ./pkgs/clinvk { };
}

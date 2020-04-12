{ pkgs ? import <nixpkgs> { } }:

{
  home-manager = rec {
    modules = builtins.attrValues rawModules;
    rawModules = import ./home-manager/modules;
  };
  lib = import ./lib;
  modules = import ./modules;
  overlays = import ./overlays;
  pkgs = import ./pkgs { inherit pkgs; };
}

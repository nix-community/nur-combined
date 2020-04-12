{ pkgs ? import <nixpkgs> { } }:

rec
{
  home-manager = rec {
    modules = pkgs.lib.attrValues rawModules;
    rawModules = import ./home-manager/modules;
  };
}
// {
  lib = import ./lib;
  modules = import ./modules;
  overlays = import ./overlays;
  pkgs = import ./pkgs { inherit pkgs; };
}

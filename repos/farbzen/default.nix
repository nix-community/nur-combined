{pkgs ? import <nixpkgs> {}}: {
  lib = import ./lib;
  modules = import ./modules;
  overlays = import ./overlays;

  narf = pkgs.callPackage ./pkgs/narf {};
  mixedupmh = pkgs.callPackage ./pkgs/mixedupmh {};
}

{pkgs ? import <nixpkgs> {}}: let
  nurLib = import ./lib;
  callPackage = pkgs.lib.callPackageWith (pkgs // {inherit (nurLib) maintainers;});
in {
  lib = nurLib;
  modules = import ./modules;
  overlays = import ./overlays;

  narf = callPackage ./pkgs/narf {};
  hive = callPackage ./pkgs/hive {};
}

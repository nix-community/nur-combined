{ pkgs, lib }:
let
  callPackageByName = name: extraArgs: callPackage (lib.pkgPathByName name) extraArgs;

  callPackage = pkgs.lib.callPackageWith (pkgs // { customLib = lib; } // packages);
  packages = {
    ugdb = callPackageByName "ugdb" { };
    pince = callPackageByName "pince" { };
  };
in
packages

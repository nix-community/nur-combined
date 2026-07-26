{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
  config ? { },
  inputs ? { },
  self ? null,
  ...
}:
let
  packageOverlay = lib.composeManyExtensions [
    allPackagesOverlay
    (
      final: prev:
      let
        packages = prev.lib.concatMapAttrs (_: v: v) (
          prev.lib.packagesFromDirectoryRecursive {
            callPackage = final._nurCallPackage;
            directory = ../by-name;
          }
        );
      in
      packages // { _nurPackageNames = builtins.attrNames packages; }
    )
  ];

  makePackageSet = base: base.extend packageOverlay;

  allPackagesOverlay = import ./all-packages.nix {
    inherit
      lib
      config
      inputs
      makePackageSet
      ;
    nur-moraxyc = self;
    nixpkgs = pkgs;
  };

  deprecatedAliases = import ./deprecated.nix pkgs;

  filters = pkgs.callPackage ../../helpers/filters.nix { };

  fixedPkgs = makePackageSet pkgs;

  exportPkgs = lib.genAttrs fixedPkgs._nurPackageNames (name: fixedPkgs.${name});

  nixosTests = import ../../nixos/tests/all-tests.nix {
    inherit lib;
    callPackage = fixedPkgs.callPackage;
  };
in
fixedPkgs
// {
  __drvPackages = lib.filterAttrs filters.isDrv exportPkgs;
  __ciPackages = lib.filterAttrs filters.isBuildable exportPkgs;
  __nixosTests = nixosTests;
  __nurPackages = lib.filterAttrs filters.isExport exportPkgs // deprecatedAliases;
}

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
    byNameOverlay
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

  byNameOverlay = import ./by-name-overlay.nix ../by-name;

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

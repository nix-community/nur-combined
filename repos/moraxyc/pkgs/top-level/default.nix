{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
  config ? { },
  inputs ? { },
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
    nixpkgs = pkgs;
  };

  byNameOverlay = import ./by-name-overlay.nix ../by-name;

  deprecatedAliases = import ./deprecated.nix pkgs;

  filters = pkgs.callPackage ../../helpers/filters.nix { };

  fixedPkgs = makePackageSet pkgs;

  exportPkgs = lib.genAttrs fixedPkgs._nurPackageNames (name: fixedPkgs.${name});
in
fixedPkgs
// {
  __drvPackages = lib.filterAttrs filters.isDrv exportPkgs;
  __ciPackages = lib.filterAttrs filters.isBuildable exportPkgs;
  __nurPackages = lib.filterAttrs filters.isExport exportPkgs // deprecatedAliases;
}

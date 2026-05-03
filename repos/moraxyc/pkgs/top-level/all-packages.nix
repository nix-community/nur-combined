{
  lib,
  config,
  inputs,
  nixpkgs,
  makePackageSet,
}:
let
  nurPythonPackagesExtensions = [
    (import ./python-packages.nix)
  ];
in
self: super: {
  _nurHasAllModuleArgs = config ? allModuleArgs;

  callPackage = lib.callPackageWith (
    lib.optionalAttrs (config ? allModuleArgs) {
      inherit (config.allModuleArgs) self' inputs' system;
    }
    // {
      inherit inputs nixpkgs;
    }
    // self
    // {
      callPackage = self.callPackage;
    }
  );

  pythonPackagesExtensions = super.pythonPackagesExtensions ++ nurPythonPackagesExtensions;

  pkgsCross = lib.recurseIntoAttrs (
    lib.mapAttrs (n: _: makePackageSet (nixpkgs.pkgsCross."${n}")) lib.systems.examples
  );

  pkgsStatic = makePackageSet nixpkgs.pkgsStatic;
}

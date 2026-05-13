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

  _nurCallPackage = lib.callPackageWith (
    {
      inherit inputs;
      nixpkgs = super;
    }
    // self
    // {
      callPackage = self._nurCallPackage;
    }
  );

  pythonPackagesExtensions = super.pythonPackagesExtensions ++ nurPythonPackagesExtensions;

  pkgsCross = lib.recurseIntoAttrs (
    lib.mapAttrs (n: _: makePackageSet (nixpkgs.pkgsCross."${n}")) lib.systems.examples
  );

  pkgsStatic = makePackageSet nixpkgs.pkgsStatic;
}

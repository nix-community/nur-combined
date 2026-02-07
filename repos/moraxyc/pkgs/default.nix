{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
  config ? { },
  inputs ? { },
  ...
}:
let
  deprecatedAliases = import ./deprecated.nix pkgs;

  filters = pkgs.callPackage ../helpers/filters.nix { };

  fixedPkgs =
    (lib.fix (self: {
      callPackageWrapper =
        pkgsArg:
        lib.callPackageWith (
          lib.optionalAttrs (config ? allModuleArgs) {
            inherit (config.allModuleArgs) self' inputs' system;
          }
          // {
            inherit inputs;
          }
          // pkgsArg
          // self.packages
        );

      pkgsFun =
        pkgsArg:
        let
          callPackage = self.callPackageWrapper pkgsArg;
          sources = lib.fileset.fileFilter (args: args.name == "package.nix") ./by-name;
          sourceFiles = lib.fileset.toList sources;
        in
        lib.listToAttrs (
          map (
            pathName:
            let
              imported = import pathName;

              fArgs = if builtins.isFunction imported then builtins.functionArgs imported else { };

              requiresInputs = fArgs ? inputs' || fArgs ? inputs;
              shouldSkip = requiresInputs && !(config ? allModuleArgs);
            in
            {
              name = baseNameOf (dirOf pathName);
              value = if shouldSkip then null else callPackage imported { };
            }
          ) sourceFiles
        );

      pkgsCross = lib.mergeAttrs (pkgs.writers.writeText "pkgsCross" "") (
        lib.mapAttrs (n: _: self.pkgsFun (pkgs.pkgsCross."${n}")) lib.systems.examples
      );

      pkgsStatic = lib.mergeAttrs (pkgs.writers.writeText "pkgsStatic" "") (self.pkgsFun pkgs.pkgsStatic);

      packages = lib.mergeAttrs (self.pkgsFun pkgs) {
        upstream = pkgs;
        inherit (self)
          pkgsCross
          pkgsStatic
          ;
      };
    })).packages;
in
fixedPkgs
// {
  __drvPackages = lib.filterAttrs filters.isDrv fixedPkgs;
  __ciPackages = lib.filterAttrs filters.isBuildable fixedPkgs;
  __nurPackages = lib.filterAttrs filters.isExport fixedPkgs // deprecatedAliases;
}

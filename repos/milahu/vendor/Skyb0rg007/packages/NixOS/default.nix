{
  pkgs ? import <nixpkgs> { config.allowUnfree = true; },
  lib ? pkgs.lib,
  ...
}:
let
  nixosModules = import ./modules/nixos;
  nixosTests = import ./tests/all-tests.nix {
    inherit pkgs nixosModules packages;
  };

  pythonOverride =
    interp:
    interp.override {
      packageOverrides =
        pself: _:
        lib.filesystem.packagesFromDirectoryRecursive {
          callPackage = pself.callPackage;
          directory = ./pkgs/python-modules;
        };
    };

  python3 = pythonOverride pkgs.python3;
  python313 = pythonOverride pkgs.python313;
  python314 = pythonOverride pkgs.python314;
  python315 = pythonOverride pkgs.python315;

  # Full package sets
  python3PackagesFull = python313PackagesFull;
  python313PackagesFull = python313.pkgs;
  python314PackagesFull = python314.pkgs;
  python315PackagesFull = python315.pkgs;

  # Packages defined only in this project
  python3ModulePackages = python313ModulePackages;
  python313ModulePackages = lib.filesystem.packagesFromDirectoryRecursive {
    callPackage = python313.pkgs.callPackage;
    directory = ./pkgs/python-modules;
  };
  python314ModulePackages = lib.filesystem.packagesFromDirectoryRecursive {
    callPackage = python314.pkgs.callPackage;
    directory = ./pkgs/python-modules;
  };
  python315ModulePackages = lib.filesystem.packagesFromDirectoryRecursive {
    callPackage = python315.pkgs.callPackage;
    directory = ./pkgs/python-modules;
  };

  python3Packages = lib.recurseIntoAttrs python313ModulePackages;
  python313Packages = lib.recurseIntoAttrs python313ModulePackages;
  python314Packages = lib.recurseIntoAttrs python314ModulePackages;
  python315Packages = lib.recurseIntoAttrs python315ModulePackages;

  # mkOcamlPackages =
  #   base:
  #   let
  #     merged = base // localOcamlModules;
  #     localOcamlModules = lib.filesystem.packagesFromDirectoryRecursive {
  #       callPackage = lib.callPackageWith (pkgs // packages // merged // { inherit nixosTests; });
  #       directory = ./pkgs/ocaml-modules;
  #     };
  #   in
  #   merged;
  #
  # ocamlPackages = mkOcamlPackages pkgs.ocamlPackages;
  # ocamlNg = lib.mapAttrs (
  #   _: v: if builtins.isAttrs v && v ? buildDunePackage then mkOcamlPackages v else v
  # ) pkgs.ocaml-ng;

  tcl9PackagesFull = pkgs.tcl9Packages // tcl9ModulePackages;
  tcl9ModulePackages = lib.filesystem.packagesFromDirectoryRecursive {
    callPackage = lib.callPackageWith (pkgs // packages // tcl9PackagesFull // { inherit nixosTests; });
    directory = ./pkgs/tcl-modules;
  };
  tcl9Packages = lib.recurseIntoAttrs tcl9ModulePackages;

  packages =
    lib.filesystem.packagesFromDirectoryRecursive {
      callPackage = lib.callPackageWith (
        pkgs
        // packages
        // {
          inherit
            python3
            python313
            python314
            python315
            nixosTests
            # ocamlPackages
            ;
          python3Packages = python3PackagesFull;
          python313Packages = python313PackagesFull;
          python314Packages = python314PackagesFull;
          python315Packages = python315PackagesFull;
          tcl9Packages = tcl9PackagesFull;
          # "ocaml-ng" = ocamlNg;
          nixpkgs = pkgs;
        }
      );
      directory = ./pkgs/by-name;
    }
    // {
      inherit
        tcl9Packages
        # ocamlPackages
        python3Packages
        python313Packages
        python314Packages
        python315Packages
        ;
      # "ocaml-ng" = ocamlNg;
    };
in
{
  inherit nixosModules;
}
// packages

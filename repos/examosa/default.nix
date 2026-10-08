{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) lib;

  packages = lib.packagesFromDirectoryRecursive {
    callPackage = lib.callPackageWith (lib.recursiveUpdate pkgs {
      # Missing in nixos-26.05
      lib.maintainers.examosa.github = "examosa";
    });

    directory = ./packages;
  };
in
  {
    overlays = import ./overlays;
  }
  // packages

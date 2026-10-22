{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) lib;

  polyfill.lib = lib.recursiveUpdate pkgs.lib {
    # Missing in nixos-26.05
    maintainers.examosa.github = "examosa";
  };

  packages = lib.packagesFromDirectoryRecursive {
    callPackage = lib.callPackageWith (pkgs // polyfill);

    newScope = extra:
      pkgs.newScope (extra // polyfill);

    directory = ./packages;
  };
in
  packages
  // {
    overlays = import ./overlays;
  }

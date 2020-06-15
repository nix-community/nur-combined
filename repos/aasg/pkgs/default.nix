{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // self);
  self = rec {

    dma = callPackage ./tools/networking/dma { };

    dyndnsc = callPackage ./tools/networking/dyndnsc { };

    guile-commonmark = callPackage ./development/guile-modules/guile-commonmark { };

    haunt = callPackage ./applications/misc/haunt { };

    linuxPackagesFor = kernel:
      (pkgs.linuxPackagesFor kernel).extend (import ./os-specific/linux/kernel-packages.nix);

    python3 = pkgs.python3.override { packageOverrides = import ./development/python-modules; };

    # Package sets, copied from <nixpkgs>/pkgs/top-level/all-packages.nix.
    linuxPackages = linuxPackagesFor pkgs.linux;
    linuxPackages_latest = linuxPackagesFor pkgs.linux_latest;
    python3Packages = python3.pkgs;

  };
in
self

{ pkgs, lib }:
let
  packages = stable // unstable // python-stable // firefox;

  callPackage = pkgs.lib.callPackageWith (pkgs // packages);
  pythonCallPackage = pkgs.lib.callPackageWith (pkgs // pkgs.python3Packages // python-stable);
  firefoxCallPackage =
    let
      buildMozillaXpiAddon = lib.mozilla.mkBuildMozillaXpiAddon { inherit (pkgs) fetchurl stdenv; };
    in
    pkgs.lib.callPackageWith (pkgs // firefox // { inherit buildMozillaXpiAddon; });

  stable = pkgs.lib.packagesFromDirectoryRecursive {
    callPackage = callPackage;
    directory = ./stable;
  };
  unstable = pkgs.lib.packagesFromDirectoryRecursive {
    callPackage = callPackage;
    directory = ./unstable;
  };
  python-stable = pkgs.lib.packagesFromDirectoryRecursive {
    callPackage = pythonCallPackage;
    directory = ./python/stable;
  };
  firefox = pkgs.lib.packagesFromDirectoryRecursive {
    callPackage = firefoxCallPackage;
    directory = ./firefox;
  };
in
packages

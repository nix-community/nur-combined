{ pkgs }:
let
  packages = stable // unstable // python-stable;
  callPackage = pkgs.lib.callPackageWith (pkgs // packages);
  pythonCallPackage = pkgs.lib.callPackageWith (pkgs // pkgs.python3Packages // python-stable);
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
in
packages

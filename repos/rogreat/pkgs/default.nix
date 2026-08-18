{
  pkgs ? import <nixpkgs> { },
}:
let
  packages = stable // unstable // nightly // python-stable;
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
  nightly = pkgs.lib.packagesFromDirectoryRecursive {
    callPackage = callPackage;
    directory = ./nightly;
  };
  python-stable = pkgs.lib.packagesFromDirectoryRecursive {
    callPackage = pythonCallPackage;
    directory = ./python/stable;
  };
in
packages

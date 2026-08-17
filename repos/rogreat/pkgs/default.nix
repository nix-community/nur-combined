{
  pkgs ? import <nixpkgs> { },
}:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // stable // unstable // python-stable);
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
stable // unstable // python-stable

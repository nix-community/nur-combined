{
  pkgs,
}:

# Every pkgs/<name>/package.nix becomes the package `<name>`.
pkgs.lib.packagesFromDirectoryRecursive {
  inherit (pkgs) callPackage;
  directory = ./pkgs;
}

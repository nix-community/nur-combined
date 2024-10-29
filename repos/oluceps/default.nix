{
  pkgs ? import <nixpkgs> { },
}:
(pkgs.lib.packagesFromDirectoryRecursive {
  inherit (pkgs) callPackage;
  directory = ./pkgs/by-name;
})

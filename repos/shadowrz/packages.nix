{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs) lib;

in
lib.filesystem.packagesFromDirectoryRecursive {
  callPackage = pkgs.callPackage;
  directory = ./pkgs;
}

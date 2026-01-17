{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  myPkgs = pkgs.lib.filesystem.packagesFromDirectoryRecursive {
    inherit (pkgs) callPackage newScope;
    directory = ./pkgs;
  };
in
myPkgs

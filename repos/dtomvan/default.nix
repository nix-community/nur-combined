{
  pkgs ? import <nixpkgs> { },
  ...
}:
(pkgs.lib.filesystem.packagesFromDirectoryRecursive {
  inherit (pkgs) callPackage newScope;
  directory = ./pkgs;
})

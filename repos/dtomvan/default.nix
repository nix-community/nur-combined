{
  pkgs ? import <nixpkgs> { },
  ...
}:
builtins.removeAttrs
  (pkgs.lib.filesystem.packagesFromDirectoryRecursive {
    inherit (pkgs) callPackage newScope;
    directory = ./pkgs;
  })
  [
    "microsoft-edit"
  ]

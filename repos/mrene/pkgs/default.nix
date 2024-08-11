{ callPackage }:
let
  localLib = callPackage ../lib {};
in

localLib.scopeFromDirectoryRecursive {
  directory = ./.;
}
{
  pkgs ? import <nixpkgs> { },
  self ? toString ./.,
}:

let
  lib = pkgs.lib;
  ourLib = import "${self}/lib/default.nix" { inherit lib; };
  lib' = pkgs.lib.recursiveUpdate lib ourLib;
  pkgs' = lib.recursiveUpdate pkgs { lib = lib'; };
in
lib.recursiveUpdate (lib'.callDirPackageWithRecursive pkgs' "${self}/pkgs") {
  lib = ourLib;
  overlays = lib'.importDirRecursive "${self}/overlays";
  modules = lib'.importDirRecursive "${self}/modules";
}

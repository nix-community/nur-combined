{
  pkgs ? import <nixpkgs> { },
  self ? toString ./.,
  inputs ? { },
}:

let
  lib = pkgs.lib;
  ourLib = import "${self}/lib/default.nix" {
    inherit lib;
    inherit inputs;
  };
  lib' = pkgs.lib.recursiveUpdate lib ourLib;
  pkgs' = lib.recursiveUpdate pkgs { lib = lib'; };
  pkgsDir = "${self}/pkgs";
  modulesDir = "${self}/modules";
  rawPackages = lib'.callDirPackageWithRecursive pkgs' pkgsDir { inherit inputs; };

in
lib.recursiveUpdate (lib.filterAttrs (_: v: v != null) rawPackages) {
  lib = ourLib;
  modules = lib'.importDirRecursive modulesDir;
}

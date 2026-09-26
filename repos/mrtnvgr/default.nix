{ pkgs }:
let
  inherit (pkgs) lib;

  packageDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./pkgs);

  packages = lib.fix (self:
    let
      callPackage = lib.callPackageWith (pkgs // self);
    in
    lib.mapAttrs (name: _: callPackage (./pkgs + "/${name}/package.nix") { }) packageDirs);
in
packages

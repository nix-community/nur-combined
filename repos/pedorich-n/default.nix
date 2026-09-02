# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:
let
  # Poor man's `packagesFromDirectoryRecursive`. Due to NUR's limitations, we can't use `lib` here, so we have to reimplement it.
  # We also assumed that all packages and modules are one level deep, and named accordingly.
  pkgsDir = ./pkgs;
  modulesDir = ./modules/nixos;

  packagePathFor = name: pkgsDir + "/${name}/package.nix";
  modulePathFor = name: modulesDir + "/${name}/module.nix";

  pkgNames = builtins.filter (n: builtins.pathExists (packagePathFor n)) (builtins.attrNames (builtins.readDir pkgsDir));
  moduleNames = builtins.filter (n: builtins.pathExists (modulePathFor n)) (builtins.attrNames (builtins.readDir modulesDir));

  packages = builtins.listToAttrs (
    map (n: {
      name = n;
      value = pkgs.callPackage (packagePathFor n) { };
    }) pkgNames
  );

  nixosModules = builtins.listToAttrs (
    map (n: {
      name = n;
      value = modulePathFor n;
    }) moduleNames
  );
in
{
  overlays = import ./overlays;
  inherit nixosModules;
}
// packages

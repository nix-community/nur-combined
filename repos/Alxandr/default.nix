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
  inherit (pkgs) lib;
  nurLib = import ./lib {
    inherit pkgs;
    packages = discoveredPackages;
  };

  packageCallArgs = {
    inherit nurLib;
    inherit (nurLib) crate2nix-package-update-script nuget-global-tool-update-script;
  };

  newScope = extra: lib.callPackageWith (pkgs // packageCallArgs // extra);

  packageScope = lib.packagesFromDirectoryRecursive {
    directory = ./pkgs;
    callPackage = newScope { };
    inherit newScope;
  };

  scopeImplementationAttrs = [
    "callPackage"
    "newScope"
    "overrideScope"
    "packages"
  ];

  isPackageSet = value: builtins.isAttrs value && value.recurseForDerivations or false;

  cleanPackageSet =
    packageSet:
    lib.mapAttrs (_: value: if isPackageSet value then cleanPackageSet value else value) (
      removeAttrs packageSet scopeImplementationAttrs
    );

  discoveredPackages = removeAttrs (cleanPackageSet packageScope) [ "recurseForDerivations" ];

  specialAttrs = {
    # The `lib`, `overlays`, `nixosModules`, `homeModules`,
    # `darwinModules` and `flakeModules` names are special
    lib = nurLib; # functions
    nixosModules = import ./nixos-modules; # NixOS modules
    homeModules = import ./home-modules; # Home Manager modules
    # darwinModules = { }; # nix-darwin modules
    # flakeModules = { }; # flake-parts modules
    overlays = import ./overlays; # nixpkgs overlays
  };
in
specialAttrs // discoveredPackages

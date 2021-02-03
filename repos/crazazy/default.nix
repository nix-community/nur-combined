# WARNING: It's best that you set impureNix to "true" when importing this repository from somewhere else
# the reason for this is that fetchGit tries to fetch repositories with all their commit history, in the case
# nixpkgs, this is about 1,3GB as of writing.
# you can also provide your own packages with the "pkgs" parameter
{ includeOverlays ? false, impureNix ? false, overlays ? [ ], ... }@args:
let
  inherit (builtins) attrValues sort;
  ensureModules = import ./lib/importFromSubmodule.nix { root = ./.; };
  # impure Nix is faster than pinned nix
  nixpkgsSrc = args.pkgs or (if impureNix then <nixpkgs> else (ensureModules ./dep/nixpkgs/default.nix));
  pkgs = import nixpkgsSrc { };
  localOverlays = import ./overlays;
  basePackageSet = self: {
    callPackage = pkgs.lib.callPackageWith self;
    callNixPackage = pkgs.callPackage;
    lib = {
      inherit ensureModules;
      srcs = import ./dep { inherit ensureModules; };
      overlays = pkgs.lib.mapAttrs (k: v: v.function) localOverlays;
      pkgsrc = import ./.;
    };
    # bare necessities
    inherit (pkgs)
      nix
      runCommand
      ;
  };
  # Adapted from https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/stage.nix
  packages =
    let
      overlayDataSet = attrValues localOverlays;
      sorted = sort (a: b: a.priority < b.priority) overlayDataSet;
      toFix = with pkgs.lib; foldl' (flip extends) basePackageSet
      ((if includeOverlays then (map (x: x.function) sorted) else []) ++ overlays);
    in
    pkgs.lib.fix toFix;

in
packages

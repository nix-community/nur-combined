{ nixpkgs ? <nixpkgs>
, supportedSystems ? [ builtins.currentSystem ]
, scrubJobs ? false }:

let
  pkgs = import nixpkgs {};
in with pkgs.lib;

let
  platformizedPkgs = let
    releaseLib = import <nixpkgs/pkgs/top-level/release-lib.nix> {
      inherit supportedSystems scrubJobs;
      packageSet = import ./.;
    };

    inherit (releaseLib) mapTestOn packagePlatforms pkgs;
  in mapTestOn (packagePlatforms pkgs);

  sanitizedPkgs =  let
    isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
    nullNonDrvs = mapAttrsRecursiveCond
    (as: ! isDerivation as && ! as ? __functor)
    (_: v: if isDerivation v && isBuildable v then v else null)
    platformizedPkgs;

    filterOutNulls = filterAttrsRecursive (_: v: v != null && v != {}) nullNonDrvs;
  in filterOutNulls;

in sanitizedPkgs // {
  lib-tests = import ./lib/tests/release.nix {};

  all-pkgs = pkgs.releaseTools.aggregate {
    name = "all-pkgs";
    meta = {
      maintainer = [{
        email = "shaybergmann@gmail.com";
      }];
      description = "all them pkgs";
    };
    constituents = collect isDerivation sanitizedPkgs;
  };
}


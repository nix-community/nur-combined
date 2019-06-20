{ nixpkgs ? <nixpkgs>
, supportedSystems ? [ builtins.currentSystem ]
, scrubJobs ? true }:

let
  platformizedPkgs = let
    releaseLib = import <nixpkgs/pkgs/top-level/release-lib.nix> {
      inherit supportedSystems scrubJobs;
      packageSet = import ./.;
    };

    inherit (releaseLib) mapTestOn packagePlatforms pkgs;
  in mapTestOn (packagePlatforms pkgs);

  sanitizedPkgs = with import <nixpkgs/lib>; let
    isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
    nullNonDrvs = mapAttrsRecursiveCond
    (as: ! isDerivation as && ! as ? __functor)
    (_: v: if isDerivation v && isBuildable v then v else null)
    platformizedPkgs;

    filterOutNulls = filterAttrsRecursive (_: v: v != null) nullNonDrvs;
  in filterOutNulls;

in sanitizedPkgs // {
  lib-tests = import ./lib/tests/release.nix {};
}


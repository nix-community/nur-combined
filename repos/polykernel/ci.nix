# This file provides all the buildable and cacheable packages and
# package outputs in you package set. These are what gets built by CI,
# so if you correctly mark packages as
#
# - broken (using `meta.broken`),
# - unfree (using `meta.license.free`), and
# - locally built (using `preferLocalBuild`)
#
# then your CI will be able to build and cache only those packages for
# which this is possible.
{pkgs ? import <nixpkgs> {}}: let
  /*
  Library imports
  */
  inherit (pkgs) lib;
  inherit
    (lib.attrsets)
    attrValues
    isAttrs
    isDerivation
    ;
  inherit
    (lib.lists)
    concatMap
    filter
    listToAttrs
    map
    ;

  /*
  Helper functions
  */
  isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;
  genOutputList = p: map (output: p.${output}) p.outputs;
  collectDrvs = p:
    if shouldRecurseForDerivations p
    then concatMap collectDrvs (attrValues p)
    else if isDerivation p
    then [p]
    else [];

  nurCore = import ./default.nix {inherit pkgs;};
  nurPkgs = concatMap collectDrvs (attrValues nurCore.pkgs);
in rec {
  buildPkgs = filter isBuildable nurPkgs;
  cachePkgs = filter isCacheable buildPkgs;

  buildOutputs = concatMap genOutputList buildPkgs;
  cacheOutputs = concatMap genOutputList cachePkgs;
}

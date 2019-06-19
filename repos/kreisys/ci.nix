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

{ pkgs ? import <nixpkgs> {} }:

with builtins;
with pkgs.lib;

let

  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;

  flattenPkgs = s:
    let
      f = p:
        if shouldRecurseForDerivations p then flattenPkgs p
        else if isDerivation p then [p]
        else [];
    in
      concatMap f (attrValues s);

  outputsOf = p: map (o: p.${o}) p.outputs;

  nurAttrs = import ./default.nix { inherit pkgs; };
  nurDrvs = mapAttrsRecursiveCond (as: ! isDerivation as && ! as ? __functor) (_: v: if isDerivation v then v else null) nurAttrs;

  nurPkgs =
    #flattenPkgs
    (listToAttrs
    (map (n: nameValuePair n nurDrvs.${n})
    (filter (n: !isReserved n)
    (attrNames nurDrvs))));

in

rec {
  buildPkgs = filterAttrsRecursive (_: v: v != null) nurDrvs;
  cachePkgs = filter isCacheable buildPkgs;

  buildOutputs = concatMap outputsOf buildPkgs;
  cacheOutputs = concatMap outputsOf cachePkgs;
}

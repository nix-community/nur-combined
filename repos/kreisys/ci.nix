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

nixpkgsArgs:

let pkgs = import <nixpkgs> nixpkgsArgs;
in

with builtins;
with pkgs.lib;

let
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;

  outputsOf = p: map (o: p.${o}) p.outputs;

  nurAttrs = import ./. { inherit pkgs; };

  nurDrvs = mapAttrsRecursiveCond (as: ! isDerivation as && ! as ? __functor) (_: v: if isDerivation v then v else null) nurAttrs;

  nurPkgs =
    (listToAttrs
    (map (n: nameValuePair n nurDrvs.${n})
    (filter (n: !isReserved n)
    (attrNames nurDrvs))));

  buildPkgs = filterAttrsRecursive (_: v: v != null && isBuildable v) nurPkgs;
  cachePkgs = filter isCacheable buildPkgs;

  buildOutputs = concatMap outputsOf buildPkgs;
  cacheOutputs = concatMap outputsOf cachePkgs;
in buildPkgs

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

{ pkgs ? import <nixpkgs> { } }:

with builtins;

let

  isReserved = n:
    n == "hmModules" || n == "lib" || n == "modules" || n == "ndModules" || n
    == "overlays";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p:
    isAttrs p && p.recurseForDerivations or false;

  nameValuePair = n: v: {
    name = n;
    value = v;
  };

  flattenPkgs = s:
    let
      f = p:
        if shouldRecurseForDerivations p then
          flattenPkgs p
        else if isDerivation p then
          [ p ]
        else
          [ ];
    in concatMap f (attrValues s);

  outputsOf = p: map (o: p.${o}) p.outputs;

  nurAttrs = import ./default.nix { inherit pkgs; }
    // import ./pkgs/home-manager { inherit pkgs; };

  nurPkgs = flattenPkgs (listToAttrs (map (n: nameValuePair n nurAttrs.${n})
    (filter (n: !isReserved n) (attrNames nurAttrs))));

in rec {
  buildPkgs = filter isBuildable nurPkgs;
  cachePkgs = filter isCacheable buildPkgs;

  buildOutputs = concatMap outputsOf buildPkgs;
  cacheOutputs = concatMap outputsOf cachePkgs;
}

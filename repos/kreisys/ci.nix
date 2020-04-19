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

{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> {
  config = { };
  overlays = [ ];
  inherit system;
} }:

with builtins;

let

  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isCompatible = p: elem system (p.meta.platforms or pkgs.lib.platforms.unix);
  isFree = p: p.meta.license.free or true;
  isUnbroken = p: !(p.meta.broken or false);
  isBuildable = p:
    all (pred: pred p) [ isDerivation isCompatible isFree isUnbroken ];
  isCacheable = p: !(p.preferLocalBuild or false);

  shouldRecurseForDerivations = p:
    isAttrs p && p.recurseForDerivations or false;

  nameValuePair = n: v: {
    name = n;
    value = v;
  };

  concatMap = builtins.concatMap or (f: xs: concatLists (map f xs));

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

  nurAttrs = import ./default.nix { inherit pkgs; };

  nurPkgs = flattenPkgs (listToAttrs (map (n: nameValuePair n nurAttrs.${n})
    (filter (n: !isReserved n) (attrNames nurAttrs))));

in rec {
  buildables = with pkgs.lib;
    pipe nurAttrs [
      (mapAttrsRecursiveCond shouldRecurseForDerivations (path: value:
        if isBuildable value then
          concatStringsSep "." path
        else if shouldRecurseForDerivations value then
          value
        else
          null))

      (filterAttrsRecursive (_: v: v != null))
      (let self = mapAttrsToList (_: v: if isString v then v else self v);
      in self)
      flatten
    ];

  buildPkgs = filter isBuildable nurPkgs;
  cachePkgs = filter isCacheable buildPkgs;

  buildOutputs = concatMap outputsOf buildPkgs;
  cacheOutputs = concatMap outputsOf cachePkgs;
}

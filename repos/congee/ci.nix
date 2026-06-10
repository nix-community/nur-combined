# This file provides all the buildable and cacheable packages and
# package outputs in your package set. These are what gets built by CI,
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
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isFree = p: p.meta.license.free or true;
  isAvailable = p:
    !(p.meta.broken or false)
    && pkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform p;
  isBuildable = p: isFree p && isAvailable p;
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;

  nameValuePair = n: v: { name = n; value = v; };

  concatMap = builtins.concatMap or (f: xs: concatLists (map f xs));

  flattenPkgs = s:
    let
      f = p:
        if shouldRecurseForDerivations p then flattenPkgs p
        else if isDerivation p then [ p ]
        else [ ];
    in
    concatMap f (attrValues s);

  outputsOf = p: map (o: p.${o}) p.outputs;

  nurAttrs = import ./default.nix { inherit pkgs; };

  nurPkgs =
    flattenPkgs
      (listToAttrs
        (map (n: nameValuePair n nurAttrs.${n})
          (filter (n: !isReserved n)
            (attrNames nurAttrs))));

in
rec {
  buildPkgs = filter isBuildable nurPkgs;
  cachePkgs = filter isCacheable buildPkgs;

  buildOutputs = concatMap outputsOf buildPkgs;
  cacheOutputs = concatMap outputsOf cachePkgs;

  unfreePkgs = filter (p: isAvailable p && !isFree p) nurPkgs;

  # cachix pushFilter regex derived from meta.license, so the workflow has no
  # second list of unfree packages to keep in sync. Evaluating it requires
  # NIXPKGS_ALLOW_UNFREE=1. "^$" never matches a store path, so an empty
  # result filters nothing.
  unfreePushFilter =
    let
      escapeRegex = pkgs.lib.replaceStrings [ "." "+" "?" ] [ "\\." "\\+" "\\?" ];
      paths = map (o: o.outPath) (concatMap outputsOf unfreePkgs);
    in
    if paths == [ ] then "^$" else concatStringsSep "|" (map escapeRegex paths);
}

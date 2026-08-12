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
  isReserved = n: n == "lib" || n == "overlays" || n == "modules" || n == "pkgs";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  evaluatedPackages = builtins.map builtins.fromJSON (pkgs.lib.splitString "\n" (pkgs.lib.fileContents ./evaluations.json));

  canEvaluate = p: elem: ((elem ? "attr" && (if isAttrs p then p ? "pname" else false)) && (pkgs.lib.hasInfix p.pname elem.attr) && (! (elem ? "error")));
  isBuildable = p: any (canEvaluate p) evaluatedPackages;
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

  nurAttrs = import ./default.nix { };

  nurPkgs =
    flattenPkgs
      (listToAttrs
        (map (n: nameValuePair n nurAttrs.${n})
          (filter (n: !isReserved n)
            (attrNames nurAttrs))));

  # Generate all paths to all (buildable) NUR packages
  allAttrPaths = pkgs.lib.mapAttrsRecursiveCond shouldRecurseForDerivations
    (path: value:
      if (isBuildable value && !(isBool value)) then
        concatStringsSep "." path
      else
        null)
    (pkgs.lib.filterAttrs (n: v: !isReserved n) nurAttrs);
in
rec {
  buildPkgs = filter isBuildable nurPkgs;
  cachePkgs = filter isCacheable buildPkgs;

  buildOutputs = concatMap outputsOf buildPkgs;
  cacheOutputs = concatMap outputsOf cachePkgs;
  inherit allAttrPaths;
}

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

{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs.lib)
    flatten
    mapAttrsToList
    nameValuePair
    filterAttrs
    ;
  inherit (builtins)
    isAttrs
    attrNames
    attrValues
    mapAttrs
    filter
    listToAttrs
    concatMap
    ;

  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isNotBroken = p: !(p.meta.broken or false);
  isBuildable = p: isNotBroken p && p.meta.license.free or true;
  isCacheable = p: !(p.meta.preferLocalBuild or false);
  isUpdatable = p: isDerivation p && (p.passthru ? updateScript && p.passthru.updateScript != null) && !(p.passthru.skipBulkUpdate or false);
  shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;

  flattenPkgs =
    s:
    let
      f =
        p:
        if shouldRecurseForDerivations p then
          flattenPkgs p
        else if isDerivation p then
          [ p ]
        else
          [ ];
    in
    concatMap f (attrValues s);

  flattenAttrs =
    s:
    let
      f =
        n: v:
        filterEmptyAttrs (
          if shouldRecurseForDerivations v then
            flattenAttrs v
          else if isUpdatable v then
            v
          else
            { }
        );
    in
    mapAttrs f s;


  recursiveAttrNames =
    s:
    let
      f = n: v: if isAttrs v && !isDerivation v then map (v: "${n}.${v}") (mapAttrsToList f v) else n;
    in
    flatten (mapAttrsToList f s);

  outputsOf = p: map (o: p.${o}) p.outputs;

  nurAttrs = import ./pkgs/default.nix { inherit pkgs; };

  pkgsAttrNames = (filter (n: !isReserved n) (attrNames nurAttrs));

  nurPkgs = flattenPkgs (listToAttrs (map (n: nameValuePair n nurAttrs.${n}) pkgsAttrNames));

  filterEmptyAttrs = set: filterAttrs (n: v: v != { }) set;
in
rec {
  updatablePkgs = filterEmptyAttrs (flattenAttrs nurAttrs);
  updatablePkgsNames = recursiveAttrNames updatablePkgs;

  allDrvs = nurPkgs;
  buildDrvs = filter isNotBroken nurPkgs;
  freeDrvs = filter isBuildable buildDrvs;
  cacheDrvs = filter isCacheable freeDrvs;

  allOutputs = concatMap outputsOf allDrvs;
  buildOutputs = concatMap outputsOf buildDrvs;
  freeOutputs = concatMap outputsOf freeDrvs;
  cacheOutputs = concatMap outputsOf cacheDrvs;

  allPkgs = listToAttrs (map (p: nameValuePair p.pname p) allOutputs);
  buildPkgs = listToAttrs (map (p: nameValuePair p.pname p) buildOutputs);
  freePkgs = listToAttrs (map (p: nameValuePair p.pname p) freeOutputs);
  cachePkgs = listToAttrs (map (p: nameValuePair p.pname p) cacheOutputs);
}

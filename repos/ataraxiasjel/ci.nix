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
  inherit (pkgs.lib) filterAttrs nameValuePair;
  inherit (builtins)
    attrNames
    attrValues
    concatMap
    filter
    isAttrs
    listToAttrs
    ;

  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isNotBroken = p: !(p.meta.broken or false);
  isFree = p: p.meta.license.free or true;
  isCacheable = p: !(p.meta.preferLocalBuild or false);
  isUpdatable =
    p:
    isDerivation p
    && (p.passthru ? updateScript && p.passthru.updateScript != null)
    && !(p.passthru.skipBulkUpdate or false);

  shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;

  flattenAttrs =
    func: attrs:
    let
      op =
        acc: n:
        let
          v = attrs.${n};
          x =
            if shouldRecurseForDerivations v then
              flattenAttrs func v
            else if func v then
              { ${n} = v; }
            else
              { };
        in
        acc // x;
    in
    pkgs.lib.foldl' op { } (pkgs.lib.attrNames attrs);

  outputsOf = p: map (o: p.${o}) p.outputs;
  nurAttrs = import ./pkgs/default.nix { inherit pkgs; };
  nurPkgs = flattenAttrs isDerivation nurAttrs;
  nurDrvs = attrValues nurPkgs;
in
rec {
  notReserved = filterAttrs (n: _: !(isReserved n)) nurAttrs;
  updatablePkgs = flattenAttrs isUpdatable nurAttrs;
  updatablePkgsNames = attrNames updatablePkgs;

  allDrvs = nurDrvs;
  buildDrvs = filter isNotBroken nurDrvs;
  cacheDrvs = filter isCacheable buildDrvs;
  freeDrvs = filter isFree buildDrvs;

  allOutputs = concatMap outputsOf allDrvs;
  buildOutputs = concatMap outputsOf buildDrvs;
  cacheOutputs = concatMap outputsOf cacheDrvs;
  freeOutputs = concatMap outputsOf freeDrvs;

  allPkgs = listToAttrs (map (p: nameValuePair p.pname p) allOutputs);
  buildPkgs = listToAttrs (map (p: nameValuePair p.pname p) buildOutputs);
  cachePkgs = listToAttrs (map (p: nameValuePair p.pname p) cacheOutputs);
  freePkgs = listToAttrs (map (p: nameValuePair p.pname p) freeOutputs);
}

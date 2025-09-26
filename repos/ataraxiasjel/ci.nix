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
  lib ? pkgs.lib,
  system ? pkgs.system,
}:

let
  inherit (lib) filterAttrs;
  inherit (builtins) attrNames isAttrs;

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
    lib.foldl' op { } (lib.attrNames attrs);

  nurAttrs = import ./pkgs/default.nix { inherit pkgs lib system; };
  nurPkgs = flattenAttrs isDerivation nurAttrs;
in
rec {
  notReserved = filterAttrs (n: _: !(isReserved n)) nurAttrs;
  updatablePkgs = flattenAttrs isUpdatable nurAttrs;
  updatablePkgsNames = attrNames updatablePkgs;

  allPkgs = nurPkgs;
  buildPkgs = filterAttrs (_: v: isNotBroken v) allPkgs;
  cachePkgs = filterAttrs (_: v: isCacheable v) buildPkgs;
  freePkgs = filterAttrs (_: v: isFree v) buildPkgs;
}

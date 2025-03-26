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
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
  lib ? pkgs.lib,
}:

let
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: builtins.isAttrs p && p ? type && p.type == "derivation";
  isBuildable =
    p:
    p.meta.available or true
    && !(p.meta.broken or false)
    && !(p.meta.unsupported or false)
    && p.meta.license.free or true;
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p: builtins.isAttrs p && p.recurseForDerivations or false;

  nameValuePair = n: v: {
    name = n;
    value = v;
  };

  concatMap = builtins.concatMap or (f: xs: builtins.concatLists (builtins.map f xs));

  flattenPackages =
    s:
    let
      f =
        p:
        if shouldRecurseForDerivations p then
          flattenPackages p
        else if isDerivation p then
          [ p ]
        else
          [ ];
    in
    concatMap f (builtins.attrValues s);

  outputsOf = p: builtins.map (o: p.${o}) p.outputs;

  nurAttrs = import ./. { inherit lib pkgs system; };

  nurPackages = flattenPackages (
    builtins.listToAttrs (
      builtins.map (n: nameValuePair n nurAttrs.${n}) (
        builtins.filter (n: !isReserved n) (builtins.attrNames nurAttrs)
      )
    )
  );

  buildPackages = builtins.filter isBuildable nurPackages;
  cachePackages = builtins.filter isCacheable buildPackages;

  buildOutputs = concatMap outputsOf buildPackages;
  cacheOutputs = concatMap outputsOf cachePackages;
in

{
  inherit
    buildPackages
    cachePackages
    buildOutputs
    cacheOutputs
    ;
}

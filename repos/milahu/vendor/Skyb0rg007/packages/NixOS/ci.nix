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
}:

let
  isReserved =
    n:
    n == "lib"
    || n == "overlays"
    || n == "nixosModules"
    || n == "homeModules"
    || n == "darwinModules"
    || n == "flakeModules";
  isDerivation = p: builtins.isAttrs p && p ? type && p.type == "derivation";
  isBuildable =
    p:
    let
      licenseFromMeta = p.meta.license or [ ];
      licenseList = if builtins.isList licenseFromMeta then licenseFromMeta else [ licenseFromMeta ];
    in
    !(p.meta.broken or false)
    && builtins.all lib.licenses.isRedistributable licenseList
    && lib.meta.availableOn pkgs.stdenv.hostPlatform p;
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p: builtins.isAttrs p && p.recurseForDerivations or false;

  nameValuePair = n: v: {
    name = n;
    value = v;
  };

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
    builtins.concatMap f (builtins.attrValues s);

  outputsOf = p: map (o: p.${o}) p.outputs;

  nurAttrs = import ./default.nix { inherit pkgs; };

  nurPkgs = flattenPkgs (
    builtins.listToAttrs (
      map (n: nameValuePair n nurAttrs.${n}) (
        builtins.filter (n: !isReserved n) (builtins.attrNames nurAttrs)
      )
    )
  );

in
rec {
  buildPkgs = builtins.filter isBuildable nurPkgs;
  cachePkgs = builtins.filter isCacheable buildPkgs;

  buildOutputs = builtins.concatMap outputsOf buildPkgs;
  cacheOutputs = builtins.concatMap outputsOf cachePkgs;
}

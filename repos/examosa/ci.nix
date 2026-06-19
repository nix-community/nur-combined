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
{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) lib;

  isBuildable = p: let
    isFree = let
      licenseList = lib.flatten [p.meta.license or []];
    in
      lib.all lib.licenses.isFree licenseList;

    isSupportedPlatform = lib.meta.availableOn pkgs.stdenv.hostPlatform p;

    isWorking = !(p.meta.broken or false);
  in
    isFree && isSupportedPlatform && isWorking;

  isCacheable = p: !(p.preferLocalBuild or false);

  shouldRecurseForDerivations = p: lib.isAttrs p && p.recurseForDerivations or false;

  flattenPkgs = s: let
    normalizePkg = p:
      if shouldRecurseForDerivations p
      then flattenPkgs p
      else if lib.isDerivation p
      then [p]
      else [];
  in
    lib.concatMap normalizePkg (lib.attrValues s);

  outputAttrsOf = p:
    lib.genAttrs' p.outputs (o:
      lib.nameValuePair
      "${lib.getName p}-${o}"
      p.${o});

  concatMapMergeAttrs = f: list: lib.mergeAttrsList (map f list);

  overlayAttrs = (import ./overlays).default pkgs pkgs;

  nurPkgs = flattenPkgs overlayAttrs;

  buildPkgs = lib.filter isBuildable nurPkgs;
  cachePkgs = lib.filter isCacheable buildPkgs;
in {
  inherit buildPkgs cachePkgs;
  buildOutputs = concatMapMergeAttrs outputAttrsOf buildPkgs;
  cacheOutputs = concatMapMergeAttrs outputAttrsOf cachePkgs;
}

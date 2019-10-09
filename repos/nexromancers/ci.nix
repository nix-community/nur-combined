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

let
  pathNixpkgs = builtins.tryEval <nixpkgs>;
  nixpkgs = if pathNixpkgs.success then pathNixpkgs.value
    else builtins.fetchTarball {
      url = https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
    };
in
{ pkgs ? import nixpkgs { }, buildUnfree ? false, flattened ? false }:

with builtins;

let

  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isBuildable = p:
    !(p.meta.broken or false) && (buildUnfree || p.meta.license.free or true);
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p:
    isAttrs p && p.recurseForDerivations or false;

  nameValuePair = n: v: { name = n; value = v; };

  nurAttrs = import ./default.nix { inherit pkgs; };

  nurPkgsAttrs =
    listToAttrs
    (map (n: nameValuePair n nurAttrs.${n})
    (filter (n: !isReserved n)
    (attrNames nurAttrs)));

  concatMap = builtins.concatMap or (f: xs: concatLists (map f xs));

  flattenPkgs = s:
    let
      f = p:
        if shouldRecurseForDerivations p then flattenPkgs p
        else if isDerivation p then [p]
        else [];
    in concatMap f (attrValues s);

  outputsOf = p: map (o: p.${o}) p.outputs;

  nurPkgs = flattenPkgs nurPkgsAttrs;

in

if flattened then rec {
  buildPkgs = filter isBuildable nurPkgs;
  cachePkgs = filter isCacheable buildPkgs;

  buildOutputs = concatMap outputsOf buildPkgs;
  cacheOutputs = concatMap outputsOf cachePkgs;
} else nurPkgsAttrs

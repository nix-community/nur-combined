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
  nixpkgsUrl =
    "https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz";
  nixpkgs = if pathNixpkgs.success
    then pathNixpkgs.value
    else builtins.fetchTarball { url = nixpkgsUrl; };
in
{ pkgs ? import nixpkgs { }, buildUnfree ? false, flattened ? false }:

with builtins;

let

  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isBuildable = p:
    !(p.meta.broken or false) && (buildUnfree || p.meta.license.free or true);
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p:
    isAttrs p && p.recurseForDerivations or false;

  nameValuePair = n: v: { name = n; value = v; };

  concatMap = builtins.concatMap or (f: xs: concatLists (map f xs));

  flattenPkgs = s:
    let
      f = p:
        if shouldRecurseForDerivations p then flattenPkgs p
        else if isDerivation p then [p]
        else [];
    in concatMap f (attrValues s);

  outputsOf = p: map (o: p.${o}) p.outputs;

  nurAttrs = (import ./default.nix { inherit pkgs; }).pkgs;

  nurPkgs = listToAttrs (map (n:
    nameValuePair n nurAttrs.${n}
  ) (attrNames nurAttrs));
  flattenedNurPkgs = flattenPkgs nurPkgs;

in

if flattened then rec {
  buildPkgs = filter isBuildable flattenedNurPkgs;
  cachePkgs = filter isCacheable buildPkgs;

  buildOutputs = concatMap outputsOf buildPkgs;
  cacheOutputs = concatMap outputsOf cachePkgs;
} else nurPkgs

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
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
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

  systems = [
    "x86_64-linux"
    "i686-linux"
    "x86_64-darwin"
    "aarch64-linux"
    "armv6l-linux"
    "armv7l-linux"
  ];
  forAllSystems = f: pkgs.lib.genAttrs systems (system: f system);

  flake = builtins.getFlake (builtins.toString ./.);
in
forAllSystems
  (system:
    let
      nurAttrs = flake.packages."${system}";
      nurPkgs = flattenPkgs nurAttrs;
    in
    concatMap outputsOf (filter (p: (isBuildable p) && (isCacheable p)) nurPkgs))

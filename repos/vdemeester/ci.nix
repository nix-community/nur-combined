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

{ sources ? import ./nix
, pkgs ? sources.pkgs { }
, pkgs-unstable ? sources.pkgs-unstable { }
, nixpkgs ? sources.nixpkgs { }
}:

with builtins;
let
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
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
  nurAttrs = p: import ./pkgs/default.nix { pkgs = p; };
  nurPkgs = p:
    flattenPkgs (
      listToAttrs (
        map
          (n: nameValuePair n (nurAttrs p).${n})
          (
            filter
              (n: !isReserved n)
              (attrNames (nurAttrs p))
          )
      )
    );
  nixosNurPkgs = nurPkgs pkgs;
  nixosUnstableNurPkgs = nurPkgs pkgs-unstable;
  nixpkgsNurPkgs = nurPkgs nixpkgs;
in
rec {
  nixosBuildPkgs = filter isBuildable nixosNurPkgs;
  nixosCachePkgs = filter isCacheable nixosBuildPkgs;
  nixosUnstableBuildPkgs = filter isBuildable nixosUnstableNurPkgs;
  nixosUnstableCachePkgs = filter isCacheable nixosUnstableBuildPkgs;
  nixpkgsBuildPkgs = filter isBuildable nixpkgsNurPkgs;
  nixpkgsCachePkgs = filter isCacheable nixpkgsBuildPkgs;

  nixosBuildOutputs = concatMap outputsOf nixosBuildPkgs;
  nixosCacheOutputs = concatMap outputsOf nixosCachePkgs;
  nixosUnstableBuildOutputs = concatMap outputsOf nixosUnstableBuildPkgs;
  nixosUnstableCacheOutputs = concatMap outputsOf nixosUnstableCachePkgs;
  nixpkgsBuildOutputs = concatMap outputsOf nixpkgsBuildPkgs;
  nixpkgsCacheOutputs = concatMap outputsOf nixpkgsCachePkgs;

  buildOuputs = nixosBuildOutputs ++ nixosUnstableBuildOutputs ++ nixpkgsBuildOutputs;
  cacheOutputs = nixosCacheOutputs ++ nixosUnstableCacheOutputs ++ nixpkgsCacheOutputs;
}

# This file provides all the buildable and cacheable packages and
# package outputs in your package set. These are what gets built by CI,
# so if you correctly mark packages as
#
# - broken (using `meta.broken`),
# - locally built (using `preferLocalBuild`)
#
# then your CI will be able to build and cache only those packages for
# which this is possible. This repository's Cachix is allowed to cache
# unfree and insecure packages.

{ pkgs ? import <nixpkgs> {
    config = {
      allowUnfree = true;
      allowInsecurePredicate = _: true;
    };
  }
}:

with builtins;
let
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isBuildable = p: !(p.meta.broken or false);
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

  flake = builtins.getFlake (toString ./.);
  system = pkgs.stdenv.hostPlatform.system;
  bun2nix = flake.inputs.bun2nix.packages.${system}.default;
  nurAttrs = import ./default.nix { inherit pkgs bun2nix; };

  nurPkgs =
    flattenPkgs
      (listToAttrs
        (map (n: nameValuePair n nurAttrs.${n})
          (filter (n: !isReserved n)
            (attrNames nurAttrs))));

in
rec {
  buildPkgs = filter isBuildable nurPkgs;
  cachePkgs = filter isCacheable buildPkgs;

  buildOutputs = concatMap outputsOf buildPkgs;
  cacheOutputs = concatMap outputsOf cachePkgs;
}

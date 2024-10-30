# This file provides all the buildable and cacheable packages and
# package outputs in your package set. These are what gets built by CI,
# so if you correctly mark packages as
#
# - broken (using `meta.broken`),
# - unfree (using `meta.license.free`),
# - platform-specific (using `meta.platform` and `meta.badPlatforms`), and
# - uncacheable (using `allowSubstitutes`)
#
# then your CI will be able to build and cache only those packages for
# which this is possible.

{
  platform ? null,
  includeDRL ? false,
  pkgs ? import <nixpkgs> (if platform != null then {
    localSystem = platform;
    packageOverrides = pkgs: {
      inherit (import <nixpkgs> {}) fetchurl fetchgit fetchzip; # Don't emulate curl and such
    };
  } else {})
}:

with builtins;
let
  inherit (pkgs) lib;
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isBuildable = p: let
    licenseFromMeta = p.meta.license or [];
    licenseList = if builtins.isList licenseFromMeta then licenseFromMeta else [licenseFromMeta];
  in
    lib.meta.availableOn pkgs.hostPlatform p &&
    !(p.meta.broken or false) &&
    builtins.all (license: license.free or true) licenseList &&
    (p.meta.knownVulnerabilities or []) == []
  ;
  isCacheable = p: (p.allowSubstitutes or true);
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

  nurAttrs' = import ./default.nix { inherit pkgs includeDRL; };
  nurAttrs = nurAttrs' // lib.optionalAttrs (nurAttrs'?_ciOnly) {
    _ciOnly = lib.recurseIntoAttrs nurAttrs'._ciOnly;
  };

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

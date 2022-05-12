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

with builtins;
let
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
  shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;

  flake = getFlake (toString ./.);
  inherit (flake) eachSystem;
  inherit (flake.lib) concatMap nameValuePair;

  flattenPkgs = s:
    let
      f = p:
        if shouldRecurseForDerivations p then flattenPkgs p
        else if isDerivation p then [ p ]
        else [ ];
    in
    concatMap f (attrValues s);

  outputsOf = p: map (o: p.${o}) p.outputs;

in
eachSystem
  (system:
    let
      nurAttrs = flake.ciPackages."${system}";
      nurPkgs = flattenPkgs nurAttrs;
    in
    concatMap outputsOf (filter isBuildable nurPkgs))

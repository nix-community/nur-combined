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
  flake = getFlake (toString ./.);
  inherit (flake) eachSystem;
  inherit (flake.lib) concatMap nameValuePair;
in
eachSystem (system:
  let
    isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
    isTargetPlatform = p: elem system (p.meta.platforms or [ system ]);
    isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
    shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;

    flattenPkgs = s:
      let
        f = p:
          if shouldRecurseForDerivations p then flattenPkgs p
          else if isDerivation p && isTargetPlatform p && isBuildable p then [ p ]
          else [ ];
      in
      concatMap f (attrValues s);

    outputsOf = p: map (o: p.${o}) p.outputs;

    nurPkgs = flattenPkgs flake.ciPackages."${system}";
  in
  concatMap outputsOf nurPkgs)

{ pkgs }:
with builtins;
with pkgs.lib;
rec {
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  forPlatform =
    p:
    (builtins.any (s: s == pkgs.stdenv.system) (p.meta.platforms or [ pkgs.stdenv.system ]))
    && !(builtins.any (s: s == pkgs.stdenv.system) (p.meta.badPlatforms or [ ]));
  isBuildable =
    p:
    let
      licenseFromMeta = p.meta.license or [ ];
      licenseList = if builtins.isList licenseFromMeta then licenseFromMeta else [ licenseFromMeta ];
    in
    forPlatform p
    && !(p.meta.broken or false)
    && builtins.all (license: license.free or true) licenseList;
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;

  nameValuePair = n: v: {
    name = n;
    value = v;
  };

  concatMap = builtins.concatMap or (f: xs: concatLists (map f xs));

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
    concatMap f (attrValues s);

  outputsOf = p: map (o: p.${o}) p.outputs;

  cacheableOutputs =
    ps: filter (p: isBuildable p && isCacheable p) (concatMap outputsOf (flattenPkgs ps));

  derivationOutputs =
    ps:
    listToAttrs (
      map (n: nameValuePair (strings.removePrefix "/nix/store/" (unsafeDiscardStringContext n)) n) (
        cacheableOutputs ps
      )
    );
}

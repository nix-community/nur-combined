{ pkgs }:
with builtins;
with pkgs.lib;
rec {
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  forPlatform =
    p:
    (builtins.any (s: s == pkgs.stdenv.system) (p.meta.platforms or [ pkgs.stdenv.system ]))
    && !(builtins.any (s: s == pkgs.stdenv.system) (p.meta.badPlatforms or [ ]));
  isPackage = n: p: isDerivation p && !(isReserved n) && forPlatform p;
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

  flakePackages =
    ps:
    foldl' mergeAttrs { } (
      mapAttrsToList (
        n: p:
        if isPackage n p then
          { ${n} = p; }
        else if shouldRecurseForDerivations p then
          mapAttrs' (sn: sp: {
            name = if sn == n then n else "${n}.${sn}";
            value = sp;
          }) (filterAttrs (sn: sp: isPackage sn sp) p)
        else
          { }
      ) ps
    );
}

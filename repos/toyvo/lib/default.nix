{
  lib,
}:
with builtins;
with lib;
rec {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
  maintainers.toyvo = {
    name = "Collin Diekvoss";
    email = "Collin@Diekvoss.com";
    matrix = "@toyvo:matrix.org";
    github = "ToyVo";
    githubId = 5168912;
  };

  # These ones are actually used by us!
  readDirRecursive =
    path:
    mapAttrs (
      path': type:
      (if (type == "directory" || type == "symlink") then readDirRecursive "${path}/${path'}" else type)
    ) (readDir path);
  initValueAtPath =
    path: value:
    if length path == 0 then value else { ${head path} = initValueAtPath (tail path) value; };
  attrNamesRecursive = mapAttrsToList (
    name: value:
    if isAttrs value then map (path: [ name ] ++ path) (attrNamesRecursive value) else [ name ]
  );
  filterAttrsRecursive' =
    filter: attrs:
    mapAttrs (
      name: value:
      if isAttrs value then
        filterAttrsRecursive' (path: value': filter ([ name ] ++ path) value') value
      else
        value
    ) (filterAttrs (name: value: (isAttrs value) || (filter [ name ] value)) attrs);
  mapAttrsRecursive' =
    mapping: attrs:
    foldlAttrs (
      acc: name: value:
      let
        result =
          if isAttrs value then
            mapAttrsRecursive' (path': value': mapping ([ name ] ++ path') value') value
          else
            let
              mapped = mapping [ name ] value;
            in
            initValueAtPath mapped.path mapped.value;
      in
      recursiveUpdate acc result
    ) { } attrs;
  filterAndMapAttrsRecursive' =
    filter: mapping: attrs:
    mapAttrsRecursive' mapping (filterAttrsRecursive' filter attrs);

  importDirRecursive =
    dir:
    filterAndMapAttrsRecursive' (path: value: (hasSuffix ".nix" (last path)) && value == "regular") (
      path: _: {
        path = (dropEnd 1 path) ++ [ (removeSuffix ".nix" (last path)) ];
        value = (import (concatStringsSep "/" ([ dir ] ++ path)));
      }) (readDirRecursive dir);
  callDirPackageWithRecursive =
    pkgs: dir:
    mapAttrs (_: f: f { }) (
      fix (
        nurPkgs:
        filterAndMapAttrsRecursive' (path: value: (last path == "package.nix") && value == "regular") (
          path: _: {
            path = dropEnd 1 path;
            value =
              _:
              callPackageWith (recursiveUpdate pkgs (mapAttrs (_: f: f { }) nurPkgs)) (concatStringsSep "/" (
                [ dir ] ++ path
              )) { };
          }) (readDirRecursive dir)
      )
    );
  callDirPackageWithRecursive' =
    pkgs: dir:
    filterAndMapAttrsRecursive' (path: value: (last path == "package.nix") && value == "regular") (
      path: {
        path = dropEnd 1 path;
        value = callPackageWith pkgs (concatStringsSep "/" ([ dir ] ++ path)) { };
      }) (readDirRecursive dir);

  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isBuildable =
    p:
    let
      licenseFromMeta = p.meta.license or [ ];
      licenseList = if isList licenseFromMeta then licenseFromMeta else [ licenseFromMeta ];
    in
    !(p.meta.broken or false) && all (license: license.free or true) licenseList;
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

  forSystem =
    system: p:
    (builtins.any (s: s == system) (p.meta.platforms or [ system ]))
    && !(builtins.any (s: s == system) (p.meta.badPlatforms or [ ]));

  flakeChecks =
    system: ps:
    listToAttrs (
      map (n: nameValuePair (removePrefix "/nix/store/" (strings.unsafeDiscardStringContext n)) n) (
        filter (p: isBuildable p && isCacheable p && forSystem system p) (
          concatMap outputsOf (flattenPkgs ps)
        )
      )
    );

  flakePackages =
    system: ps:
    foldl' mergeAttrs { } (
      mapAttrsToList (
        n: p:
        if isDerivation p && forSystem system p then
          { ${n} = p; }
        else if shouldRecurseForDerivations p then
          mapAttrs' (sn: sp: {
            name = if sn == n then n else "${n}.${sn}";
            value = sp;
          }) (filterAttrs (_: sp: isDerivation sp && forSystem system sp) p)
        else
          { }
      ) ps
    );
}

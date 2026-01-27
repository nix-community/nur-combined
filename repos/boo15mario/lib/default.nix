{
  lib,
}:

rec {
  # Add your library functions here
  #
  # hexint = x: hexvals.${lib.toLower x};

  # These ones are actually used by us!
  readDirRecursive =
    path:
    lib.mapAttrs (
      path': type:
      (if (type == "directory" || type == "symlink") then readDirRecursive "${path}/${path'}" else type)
    ) (builtins.readDir path);
  initValueAtPath =
    path: value:
    if lib.length path == 0 then
      value
    else
      { ${lib.head path} = initValueAtPath (lib.tail path) value; };
  attrNamesRecursive = lib.mapAttrsToList (
    name: value:
    if lib.isAttrs value then lib.map (path: [ name ] ++ path) (lib.attrNamesRecursive value) else [ name ]
  );
  filterAttrsRecursive' =
    filter: attrs:
    lib.mapAttrs (
      name: value:
      if lib.isAttrs value then
        filterAttrsRecursive' (path: value': filter ([ name ] ++ path) value') value
      else
        value
    ) (lib.filterAttrs (name: value: (lib.isAttrs value) || (filter [ name ] value)) attrs);
  mapAttrsRecursive' =
    mapping: attrs:
    lib.foldlAttrs (
      acc: name: value:
      let
        result =
          if lib.isAttrs value then
            mapAttrsRecursive' (path': value': mapping ([ name ] ++ path') value') value
          else
            let
              mapped = mapping [ name ] value;
            in
            initValueAtPath mapped.path mapped.value;
      in
      lib.recursiveUpdate acc result
    ) { } attrs;
  filterAndMapAttrsRecursive' =
    filter: mapping: attrs:
    mapAttrsRecursive' mapping (filterAttrsRecursive' filter attrs);

  importDirRecursive =
    dir:
    filterAndMapAttrsRecursive'
      (path: value: (lib.hasSuffix ".nix" (lib.last path)) && value == "regular")
      (path: _: {
        path = (lib.dropEnd 1 path) ++ [ (lib.removeSuffix ".nix" (lib.last path)) ];
        value = (import (lib.concatStringsSep "/" ([ dir ] ++ path)));
      })
      (readDirRecursive dir);
  callDirPackageWithRecursive =
    pkgs: dir:
    lib.mapAttrs (_: f: f { }) (
      lib.fix (
        nurPkgs:
        filterAndMapAttrsRecursive'
          (path: value: (lib.last path == "package.nix") && value == "regular")
          (path: _: {
            path = lib.dropEnd 1 path;
            value =
              _:
              lib.callPackageWith (lib.recursiveUpdate pkgs (lib.mapAttrs (_: f: f { }) nurPkgs)) (
                lib.concatStringsSep
                "/"
                ([ dir ] ++ path)
              ) { };
          })
          (readDirRecursive dir)
      )
    );
  callDirPackageWithRecursive' =
    pkgs: dir:
    filterAndMapAttrsRecursive'
      (path: value: (lib.last path == "package.nix") && value == "regular")
      (path: {
        path = lib.dropEnd 1 path;
        value = lib.callPackageWith pkgs (lib.concatStringsSep "/" ([ dir ] ++ path)) { };
      })
      (lib.readDirRecursive dir);
}

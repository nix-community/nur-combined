{
  lib,
  root,
  args,
}: let
  discover = directory: let
    entries = builtins.readDir directory;
  in
    lib.concatMap (
      name: let
        entryType = entries.${name};
        path = directory + "/${name}";
      in
        if entryType == "directory"
        then discover path
        else if entryType == "regular" && name != "default.nix" && lib.hasSuffix ".nix" name
        then [path]
        else []
    ) (builtins.attrNames entries);

  merge = accumulated: discovered: let
    duplicateNames = lib.intersectLists (builtins.attrNames accumulated) (builtins.attrNames discovered);
  in
    if duplicateNames != []
    then throw "duplicate discovered output names: ${lib.concatStringsSep ", " duplicateNames}"
    else accumulated // discovered;
in
  lib.foldl' merge {} (map (path: import path args) (discover root))

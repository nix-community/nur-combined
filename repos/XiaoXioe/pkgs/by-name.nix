{ lib, baseDirectory }:
let
  inherit (builtins) readDir;
  inherit (lib.attrsets)
    mapAttrs
    mapAttrsToList
    mergeAttrsList
    filterAttrs
    ;

  shards = filterAttrs (name: type: type == "directory") (readDir baseDirectory);

  namesForShard =
    shard: type:
    let
      shardPath = baseDirectory + "/${shard}";
      pkgDirs = filterAttrs (name: type: type == "directory") (readDir shardPath);
    in
    mapAttrs (name: _: shardPath + "/${name}/package.nix") pkgDirs;

  packageFiles = mergeAttrsList (mapAttrsToList namesForShard shards);
in
packageFiles

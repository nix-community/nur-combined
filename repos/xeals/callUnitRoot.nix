{ pkgs
, lib ? pkgs.lib
, unitDir ? "unit"
, packageFun ? "package.nix"
, root ? "${./pkgs}/${unitDir}"
}:
let
  shards = lib.attrNames (builtins.readDir root);
  namesForShard = shard: lib.mapAttrs'
    (name: _: { inherit name; value = root + "/${shard}/${name}"; })
    (builtins.readDir (root + "/${shard}"));
  namesToPath = lib.foldl' lib.recursiveUpdate { } (map namesForShard shards);
  units = lib.mapAttrs (_: path: pkgs.callPackage (path + "/${packageFun}") { }) namesToPath;
in
units

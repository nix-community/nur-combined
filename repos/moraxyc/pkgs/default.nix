mode:
{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  lib = pkgs.lib;
  baseDir = ./by-name;

  readDirs = path: lib.filterAttrs (n: v: v == "directory") (builtins.readDir path);

  packages = lib.makeScope pkgs.newScope (
    self:
    let
      shards = builtins.attrNames (readDirs baseDir);
      processShard =
        shard:
        let
          shardDir = baseDir + "/${shard}";
          packageNames = builtins.attrNames (readDirs shardDir);
        in
        lib.genAttrs packageNames (name: self.callPackage (shardDir + "/${name}/package.nix") { });
    in
    if builtins.pathExists baseDir then
      lib.foldl' (acc: shard: acc // (processShard shard)) { } shards
    else
      { }
  );

  filters = pkgs.callPackage ../helpers/filters.nix { };

  ciPackages = lib.filterAttrs filters.isBuildable packages;
  nurPackages = lib.filterAttrs filters.isExport packages;
in
if mode == "ci" then
  ciPackages
else if mode == "nur" then
  nurPackages
else
  packages

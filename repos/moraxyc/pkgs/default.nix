{
  pkgs ? import <nixpkgs> { },
  inputs' ? null,
  ...
}:
let
  lib = pkgs.lib;
  baseDir = ./by-name;

  deprecatedAliases = import ./deprecated.nix pkgs;

  readDirs = path: lib.filterAttrs (n: v: v == "directory") (builtins.readDir path);

  allPackages = lib.makeScope pkgs.newScope (
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

      autoDiscovered =
        if builtins.pathExists baseDir then
          lib.foldl' (acc: shard: acc // (processShard shard)) { } shards
        else
          { };
    in
    {
      upstream = pkgs;
      inherit inputs';
    }
    // autoDiscovered
    // deprecatedAliases
  );

  filters = pkgs.callPackage ../helpers/filters.nix { };

  activePackages = builtins.removeAttrs allPackages (builtins.attrNames deprecatedAliases);
in
allPackages
// {
  __drvPackages = lib.filterAttrs filters.isDrv activePackages;
  __ciPackages = lib.filterAttrs filters.isBuildable activePackages;
  __nurPackages = lib.filterAttrs filters.isExport activePackages // deprecatedAliases;
}

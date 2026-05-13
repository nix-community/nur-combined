baseDirectory:
let
  inherit (builtins)
    attrValues
    foldl'
    mapAttrs
    readDir
    ;

  namesForShard =
    shard: type:
    if type != "directory" then
      { }
    else
      let
        shardEntries = attrValues (
          mapAttrs (name: type: { inherit name type; }) (readDir (baseDirectory + "/${shard}"))
        );
        packageDirs = foldl' (
          acc: entry:
          if
            entry.type == "directory" && (readDir (baseDirectory + "/${shard}/${entry.name}")) ? "package.nix"
          then
            acc // { "${entry.name}" = entry.type; }
          else
            acc
        ) { } shardEntries;
      in
      mapAttrs (name: _: baseDirectory + "/${shard}/${name}/package.nix") packageDirs;

  packageFiles = foldl' (acc: entry: acc // (namesForShard entry.name entry.type)) { } (
    attrValues (mapAttrs (name: type: { inherit name type; }) (readDir baseDirectory))
  );
in
self: super:
{
  _nurPackageNames = builtins.attrNames packageFiles;
}
// mapAttrs (name: path: self._nurCallPackage (import path) { }) packageFiles

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
// mapAttrs (
  name: path:
  let
    imported = import path;
    fArgs = if builtins.isFunction imported then builtins.functionArgs imported else { };
    requiresInputs = fArgs ? inputs' || fArgs ? inputs;
  in
  if requiresInputs && !self._nurHasAllModuleArgs then null else self.callPackage imported { }
) packageFiles

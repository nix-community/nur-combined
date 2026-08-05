# Adapted from nixpkgs pkgs/top-level/by-name-overlay.nix
# (reckenrode/nixpkgs swift-update-mk2 @ 9bd6cfed336853908d93c95c21f39e0255ac409c).
# Takes `lib` as an argument so this tree does not need a vendored copy of nixpkgs `lib/`.

lib: baseDirectory:
let
  inherit (builtins) readDir;

  inherit (lib.attrsets)
    mapAttrs
    mapAttrsToList
    mergeAttrsList
    ;

  inherit (lib.trivial) flip;

  namesForShard =
    shard: type:
    if type != "directory" then
      { }
    else
      mapAttrs (name: _: baseDirectory + "/${shard}/${name}/package.nix") (
        readDir (baseDirectory + "/${shard}")
      );

  packageFiles = mergeAttrsList (mapAttrsToList namesForShard (readDir baseDirectory));
in
self: super:
{
  _internalCallByNamePackageFile = flip self.callPackage { };
}
// mapAttrs (name: self._internalCallByNamePackageFile) packageFiles

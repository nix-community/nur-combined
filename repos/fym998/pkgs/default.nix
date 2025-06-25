{
  pkgs,
  lib ? pkgs.lib,
  ...
}:
lib.filterAttrs (n: v: n != "default" && lib.isDerivation v) (
  lib.packagesFromDirectoryRecursive {
    inherit (pkgs) callPackage newScope;
    directory = ./.;
  }
)

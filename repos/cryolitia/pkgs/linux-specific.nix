# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
  gpd-fan-driver,
  ...
}:
let

  lib = pkgs.lib;

  linux-packages = [
    {
      name = "";
      package = pkgs.linuxPackages;
    }
    {
      name = "_latest";
      package = pkgs.linuxPackages_latest;
    }
  ];

  packagesFromDirectoryRecursive =
    {
      directory,
      ...
    }:
    let
      inherit (lib) concatMapAttrs removeSuffix;
      inherit (lib.path) append;
      defaultPath = append directory "package.nix";
      inherit (builtins) pathExists;
      inherit (lib.strings) hasSuffix;
    in
    if pathExists defaultPath then
      # if `${directory}/package.nix` exists, call it directly
      defaultPath
    else
      concatMapAttrs (
        name: type:
        # otherwise, for each directory entry
        let
          path = append directory name;
        in
        if type == "directory" then
          {
            # recurse into directories
            "${name}" = packagesFromDirectoryRecursive {
              directory = path;
            };
          }
        else if type == "regular" && hasSuffix ".nix" name then
          {
            # call .nix files
            "${removeSuffix ".nix" name}" = path;
          }
        else if type == "regular" then
          {
            # ignore non-nix files
          }
        else
          throw ''
            lib.filesystem.packagesFromDirectoryRecursive: Unsupported file type ${type} at path ${toString path}
          ''
      ) (builtins.readDir directory);
in
lib.attrsets.mergeAttrsList (
  lib.lists.forEach linux-packages (
    linux-package:
    lib.attrsets.mapAttrs'
      (
        name: package:
        lib.attrsets.nameValuePair (name + linux-package.name) (
          linux-package.package.callPackage package { }
        )
      )
      (
        {
          gpd-fan-driver = gpd-fan-driver.modulePackage;
        }
        // packagesFromDirectoryRecursive {
          directory = ../pkgs/linux;
        }
      )
  )
)

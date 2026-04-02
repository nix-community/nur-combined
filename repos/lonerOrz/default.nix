{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
  dir ? ./pkgs,
  pkgFileName ? "default.nix",
}:
let
  lib = pkgs.lib;
  entries = builtins.readDir dir;

  excludedNames = [ ];
  names = lib.filter (name: !(lib.elem name excludedNames)) (builtins.attrNames entries);

  addUpdateFile =
    drv: file:
    drv.overrideAttrs (old: {
      passthru = (old.passthru or { }) // {
        updateFile = file;
      };
    });

  importDir = lib.foldl' (
    acc: name:
    let
      path = dir + "/${name}";
      kind = entries.${name};
    in

    if kind == "regular" && lib.hasSuffix ".nix" name then
      let
        relativePath = path;
        drv = pkgs.callPackage relativePath { };
      in
      acc
      // {
        "${lib.removeSuffix ".nix" name}" = addUpdateFile drv relativePath;
      }

    else if kind == "directory" then
      let
        subPath = path + "/${pkgFileName}";
      in
      if builtins.pathExists subPath then
        let
          drv = pkgs.callPackage subPath { };
        in
        acc
        // {
          "${name}" = addUpdateFile drv subPath;
        }
      else
        acc

    else
      acc
  ) { } names;

in
importDir

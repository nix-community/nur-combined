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
    if lib.isDerivation drv && drv ? overrideAttrs then
      drv.overrideAttrs (old: {
        passthru = (old.passthru or { }) // {
          updateFile = file;
        };
      })
    else
      # 非派生包（函数、普通属性集）直接返回
      drv;

  toEntry =
    name:
    let
      path = dir + "/${name}";
      kind = entries.${name};
      isNixFile = kind == "regular" && lib.hasSuffix ".nix" name;
      subPath = path + "/${pkgFileName}";
      hasDefaultNix = kind == "directory" && builtins.pathExists subPath;
    in
    if isNixFile then
      let
        drv = pkgs.callPackage path { };
      in
      {
        name = lib.removeSuffix ".nix" name;
        value = addUpdateFile drv path;
      }
    else if hasDefaultNix then
      let
        drv = pkgs.callPackage subPath { };
      in
      {
        inherit name;
        value = addUpdateFile drv subPath;
      }
    else
      null;

  validEntries = builtins.filter (x: x != null) (map toEntry names);

in
builtins.listToAttrs validEntries

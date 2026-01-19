{ pkgs, ... }:
with pkgs.lib;
let
  callPackage = callPackageWith (pkgs // mypkgs);
  mypkgs = pipe (builtins.readDir ./.) [
    (filterAttrs (_: type: type == "directory"))
    (mapAttrs (k: v: callPackage ./${k} { }))
  ];
in
filterAttrs (
  k: v: !(v.meta ? platforms) || (builtins.elem pkgs.stdenv.hostPlatform.system v.meta.platforms)
) mypkgs

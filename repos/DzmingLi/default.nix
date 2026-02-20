# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  lib = pkgs.lib;

  importFromDir =
    dir:
    let
      entries = builtins.readDir dir;
      names = builtins.attrNames entries;
      isDir = name: entries.${name} == "directory";
      isFile = name: entries.${name} == "regular" && lib.hasSuffix ".nix" name;
      mkEntry =
        name: path:
        let
          pkg = pkgs.callPackage path { };
        in
        if pkg ? pname then
          {
            name = pkg.pname;
            value = pkg;
          }
        else
          null;
      dirPkgs =
        builtins.listToAttrs
          (builtins.filter (entry: entry != null)
            (map (name: mkEntry name (dir + "/${name}")) (builtins.filter isDir names)));
      filePkgs =
        builtins.listToAttrs
          (builtins.filter (entry: entry != null)
            (map (name: mkEntry (lib.removeSuffix ".nix" name) (dir + "/${name}")) (builtins.filter isFile names)));
    in
    dirPkgs // filePkgs;

  pkgsFrom = importFromDir ./pkgs;
in
{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
} // pkgsFrom // { mcp-nixos = pkgs.mcp-nixos; }

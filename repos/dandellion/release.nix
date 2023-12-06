{ nixpkgs ? <nixpkgs>, args ? {} }:

let
  pkgs = import nixpkgs args;
in
  pkgs.lib.attrsets.filterAttrs
    (n: v: !v.meta.broken or false)
    (import ./default.nix { inherit pkgs; })

f: { system ? builtins.currentSystem
   , pkgs ? import <nixpkgs> { inherit system; config = { }; }
   , ...
   } @ args:

with import <nixpkgs/nixos/lib/testing-python.nix> { inherit system pkgs; };
let
  input = if pkgs.lib.isFunction f then f (args // { inherit pkgs;inherit (pkgs) lib; }) else f;
  modules = pkgs.lib.attrValues (import ../../modules);
  nodes = pkgs.lib.mapAttrs (name: node: node // { imports = modules ++ (node.imports or [ ]); }) input.nodes;
in
makeTest (input // { nodes = nodes; })

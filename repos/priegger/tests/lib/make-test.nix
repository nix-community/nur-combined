f: { system ? builtins.currentSystem
   , pkgs ? import <nixpkgs> { inherit system; config = { }; }
   , ...
   } @ args:
let
  modules = pkgs.lib.attrValues (import ../../modules);
  extraConfigurations = [{ imports = modules; }];

  inherit (import <nixpkgs/nixos/lib/testing-python.nix> { inherit system pkgs extraConfigurations; }) makeTest;

  input = if pkgs.lib.isFunction f then f (args // { inherit pkgs;inherit (pkgs) lib; }) else f;
in
makeTest input

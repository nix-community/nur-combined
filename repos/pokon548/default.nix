{ pkgs ? import <nixpkgs> { } }:
let
  genPkg = f: name: {
    inherit name;
    value = f name;
  };
  pkgDir = ./pkgs;
  names = with builtins; attrNames (readDir pkgDir);
  withContents = f: with builtins; listToAttrs (map (genPkg f) names);
in 
  withContents (name: pkgs.callPackage (pkgDir + "/${name}") { })
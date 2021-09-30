{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> { inherit system; }
}:

with pkgs;
with lib;
let
  packages = {
    autorestic = pkgs.callPackage ./pkgs/autorestic { };
    activitywatch-bin = pkgs.callPackage ./pkgs/activitywatch-bin { };
    datalad = pkgs.callPackage ./pkgs/datalad { };
  };
  supportedSystem = (name: pkg: builtins.elem system pkg.meta.platforms);
in (filterAttrs supportedSystem packages)

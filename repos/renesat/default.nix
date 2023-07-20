{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> {
  inherit system;
  overlays = (import ./overlays.nix);
} }:

let
  aliases = {
    autorestic = throw "Use `pkgs.autorestic` instead";
    datalad = throw "Use `pkgs.datalad` instead";
    warpd = throw "Use `pkgs.warpd` instead";
  };
  packages = rec {
    activitywatch-bin = pkgs.callPackage ./pkgs/activitywatch-bin { };
    hledger-utils = pkgs.callPackage ./pkgs/hledger-utils { };
    drawilleplot = pkgs.callPackage ./pkgs/drawilleplot { };
    drawille = pkgs.callPackage ./pkgs/drawille { };
    # stash = pkgs.callPackage ./pkgs/stash/ui.nix { };
    math-preview = pkgs.callPackage ./pkgs/math-preview { };
    daqp = pkgs.callPackage ./pkgs/daqp { };
    daqp-python = pkgs.callPackage ./pkgs/daqp/python.nix { };
    qpsolvers = pkgs.callPackage ./pkgs/qpsolvers { daqp=daqp-python; };
  };
  supportedSystem = (name: pkg: builtins.elem system pkg.meta.platforms);
in (pkgs.lib.filterAttrs supportedSystem packages) // aliases

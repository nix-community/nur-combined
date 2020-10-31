{ pkgs, pythonPackages }:

with pkgs.lib;
let
  packages = (self:
let
  callPackage = pkgs.newScope (pythonPackages // self);
in
with self; {
  inherit callPackage;

  aamp = callPackage ./aamp { };

  botw-utils = callPackage ./botw-utils { };

  byml = callPackage ./byml { };

  debugpy = callPackage ./debugpy { };

  lunr = callPackage ./lunr { };

  mkdocs = callPackage ./mkdocs { };

  mkdocs-material = callPackage ./mkdocs-material { };

  mkdocs-material-extensions = callPackage ./mkdocs-material-extensions { };

  oead = callPackage ./oead {
    inherit (pkgs) cmake;
  };

  pygls = callPackage ./pygls { };

  pymdown-extensions = callPackage ./pymdown-extensions { };

  pytest-datadir = callPackage ./pytest-datadir { };

  rstb = callPackage ./rstb { };

  vdf = callPackage ./vdf { };
});
in
fix packages

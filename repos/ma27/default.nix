{ pkgs ? import <nixpkgs> {}, nixpkgs ? null }:

assert nixpkgs == null -> pkgs != null;

let

  lib = if pkgs == null then import "${toString nixpkgs}/lib" else pkgs.lib;

  callPackage = assert pkgs != null;
    pkgs.newScope (pkgs // nurSet);

  nurSet = import ./components.nix {
    inherit callPackage lib;
  };

in

  nurSet

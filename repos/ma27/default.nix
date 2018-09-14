{ pkgs ? import <nixpkgs> {} }:

let

  moduleList = import ./module-list.nix;

  callPackage = pkgs.newScope (pkgs // nurSet);

  nurSet = import ./packages.nix {
    inherit callPackage moduleList;
    inherit (pkgs) lib;
  };

in

  nurSet

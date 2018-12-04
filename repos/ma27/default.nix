{ pkgs ? null }:

let

  callPackage = assert pkgs != null;
    pkgs.newScope (pkgs // nurSet);

  nurSet = import ./components.nix {
    inherit callPackage;
  };

in

  nurSet

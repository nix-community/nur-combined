{ pkgs ? import <nixpkgs> {} }:

let
  nur = pkgs.callPackage ./../.. {};
  inherit (nur) dnd;
in

(pkgs.writeText "spells" (dnd.spells.byName.minorIllusion))

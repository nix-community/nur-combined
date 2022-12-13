{ pkgs ? import <nixpkgs> { }
, arc ? (import ../canon.nix { inherit pkgs; })
, self ? arc.pkgs
, super ? arc.super.pkgs
, lib ? arc.super.lib
}: let
  shells = {
  };
in arc.callPackageAttrs shells { }

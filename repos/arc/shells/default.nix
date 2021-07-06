{ pkgs ? import <nixpkgs> { }
, arc ? (import ../canon.nix { inherit pkgs; })
, self ? arc.pkgs
, super ? arc.super.pkgs
, lib ? arc.super.lib
}: let
  shells = {
    rust = import ./rust.nix;
  };
in arc.callPackageAttrs shells { }

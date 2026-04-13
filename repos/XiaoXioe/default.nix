{ pkgs ? import <nixpkgs> {} }:

let
  lib = pkgs.lib;
  pkgsPath = ./pkgs;

  # Membaca direktori secara dinamis persis seperti di flake.nix kamu
  packageDirs = lib.filterAttrs (name: type: type == "directory") (builtins.readDir pkgsPath);
  packageNames = builtins.attrNames packageDirs;
in
lib.genAttrs packageNames (
  name: pkgs.callPackage (pkgsPath + "/${name}/default.nix") { }
)

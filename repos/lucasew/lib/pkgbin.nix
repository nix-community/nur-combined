{name, pkgs ? import <nixpkgs> {}}:
let
  pkg = pkgs."${name}";
in "${pkg}/bin/${name}"

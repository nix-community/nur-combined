{ nixpkgs ? <nixpkgs>, args ? {} }:

let
  pkgs = import nixpkgs args;
in
  pkgs.callPackages ./default.nix {}

{ pkgs ? import <nixpkgs> {} }:

{
  krypton-cli = pkgs.callPackage ./krypton-cli.nix {};
}


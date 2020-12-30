# Derived from: https://github.com/nix-community/nur-combined/blob/master/repos/ijohanne/pkgs/firefox-plugins/default.nix
{ pkgs ? import <nixpkgs> {} }:
let
  inherit (pkgs) fetchFirefoxAddon fetchurl stdenv;
  buildFirefoxXpiAddon = { pname, url, sha256, ... }: 
    fetchFirefoxAddon { inherit url sha256; name = pname; };
  generated = import ./generated.nix { inherit buildFirefoxXpiAddon fetchurl stdenv; };
in
  generated // { recurseForDerivations = true; }

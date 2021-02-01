# Derived from: https://github.com/nix-community/nur-combined/blob/master/repos/ijohanne/pkgs/firefox-plugins/default.nix
{ pkgs ? import <nixpkgs> {} }:
let
  inherit (pkgs) fetchFirefoxAddon fetchurl stdenv;
  buildFirefoxXpiAddon = { pname, url, sha256, meta, ... }: let
    inherit (pkgs.stdenv.lib) licenses;
    newMeta = if meta ? license then meta else meta // { license = licenses.unfree; };
  in
    (fetchFirefoxAddon { inherit url sha256; name = pname; }) // { meta = newMeta;} ;
  generated = import ./generated.nix { inherit buildFirefoxXpiAddon fetchurl stdenv; };
in
  generated // { recurseForDerivations = true; }

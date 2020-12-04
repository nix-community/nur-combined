{ pkgs, fetchurl, stdenv }:
let
  buildFirefoxXpiAddon = { pname, url, sha256, ... }:
    pkgs.fetchFirefoxAddon { inherit url sha256; name = pname; };

  packages = import ./generated-addons.nix {
    inherit buildFirefoxXpiAddon fetchurl stdenv;
  };

in
packages // { inherit buildFirefoxXpiAddon; }

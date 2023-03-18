{ stdenv, fetchurl, lib, ... }:
let
  # copied from https://gitlab.com/rycee/nur-expressions/-/blob/master/pkgs/firefox-addons/default.nix
  buildFirefoxXpiAddon = { pname, version, addonId, url, sha256, meta, ... }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";

      inherit meta;

      src = fetchurl { inherit url sha256; };

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    }
  ;
in
import ./addons.nix {
  inherit buildFirefoxXpiAddon stdenv fetchurl lib;
}

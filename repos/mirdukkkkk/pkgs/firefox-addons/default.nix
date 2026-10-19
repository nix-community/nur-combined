{
  fetchurl,
  lib,
  stdenv,
}:
let
  # Copied from rycee's NUR repository (MIT):
  # https://gitlab.com/rycee/nur-expressions/-/blob/master/pkgs/firefox-addons/default.nix
  # NUR evaluates every repository in isolation, so it cannot be imported.
  buildMozillaXpiAddon = lib.makeOverridable (
    {
      pname,
      version,
      addonId,
      url,
      sha256,
      meta,
      ...
    }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";

      inherit meta;

      src = fetchurl { inherit url sha256; };

      preferLocalBuild = true;
      allowSubstitutes = true;

      passthru = { inherit addonId; };

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    }
  );
in
# generated.nix is written by mozilla-addons-to-nix from addons.json,
# see .github/workflows/update.yml
import ./generated.nix {
  inherit
    buildMozillaXpiAddon
    fetchurl
    lib
    stdenv
    ;
}
// {
  media-harvest = import ./media-harvest.nix { inherit buildMozillaXpiAddon lib; };
}

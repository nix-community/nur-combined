final: prev: {
  buildFirefoxXpiAddon = { pname, version, addonId, url, sha256, meta, ... }:
    final.stdenvNoCC.mkDerivation {
      inherit pname version meta;

      src = final.fetchurl { inherit url sha256; };

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        install -Dm644 "$src" "$dst/${addonId}.xpi"
      '';
    };

  firefox-addons = final.callPackage ./packages.nix { };
}

{ pkgs, ... }:
let
  inherit (pkgs) fetchurl lib stdenv;
  buildFirefoxXpiAddon = lib.makeOverridable
    ({ pname, version, addonId, url, sha256, meta, ... }:
      stdenv.mkDerivation {
        name = "${pname}-${version}";
        inherit meta;
        src = fetchurl { inherit url sha256; };
        preferLocalBuild = true;
        allowSubstitutes = true;

        buildCommand = ''
          dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
          mkdir -p "$dst"
          install -v -m644 "$src" "$dst/${addonId}.xpi"
        '';
      });
in buildFirefoxXpiAddon {
  pname = "better-english";
  version = "2.2.1webext";
  addonId = "{6d96bb5e-1175-4ebf-8ab5-5f56f1c79f65}";
  url =
    "https://addons.mozilla.org/firefox/downloads/file/1163883/english_australian_dictionary-2.2.1webext.xpi";
  sha256 = "PiB9g7R6a9dyiF8XpykAUAPhTYXNpvbautJM7VNckQc=";
  meta = with lib; {
    homepage =
      "https://addons.mozilla.org/en-US/firefox/addon/english-australian-dictionary/";
    description = "Australian English Dictionary for Mozilla applications.";
    license = licenses.gpl2;
    platforms = platforms.all;
  };
}

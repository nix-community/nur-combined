{ fetchurl, lib, stdenv }@args:

let

  buildFirefoxXpiAddon = lib.makeOverridable ({ stdenv ? args.stdenv
    , fetchurl ? args.fetchurl, pname, version, addonId, url, sha256, meta, ...
    }:
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

in {
  inherit buildFirefoxXpiAddon;

  dracula-dark-colorscheme = buildFirefoxXpiAddon {
    pname = "dracula-dark-colorscheme";
    version = "1.9.3";
    url = "https://github.com/dracula/firefox/releases/download/1.9.3/DraculaFirefoxv1.9.3.xpi";
    sha256 = "rdhqWO1rBXheky3Ybuu4tMRkSBekiFs1SSmznH3CgR0=";
    addonId = "dracula-dark-colorscheme";
    meta = with lib; {
      homepage = "https://github.com/dracula/firefox";
      description =
        "Dracula for Firefox";
      license = {
        free = false;
      };
      platforms = platforms.all;
    };
  };

}

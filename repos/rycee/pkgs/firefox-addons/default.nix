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

  packages = import ./generated-firefox-addons.nix {
    inherit buildFirefoxXpiAddon fetchurl lib stdenv;
  };

in packages // {
  inherit buildFirefoxXpiAddon;

  # Aliases.
  "1password-x-password-manager" = packages.onepassword-password-manager;

  gaoptout = buildFirefoxXpiAddon {
    pname = "gaoptout";
    version = "1.0.8";
    addonId = "{6d96bb5e-1175-4ebf-8ab5-5f56f1c79f65}";
    url = "https://dl.google.com/analytics/optout/gaoptoutaddon_1.0.8.xpi";
    sha256 = "vJKe77kKcEOrSkpDJ3nGW3j155heOgojFkDroySE0r8=";
    meta = with lib; {
      homepage = "https://tools.google.com/dlpage/gaoptout";
      description = "Tells the Google Analytics JavaScript not to send information to Google Analytics.";
      license = {
        shortName = "gaooba";
        fullName = "Google Analytics Opt-out Browser Add-on - Additional Terms of Service";
        url = "http://tools.google.com/dlpage/gaoptout/intl/en/eula_text.html";
        free = false;
      };
      platforms = platforms.all;
    };
  };

  proxydocile = buildFirefoxXpiAddon {
    pname = "proxydocile";
    version = "2.3";
    addonId = "proxydocile@unipd.it";
    url = "https://softwarecab.cab.unipd.it/proxydocile/proxydocile.xpi";
    sha256 = "sha256-Xz6BpDHtqbLfTbmlXiNMzUkqRxmEtPw3q+JzvpzA938=";
    meta = with lib; {
      homepage =
        "https://bibliotecadigitale.cab.unipd.it/bd/proxy/proxy-docile";
      description = "Automatically connect to university proxy.";
      platforms = platforms.all;
    };
  };
}

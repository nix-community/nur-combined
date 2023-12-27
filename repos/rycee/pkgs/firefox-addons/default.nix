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

  "1password-x-password-manager" = packages.onepassword-password-manager;

  bypass-paywalls-clean = let version = "3.4.7.0";
  in buildFirefoxXpiAddon {
    pname = "bypass-paywalls-clean";
    inherit version;
    addonId = "magnolia@12.34";
    url =
      "https://gitlab.com/magnolia1234/bpc-uploads/-/raw/master/bypass_paywalls_clean-${version}.xpi";
    sha256 = "sha256-GNpv/P3J0AVTv4fIpHIB/j6miSsiK58WXB/ZgIp7uCs=";
    meta = with lib; {
      homepage =
        "https://gitlab.com/magnolia1234/bypass-paywalls-firefox-clean";
      description = "Bypass Paywalls of (custom) news sites";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };

  enhancer-for-youtube = buildFirefoxXpiAddon {
    pname = "enhancer-for-youtube";
    version = "2.0.121";
    addonId = "enhancerforyoutube@maximerf.addons.mozilla.org";
    url =
      "https://web.archive.org/web/20231025064948id_/https://addons.mozilla.org/firefox/downloads/file/4157491/enhancer_for_youtube-2.0.121.xpi";
    sha256 = "baaba2f8eef7166c1bee8975be63fc2c28d65f0ee48c8a0d1c1744b66db8a2ad";
    meta = with lib; {
      homepage = "https://www.mrfdev.com/enhancer-for-youtube";
      description = "Take control of YouTube and boost your user experience!";
      license = {
        shortName = "enhancer-for-youtube";
        fullName = "Custom License for Enhancer for YouTube™";
        url =
          "https://addons.mozilla.org/en-US/firefox/addon/enhancer-for-youtube/license/";
        free = false;
      };
      mozPermissions = [
        "cookies"
        "storage"
        "*://www.youtube.com/*"
        "*://www.youtube.com/embed/*"
        "*://www.youtube.com/live_chat*"
        "*://www.youtube.com/pop-up-player/*"
        "*://www.youtube.com/shorts/*"
      ];
      platforms = platforms.all;
    };
  };

  fx_cast = let version = "0.3.1";
  in buildFirefoxXpiAddon {
    pname = "fx_cast";
    inherit version;
    addonId = "fx_cast@matt.tf";
    url =
      "https://github.com/hensm/fx_cast/releases/download/v${version}/fx_cast-${version}.xpi";
    sha256 = "sha256-zaYnUJpJkRAPSCpM3S20PjMS4aeBtQGhXB2wgdlFkSQ=";
    meta = with lib; {
      homepage = "https://hensm.github.io/fx_cast/";
      description = "Chromecast Web Sender SDK implementation for Firefox";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };

  gaoptout = buildFirefoxXpiAddon {
    pname = "gaoptout";
    version = "1.0.8";
    addonId = "{6d96bb5e-1175-4ebf-8ab5-5f56f1c79f65}";
    url = "https://dl.google.com/analytics/optout/gaoptoutaddon_1.0.8.xpi";
    sha256 = "vJKe77kKcEOrSkpDJ3nGW3j155heOgojFkDroySE0r8=";
    meta = with lib; {
      homepage = "https://tools.google.com/dlpage/gaoptout";
      description =
        "Tells the Google Analytics JavaScript not to send information to Google Analytics.";
      license = {
        shortName = "gaooba";
        fullName =
          "Google Analytics Opt-out Browser Add-on - Additional Terms of Service";
        url = "http://tools.google.com/dlpage/gaoptout/intl/en/eula_text.html";
        free = false;
      };
      platforms = platforms.all;
    };
  };

  mullvad = let version = "0.8.3";
  in buildFirefoxXpiAddon {
    pname = "mullvad";
    inherit version;
    addonId = "{d19a89b9-76c1-4a61-bcd4-49e8de916403}";
    url =
      "https://cdn.mullvad.net/browser-extension/${version}/mullvad-browser-extension-${version}.xpi";
    sha256 = "sha256-5THOboCQketAhIh06p5pW85hGWOXttgjirWCoVLgKsc=";
    meta = with lib; {
      homepage = "https://mullvad.net/en/download/browser/extension";
      description = "Mullvad Browser Extension";
      license = licenses.gpl3Plus;
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

  trilium-web-clipper = let version = "1.0.1";
  in buildFirefoxXpiAddon {
    pname = "trilium-web-clipper";
    inherit version;
    addonId = "{1410742d-b377-40e7-a9db-63dc9c6ec99c}";
    url =
      "https://github.com/zadam/trilium-web-clipper/releases/download/v${version}/trilium_web_clipper-${version}.xpi";
    sha256 = "sha256-VLDky7KQz8SBKowwEAWdEs1f1OZvEa+SRfWSjDrc5Cg=";
    meta = with lib; {
      homepage = "https://github.com/zadam/trilium-web-clipper";
      description = "Save web clippings to Trilium Notes";
      license = licenses.gpl3Plus;
      platforms = platforms.all;
    };
  };
}

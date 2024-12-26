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

      passthru = { inherit addonId; };

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    });

  generatedPackages = import ./generated-firefox-addons.nix {
    inherit buildFirefoxXpiAddon fetchurl lib stdenv;
  };

  packages = generatedPackages // {
    inherit buildFirefoxXpiAddon;

    "1password-x-password-manager" = packages.onepassword-password-manager;

    "7tv" = packages.seventv;

    # Upstream deletes old versions from the repository, causing builds to fail.
    # The download link should be updated pending
    # https://github.com/bpc-clone/bypass-paywalls-firefox-clean/issues/232
    bypass-paywalls-clean = let version = "3.8.7.0";
    in buildFirefoxXpiAddon {
      pname = "bypass-paywalls-clean";
      inherit version;
      addonId = "magnolia@12.34";
      url =
        "https://gitflic.ru/project/magnolia1234/bpc_uploads/blob/raw?file=bypass_paywalls_clean-${version}.xpi";
      sha256 = "sha256-A+V4BFjBn+TcKifWrVOnzuSaW5ROTNLqWI5MUIzBx9Y=";
      meta = with lib; {
        homepage = "https://twitter.com/Magnolia1234B";
        description = "Bypass Paywalls of (custom) news sites";
        license = licenses.mit;
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
          url =
            "http://tools.google.com/dlpage/gaoptout/intl/en/eula_text.html";
          free = false;
        };
        platforms = platforms.all;
      };
    };

    mullvad = let version = "0.9.3";
    in buildFirefoxXpiAddon {
      pname = "mullvad";
      inherit version;
      addonId = "{d19a89b9-76c1-4a61-bcd4-49e8de916403}";
      url =
        "https://cdn.mullvad.net/browser-extension/${version}/mullvad-browser-extension-${version}.xpi";
      sha256 = "sha256-/GvHyFCt+IRf7BW36gYyT2X4QxVeLMXb2HGeNENlEq8=";
      meta = with lib; {
        homepage = "https://mullvad.net/en/download/browser/extension";
        description = "Mullvad Browser Extension";
        license = licenses.gpl3Plus;
        platforms = platforms.all;
      };
    };

    proxydocile = buildFirefoxXpiAddon {
      pname = "proxydocile";
      version = "2.4";
      addonId = "proxydocile@unipd.it";
      url = "https://softwarecab.cab.unipd.it/proxydocile/proxydocile.xpi";
      sha256 = "sha256-XiN4iJYs+nR227Yx9kCd1xPc3UQeaOrke6TEegcbgg0=";
      meta = with lib; {
        homepage =
          "https://bibliotecadigitale.cab.unipd.it/bd/proxy/proxy-docile";
        description = "Automatically connect to university proxy.";
        platforms = platforms.all;
      };
    };

    seventv = let version = "3.0.9";
    in buildFirefoxXpiAddon {
      pname = "7tv";
      inherit version;
      addonId = "moz-addon-prod@7tv.app";
      url =
        "https://github.com/SevenTV/Extension/releases/download/v${version}/7tv-webextension-ext-signed.xpi";
      sha256 = "32LAjiEthFYwK6GwoWaeKk1C9F28kmWuudZ5htZZs2o=";
      meta = with lib; {
        homepage = "https://7tv.app/";
        description =
          "The Web Extension for 7TV, bringing new features, emotes, vanity and performance to Twitch, Kick & YouTube";
        license = licenses.asl20;
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

    zotero-connector =
      import ./zotero.nix { inherit buildFirefoxXpiAddon fetchurl lib stdenv; };
  };

in packages

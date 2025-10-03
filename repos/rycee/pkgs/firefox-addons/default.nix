{
  fetchurl,
  lib,
  stdenv,
}@args:

let

  buildFirefoxXpiAddon = lib.makeOverridable (
    {
      stdenv ? args.stdenv,
      fetchurl ? args.fetchurl,
      pname,
      version,
      addonId,
      url ? "",
      urls ? [ ], # Alternative for 'url' a list of URLs to try in specified order.
      sha256,
      meta,
      ...
    }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";

      inherit meta;

      src = fetchurl { inherit url urls sha256; };

      preferLocalBuild = true;
      allowSubstitutes = true;

      passthru = {
        inherit addonId;
      };

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    }
  );

  generatedPackages = import ./generated-firefox-addons.nix {
    inherit
      buildFirefoxXpiAddon
      fetchurl
      lib
      stdenv
      ;
  };

  packages = generatedPackages // {
    inherit buildFirefoxXpiAddon;

    "1password-x-password-manager" = packages.onepassword-password-manager;

    "7tv" = packages.seventv;

    asbplayer =
      let
        version = "1.12.0";
      in
      buildFirefoxXpiAddon {
        pname = "asbplayer";
        inherit version;
        addonId = "{e4b27483-2e73-4762-b2ec-8d988a143a40}";
        url = "https://github.com/killergerbah/asbplayer/releases/download/v${version}/asbplayer-extension-${version}-firefox.xpi";
        sha256 = "sha256-HBlO0MJSjopaLYccWYLlTZlt3nrVNHCP1H7bJVcxm1E=";
        meta = with lib; {
          homepage = "https://github.com/killergerbah/asbplayer";
          description = "Browser-based media player and Chrome extension for subtitle sentence mining ";
          license = licenses.mit;
          mozPermissions = [
            "tabs"
            "storage"
            "contextMenus"
            "webRequest"
            "webRequestBlocking"
            "clipboardWrite"
            "<all_urls>"
          ];
          platforms = platforms.all;
        };
      };

    enhancer-for-youtube = buildFirefoxXpiAddon {
      pname = "enhancer-for-youtube";
      version = "2.0.130.1";
      addonId = "enhancerforyoutube@maximerf.addons.mozilla.org";
      urls = [
        "https://addons.mozilla.org/firefox/downloads/file/4393561/enhancer_for_youtube-2.0.130.1.xpi"
        "https://www.mrfdev.com/downloads/enhancer_for_youtube-2.0.130.1.xpi"
        "https://github.com/PerchunPak/storage/raw/ae69d69b3323ea56b86c7ec2c07f3ece677dfb20/firefox/enhancer_for_youtube-2.0.130.1.xpi"
      ];
      sha256 = "6d84dcba9b197840f485d66d3fd435279d6e1bcd2155d28389999e87ea01312c";
      meta = with lib; {
        homepage = "https://www.mrfdev.com/enhancer-for-youtube";
        description = "Take control of YouTube and boost your user experience!";
        license = {
          shortName = "enhancer-for-youtube";
          fullName = "Custom License for Enhancer for YouTube™";
          url = "https://addons.mozilla.org/en-US/firefox/addon/enhancer-for-youtube/license/";
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

    fx_cast =
      let
        version = "0.3.1";
      in
      buildFirefoxXpiAddon {
        pname = "fx_cast";
        inherit version;
        addonId = "fx_cast@matt.tf";
        url = "https://github.com/hensm/fx_cast/releases/download/v${version}/fx_cast-${version}.xpi";
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

    mullvad =
      let
        version = "0.9.3";
      in
      buildFirefoxXpiAddon {
        pname = "mullvad";
        inherit version;
        addonId = "{d19a89b9-76c1-4a61-bcd4-49e8de916403}";
        url = "https://cdn.mullvad.net/browser-extension/${version}/mullvad-browser-extension-${version}.xpi";
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
      version = "2.5";
      addonId = "proxydocile@unipd.it";
      url = "https://softwarecab.cab.unipd.it/proxydocile/proxydocile.xpi";
      sha256 = "sha256-w07JQmaq0eu+KnC26F6fS5iFg7bgsYMSZaTHgklu2aw=";
      meta = with lib; {
        homepage = "https://bibliotecadigitale.cab.unipd.it/bd/proxy/proxy-docile";
        description = "Automatically connect to university proxy.";
        platforms = platforms.all;
      };
    };

    seventv =
      let
        version = "3.0.9";
      in
      buildFirefoxXpiAddon {
        pname = "7tv";
        inherit version;
        addonId = "moz-addon-prod@7tv.app";
        url = "https://github.com/SevenTV/Extension/releases/download/v${version}/7tv-webextension-ext-signed.xpi";
        sha256 = "32LAjiEthFYwK6GwoWaeKk1C9F28kmWuudZ5htZZs2o=";
        meta = with lib; {
          homepage = "https://7tv.app/";
          description = "The Web Extension for 7TV, bringing new features, emotes, vanity and performance to Twitch, Kick & YouTube";
          license = licenses.asl20;
          platforms = platforms.all;
        };
      };

    trilium-web-clipper =
      let
        version = "1.0.1";
      in
      buildFirefoxXpiAddon {
        pname = "trilium-web-clipper";
        inherit version;
        addonId = "{1410742d-b377-40e7-a9db-63dc9c6ec99c}";
        url = "https://github.com/zadam/trilium-web-clipper/releases/download/v${version}/trilium_web_clipper-${version}.xpi";
        sha256 = "sha256-VLDky7KQz8SBKowwEAWdEs1f1OZvEa+SRfWSjDrc5Cg=";
        meta = with lib; {
          homepage = "https://github.com/zadam/trilium-web-clipper";
          description = "Save web clippings to Trilium Notes";
          license = licenses.gpl3Plus;
          platforms = platforms.all;
        };
      };

    free-map-genie =
      let
        version = "2.1.1";
      in
      buildFirefoxXpiAddon {
        pname = "free-map-genie";
        inherit version;
        addonId = "viper-fmg@freemapgenie.com";
        url = "https://github.com/V1P3R-FMG/free-map-genie/releases/download/v${version}/fmg-firefox-v${version}.xpi";
        sha256 = "4eee47959d3e553c683ab380b532c58c457bc6f2f1f9a7fc831941d95b293359";
        meta = with lib; {
          homepage = "https://github.com/V1P3R-FMG/free-map-genie";
          description = "Unlock mapgenie pro features for free";
          license = licenses.mit;
          platforms = platforms.all;
        };
      };

    # The same uBlock Origin as from Mozilla site but instead fetched from the
    # upstream source (GitHub).
    ublock-origin-upstream = generatedPackages.ublock-origin.overrideAttrs (prev: {
      src =
        let
          version = lib.getVersion prev.name;
        in
        prev.src.overrideAttrs {
          url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.firefox.signed.xpi";
        };
    });

    zotero-connector = import ./zotero.nix {
      inherit
        buildFirefoxXpiAddon
        lib
        ;
    };

    improved-intra =
      let
        version = "4.4.0";
      in
      buildFirefoxXpiAddon {
        pname = "improved-intra";
        inherit version;
        addonId = "{56d1b2d9-ceba-435d-b8a5-b89dd0d1f9ef}";
        url = "https://github.com/FreekBes/improved_intra/releases/download/v${version}/firefox.xpi";
        sha256 = "d14e951035c86d783379fff74ee6ced942834ae2fc3774715a2f9aa67f562ab3";
        meta = with lib; {
          homepage = "https://github.com/FreekBes/improved_intra";
          description = "The ultimate browser extension for 42's Intranet, adding many improvements, such as dark mode, customizable profiles and much more!";
          license = licenses.mit;
          platforms = platforms.all;
        };
      };
  };

in
packages

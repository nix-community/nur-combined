{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }@args:
let
 buildFirefoxXpiAddonFromFile = lib.makeOverridable ({ stdenv ? args.stdenv
    , fetchurl ? args.fetchurl, pname, version, addonId, path, meta, ...
    }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";

      inherit meta;

      preferLocalBuild = true;
      allowSubstitutes = true;

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$path" "$dst/${addonId}.xpi"
      '';
    });

  packages = import ./generated-firefox-addons.nix {
    inherit buildFirefoxXpiAddon fetchurl lib stdenv;
  };
in
  {
    /*
    "onetab" = buildFirefoxXpiAddonFromFile {
      pname = "onetab";
      version = "4.2.240";
    };
    */



    "visionary-bold-fixed" = buildFirefoxXpiAddon {
      pname = "visionary-bold-fixed";
      version = "1.0";
      addonId = "{8d38d24a-dd1b-4142-8873-bbaa32e4e44f}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4122855/visionary_bold_fixed-1.0.xpi";
      sha256 = "c4aed779329b980c7e59cf2353e54108713d60b515b918bf7a535f9944c01ae8";
      meta = with lib;
      {
        description = "As you could notice almost all new mozilla's dark themes (colorways bold) are little broken (dark tabs on dark background). I decided to fix this moment in Visionary Bold theme.";
        license = licenses.cc-by-30;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "visionary-bold" = buildFirefoxXpiAddon {
      pname = "visionary-bold";
      version = "2.1";
      addonId = "visionary-bold-colorway@mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4066246/visionary_bold-2.1.xpi";
      sha256 = "73b6a25f41877f2c199c0b07ef28d25f69b067ab56bc08cf238e9fb89dfa92d9";
      meta = with lib;
      {
        description = "You question the status quo and move others to imagine a better future.";
        license = licenses.cc-by-30;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "atom-one-dark-theme2" = buildFirefoxXpiAddon {
      pname = "atom-one-dark-theme2";
      version = "2.0";
      addonId = "{53de5a1e-f54c-45f7-b86e-09f0161b85f3}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3369239/atom_one_dark_theme2-2.0.xpi";
      sha256 = "3168163ab8bf2da4a64d10f266c50fd0a03226c6260b60cbcbb4e8779db53b02";
      meta = with lib;
      {
        description = "the atom dark theme extrack for the oponime software";
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "simple-style-fox" = buildFirefoxXpiAddon {
      pname = "simple-style-fox";
      version = "4.0";
      addonId = "{05914925-648e-42bc-9024-3b4ea9ec379e}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3890846/simple_style_fox-4.0.xpi";
      sha256 = "2d8369ca5215030db03dcce61c3bf4c358fe0c97b6a3e89a64a146063195c038";
      meta = with lib;
      {
        description = "Simple style fox";
        license = licenses.cc-by-30;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "adguard-adblocker" = buildFirefoxXpiAddon {
      pname = "adguard-adblocker";
      version = "4.2.240";
      addonId = "adguardadblocker@adguard.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4209021/adguard_adblocker-4.2.240.xpi";
      sha256 = "30790a6d58a2ccc31dc703544f25ef193a8a60074bf2f5775097739db4bcc2e0";
      meta = with lib;
      {
        homepage = "https://adguard.com/";
        description = "Unmatched adblock extension against advertising and pop-ups. Blocks ads on Facebook, Youtube and all other websites.";
        license = licenses.lgpl3;
        mozPermissions = [
          "tabs"
          "<all_urls>"
          "webRequest"
          "webRequestBlocking"
          "webNavigation"
          "storage"
          "contextMenus"
          "cookies"
          "privacy"
          "http://*/*"
          "https://*/*"
          "*://*.adguard.com/*/thankyou.html*"
          "*://*.adguard.info/*/thankyou.html*"
          "*://*.adguard.app/*/thankyou.html*"
          ];
        platforms = platforms.all;
        };
      };
    "grepper" = buildFirefoxXpiAddon {
      pname = "grepper";
      version = "0.0.8.9";
      addonId = "grepper@codegrepper.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4069054/grepper-0.0.8.9.xpi";
      sha256 = "17db8b2f138f442882f7db5ba40e6d2af591c45e322cf3262628705c76af1b04";
      meta = with lib;
      {
        description = "The Query &amp; Answer System for the Coder Community";
        mozPermissions = [
          "storage"
          "webRequest"
          "activeTab"
          "<all_urls>"
          "alarms"
          "https://www.google.com/*"
          "https://www.google.co.uk/*"
          "https://www.google.co.za/*"
          "https://www.google.co.th/*"
          "https://www.google.co.jp/*"
          "https://www.google.co.il/*"
          "https://www.google.es/*"
          "https://www.google.ca/*"
          "https://www.google.de/*"
          "https://www.google.it/*"
          "https://www.google.fr/*"
          "https://www.google.com.au/*"
          "https://www.google.com.ph/*"
          "https://www.google.com.tw/*"
          "https://www.google.com.br/*"
          "https://www.google.com.ua/*"
          "https://www.google.com.my/*"
          "https://www.google.com.hk/*"
          "https://www.google.ru/*"
          "https://www.google.com.tr/*"
          "https://www.google.be/*"
          "https://www.google.com.gr/*"
          "https://www.google.co.in/*"
          "https://www.google.com.mx/*"
          "https://www.google.dk/*"
          "https://www.google.com.ar/*"
          "https://www.google.ch/*"
          "https://www.google.cl/*"
          "https://www.google.co.kr/*"
          "https://www.google.com.co/*"
          "https://www.google.pl/*"
          "https://www.google.pt/*"
          "https://www.google.com.pk/*"
          "https://www.google.co.id/*"
          "https://www.google.com.vn/*"
          "https://www.google.nl/*"
          "https://www.google.se/*"
          "https://www.google.com.sg/*"
          "http://*/*"
          "https://*/*"
          "http://localhost:8888/grepper_app/*"
          "https://www.codegrepper.com/*"
          "https://www.grepper.com/*"
          "https://staging.codegrepper.com/*"
          "https://www.grepper.com/app/notifications.php"
          ];
        platforms = platforms.all;
        };
      };
    }

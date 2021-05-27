{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
  {
    "enhancer-for-youtube" = buildFirefoxXpiAddon {
      pname = "enhancer-for-youtube";
      version = "2.0.104.12";
      addonId = "enhancerforyoutube@maximerf.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3780706/enhancer_for_youtubetm-2.0.104.12-fx.xpi";
      sha256 = "17217b857409bbe1b1e520e4b542b90e893d2e3f61493424945083b79f245a7e";
      meta = with lib;
      {
        homepage = "https://www.mrfdev.com/enhancer-for-youtube";
        description = "Take control of YouTube and boost your user experience!";
        license = {
          shortName = "clefy";
          fullName = "Custom License for Enhancer for YouTube";
          url = "https://addons.mozilla.org/en-US/firefox/addon/enhancer-for-youtube/license/";
          free = false;
          };
        platforms = platforms.all;
        };
      };
    "nextcloud-passwords" = buildFirefoxXpiAddon {
      pname = "nextcloud-passwords";
      version = "2.1.2";
      addonId = "ncpasswords@mdns.eu";
      url = "https://addons.mozilla.org/firefox/downloads/file/3782489/passwords_for_nextcloud_browser_add_on-2.1.2-an+fx.xpi";
      sha256 = "d096f4b5690f0391619a7f3f8d955f5d591db9ba816c58ea4d98ea5bb1dff9ce";
      meta = with lib;
      {
        homepage = "https://github.com/marius-wieschollek/passwords-webextension";
        description = "The official browser extension for the Passwords app for Nextcloud.";
        license = licenses.lgpl3;
        platforms = platforms.all;
        };
      };
    "sponsorblock" = buildFirefoxXpiAddon {
      pname = "sponsorblock";
      version = "2.0.16.2";
      addonId = "sponsorBlocker@ajay.app";
      url = "https://addons.mozilla.org/firefox/downloads/file/3780797/sponsorblock_skip_sponsorships_on_youtube-2.0.16.2-an+fx.xpi";
      sha256 = "17c15d51df20c5b00bdce6032c6c8ac464e8802b65241e141e3c41abfa98bc6a";
      meta = with lib;
      {
        homepage = "https://sponsor.ajay.app";
        description = "Easily skip YouTube video sponsors. When you visit a YouTube video, the extension will check the database for reported sponsors and automatically skip known sponsors. You can also report sponsors in videos.\n\nOther browsers: https://sponsor.ajay.app";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    }
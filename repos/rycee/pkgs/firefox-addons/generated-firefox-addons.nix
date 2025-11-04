{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
  {
    "10ten-ja-reader" = buildFirefoxXpiAddon {
      pname = "10ten-ja-reader";
      version = "1.25.1";
      addonId = "{59812185-ea92-4cca-8ab7-cfcacee81281}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4539398/10ten_ja_reader-1.25.1.xpi";
      sha256 = "808ed4f1b5db774c6b2e3f0d68b6f8bb46293bc94a0d5450f0d877aa60407d63";
      meta = with lib;
      {
        homepage = "https://10ten.life";
        description = "Quickly translate Japanese by hovering over words. Formerly released as Rikaichamp.";
        license = licenses.gpl3;
        mozPermissions = [
          "alarms"
          "clipboardWrite"
          "contextMenus"
          "storage"
          "unlimitedStorage"
          "http://*/*"
          "https://*/*"
          "file:///*"
          "https://docs.google.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "2fas-two-factor-authentication" = buildFirefoxXpiAddon {
      pname = "2fas-two-factor-authentication";
      version = "1.7.4";
      addonId = "admin@2fas.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4486799/2fas_two_factor_authentication-1.7.4.xpi";
      sha256 = "1009604f495182a7e3f83c24252bcfafaa24061fc3e2e03e406b0e9f9a49038e";
      meta = with lib;
      {
        homepage = "https://2fas.com/";
        description = "2FAS Auth Browser Extension is simple, private, and secured: one click, one tap, and your 2FA token is automatically entered!";
        license = licenses.gpl3;
        mozPermissions = [
          "activeTab"
          "tabs"
          "storage"
          "notifications"
          "contextMenus"
          "webNavigation"
          "https://*/*"
          "http://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "a11ycss" = buildFirefoxXpiAddon {
      pname = "a11ycss";
      version = "2.1.0";
      addonId = "a11y.css@ffoodd";
      url = "https://addons.mozilla.org/firefox/downloads/file/4403161/a11ycss-2.1.0.xpi";
      sha256 = "f531360f0466a387a753d92a36695e43b34707433aa676c6454c4621f95a47c2";
      meta = with lib;
      {
        homepage = "https://ffoodd.github.io/a11y.css/";
        description = "a11y.css provides warnings about possible risks and mistakes that exist in HTML code through a style sheet. This extension also provides several accessibility-related utilities.\n\nsee https://github.com/ffoodd/a11y.css/tree/webextension for  details";
        license = licenses.mit;
        mozPermissions = [ "activeTab" "storage" "scripting" "tabs" "*://*/*" ];
        platforms = platforms.all;
      };
    };
    "about-sync" = buildFirefoxXpiAddon {
      pname = "about-sync";
      version = "0.25.20250227.104629";
      addonId = "aboutsync@mhammond.github.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4445183/about_sync-0.25.20250227.104629.xpi";
      sha256 = "f3b84776bb50f9c0ee3b98204428049cd1a28483fd0df2e470d8de1d0b4762eb";
      meta = with lib;
      {
        homepage = "https://github.com/mhammond/aboutsync";
        description = "Show information about Firefox Sync.\nThis addon shows information about your Sync account, including showing all server data for your account. It is designed primarily for Sync developers or advanced users.";
        license = licenses.mpl20;
        mozPermissions = [ "mozillaAddons" ];
        platforms = platforms.all;
      };
    };
    "absolute-enable-right-click" = buildFirefoxXpiAddon {
      pname = "absolute-enable-right-click";
      version = "1.3.9resigned1";
      addonId = "{9350bc42-47fb-4598-ae0f-825e3dd9ceba}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4274207/absolute_enable_right_click-1.3.9resigned1.xpi";
      sha256 = "46cd0be06eb1decc2095b1afd47fd11aee80db7d5576b59f8794246ef65301ff";
      meta = with lib;
      {
        description = "Force Enable Right Click &amp; Copy";
        license = licenses.bsd2;
        mozPermissions = [ "tabs" "storage" "activeTab" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "adaptive-tab-bar-colour" = buildFirefoxXpiAddon {
      pname = "adaptive-tab-bar-colour";
      version = "3.2";
      addonId = "ATBC@EasonWong";
      url = "https://addons.mozilla.org/firefox/downloads/file/4583675/adaptive_tab_bar_colour-3.2.xpi";
      sha256 = "f85389acf19923f81cb3f5500c9f95dfa7a444fd65fd539b08f757acd65347fe";
      meta = with lib;
      {
        homepage = "https://github.com/easonwong-de/Adaptive-Tab-Bar-Colour";
        description = "Changes the color of Firefox theme to match the website’s appearance.";
        license = licenses.mit;
        mozPermissions = [
          "tabs"
          "theme"
          "storage"
          "browserSettings"
          "management"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "adblocker-ultimate" = buildFirefoxXpiAddon {
      pname = "adblocker-ultimate";
      version = "3.8.44";
      addonId = "adblockultimate@adblockultimate.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4589990/adblocker_ultimate-3.8.44.xpi";
      sha256 = "d21fd716564460bd369501a3157711ab44856421b165475736cadcf41f5c676c";
      meta = with lib;
      {
        homepage = "https://adblockultimate.net";
        description = "Completely remove ALL ads. No “acceptable” ads or whitelisted advertisers allowed. This free extensions also helps block trackers and malware.";
        license = licenses.lgpl3;
        mozPermissions = [
          "tabs"
          "<all_urls>"
          "webRequest"
          "webRequestBlocking"
          "webNavigation"
          "storage"
          "unlimitedStorage"
          "contextMenus"
          "http://*/*"
          "https://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "add-custom-search-engine" = buildFirefoxXpiAddon {
      pname = "add-custom-search-engine";
      version = "5.0";
      addonId = "{af37054b-3ace-46a2-ac59-709e4412bec6}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4464745/add_custom_search_engine-5.0.xpi";
      sha256 = "8b91bae54ef4d3b00cf7478fffc1bc005037bf6acd554d22169f95754b996e96";
      meta = with lib;
      {
        description = "Add a custom search engine to the list of available search engines in the search bar and URL bar.";
        license = licenses.mpl20;
        mozPermissions = [
          "https://paste.mozilla.org/api/"
          "https://dpaste.org/api/"
          "search"
        ];
        platforms = platforms.all;
      };
    };
    "addy_io" = buildFirefoxXpiAddon {
      pname = "addy_io";
      version = "2.3.8";
      addonId = "browser-extension@anonaddy";
      url = "https://addons.mozilla.org/firefox/downloads/file/4603730/addy_io-2.3.8.xpi";
      sha256 = "c6d893176526cddf0cacea9239254965ec6b1b35a639eba2d2d5e2b7d19e30b8";
      meta = with lib;
      {
        homepage = "https://addy.io";
        description = "Open-source Anonymous Email Forwarding. \n\nQuickly and easily view, search, manage and create new aliases in just a few clicks using the addy.io browser extension.";
        license = licenses.mit;
        mozPermissions = [ "storage" "activeTab" ];
        platforms = platforms.all;
      };
    };
    "adnauseam" = buildFirefoxXpiAddon {
      pname = "adnauseam";
      version = "3.26.0";
      addonId = "adnauseam@rednoise.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4592803/adnauseam-3.26.0.xpi";
      sha256 = "9897fd5c29b535092ef61210bf9579fa5a1b073d298e403a35e1bf2c0b35c70f";
      meta = with lib;
      {
        homepage = "https://adnauseam.io";
        description = "Blocking ads and fighting back against advertising surveillance.";
        license = licenses.gpl3;
        mozPermissions = [
          "alarms"
          "dns"
          "menus"
          "privacy"
          "storage"
          "tabs"
          "unlimitedStorage"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "management"
          "<all_urls>"
          "http://*/*"
          "https://*/*"
          "file://*/*"
          "https://easylist.to/*"
          "https://*.fanboy.co.nz/*"
          "https://filterlists.com/*"
          "https://forums.lanik.us/*"
          "https://github.com/*"
          "https://*.github.io/*"
          "https://github.com/uBlockOrigin/*"
          "https://ublockorigin.github.io/*"
          "https://*.reddit.com/r/uBlockOrigin/*"
        ];
        platforms = platforms.all;
      };
    };
    "adsum-notabs" = buildFirefoxXpiAddon {
      pname = "adsum-notabs";
      version = "1.2resigned1";
      addonId = "{c9f848fb-3fb6-4390-9fc1-e4dd4d1c5122}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4274750/adsum_notabs-1.2resigned1.xpi";
      sha256 = "853674a75add207d3c9635de0a43a478eed8805c0e6b673c1f5f4a26f765eb0e";
      meta = with lib;
      {
        homepage = "https://gitlab.com/adsum/firefox-notabs";
        description = "Disable tabs completely, by always opening a new window instead.";
        license = licenses.gpl3;
        mozPermissions = [ "tabs" ];
        platforms = platforms.all;
      };
    };
    "alby" = buildFirefoxXpiAddon {
      pname = "alby";
      version = "3.13.0";
      addonId = "extension@getalby.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4587202/alby-3.13.0.xpi";
      sha256 = "b64c2405de386e9660c798d456490e231763c3bed6175cc479c6071eb84dfe84";
      meta = with lib;
      {
        homepage = "https://getAlby.com/";
        description = "Your Bitcoin Lightning wallet and companion for accessing Bitcoin and Nostr apps, payments across the globe and passwordless logins.";
        license = licenses.mit;
        mozPermissions = [
          "nativeMessaging"
          "notifications"
          "storage"
          "tabs"
          "unlimitedStorage"
          "contextMenus"
          "*://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "alfred-launcher-integration" = buildFirefoxXpiAddon {
      pname = "alfred-launcher-integration";
      version = "1.2.0";
      addonId = "alfredfirefox@deanishe.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/3713996/alfred_launcher_integration-1.2.0.xpi";
      sha256 = "73e620f6c01dd61c7f1a9b17aae54cdcfded46214dc0b685296f9594a221f639";
      meta = with lib;
      {
        homepage = "https://github.com/deanishe/alfred-firefox";
        description = "Integrate Firefox with Alfred — Search your Firefox bookmarks &amp; history and control Firefox tabs from Alfred.";
        license = licenses.mit;
        mozPermissions = [
          "<all_urls>"
          "bookmarks"
          "downloads"
          "history"
          "tabs"
          "nativeMessaging"
        ];
        platforms = platforms.all;
      };
    };
    "amp2html" = buildFirefoxXpiAddon {
      pname = "amp2html";
      version = "2.1.0";
      addonId = "{569456be-2850-4f7e-b669-71e55140ee0a}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3546077/amp2html-2.1.0.xpi";
      sha256 = "762e4032782c30d3d4805371c7730ac36255ab57f5ce5279b4849f0d4ca65790";
      meta = with lib;
      {
        homepage = "https://www.daniel.priv.no/web-extensions/amp2html.html";
        description = "Automatically redirects AMP pages to the regular web page variant.";
        license = licenses.mit;
        mozPermissions = [
          "*://t.co/*"
          "https://bing-amp.com/c/*"
          "https://*.bing-amp.com/c/*"
          "https://cdn.ampproject.org/c/*"
          "https://*.cdn.ampproject.org/c/*"
          "https://www.bing.com/amp/*"
          "https://www.google.com/amp/*"
          "webRequest"
          "webRequestBlocking"
          "http://*/*"
          "https://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "anchors-reveal" = buildFirefoxXpiAddon {
      pname = "anchors-reveal";
      version = "1.2resigned1";
      addonId = "jid1-XX0TcCGBa7GVGw@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4270578/anchors_reveal-1.2resigned1.xpi";
      sha256 = "bcae97368b2c2271cf694676a2fb29dd168698e6e8105a6df6607fcf0bbce77a";
      meta = with lib;
      {
        homepage = "http://dascritch.net/post/2014/06/24/Sniffeur-d-ancre";
        description = "Reveal the anchors in a webpage";
        license = licenses.gpl3;
        mozPermissions = [ "activeTab" "storage" "contextMenus" ];
        platforms = platforms.all;
      };
    };
    "angular-devtools" = buildFirefoxXpiAddon {
      pname = "angular-devtools";
      version = "1.4.1";
      addonId = "{20a9bb38-ed7c-4faf-9aaf-7c5d241fd747}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4598947/angular_devtools-1.4.1.xpi";
      sha256 = "4a2cf078e6a41eb67121efc867e6f350e050dad97ece520b9b2b707f41741543";
      meta = with lib;
      {
        homepage = "https://angular.dev/tools/devtools/";
        description = "Angular DevTools extends Firefox DevTools adding Angular specific debugging and profiling capabilities.";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "storage"
          "http://*/*"
          "https://*/*"
          "file:///*"
          "devtools"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "animalese-typing" = buildFirefoxXpiAddon {
      pname = "animalese-typing";
      version = "1.45.3";
      addonId = "dagexviii.dev@gmail.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4494704/animalese_typing-1.45.3.xpi";
      sha256 = "850842d4f68e20715d39fab86e832fb8bbc50a518b10d76cb16949f80d4e5f13";
      meta = with lib;
      {
        description = "Plays animal crossing villager sounds whenever you type!";
        license = licenses.mpl20;
        mozPermissions = [ "scripting" "storage" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "anki-jpdb-reader" = buildFirefoxXpiAddon {
      pname = "anki-jpdb-reader";
      version = "0.7.1";
      addonId = "{67e602c3-7324-4b00-85cd-b652eb47b0f9}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4554049/anki_jpdb_reader-0.7.1.xpi";
      sha256 = "3022235a979953222c66a143153ea9cb0205fb63d44f6ee53d2416df4eab3054";
      meta = with lib;
      {
        homepage = "https://github.com/Kagu-chan/anki-jpdb.reader";
        description = "Japanese text parsing + sentence mining with JPDB and Anki";
        license = licenses.mit;
        mozPermissions = [ "contextMenus" "scripting" "storage" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "annotations-restored" = buildFirefoxXpiAddon {
      pname = "annotations-restored";
      version = "1.2";
      addonId = "{0731d555-4732-4047-99f9-38a388ffa044}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4002251/annotations_restored-1.2.xpi";
      sha256 = "114666c34865b32f31162e47959da3b46735f31c9166ce71fd60a97f04822c64";
      meta = with lib;
      {
        homepage = "https://github.com/isaackd/AnnotationsRestored";
        description = "Brings annotation support back to YouTube™!";
        license = licenses.gpl3;
        mozPermissions = [
          "https://storage.googleapis.com/biggest_bucket/annotations/*"
          "storage"
          "*://www.youtube.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "archivebox-exporter" = buildFirefoxXpiAddon {
      pname = "archivebox-exporter";
      version = "1.3.1";
      addonId = "archivebox@tjhorner.dev";
      url = "https://addons.mozilla.org/firefox/downloads/file/3865261/archivebox_exporter-1.3.1.xpi";
      sha256 = "b50223ee208308c40ed6d96c24c7ea2085f956fe45bbe0b1aed9a837a6af73b2";
      meta = with lib;
      {
        homepage = "https://github.com/ArchiveBox/archivebox-browser-extension";
        description = "Automatically or manually send pages to your ArchiveBox for archival.";
        license = licenses.mit;
        mozPermissions = [
          "history"
          "contextMenus"
          "storage"
          "alarms"
          "*://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "are-na" = buildFirefoxXpiAddon {
      pname = "are-na";
      version = "2.12.0";
      addonId = "{4245110a-2f3e-4f78-8303-10cae12384cc}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4574392/are_na-2.12.0.xpi";
      sha256 = "a3575ac6500799fbc074e1609c44be95840cbaa9d471c8cce735dbe483d94566";
      meta = with lib;
      {
        homepage = "https://www.are.na";
        description = "Assemble and connect information.";
        license = licenses.mit;
        mozPermissions = [ "activeTab" "contextMenus" "storage" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "aria2-integration" = buildFirefoxXpiAddon {
      pname = "aria2-integration";
      version = "0.4.5";
      addonId = "{e2488817-3d73-4013-850d-b66c5e42d505}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3025850/aria2_integration-0.4.5.xpi";
      sha256 = "1672866f9860499d1a1d5848baab506431ac7db2e99253d517c3735f84410f26";
      meta = with lib;
      {
        description = "Replace built-in download manager. When activated, detects the download links to direct links to this add-on and send to Aria2";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "tabs"
          "notifications"
          "downloads"
          "downloads.open"
          "contextMenus"
          "webRequest"
          "webRequestBlocking"
          "cookies"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "ask-historians-comment-helper" = buildFirefoxXpiAddon {
      pname = "ask-historians-comment-helper";
      version = "1.0.6";
      addonId = "ask_historians_comment_helper@reddit";
      url = "https://addons.mozilla.org/firefox/downloads/file/4451056/ask_historians_comment_helper-1.0.6.xpi";
      sha256 = "2319bb56e08b758251cc8772b8bb94453d0bcdf32cfd9aa50d4f80dddfaf99bb";
      meta = with lib;
      {
        description = "Ask Historians Comment Helper will show an improved comment count for the sub-reddit r/AskHistorians.\nIt also allows you to monitor topics to see when they will get an answer.";
        license = licenses.gpl2;
        mozPermissions = [
          "storage"
          "*://*.reddit.com/"
          "*://*.reddit.com/hot/"
          "*://*.reddit.com/new/"
          "*://*.reddit.com/rising/"
          "*://*.reddit.com/controversial/"
          "*://*.reddit.com/top/"
          "*://*.reddit.com/gilded/"
          "*://*.reddit.com/r/askhistorians/*"
          "*://*.reddit.com/r/AskHistorians/*"
          "*://*.reddit.com/r/popular/"
          "*://*.reddit.com/r/Popular/"
          "*://*.reddit.com/r/all/"
          "*://*.reddit.com/r/All/"
        ];
        platforms = platforms.all;
      };
    };
    "audiocontext-suspender" = buildFirefoxXpiAddon {
      pname = "audiocontext-suspender";
      version = "1.4";
      addonId = "audiocontextsuspender@h43z";
      url = "https://addons.mozilla.org/firefox/downloads/file/4377466/audiocontext_suspender-1.4.xpi";
      sha256 = "c6b941dc5d8633005b72627575c9aa2dbbb4ea9edb7e1ab00bda35bc177adaf4";
      meta = with lib;
      {
        description = "Suspending AudioContext instances automatically";
        license = licenses.mpl20;
        mozPermissions = [ "activeTab" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "augmented-steam" = buildFirefoxXpiAddon {
      pname = "augmented-steam";
      version = "4.3.1";
      addonId = "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4588502/augmented_steam-4.3.1.xpi";
      sha256 = "b89391a31c490e59a9ab0f209a8efd6bfa172b39bc07a59f8653ceab2eeec75a";
      meta = with lib;
      {
        homepage = "https://augmentedsteam.com/";
        description = "Augments your Steam Experience";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "contextMenus"
          "webRequest"
          "*://store.steampowered.com/*"
          "*://steamcommunity.com/*"
          "*://steamcommunity.com/id/*/inventory"
          "*://steamcommunity.com/id/*/inventory/"
          "*://steamcommunity.com/id/*/inventory/?*"
          "*://steamcommunity.com/id/*/inventory?*"
          "*://steamcommunity.com/profiles/*/inventory"
          "*://steamcommunity.com/profiles/*/inventory/"
          "*://steamcommunity.com/profiles/*/inventory/?*"
          "*://steamcommunity.com/profiles/*/inventory?*"
          "*://steamcommunity.com/sharedfiles"
          "*://steamcommunity.com/sharedfiles/"
          "*://steamcommunity.com/sharedfiles/?*"
          "*://steamcommunity.com/sharedfiles?*"
          "*://steamcommunity.com/workshop"
          "*://steamcommunity.com/workshop/"
          "*://steamcommunity.com/workshop/?*"
          "*://steamcommunity.com/workshop?*"
          "*://steamcommunity.com/id/*/friends"
          "*://steamcommunity.com/id/*/friends/*"
          "*://steamcommunity.com/id/*/friends?*"
          "*://steamcommunity.com/profiles/*/friends"
          "*://steamcommunity.com/profiles/*/friends/*"
          "*://steamcommunity.com/profiles/*/friends?*"
          "*://steamcommunity.com/id/*/groups"
          "*://steamcommunity.com/id/*/groups/*"
          "*://steamcommunity.com/id/*/groups?*"
          "*://steamcommunity.com/profiles/*/groups"
          "*://steamcommunity.com/profiles/*/groups/*"
          "*://steamcommunity.com/profiles/*/groups?*"
          "*://steamcommunity.com/id/*/following"
          "*://steamcommunity.com/id/*/following/*"
          "*://steamcommunity.com/id/*/following?*"
          "*://steamcommunity.com/profiles/*/following"
          "*://steamcommunity.com/profiles/*/following/*"
          "*://steamcommunity.com/profiles/*/following?*"
          "*://steamcommunity.com/sharedfiles/editguide/?*"
          "*://steamcommunity.com/sharedfiles/editguide?*"
          "*://steamcommunity.com/workshop/editguide/?*"
          "*://steamcommunity.com/workshop/editguide?*"
          "*://steamcommunity.com/app/*/guides"
          "*://steamcommunity.com/app/*/guides/"
          "*://steamcommunity.com/app/*/guides/?*"
          "*://steamcommunity.com/app/*/guides?*"
          "*://steamcommunity.com/tradingcards/boostercreator"
          "*://steamcommunity.com/tradingcards/boostercreator/"
          "*://steamcommunity.com/tradingcards/boostercreator/?*"
          "*://steamcommunity.com/tradingcards/boostercreator?*"
          "*://steamcommunity.com/app/*"
          "*://steamcommunity.com/market"
          "*://steamcommunity.com/market/"
          "*://steamcommunity.com/market/?*"
          "*://steamcommunity.com/market?*"
          "*://steamcommunity.com/id/*/badges"
          "*://steamcommunity.com/id/*/badges/"
          "*://steamcommunity.com/id/*/badges/?*"
          "*://steamcommunity.com/id/*/badges?*"
          "*://steamcommunity.com/profiles/*/badges"
          "*://steamcommunity.com/profiles/*/badges/"
          "*://steamcommunity.com/profiles/*/badges/?*"
          "*://steamcommunity.com/profiles/*/badges?*"
          "*://store.steampowered.com/"
          "*://store.steampowered.com/?*"
          "*://*.steampowered.com/sub/*"
          "*://*.steampowered.com/bundle/*"
          "*://steamcommunity.com/sharedfiles/filedetails"
          "*://steamcommunity.com/sharedfiles/filedetails/*"
          "*://steamcommunity.com/sharedfiles/filedetails?*"
          "*://steamcommunity.com/workshop/filedetails"
          "*://steamcommunity.com/workshop/filedetails/*"
          "*://steamcommunity.com/workshop/filedetails?*"
          "*://*.steampowered.com/steamaccount/addfunds"
          "*://*.steampowered.com/steamaccount/addfunds/"
          "*://*.steampowered.com/steamaccount/addfunds/?*"
          "*://*.steampowered.com/steamaccount/addfunds?*"
          "*://*.steampowered.com/digitalgiftcards/selectgiftcard"
          "*://*.steampowered.com/digitalgiftcards/selectgiftcard/"
          "*://*.steampowered.com/digitalgiftcards/selectgiftcard/?*"
          "*://*.steampowered.com/digitalgiftcards/selectgiftcard?*"
          "*://steamcommunity.com/id/*/myworkshopfiles/?*browsefilter=mysubscriptions*"
          "*://steamcommunity.com/id/*/myworkshopfiles?*browsefilter=mysubscriptions*"
          "*://steamcommunity.com/profiles/*/myworkshopfiles/?*browsefilter=mysubscriptions*"
          "*://steamcommunity.com/profiles/*/myworkshopfiles?*browsefilter=mysubscriptions*"
          "*://steamcommunity.com/id/*"
          "*://steamcommunity.com/profiles/*"
          "*://steamcommunity.com/market/search"
          "*://steamcommunity.com/market/search/*"
          "*://steamcommunity.com/market/search?*"
          "*://*.steampowered.com/search"
          "*://*.steampowered.com/search/*"
          "*://*.steampowered.com/search?*"
          "*://steamcommunity.com/id/*/friendsthatplay/*"
          "*://steamcommunity.com/profiles/*/friendsthatplay/*"
          "*://*.steampowered.com/account/registerkey"
          "*://*.steampowered.com/account/registerkey/"
          "*://*.steampowered.com/account/registerkey/?*"
          "*://*.steampowered.com/account/registerkey?*"
          "*://steamcommunity.com/id/*/recommended"
          "*://steamcommunity.com/id/*/recommended/"
          "*://steamcommunity.com/id/*/recommended/?*"
          "*://steamcommunity.com/id/*/recommended?*"
          "*://steamcommunity.com/profiles/*/recommended"
          "*://steamcommunity.com/profiles/*/recommended/"
          "*://steamcommunity.com/profiles/*/recommended/?*"
          "*://steamcommunity.com/profiles/*/recommended?*"
          "*://steamcommunity.com/id/*/reviews"
          "*://steamcommunity.com/id/*/reviews/"
          "*://steamcommunity.com/id/*/reviews/?*"
          "*://steamcommunity.com/id/*/reviews?*"
          "*://steamcommunity.com/profiles/*/reviews"
          "*://steamcommunity.com/profiles/*/reviews/"
          "*://steamcommunity.com/profiles/*/reviews/?*"
          "*://steamcommunity.com/profiles/*/reviews?*"
          "*://steamcommunity.com/groups/*"
          "*://*.steampowered.com/account"
          "*://*.steampowered.com/account/"
          "*://*.steampowered.com/account/?*"
          "*://*.steampowered.com/account?*"
          "*://steamcommunity.com/id/*/home"
          "*://steamcommunity.com/id/*/home/"
          "*://steamcommunity.com/id/*/home/?*"
          "*://steamcommunity.com/id/*/home?*"
          "*://steamcommunity.com/profiles/*/home"
          "*://steamcommunity.com/profiles/*/home/"
          "*://steamcommunity.com/profiles/*/home/?*"
          "*://steamcommunity.com/profiles/*/home?*"
          "*://steamcommunity.com/id/*/myactivity"
          "*://steamcommunity.com/id/*/myactivity/"
          "*://steamcommunity.com/id/*/myactivity/?*"
          "*://steamcommunity.com/id/*/myactivity?*"
          "*://steamcommunity.com/profiles/*/myactivity"
          "*://steamcommunity.com/profiles/*/myactivity/"
          "*://steamcommunity.com/profiles/*/myactivity/?*"
          "*://steamcommunity.com/profiles/*/myactivity?*"
          "*://steamcommunity.com/id/*/friendactivitydetail/*"
          "*://steamcommunity.com/profiles/*/friendactivitydetail/*"
          "*://steamcommunity.com/id/*/status/*"
          "*://steamcommunity.com/profiles/*/status/*"
          "*://store.steampowered.com/account/licenses"
          "*://store.steampowered.com/account/licenses/"
          "*://store.steampowered.com/account/licenses/?*"
          "*://store.steampowered.com/account/licenses?*"
          "*://steamcommunity.com/sharedfiles/browse"
          "*://steamcommunity.com/sharedfiles/browse/"
          "*://steamcommunity.com/sharedfiles/browse/?*"
          "*://steamcommunity.com/sharedfiles/browse?*"
          "*://steamcommunity.com/workshop/browse"
          "*://steamcommunity.com/workshop/browse/"
          "*://steamcommunity.com/workshop/browse/?*"
          "*://steamcommunity.com/workshop/browse?*"
          "*://*.steampowered.com/points"
          "*://*.steampowered.com/points/*"
          "*://*.steampowered.com/points?*"
          "*://steamcommunity.com/tradeoffer/*"
          "*://*.steampowered.com/agecheck/*"
          "*://*.steampowered.com/wishlist"
          "*://*.steampowered.com/wishlist/"
          "*://*.steampowered.com/wishlist/?*"
          "*://*.steampowered.com/wishlist?*"
          "*://*.steampowered.com/wishlist/id/*"
          "*://*.steampowered.com/wishlist/profiles/*"
          "*://*.steampowered.com/app/*"
          "*://steamcommunity.com/id/*/stats/*"
          "*://steamcommunity.com/profiles/*/stats/*"
          "*://*.steampowered.com/*"
          "*://steamcommunity.com/id/*/edit/*"
          "*://steamcommunity.com/profiles/*/edit/*"
          "*://*.steampowered.com/cart"
          "*://*.steampowered.com/cart/*"
          "*://*.steampowered.com/cart?*"
          "*://steamcommunity.com/id/*/games"
          "*://steamcommunity.com/id/*/games/"
          "*://steamcommunity.com/id/*/games/?*"
          "*://steamcommunity.com/id/*/games?*"
          "*://steamcommunity.com/profiles/*/games"
          "*://steamcommunity.com/profiles/*/games/"
          "*://steamcommunity.com/profiles/*/games/?*"
          "*://steamcommunity.com/profiles/*/games?*"
          "*://steamcommunity.com/id/*/followedgames"
          "*://steamcommunity.com/id/*/followedgames/"
          "*://steamcommunity.com/id/*/followedgames/?*"
          "*://steamcommunity.com/id/*/followedgames?*"
          "*://steamcommunity.com/profiles/*/followedgames"
          "*://steamcommunity.com/profiles/*/followedgames/"
          "*://steamcommunity.com/profiles/*/followedgames/?*"
          "*://steamcommunity.com/profiles/*/followedgames?*"
          "*://steamcommunity.com/market/listings/*"
          "*://steamcommunity.com/id/*/gamecards/*"
          "*://steamcommunity.com/profiles/*/gamecards/*"
        ];
        platforms = platforms.all;
      };
    };
    "auth-helper" = buildFirefoxXpiAddon {
      pname = "auth-helper";
      version = "8.0.2";
      addonId = "authenticator@mymindstorm";
      url = "https://addons.mozilla.org/firefox/downloads/file/4353166/auth_helper-8.0.2.xpi";
      sha256 = "dbab91947237df4c8597fea1b00dce05cf7faea277223f2c51090f9148812a62";
      meta = with lib;
      {
        homepage = "https://github.com/Authenticator-Extension/Authenticator";
        description = "Authenticator generates 2-Step Verification codes in your browser.";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "storage"
          "identity"
          "alarms"
          "scripting"
        ];
        platforms = platforms.all;
      };
    };
    "auto-referer" = buildFirefoxXpiAddon {
      pname = "auto-referer";
      version = "0.8.53";
      addonId = "{f6a3df9c-c297-46a1-bb84-d9cb00b314f0}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4561344/auto_referer-0.8.53.xpi";
      sha256 = "10ec932a4bf6de382db80696a84e86716a4b81694c668a654ccfdf9cc0e9b626";
      meta = with lib;
      {
        homepage = "https://garywill.github.io";
        description = "Control HTTP referer to protect privacy and not break web. And this is the addon (maybe the only one?) that deals with the 'document.referrer' bug";
        license = licenses.gpl2;
        mozPermissions = [
          "webRequest"
          "webRequestBlocking"
          "*://*/*"
          "ws://*/*"
          "wss://*/*"
          "<all_urls>"
          "contextMenus"
          "tabs"
          "storage"
        ];
        platforms = platforms.all;
      };
    };
    "auto-sort-bookmarks" = buildFirefoxXpiAddon {
      pname = "auto-sort-bookmarks";
      version = "3.4.5";
      addonId = "sortbookmarks@bouanto";
      url = "https://addons.mozilla.org/firefox/downloads/file/3948412/auto_sort_bookmarks-3.4.5.xpi";
      sha256 = "8cbeb04f2c46dcd28a6762c7a4ebd617124a8b1854a94fec15af37fd247b86fd";
      meta = with lib;
      {
        homepage = "https://github.com/eric-bixby/auto-sort-bookmarks-webext";
        description = "Sort bookmarks by multiple criteria";
        license = licenses.gpl3;
        mozPermissions = [ "bookmarks" "downloads" "history" "storage" "tabs" ];
        platforms = platforms.all;
      };
    };
    "auto-tab-discard" = buildFirefoxXpiAddon {
      pname = "auto-tab-discard";
      version = "0.6.7";
      addonId = "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4045009/auto_tab_discard-0.6.7.xpi";
      sha256 = "89e59b8603c444258c89a507d7126be52ad7a35e4f7b8cfbca039b746f70b5d5";
      meta = with lib;
      {
        homepage = "https://webextension.org/listing/tab-discard.html";
        description = "Increase browser speed and reduce memory load and when you have numerous open tabs.";
        license = licenses.mpl20;
        mozPermissions = [
          "idle"
          "storage"
          "contextMenus"
          "notifications"
          "alarms"
          "*://*/*"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "automatic-dark" = buildFirefoxXpiAddon {
      pname = "automatic-dark";
      version = "1.4.1";
      addonId = "{9ed7d361-ccd9-4cad-9846-977da2651fb5}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4074771/automatic_dark-1.4.1.xpi";
      sha256 = "77efc42567960695ab4fade263e201cca0b85c1af8dd1dd69906b0950fa46a8c";
      meta = with lib;
      {
        homepage = "https://github.com/skhzhang/time-based-themes/";
        description = "Automatically change Firefox's theme based on the time.";
        license = licenses.mit;
        mozPermissions = [
          "alarms"
          "browserSettings"
          "management"
          "storage"
          "theme"
        ];
        platforms = platforms.all;
      };
    };
    "aw-watcher-web" = buildFirefoxXpiAddon {
      pname = "aw-watcher-web";
      version = "0.5.2";
      addonId = "{ef87d84c-2127-493f-b952-5b4e744245bc}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4452349/aw_watcher_web-0.5.2.xpi";
      sha256 = "d5ef6cfd0764296a9ab2342499fbaac368bfffc13dd3d0c6ac5f2dbfdb942470";
      meta = with lib;
      {
        homepage = "https://github.com/ActivityWatch/aw-watcher-web";
        description = "This extension logs the current tab and your browser activity to ActivityWatch.";
        license = licenses.mpl20;
        mozPermissions = [
          "tabs"
          "alarms"
          "notifications"
          "activeTab"
          "storage"
          "http://127.0.0.1:5600/api/*"
          "http://127.0.0.1:5666/api/*"
        ];
        platforms = platforms.all;
      };
    };
    "awesome-rss" = buildFirefoxXpiAddon {
      pname = "awesome-rss";
      version = "1.3.6resigned1";
      addonId = "{97d566da-42c5-4ef4-a03b-5a2e5f7cbcb2}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4272927/awesome_rss-1.3.6resigned1.xpi";
      sha256 = "383981387b37cba3ba1931235dfa58cb8b76ec7dff6195d1adbfde221a26c36b";
      meta = with lib;
      {
        description = "Puts an RSS/Atom subscribe button back in URL bar.\n\nSupports \"Live Bookmarks\" (built-in), Feedly, &amp; Inoreader";
        license = licenses.gpl3;
        mozPermissions = [ "tabs" "storage" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "aws-extend-switch-roles3" = buildFirefoxXpiAddon {
      pname = "aws-extend-switch-roles3";
      version = "6.0.1";
      addonId = "aws-extend-switch-roles@toshi.tilfin.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4609208/aws_extend_switch_roles3-6.0.1.xpi";
      sha256 = "627a37d531f3849b090d8865a82fd4b29c15203bb321e981c73f8a7a91302b8b";
      meta = with lib;
      {
        homepage = "https://github.com/tilfinltd/aws-extend-switch-roles";
        description = "Extend your AWS IAM switching roles. You can set the configuration by aws config format";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "storage"
          "https://*.console.aws.amazon.com/*"
          "https://health.aws.amazon.com/*"
          "https://lightsail.aws.amazon.com/*"
          "https://*.console.amazonaws-us-gov.com/*"
          "https://phd.amazonaws-us-gov.com/*"
          "https://*.console.amazonaws.cn/*"
          "https://health.amazonaws.cn/*"
        ];
        platforms = platforms.all;
      };
    };
    "bandcamp-player-volume-control" = buildFirefoxXpiAddon {
      pname = "bandcamp-player-volume-control";
      version = "1.0.3";
      addonId = "{308ec088-284a-40fe-ae14-7c917526f694}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4084124/bandcamp_player_volume_control-1.0.3.xpi";
      sha256 = "16c2e385faf56728d6467d3352ce410388daf377b5994d559e8cf88b524c143c";
      meta = with lib;
      {
        homepage = "https://github.com/butterknight/bandcamp-volume-control";
        description = "It's a volume control for Bandcamp audio player. The extension adds another slider (somewhere around the one that controls the track progress) to control the volume.";
        license = licenses.asl20;
        mozPermissions = [
          "storage"
          "https://*.bandcamp.com/*"
          "https://music.monstercat.com/*"
          "https://shop.attackthemusic.com/*"
          "https://listen.20buckspin.com/*"
          "https://halleylabs.com/*"
          "https://music.dynatronsynth.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "batchcamp" = buildFirefoxXpiAddon {
      pname = "batchcamp";
      version = "1.5.0";
      addonId = "{d44fa1f9-1400-401d-a79e-650d466ec6d6}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4504980/batchcamp-1.5.0.xpi";
      sha256 = "cea2fe84df3733bd78de0369dce18da4f0ae71d808b1af9ed40653eaf85955eb";
      meta = with lib;
      {
        homepage = "https://deejay.tools";
        description = "Bulk downloader for your Bandcamp purchases";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "downloads"
          "cookies"
          "https://bandcamp.com/*"
          "https://*.bandcamp.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "behave" = buildFirefoxXpiAddon {
      pname = "behave";
      version = "0.9.7.1";
      addonId = "{17c7f098-dbb8-4f15-ad39-8b578da80f7e}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3606644/behave-0.9.7.1.xpi";
      sha256 = "983b43da26b49df421186c5d550b27aad36e38761089c032eb18441d3ffd21d9";
      meta = with lib;
      {
        description = "A monitoring browser extension for pages acting as bad boys";
        license = licenses.gpl3;
        mozPermissions = [
          "webRequest"
          "webRequestBlocking"
          "notifications"
          "storage"
          "<all_urls>"
          "tabs"
        ];
        platforms = platforms.all;
      };
    };
    "behind-the-overlay-revival" = buildFirefoxXpiAddon {
      pname = "behind-the-overlay-revival";
      version = "1.8.3";
      addonId = "{c0e1baea-b4cb-4b62-97f0-278392ff8c37}";
      url = "https://addons.mozilla.org/firefox/downloads/file/1749632/behind_the_overlay_revival-1.8.3.xpi";
      sha256 = "95c9b03c87f2d02cae3625d85b3aab286b01647c84752811fb0be9b49b3f6a22";
      meta = with lib;
      {
        homepage = "https://gitlab.com/ivanruvalcaba/BehindTheOverlayRevival";
        description = "Click to close any overlay popup on any website.";
        license = licenses.gpl3;
        mozPermissions = [ "activeTab" "menus" "storage" "tabs" ];
        platforms = platforms.all;
      };
    };
    "belgium-eid" = buildFirefoxXpiAddon {
      pname = "belgium-eid";
      version = "1.0.32";
      addonId = "belgiumeid@eid.belgium.be";
      url = "https://addons.mozilla.org/firefox/downloads/file/3736679/belgium_eid-1.0.32.xpi";
      sha256 = "b76cdb139f08b8778094cf7594d5f8adb8962f3b79b10ab7e746f53d175263bc";
      meta = with lib;
      {
        homepage = "https://eid.belgium.be/";
        description = "Use the Belgian electronic identity card (eID) in Firefox";
        license = licenses.lgpl3;
        mozPermissions = [ "pkcs11" "notifications" "https://*.belgium.be/*" ];
        platforms = platforms.all;
      };
    };
    "better-canvas" = buildFirefoxXpiAddon {
      pname = "better-canvas";
      version = "5.12.0";
      addonId = "{8927f234-4dd9-48b1-bf76-44a9e153eee0}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4373438/better_canvas-5.12.0.xpi";
      sha256 = "dcec560f4099b8982c064277cdd3f35070aa22851f6fdedeb975c21b1f611d23";
      meta = with lib;
      {
        description = "Best dark mode for Canvas, plus other features";
        license = licenses.mpl20;
        mozPermissions = [ "storage" "https://*/*" ];
        platforms = platforms.all;
      };
    };
    "better-darker-docs" = buildFirefoxXpiAddon {
      pname = "better-darker-docs";
      version = "1.1.1";
      addonId = "batterdarkerdocs@threethan.github.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/4190471/better_darker_docs-1.1.1.xpi";
      sha256 = "427269938272afd2eaed49f676238b86750ee0196b89229e2c8c1ac603aaf9d0";
      meta = with lib;
      {
        description = "Gives Google Docs, Sheets, Slides, and Drawings a proper dark mode based on system theme, plus clearer text";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "*://docs.google.com/*"
          "*://docs.google.com/document*"
          "*://docs.google.com/spreadsheet*"
          "*://docs.google.com/presentation*"
        ];
        platforms = platforms.all;
      };
    };
    "betterttv" = buildFirefoxXpiAddon {
      pname = "betterttv";
      version = "7.6.17";
      addonId = "firefox@betterttv.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4600550/betterttv-7.6.17.xpi";
      sha256 = "2943e58714c7521b3ae466ce68f3cd73a82bd0c1c98aae0088e463c774b7fa1e";
      meta = with lib;
      {
        homepage = "https://betterttv.com";
        description = "Enhances Twitch and YouTube with new features, emotes, and more.";
        license = {
          shortName = "betterttv";
          fullName = "BetterTTV Terms of Service";
          url = "https://betterttv.com/terms";
          free = false;
        };
        mozPermissions = [ "scripting" "activeTab" "*://*.twitch.tv/*" ];
        platforms = platforms.all;
      };
    };
    "beyond-20" = buildFirefoxXpiAddon {
      pname = "beyond-20";
      version = "2.16.2";
      addonId = "beyond20@kakaroto.homelinux.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4572093/beyond_20-2.16.2.xpi";
      sha256 = "0b8145f90d8479d897501256cfcb23db36a7d7e903d6b23da79fd9141c7156ad";
      meta = with lib;
      {
        homepage = "https://beyond20.here-for-more.info";
        description = "Integrates the D&amp;D Beyond Character Sheet into Roll20 and Foundry VTT.";
        license = licenses.gpl3;
        mozPermissions = [
          "activeTab"
          "tabs"
          "storage"
          "*://beyond20.kicks-ass.org/roll"
          "*://app.roll20.net/editor/"
          "*://*.dndbeyond.com/*"
          "*://*.forge-vtt.com/game"
          "*://*.dndbeyond.com/*characters/*"
          "*://*.dndbeyond.com/characters"
          "*://*.dndbeyond.com/monsters/*"
          "*://*.dndbeyond.com/vehicles/*"
          "*://*.dndbeyond.com/spells/*"
          "*://*.dndbeyond.com/my-encounters"
          "*://*.dndbeyond.com/encounters/*"
          "*://*.dndbeyond.com/combat-tracker/*"
          "*://*.dndbeyond.com/equipment/*"
          "*://*.dndbeyond.com/magic-items/*"
          "*://*.dndbeyond.com/feats/*"
          "*://*.dndbeyond.com/sources/*"
          "*://*.dndbeyond.com/classes/*"
          "*://*.dndbeyond.com/races/*"
          "*://*.dndbeyond.com/species/*"
          "*://*.dndbeyond.com/backgrounds/*"
          "*://app.roll20.net/editor/*"
        ];
        platforms = platforms.all;
      };
    };
    "bibbot" = buildFirefoxXpiAddon {
      pname = "bibbot";
      version = "0.40.8";
      addonId = "voebbot@stefanwehrmeyer.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4606516/bibbot-0.40.8.xpi";
      sha256 = "7ce66cef18946af215cde623ade6fee5848a9118a39b7a2b8de2cc78476ae3ea";
      meta = with lib;
      {
        homepage = "https://github.com/stefanw/bibbot";
        description = "Durch ein Bibliothekskonto mit Pressedatenbankzugriff entfernt dieses Add-On die Paywall bei deutschen Nachrichtenseiten. Ein solches Bibliothekskonto ist Voraussetzung zur Nutzung des Add-On.";
        license = licenses.gpl3;
        mozPermissions = [
          "activeTab"
          "tabs"
          "storage"
          "scripting"
          "https://www.spiegel.de/*"
          "https://www.zeit.de/*"
          "https://www.wiwo.de/*"
          "https://www.welt.de/*"
          "https://www.tagesspiegel.de/*"
          "https://www.sueddeutsche.de/*"
          "https://sz-magazin.sueddeutsche.de/*"
          "https://www.handelsblatt.com/*"
          "https://www.berliner-zeitung.de/*"
          "https://www.morgenpost.de/*"
          "https://www.nordkurier.de/*"
          "https://www.abendblatt.de/*"
          "https://www.moz.de/*"
          "https://www.noz.de/*"
          "https://www.waz.de/*"
          "https://www.heise.de/*"
          "https://www.maz-online.de/*"
          "https://www.lr-online.de/*"
          "https://www.nachrichten.at/*"
          "https://ga.de/*"
          "https://www.ksta.de/*"
          "https://www.rundschau-online.de/*"
          "https://rp-online.de/*"
          "https://www.tagesanzeiger.ch/*"
          "https://www.falter.at/*"
          "https://www.stuttgarter-zeitung.de/*"
          "https://www.stuttgarter-nachrichten.de/*"
          "https://www.ostsee-zeitung.de/*"
          "https://www.stimme.de/*"
          "https://kurier.at/*"
          "https://freizeit.at/*"
          "https://www.diepresse.com/*"
          "https://www.sn.at/*"
          "https://www.kleinezeitung.at/*"
          "https://www.vn.at/*"
          "https://www.thueringer-allgemeine.de/*"
          "https://www.mopo.de/*"
          "https://www.saechsische.de/*"
          "https://www.freiepresse.de/*"
          "https://www.haz.de/*"
          "https://www.lvz.de/*"
          "https://www.dnn.de/*"
          "https://www.swp.de/*"
          "https://www.ruhrnachrichten.de/*"
          "https://www.businessinsider.de/*"
          "https://www.badische-zeitung.de/*"
          "https://www.stern.de/*"
          "https://www.mittelbayerische.de/*"
          "https://www.tagblatt.de/*"
          "https://www.mz.de/*"
          "https://www.capital.de/*"
          "https://www.iz.de/*"
          "https://www.shz.de/*"
          "https://www.aerztezeitung.de/*"
          "https://www.geo.de/*"
          "https://www.nzz.ch/*"
          "https://www.manager-magazin.de/*"
          "https://www.nwzonline.de/*"
          "https://www.saarbruecker-zeitung.de/*"
          "https://www.idowa.de/*"
          "https://www.aachener-zeitung.de/*"
          "https://www.nn.de/*"
        ];
        platforms = platforms.all;
      };
    };
    "bilisponsorblock" = buildFirefoxXpiAddon {
      pname = "bilisponsorblock";
      version = "0.10.2";
      addonId = "{f10c197e-c2a4-43b6-a982-7e186f7c63d9}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4608129/bilisponsorblock-0.10.2.xpi";
      sha256 = "2d44d1b850a6df6ffb78d175396503e211e892ad8a105ac1210a22cd7ad012b5";
      meta = with lib;
      {
        homepage = "https://www.bsbsb.top";
        description = "恰饭？桌子都给你掀了(/= _ =)/~┴┴   带你精准空降到恰饭结束或者高能时刻，自动跳过视频中的赞助广告、订阅提醒等片段。你也可以亲自标记视频中的广告并上传，所有人都会从您的贡献中受益。";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "scripting"
          "https://*.bilibili.com/*"
          "http://*.bsbsb.top/*"
        ];
        platforms = platforms.all;
      };
    };
    "binnen-i-be-gone" = buildFirefoxXpiAddon {
      pname = "binnen-i-be-gone";
      version = "3.1.1";
      addonId = "{b65d7d9a-4ec0-4974-b07f-83e30f6e973f}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3862807/binnen_i_be_gone-3.1.1.xpi";
      sha256 = "15a369100cfc5d34d9bc4eaae6f9cc76d817bbebd9554b3b47e84719d93d4564";
      meta = with lib;
      {
        description = "This add-on likely is only useful for users who speak German or visit German language websites  - it will remove so called \"Binnen-Is\" on webpages.";
        license = licenses.gpl3;
        mozPermissions = [ "storage" "http://*/*" "https://*/*" ];
        platforms = platforms.all;
      };
    };
    "bionic-reader" = buildFirefoxXpiAddon {
      pname = "bionic-reader";
      version = "1.6.25";
      addonId = "{c2ecdf60-7077-4bfa-b9c2-4892a8ded8c6}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4218879/bionic_reader-1.6.25.xpi";
      sha256 = "d759562525f8db7d066c72bee662ab93f28c530a947adec579c5094bc1034aa4";
      meta = with lib;
      {
        description = "- Apply Bionic Reading style with adjustable strength to a webpage.\n- Adjustable vowels for different languages.\n- Adjustable font family, font size, font weight and font opacity.\n- Support Unicode characters.\n- Apply dark mode to a webpage.";
        license = licenses.mpl20;
        mozPermissions = [ "storage" "tabs" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "bitwarden" = buildFirefoxXpiAddon {
      pname = "bitwarden";
      version = "2025.10.0";
      addonId = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4599707/bitwarden_password_manager-2025.10.0.xpi";
      sha256 = "31b88743f36032fa3cfb78e0582fb732ef00a3c5915182ba37fd08b04aac1d3b";
      meta = with lib;
      {
        homepage = "https://bitwarden.com";
        description = "At home, at work, or on the go, Bitwarden easily secures all your passwords, passkeys, and sensitive information.";
        license = licenses.gpl3;
        mozPermissions = [
          "<all_urls>"
          "*://*/*"
          "alarms"
          "clipboardRead"
          "clipboardWrite"
          "contextMenus"
          "idle"
          "storage"
          "tabs"
          "unlimitedStorage"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "notifications"
          "file:///*"
        ];
        platforms = platforms.all;
      };
    };
    "blocktube" = buildFirefoxXpiAddon {
      pname = "blocktube";
      version = "0.4.6";
      addonId = "{58204f8b-01c2-4bbc-98f8-9a90458fd9ef}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4578806/blocktube-0.4.6.xpi";
      sha256 = "67ea8463b6ff9ed9737cf17ab0a89339f66b54a721741f3073d2c34591ae51d1";
      meta = with lib;
      {
        homepage = "https://github.com/amitbl/blocktube";
        description = "YouTube™ Content Blocker\nBlock channels and videos from YouTube™\nFast and easy";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "unlimitedStorage"
          "https://www.youtube.com/*"
          "https://m.youtube.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "bonjourr-startpage" = buildFirefoxXpiAddon {
      pname = "bonjourr-startpage";
      version = "21.2.1";
      addonId = "{4f391a9e-8717-4ba6-a5b1-488a34931fcb}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4575253/bonjourr_startpage-21.2.1.xpi";
      sha256 = "f694c2fa42d60c806af9aa1560dc8dd1debd5b3cf1ee52651ab777d2e51ba772";
      meta = with lib;
      {
        homepage = "https://bonjourr.fr";
        description = "Improve your web browsing experience with Bonjourr, a beautiful, customizable and lightweight homepage inspired by iOS.";
        license = licenses.gpl3;
        mozPermissions = [ "storage" ];
        platforms = platforms.all;
      };
    };
    "bookmark-search-plus-2" = buildFirefoxXpiAddon {
      pname = "bookmark-search-plus-2";
      version = "2.0.135";
      addonId = "bookmarksearchplus2@aafn.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4514021/bookmark_search_plus_2-2.0.135.xpi";
      sha256 = "dd64dc528cac77e39dfca90cfadc6c024b900264ddef41c4a57d274233dc261e";
      meta = with lib;
      {
        homepage = "https://github.com/aaFn/Bookmark-search-plus-2/wiki";
        description = "Search for both bookmarks and folders. Find exact location in bookmark tree (show parent folder, go parent folder). Advanced filters and searches, use regex.";
        license = licenses.mpl20;
        mozPermissions = [
          "<all_urls>"
          "storage"
          "unlimitedStorage"
          "tabs"
          "bookmarks"
          "history"
          "browserSettings"
          "topSites"
          "menus"
          "menus.overrideContext"
          "theme"
        ];
        platforms = platforms.all;
      };
    };
    "bookmarkhub" = buildFirefoxXpiAddon {
      pname = "bookmarkhub";
      version = "0.0.4";
      addonId = "{9c37f9a3-ea04-4a2b-9fcc-c7a814c14311}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3815080/bookmarkhub-0.0.4.xpi";
      sha256 = "15132a6223fd79141b65bb41e8289946ef36eb26cb1cb2cdfa6aadb54cb1e3ae";
      meta = with lib;
      {
        homepage = "https://www.github.com/dudor/BookmarkHub";
        description = "BookmarkHub,sync bookmarks across different browsers";
        license = licenses.gpl3;
        mozPermissions = [
          "bookmarks"
          "storage"
          "notifications"
          "https://*.github.com/"
          "https://*.githubusercontent.com/"
        ];
        platforms = platforms.all;
      };
    };
    "boring-rss" = buildFirefoxXpiAddon {
      pname = "boring-rss";
      version = "0.5";
      addonId = "{45d4d1a3-4faa-42b7-9747-bcf2153310cd}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3660917/boring_rss-0.5.xpi";
      sha256 = "23da27d92980bf0793cabf9722813a45cbf55a24a44434a217c3d38af4b2cdfb";
      meta = with lib;
      {
        homepage = "https://git.sr.ht/~tomf/boring-rss";
        description = "A low-permission button to find RSS/Atom feeds in the current page.";
        license = licenses.gpl3;
        mozPermissions = [ "activeTab" ];
        platforms = platforms.all;
      };
    };
    "brandon1024-find" = buildFirefoxXpiAddon {
      pname = "brandon1024-find";
      version = "2.2.1";
      addonId = "{6fa42eda-38ca-4126-96d5-3163f0de6900}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3825098/brandon1024_find-2.2.1.xpi";
      sha256 = "54f29a6839a83ef6b07f9fbeae1e6e7697d8416f16ce45d3bdc17ec5d8a243ca";
      meta = with lib;
      {
        homepage = "https://github.com/brandon1024/find/";
        description = "A find-in-page extension with support for regular expressions.";
        license = licenses.gpl3;
        mozPermissions = [
          "tabs"
          "activeTab"
          "storage"
          "contextMenus"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "british-english-dictionary-2" = buildFirefoxXpiAddon {
      pname = "british-english-dictionary-2";
      version = "4.0.3";
      addonId = "marcoagpinto@mail.telepac.pt";
      url = "https://addons.mozilla.org/firefox/downloads/file/4568898/british_english_dictionary_2-4.0.3.xpi";
      sha256 = "362d45508eaa92f1addf1e91624106f16383bd9791d8864433dd2d13d25141c1";
      meta = with lib;
      {
        homepage = "https://proofingtoolgui.org";
        description = "A fork of Mark Tyndall's add-on, based on David Bartlett's \nBritish Dictionary R1.19 for Firefox, Thunderbird and SeaMonkey.";
        license = licenses.lgpl3;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "brotab" = buildFirefoxXpiAddon {
      pname = "brotab";
      version = "1.4.0";
      addonId = "brotab_mediator@example.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3955334/brotab-1.4.0.xpi";
      sha256 = "1966f39933fadcc0d8b4a2344111d241874dc6ffec4fe8c261e3703be1d32e17";
      meta = with lib;
      {
        homepage = "https://github.com/balta2ar/brotab/";
        description = "Control your Firefox's tabs from command line";
        license = licenses.mit;
        mozPermissions = [ "nativeMessaging" "tabs" "activeTab" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "browserpass" = buildFirefoxXpiAddon {
      pname = "browserpass";
      version = "3.11.0";
      addonId = "browserpass@maximbaz.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4542488/browserpass_ce-3.11.0.xpi";
      sha256 = "11acffd3dbfe0be493c7855669dd24faf325dda8a2ee0ee67148969500f5d778";
      meta = with lib;
      {
        homepage = "https://github.com/browserpass/browserpass-extension";
        description = "Browserpass is a browser extension for Firefox and Chrome to retrieve login details from zx2c4's pass (passwordstore.org) straight from your browser. Tags: passwordstore, password store, password manager, passwordmanager, gpg";
        license = licenses.isc;
        mozPermissions = [
          "activeTab"
          "alarms"
          "tabs"
          "clipboardRead"
          "clipboardWrite"
          "nativeMessaging"
          "notifications"
          "scripting"
          "storage"
          "webRequest"
          "webRequestAuthProvider"
        ];
        platforms = platforms.all;
      };
    };
    "bulgarian-dictionary" = buildFirefoxXpiAddon {
      pname = "bulgarian-dictionary";
      version = "4.4.3";
      addonId = "bg-BG@dictionaries.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3609719/bulgarian_dictionary-4.4.3.xpi";
      sha256 = "f5aa20ff1954a00be98fbf20fe5a77f0115813b36c5fc14c6f0e713cb597d5b2";
      meta = with lib;
      {
        homepage = "http://bgoffice.sourceforge.net/";
        description = "Bulgarian spellchecking...";
        license = licenses.mpl20;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "bulkurlopener" = buildFirefoxXpiAddon {
      pname = "bulkurlopener";
      version = "1.11.3";
      addonId = "{c5b32a48-5514-4a46-81f2-075ebf3cbc29}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3964817/bulkurlopener-1.11.3.xpi";
      sha256 = "7de50750a715d1c21a6d42b6526c323d4b0b1758b32aabf64c3280082be718c1";
      meta = with lib;
      {
        homepage = "https://bulkurlopener.com";
        description = "Allows user to open a list of url in one click.";
        license = licenses.mit;
        mozPermissions = [ "tabs" "storage" "contextMenus" ];
        platforms = platforms.all;
      };
    };
    "buster-captcha-solver" = buildFirefoxXpiAddon {
      pname = "buster-captcha-solver";
      version = "3.1.0";
      addonId = "{e58d3966-3d76-4cd9-8552-1582fbc800c1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4297951/buster_captcha_solver-3.1.0.xpi";
      sha256 = "6892c4e1777b6e5480bb4224c2503b62d1cb92b49996ee9948cb746110a351d8";
      meta = with lib;
      {
        homepage = "https://github.com/dessant/buster#readme";
        description = "Save time by asking Buster to solve CAPTCHAs for you.";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "notifications"
          "webRequest"
          "webRequestBlocking"
          "webNavigation"
          "nativeMessaging"
          "<all_urls>"
          "https://google.com/recaptcha/api2/bframe*"
          "https://www.google.com/recaptcha/api2/bframe*"
          "https://google.com/recaptcha/enterprise/bframe*"
          "https://www.google.com/recaptcha/enterprise/bframe*"
          "https://recaptcha.net/recaptcha/api2/bframe*"
          "https://www.recaptcha.net/recaptcha/api2/bframe*"
          "https://recaptcha.net/recaptcha/enterprise/bframe*"
          "https://www.recaptcha.net/recaptcha/enterprise/bframe*"
          "http://127.0.0.1/buster/setup?session=*"
        ];
        platforms = platforms.all;
      };
    };
    "c-c-search-extension" = buildFirefoxXpiAddon {
      pname = "c-c-search-extension";
      version = "0.4.0";
      addonId = "{e737d9cb-82de-4f23-83c6-76f70a82229c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4145773/c_c_search_extension-0.4.0.xpi";
      sha256 = "abafbcb454bb0270d4dafdc1a0bce7810eae06226e33e685df9d2592256932dc";
      meta = with lib;
      {
        homepage = "https://cpp.extension.sh";
        description = "The ultimate search extension for C/C++";
        mozPermissions = [ "storage" "unlimitedStorage" ];
        platforms = platforms.all;
      };
    };
    "canvasblocker" = buildFirefoxXpiAddon {
      pname = "canvasblocker";
      version = "1.11";
      addonId = "CanvasBlocker@kkapsner.de";
      url = "https://addons.mozilla.org/firefox/downloads/file/4413485/canvasblocker-1.11.xpi";
      sha256 = "0479b7315ce2c195fd2fbd519c50866030083abdb6d895c1b162d52762a676ec";
      meta = with lib;
      {
        homepage = "https://github.com/kkapsner/CanvasBlocker/";
        description = "Alters some JS APIs to prevent fingerprinting.";
        license = licenses.mpl20;
        mozPermissions = [
          "<all_urls>"
          "storage"
          "tabs"
          "webRequest"
          "webRequestBlocking"
          "contextualIdentities"
          "cookies"
          "privacy"
        ];
        platforms = platforms.all;
      };
    };
    "capital-one-eno" = buildFirefoxXpiAddon {
      pname = "capital-one-eno";
      version = "5.4.2";
      addonId = "{4d5b7a5e-5232-9e45-97f4-f8e1ca2626e5}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4574952/capital_one_eno-5.4.2.xpi";
      sha256 = "e477431441d0b5a7f91705b9af4aed30932af21506f11a2a63024790da1bb58e";
      meta = with lib;
      {
        homepage = "https://www.capitalone.com/applications/eno/virtualnumbers/";
        description = "Shop more securely through your desktop browser with Eno®, your Capital One® assistant.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "activeTab"
          "alarms"
          "tabs"
          "storage"
          "cookies"
          "https://*/*"
          "http://*/*"
          "https://*.capitalone.com/*"
          "http://*.capitalone.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "capture-print" = buildFirefoxXpiAddon {
      pname = "capture-print";
      version = "0.2.1";
      addonId = "{146f1820-2b0d-49ef-acbf-d85a6986e10c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/2222170/capture_print-0.2.1.xpi";
      sha256 = "b6b4dd9df712d0a1d5de683412a095b9836cf6763f7b75e86d03a91216091392";
      meta = with lib;
      {
        description = "This add-on lets you print a webpage's area easily.";
        license = licenses.mpl20;
        mozPermissions = [
          "menus"
          "activeTab"
          "<all_urls>"
          "clipboard"
          "notifications"
          "clipboardWrite"
        ];
        platforms = platforms.all;
      };
    };
    "castkodi" = buildFirefoxXpiAddon {
      pname = "castkodi";
      version = "7.14.0";
      addonId = "castkodi@regseb.github.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/4585613/castkodi-7.14.0.xpi";
      sha256 = "0975a6c35f49ceb780666fd8e22f338a5141ee81b1c46ed73d72ae15065de05e";
      meta = with lib;
      {
        homepage = "https://github.com/regseb/castkodi";
        description = "Cast videos and music from more than 50 sites (YouTube, Twitch, Vimeo, SoundCloud, torrents, …) to Kodi with context menu and remote control.";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "contextMenus"
          "notifications"
          "storage"
        ];
        platforms = platforms.all;
      };
    };
    "catppuccin-mocha-mauve" = buildFirefoxXpiAddon {
      pname = "catppuccin-mocha-mauve";
      version = "2.0";
      addonId = "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3990325/catppuccin_mocha_mauve_git-2.0.xpi";
      sha256 = "a5297355eed76d36eb0bbea20229d8aebeea225ebd3a91f75a4d343280087bbe";
      meta = with lib;
      {
        description = "🦊 Soothing pastel theme for Firefox (Official)";
        license = licenses.cc-by-30;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "catppuccin-web-file-icons" = buildFirefoxXpiAddon {
      pname = "catppuccin-web-file-icons";
      version = "1.6.0";
      addonId = "{bbb880ce-43c9-47ae-b746-c3e0096c5b76}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4603824/catppuccin_web_file_icons-1.6.0.xpi";
      sha256 = "3a0b1bb62583f43272127452831fb2e15550eaa520140928b9561b670e63f546";
      meta = with lib;
      {
        homepage = "https://github.com/catppuccin/web-file-explorer-icons";
        description = "Soothing pastel icons for file explorers on the web!";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "contextMenus"
          "activeTab"
          "*://bitbucket.org/*"
          "*://codeberg.org/*"
          "*://gitea.com/*"
          "*://github.com/*"
          "*://gitlab.com/*"
          "*://tangled.org/*"
        ];
        platforms = platforms.all;
      };
    };
    "censor-tracker" = buildFirefoxXpiAddon {
      pname = "censor-tracker";
      version = "18.5.0";
      addonId = "{5d0d1f87-5991-42d3-98c3-54878ead1ed1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4333567/censor_tracker-18.5.0.xpi";
      sha256 = "5c90e1be3d1a1aa9cdafe51c84a0d1cdacd2cbb1445bf0e800e82bf1d85ec4b4";
      meta = with lib;
      {
        homepage = "https://censortracker.org/en.html";
        description = "Censor Tracker is an extension that allows you to bypass Internet censorship, warns you about sites that transmit your data with government agencies, and detect new acts of censorship.";
        license = licenses.mit;
        mozPermissions = [
          "<all_urls>"
          "webRequest"
          "alarms"
          "activeTab"
          "management"
          "notifications"
          "proxy"
          "storage"
          "tabs"
          "unlimitedStorage"
        ];
        platforms = platforms.all;
      };
    };
    "chameleon-ext" = buildFirefoxXpiAddon {
      pname = "chameleon-ext";
      version = "0.22.77.1";
      addonId = "{3579f63b-d8ee-424f-bbb6-6d0ce3285e6a}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4591578/chameleon_ext-0.22.77.1.xpi";
      sha256 = "47668f11e43d751474f4ff14d291a5566ff789ac139e140192fbcad167e0517d";
      meta = with lib;
      {
        homepage = "https://sereneblue.github.io/chameleon";
        description = "Spoof your browser profile. Includes a few privacy enhancing options.\n\nA WebExtension port of Random Agent Spoofer.";
        license = licenses.gpl3;
        mozPermissions = [
          "<all_urls>"
          "alarms"
          "contextMenus"
          "notifications"
          "storage"
          "tabs"
          "webRequest"
          "webRequestBlocking"
        ];
        platforms = platforms.all;
      };
    };
    "change-timezone-time-shift" = buildFirefoxXpiAddon {
      pname = "change-timezone-time-shift";
      version = "0.1.8";
      addonId = "{acf99872-d701-4863-adc2-cdda1163aa34}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4490488/change_timezone_time_shift-0.1.8.xpi";
      sha256 = "3095f0f75aac7dcac45ec148c7c883691036da8c26854e5d2d1db7c3d9de912c";
      meta = with lib;
      {
        homepage = "https://mybrowseraddon.com/change-timezone.html";
        description = "Easily change your timezone to a desired value and protect your privacy.";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "scripting"
          "contextMenus"
          "webNavigation"
          "https://webbrowsertools.com/timezone*"
        ];
        platforms = platforms.all;
      };
    };
    "chatgptbox" = buildFirefoxXpiAddon {
      pname = "chatgptbox";
      version = "2.5.9";
      addonId = "{b764208e-0a98-436d-a599-c1baa044f829}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4542740/chatgptbox-2.5.9.xpi";
      sha256 = "21af9e7b4f12090b8265fcb3aea324480a7420ee8ad997bfb7106efb1f6d04e0";
      meta = with lib;
      {
        homepage = "https://github.com/josStorer/chatGPTBox";
        description = "This extension integrates ChatGPT into the browser deeply, and provides chat windows, search engines and commonly used websites integration, and selection tools.";
        license = licenses.mit;
        mozPermissions = [
          "cookies"
          "storage"
          "contextMenus"
          "unlimitedStorage"
          "tabs"
          "webRequest"
          "https://*.chatgpt.com/*"
          "https://*.openai.com/"
          "https://*.bing.com/"
          "wss://*.bing.com/*"
          "https://*.poe.com/"
          "https://*.google.com/"
          "https://claude.ai/"
          "https://*.moonshot.cn/*"
          "<all_urls>"
          "https://*/*"
          "http://*/*"
          "file://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "chrome-mask" = buildFirefoxXpiAddon {
      pname = "chrome-mask";
      version = "7.0.1";
      addonId = "chrome-mask@overengineer.dev";
      url = "https://addons.mozilla.org/firefox/downloads/file/4589979/chrome_mask-7.0.1.xpi";
      sha256 = "52c83e0a08c2a8b46cc50609646cf92160ad971ebffaccc9193a7cba637eb99f";
      meta = with lib;
      {
        homepage = "https://github.com/denschub/chrome-mask";
        description = "Makes Firefox wear a mask to look like Chrome to websites that block Firefox otherwise.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "tabs"
          "webRequest"
          "webRequestBlocking"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "clearcache" = buildFirefoxXpiAddon {
      pname = "clearcache";
      version = "4.4";
      addonId = "clearcache@michel.de.almeida";
      url = "https://addons.mozilla.org/firefox/downloads/file/4573847/clearcache-4.4.xpi";
      sha256 = "0fd80a9e8efbb66df4cfb59e556ed03da10eb1b1b638ea653cbdee793aa19f36";
      meta = with lib;
      {
        homepage = "https://github.com/TenSoja/clear-cache";
        description = "Advanced cache clearing with time periods, current tab filter, and smart notifications. Perfect for developers and power users. F9 shortcut included!";
        license = licenses.mpl20;
        mozPermissions = [
          "browsingData"
          "contextMenus"
          "notifications"
          "storage"
          "tabs"
        ];
        platforms = platforms.all;
      };
    };
    "clearurls" = buildFirefoxXpiAddon {
      pname = "clearurls";
      version = "1.27.3";
      addonId = "{74145f27-f039-47ce-a470-a662b129930a}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4432106/clearurls-1.27.3.xpi";
      sha256 = "54926b6e4274d5935a5fc0daa6320f1d371e3d2f1a5877467ca3ab22a65c4f20";
      meta = with lib;
      {
        homepage = "https://clearurls.xyz/";
        description = "Removes tracking elements from URLs";
        license = licenses.lgpl3;
        mozPermissions = [
          "<all_urls>"
          "webRequest"
          "webRequestBlocking"
          "storage"
          "unlimitedStorage"
          "contextMenus"
          "webNavigation"
          "tabs"
          "downloads"
          "*://*.google.com/*"
          "*://*.google.ad/*"
          "*://*.google.ae/*"
          "*://*.google.com.af/*"
          "*://*.google.com.ag/*"
          "*://*.google.com.ai/*"
          "*://*.google.al/*"
          "*://*.google.am/*"
          "*://*.google.co.ao/*"
          "*://*.google.com.ar/*"
          "*://*.google.as/*"
          "*://*.google.at/*"
          "*://*.google.com.au/*"
          "*://*.google.az/*"
          "*://*.google.ba/*"
          "*://*.google.com.bd/*"
          "*://*.google.be/*"
          "*://*.google.bf/*"
          "*://*.google.bg/*"
          "*://*.google.com.bh/*"
          "*://*.google.bi/*"
          "*://*.google.bj/*"
          "*://*.google.com.bn/*"
          "*://*.google.com.bo/*"
          "*://*.google.com.br/*"
          "*://*.google.bs/*"
          "*://*.google.bt/*"
          "*://*.google.co.bw/*"
          "*://*.google.by/*"
          "*://*.google.com.bz/*"
          "*://*.google.ca/*"
          "*://*.google.cd/*"
          "*://*.google.cf/*"
          "*://*.google.cg/*"
          "*://*.google.ch/*"
          "*://*.google.ci/*"
          "*://*.google.co.ck/*"
          "*://*.google.cl/*"
          "*://*.google.cm/*"
          "*://*.google.cn/*"
          "*://*.google.com.co/*"
          "*://*.google.co.cr/*"
          "*://*.google.com.cu/*"
          "*://*.google.cv/*"
          "*://*.google.com.cy/*"
          "*://*.google.cz/*"
          "*://*.google.de/*"
          "*://*.google.dj/*"
          "*://*.google.dk/*"
          "*://*.google.dm/*"
          "*://*.google.com.do/*"
          "*://*.google.dz/*"
          "*://*.google.com.ec/*"
          "*://*.google.ee/*"
          "*://*.google.com.eg/*"
          "*://*.google.es/*"
          "*://*.google.com.et/*"
          "*://*.google.fi/*"
          "*://*.google.com.fj/*"
          "*://*.google.fm/*"
          "*://*.google.fr/*"
          "*://*.google.ga/*"
          "*://*.google.ge/*"
          "*://*.google.gg/*"
          "*://*.google.com.gh/*"
          "*://*.google.com.gi/*"
          "*://*.google.gl/*"
          "*://*.google.gm/*"
          "*://*.google.gp/*"
          "*://*.google.gr/*"
          "*://*.google.com.gt/*"
          "*://*.google.gy/*"
          "*://*.google.com.hk/*"
          "*://*.google.hn/*"
          "*://*.google.hr/*"
          "*://*.google.ht/*"
          "*://*.google.hu/*"
          "*://*.google.co.id/*"
          "*://*.google.ie/*"
          "*://*.google.co.il/*"
          "*://*.google.im/*"
          "*://*.google.co.in/*"
          "*://*.google.iq/*"
          "*://*.google.is/*"
          "*://*.google.it/*"
          "*://*.google.je/*"
          "*://*.google.com.jm/*"
          "*://*.google.jo/*"
          "*://*.google.co.jp/*"
          "*://*.google.co.ke/*"
          "*://*.google.com.kh/*"
          "*://*.google.ki/*"
          "*://*.google.kg/*"
          "*://*.google.co.kr/*"
          "*://*.google.com.kw/*"
          "*://*.google.kz/*"
          "*://*.google.la/*"
          "*://*.google.com.lb/*"
          "*://*.google.li/*"
          "*://*.google.lk/*"
          "*://*.google.co.ls/*"
          "*://*.google.lt/*"
          "*://*.google.lu/*"
          "*://*.google.lv/*"
          "*://*.google.com.ly/*"
          "*://*.google.co.ma/*"
          "*://*.google.md/*"
          "*://*.google.me/*"
          "*://*.google.mg/*"
          "*://*.google.mk/*"
          "*://*.google.ml/*"
          "*://*.google.com.mm/*"
          "*://*.google.mn/*"
          "*://*.google.ms/*"
          "*://*.google.com.mt/*"
          "*://*.google.mu/*"
          "*://*.google.mv/*"
          "*://*.google.mw/*"
          "*://*.google.com.mx/*"
          "*://*.google.com.my/*"
          "*://*.google.co.mz/*"
          "*://*.google.com.na/*"
          "*://*.google.com.nf/*"
          "*://*.google.com.ng/*"
          "*://*.google.com.ni/*"
          "*://*.google.ne/*"
          "*://*.google.nl/*"
          "*://*.google.no/*"
          "*://*.google.com.np/*"
          "*://*.google.nr/*"
          "*://*.google.nu/*"
          "*://*.google.co.nz/*"
          "*://*.google.com.om/*"
          "*://*.google.com.pa/*"
          "*://*.google.com.pe/*"
          "*://*.google.com.pg/*"
          "*://*.google.com.ph/*"
          "*://*.google.com.pk/*"
          "*://*.google.pl/*"
          "*://*.google.pn/*"
          "*://*.google.com.pr/*"
          "*://*.google.ps/*"
          "*://*.google.pt/*"
          "*://*.google.com.py/*"
          "*://*.google.com.qa/*"
          "*://*.google.ro/*"
          "*://*.google.ru/*"
          "*://*.google.rw/*"
          "*://*.google.com.sa/*"
          "*://*.google.com.sb/*"
          "*://*.google.sc/*"
          "*://*.google.se/*"
          "*://*.google.com.sg/*"
          "*://*.google.sh/*"
          "*://*.google.si/*"
          "*://*.google.sk/*"
          "*://*.google.com.sl/*"
          "*://*.google.sn/*"
          "*://*.google.so/*"
          "*://*.google.sm/*"
          "*://*.google.sr/*"
          "*://*.google.st/*"
          "*://*.google.com.sv/*"
          "*://*.google.td/*"
          "*://*.google.tg/*"
          "*://*.google.co.th/*"
          "*://*.google.com.tj/*"
          "*://*.google.tk/*"
          "*://*.google.tl/*"
          "*://*.google.tm/*"
          "*://*.google.tn/*"
          "*://*.google.to/*"
          "*://*.google.com.tr/*"
          "*://*.google.tt/*"
          "*://*.google.com.tw/*"
          "*://*.google.co.tz/*"
          "*://*.google.com.ua/*"
          "*://*.google.co.ug/*"
          "*://*.google.co.uk/*"
          "*://*.google.com.uy/*"
          "*://*.google.co.uz/*"
          "*://*.google.com.vc/*"
          "*://*.google.co.ve/*"
          "*://*.google.vg/*"
          "*://*.google.co.vi/*"
          "*://*.google.com.vn/*"
          "*://*.google.vu/*"
          "*://*.google.ws/*"
          "*://*.google.rs/*"
          "*://*.google.co.za/*"
          "*://*.google.co.zm/*"
          "*://*.google.co.zw/*"
          "*://*.google.cat/*"
          "*://*.yandex.ru/*"
          "*://*.yandex.com/*"
          "*://*.ya.ru/*"
        ];
        platforms = platforms.all;
      };
    };
    "click-and-read" = buildFirefoxXpiAddon {
      pname = "click-and-read";
      version = "4.0.0";
      addonId = "inist.users@gmail.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4594483/click_and_read-4.0.0.xpi";
      sha256 = "4180fa19b20deb4fe1a3980bace2d5b59de683c68b2a2b2f234b50239f151138";
      meta = with lib;
      {
        homepage = "https://clickandread.inist.fr/";
        description = "Developed by the CNRS to facilitate access to documents, the extension scans the web page you visit for document identifiers (DOI, PMID, PII) and adds a link if the resource is available.";
        license = licenses.mpl20;
        mozPermissions = [
          "scripting"
          "storage"
          "webNavigation"
          "notifications"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "cliget" = buildFirefoxXpiAddon {
      pname = "cliget";
      version = "2.1.0";
      addonId = "cliget@zaidabdulla.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3707199/cliget-2.1.0.xpi";
      sha256 = "5277da8f3b051fc1c05742520eecd5be7ea445638161d2c86f546ba27246db61";
      meta = with lib;
      {
        homepage = "https://github.com/zaidka/cliget";
        description = "Download login-protected files from the command line using curl, wget or aria2.";
        license = licenses.mpl20;
        mozPermissions = [ "webRequest" "storage" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "close-other-windows" = buildFirefoxXpiAddon {
      pname = "close-other-windows";
      version = "0.2resigned1";
      addonId = "{fab4ea0f-e0d3-4bb4-9515-aea14d709f69}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4271965/close_other_windows-0.2resigned1.xpi";
      sha256 = "98428363daef4acafd983f37125c4c24f1f843c76e801b2fa5ca3a9f71a8db6a";
      meta = with lib;
      {
        description = "Adds a button to close all tabs in other windows which are not pinned";
        license = licenses.mit;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "close-tabs-shortcuts" = buildFirefoxXpiAddon {
      pname = "close-tabs-shortcuts";
      version = "1.2.2";
      addonId = "{53fd9440-6db2-4d03-a21a-79735fe42160}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3574518/close_tabs_shortcuts-1.2.2.xpi";
      sha256 = "a71d331ccfd3a6408f408f0e0088e38795f369c62d10f54f62f4f0068a8ff2d9";
      meta = with lib;
      {
        description = "Adds keyboard shortcuts for closing all not active tabs, all to the left of the active one, all to the right";
        license = licenses.mpl20;
        mozPermissions = [ "tabs" ];
        platforms = platforms.all;
      };
    };
    "codecov" = buildFirefoxXpiAddon {
      pname = "codecov";
      version = "0.7.0";
      addonId = "{f3924b0d-e29f-4593-b605-084b3d71ed9d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4557234/codecov-0.7.0.xpi";
      sha256 = "c2659cb2282a697dff29bac84f1496578117f17cde28c9cbaceab818a419c988";
      meta = with lib;
      {
        homepage = "https://about.codecov.io";
        description = "Codecov Browser Extension\n\nadds Codecov coverage data and line annotations to public and private repositories on GitHub.";
        license = licenses.asl20;
        mozPermissions = [
          "storage"
          "scripting"
          "activeTab"
          "*://github.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "commafeed" = buildFirefoxXpiAddon {
      pname = "commafeed";
      version = "3.3.2";
      addonId = "firefox@commafeed.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4126587/commafeed-3.3.2.xpi";
      sha256 = "44ce246de1cd163891c6ddb42e0c1f2b50e4451d023821293795c8c9e695465e";
      meta = with lib;
      {
        description = "The extension will show an action next to the address bar with the count of your unread articles.\nClicking the button will either:\n\n-   show CommaFeed in a popup\n-   open CommaFeed in a new tab\n-   open next unread article in a new tab";
        license = licenses.mpl20;
        mozPermissions = [ "storage" "alarms" "*://*/*" ];
        platforms = platforms.all;
      };
    };
    "competitive-companion" = buildFirefoxXpiAddon {
      pname = "competitive-companion";
      version = "2.63.0";
      addonId = "{74e326aa-c645-4495-9287-b6febc5565a7}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4606404/competitive_companion-2.63.0.xpi";
      sha256 = "ec81a3680dc6528cb9687f1195983247600ba9e07395fe3afdd3c97b48b013db";
      meta = with lib;
      {
        homepage = "https://github.com/jmerle/competitive-companion";
        description = "Parses competitive programming problems and sends them to various tools like CP Editor and CPH.";
        license = licenses.mit;
        mozPermissions = [ "activeTab" "contextMenus" "storage" "scripting" ];
        platforms = platforms.all;
      };
    };
    "conex" = buildFirefoxXpiAddon {
      pname = "conex";
      version = "0.9.8resigned1";
      addonId = "{ec9d70ea-0229-49c0-bbf7-0df9bbccde35}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4272819/conex-0.9.8resigned1.xpi";
      sha256 = "4b1f0eab09dea1aada9069be1c79996ac32d905614e489994e29de55f0762c88";
      meta = with lib;
      {
        homepage = "https://github.com/kesselborn/conex#conex";
        description = "TabGroups married with Tab Containers and bookmark  &amp; history search";
        license = licenses.mpl20;
        mozPermissions = [
          "<all_urls>"
          "contextualIdentities"
          "cookies"
          "menus"
          "storage"
          "tabs"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
        ];
        platforms = platforms.all;
      };
    };
    "consent-o-matic" = buildFirefoxXpiAddon {
      pname = "consent-o-matic";
      version = "1.1.5";
      addonId = "gdpr@cavi.au.dk";
      url = "https://addons.mozilla.org/firefox/downloads/file/4515369/consent_o_matic-1.1.5.xpi";
      sha256 = "a2119abc329638d6e7af1ab4e5548a348465e02eec11de08dee0af84919923dc";
      meta = with lib;
      {
        homepage = "https://consentomatic.au.dk/";
        description = "Automatic handling of GDPR consent forms";
        license = licenses.mit;
        mozPermissions = [ "activeTab" "tabs" "storage" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "container-colors" = buildFirefoxXpiAddon {
      pname = "container-colors";
      version = "1.2";
      addonId = "{10ea07a8-8914-45e4-abd2-f85e962f3117}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3907316/container_colors-1.2.xpi";
      sha256 = "6bb9c3c22f3a72baf8b670b4639558968e2e88546856360ef9158e34cbe4b884";
      meta = with lib;
      {
        description = "Change theme colour based on your container color";
        license = licenses.mpl20;
        mozPermissions = [
          "cookies"
          "storage"
          "theme"
          "contextualIdentities"
          "<all_urls>"
          "tabs"
        ];
        platforms = platforms.all;
      };
    };
    "container-proxy" = buildFirefoxXpiAddon {
      pname = "container-proxy";
      version = "0.1.22";
      addonId = "contaner-proxy@bekh-ivanov.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/3865750/container_proxy-0.1.22.xpi";
      sha256 = "d1b82cecf0c2a136085a380540698cd6bcc43d7348364454da687d3d49cb2e21";
      meta = with lib;
      {
        homepage = "https://github.com/bekh6ex/firefox-container-proxy";
        description = "Allows Firefox user assign different proxies to be used in different containers";
        license = licenses.bsd2;
        mozPermissions = [
          "<all_urls>"
          "webRequest"
          "webRequestBlocking"
          "storage"
          "contextualIdentities"
          "cookies"
          "proxy"
        ];
        platforms = platforms.all;
      };
    };
    "container-tab-groups" = buildFirefoxXpiAddon {
      pname = "container-tab-groups";
      version = "11.11.0.200";
      addonId = "tab-array@menhera.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4436058/container_tab_groups-11.11.0.200.xpi";
      sha256 = "54ae4d2d4e412e524a1b461edd4108f6b0f5b0719fc0d34809dbdebedc0a63f1";
      meta = with lib;
      {
        homepage = "https://github.com/menhera-org/TabArray";
        description = "Chrome-like tab groups using private and isolated containers: The ultimate tab manager and groups for Firefox.";
        license = licenses.gpl3;
        mozPermissions = [
          "tabs"
          "tabHide"
          "<all_urls>"
          "cookies"
          "contextualIdentities"
          "menus"
          "menus.overrideContext"
          "storage"
          "browserSettings"
          "privacy"
          "webRequest"
          "webRequestBlocking"
          "sessions"
          "browsingData"
          "theme"
          "alarms"
          "scripting"
          "proxy"
        ];
        platforms = platforms.all;
      };
    };
    "container-tabs-sidebar" = buildFirefoxXpiAddon {
      pname = "container-tabs-sidebar";
      version = "1.2.0";
      addonId = "containertabssidebar@maciekmm.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4248024/container_tabs_sidebar-1.2.0.xpi";
      sha256 = "03a4b63c9283be40d29ddc41aefc169afd90d6188cba15dbbd01ed80db606bc1";
      meta = with lib;
      {
        homepage = "https://github.com/maciekmm/container-tabs-sidebar";
        description = "Show tabs in a sidebar grouped by privacy containers.";
        license = licenses.mpl20;
        mozPermissions = [
          "tabs"
          "contextualIdentities"
          "cookies"
          "menus"
          "menus.overrideContext"
          "storage"
          "sessions"
        ];
        platforms = platforms.all;
      };
    };
    "containerise" = buildFirefoxXpiAddon {
      pname = "containerise";
      version = "3.9.0";
      addonId = "containerise@kinte.sh";
      url = "https://addons.mozilla.org/firefox/downloads/file/3724805/containerise-3.9.0.xpi";
      sha256 = "bf511aa160512c5ece421d472977973d92e1609a248020e708561382aa10d1e5";
      meta = with lib;
      {
        homepage = "https://github.com/kintesh/containerise";
        description = "Automatically open websites in a dedicated container. Simply add rules to map domain or subdomain to your container.";
        license = licenses.mit;
        mozPermissions = [
          "contextualIdentities"
          "cookies"
          "tabs"
          "webRequest"
          "webRequestBlocking"
          "storage"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "control-panel-for-twitter" = buildFirefoxXpiAddon {
      pname = "control-panel-for-twitter";
      version = "4.14.1";
      addonId = "{5cce4ab5-3d47-41b9-af5e-8203eea05245}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4582072/control_panel_for_twitter-4.14.1.xpi";
      sha256 = "dd6b3ca65003e1ed778e1094e33e41963dc1e088e0918693501d5328c6c18ff6";
      meta = with lib;
      {
        homepage = "https://soitis.dev/control-panel-for-twitter";
        description = "Gives you more control over Twitter and adds missing features and UI improvements";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "https://twitter.com/*"
          "https://mobile.twitter.com/*"
          "https://x.com/*"
          "https://mobile.x.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "cookie-autodelete" = buildFirefoxXpiAddon {
      pname = "cookie-autodelete";
      version = "3.8.2";
      addonId = "CookieAutoDelete@kennydo.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4040738/cookie_autodelete-3.8.2.xpi";
      sha256 = "b02438aa5df2a79eb743da1b629b80d8c48114c9d030abb5538b591754e30f74";
      meta = with lib;
      {
        homepage = "https://github.com/Cookie-AutoDelete/Cookie-AutoDelete";
        description = "Control your cookies! This WebExtension is inspired by Self Destructing Cookies. When a tab closes, any cookies not being used are automatically deleted. Keep the ones you trust (forever/until restart) while deleting the rest. Containers Supported";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "alarms"
          "browsingData"
          "contextMenus"
          "contextualIdentities"
          "cookies"
          "notifications"
          "storage"
          "tabs"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "cookie-quick-manager" = buildFirefoxXpiAddon {
      pname = "cookie-quick-manager";
      version = "0.5rc2";
      addonId = "{60f82f00-9ad5-4de5-b31c-b16a47c51558}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3343599/cookie_quick_manager-0.5rc2.xpi";
      sha256 = "b826e443438c880b3998e42e099d0e1949ff51489c788b50193b92ef80426c6e";
      meta = with lib;
      {
        homepage = "https://github.com/ysard/cookie-quick-manager";
        description = "An addon to manage cookies (view, search, create, edit, remove, backup, restore, protect from deletion and much more). Firefox 57+ is supported.";
        license = licenses.gpl3;
        mozPermissions = [
          "cookies"
          "<all_urls>"
          "activeTab"
          "storage"
          "browsingData"
          "contextualIdentities"
          "privacy"
        ];
        platforms = platforms.all;
      };
    };
    "cookies-txt" = buildFirefoxXpiAddon {
      pname = "cookies-txt";
      version = "0.9";
      addonId = "{12cf650b-1822-40aa-bff0-996df6948878}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4573893/cookies_txt-0.9.xpi";
      sha256 = "a734a72d34dbeea1c0a2035c3fa3eb3e9119918b0249b5722ab1d89b142f42a0";
      meta = with lib;
      {
        description = "Exports all cookies to a Netscape HTTP Cookie File, as used by curl, wget, and youtube-dl, among others.";
        license = licenses.gpl3;
        mozPermissions = [
          "cookies"
          "downloads"
          "contextualIdentities"
          "<all_urls>"
          "tabs"
        ];
        platforms = platforms.all;
      };
    };
    "copy-as-markdown" = buildFirefoxXpiAddon {
      pname = "copy-as-markdown";
      version = "3.3.0";
      addonId = "jid1-tfBgelm3d4bLkQ@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4503663/copy_as_markdown-3.3.0.xpi";
      sha256 = "e88e11fd25a947caf6dc35b854081c94f95fc10d1795bab4aed12e43ed8a96a9";
      meta = with lib;
      {
        homepage = "https://github.com/yorkxin/copy-as-markdown";
        description = "Copy Links, Tabs &amp; Images as Markdown via right clicks.";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "alarms"
          "contextMenus"
          "clipboardWrite"
          "scripting"
          "storage"
        ];
        platforms = platforms.all;
      };
    };
    "copy-as-org-mode" = buildFirefoxXpiAddon {
      pname = "copy-as-org-mode";
      version = "0.2.0";
      addonId = "{59e590fc-6635-45fe-89c7-af637eb4b9c0}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3939068/copy_as_org_mode-0.2.0.xpi";
      sha256 = "dcd02dbd1a753928b82e772055a0532421f94bb40ae23b0606e6e91117909cce";
      meta = with lib;
      {
        homepage = "https://github.com/kuanyui/copy-as-org-mode";
        description = "Copy selection or link of current page as Org-mode format text!";
        license = licenses.mpl20;
        mozPermissions = [
          "activeTab"
          "clipboardWrite"
          "menus"
          "storage"
          "notifications"
        ];
        platforms = platforms.all;
      };
    };
    "copy-link-text" = buildFirefoxXpiAddon {
      pname = "copy-link-text";
      version = "1.6.6";
      addonId = "{b144be59-6bdc-41e0-9141-9f8d00373d93}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4563651/copy_link_text_webextension-1.6.6.xpi";
      sha256 = "909fa434170e57288d08fad67ff06d01f402196fdf87f564e20c045b67a5f8a3";
      meta = with lib;
      {
        homepage = "https://github.com/def00111/copy-link-text";
        description = "Copy the text of the link.";
        license = licenses.mpl20;
        mozPermissions = [ "clipboardWrite" "menus" "scripting" ];
        platforms = platforms.all;
      };
    };
    "copy-selected-links" = buildFirefoxXpiAddon {
      pname = "copy-selected-links";
      version = "2.4.1";
      addonId = "jid1-vs5odTmtIydjMg@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3860788/copy_selected_links-2.4.1.xpi";
      sha256 = "f32e2a30518dfcf72cfd39eda5015c85795d694c09b9d29ed0c62f67ed8768e1";
      meta = with lib;
      {
        homepage = "https://gitlab.com/Marnes/webextensions";
        description = "Right-click selected text to copy the URL of any links it contains.";
        license = licenses.mpl20;
        mozPermissions = [
          "notifications"
          "contextMenus"
          "storage"
          "activeTab"
        ];
        platforms = platforms.all;
      };
    };
    "copy-selected-tabs-to-clipboard" = buildFirefoxXpiAddon {
      pname = "copy-selected-tabs-to-clipboard";
      version = "1.6.7";
      addonId = "copy-selected-tabs-to-clipboard@piro.sakura.ne.jp";
      url = "https://addons.mozilla.org/firefox/downloads/file/4460922/copy_selected_tabs_to_clipboar-1.6.7.xpi";
      sha256 = "8b08615999b120e9b4927193c94275059b7c24af8fc5df668f3e44720c383218";
      meta = with lib;
      {
        description = "Provides ability to copy title and URL of selected tabs to the clipboard.";
        license = licenses.mpl20;
        mozPermissions = [
          "activeTab"
          "clipboardWrite"
          "contextualIdentities"
          "cookies"
          "menus"
          "notifications"
          "storage"
          "tabs"
        ];
        platforms = platforms.all;
      };
    };
    "copy-selection-as-markdown" = buildFirefoxXpiAddon {
      pname = "copy-selection-as-markdown";
      version = "0.23.0";
      addonId = "{db9a72da-7bc5-4805-bcea-da3cb1a15316}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4504977/copy_selection_as_markdown-0.23.0.xpi";
      sha256 = "64cb064d31aa79a26d0d8233272271f945b6dce79a1313832469a613e8370cee";
      meta = with lib;
      {
        homepage = "https://github.com/0x6b/copy-selection-as-markdown";
        description = "Copy title, URL, and selection as Markdown.";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "clipboardWrite"
          "contextMenus"
          "storage"
          "scripting"
        ];
        platforms = platforms.all;
      };
    };
    "copywebtables" = buildFirefoxXpiAddon {
      pname = "copywebtables";
      version = "0.1.1";
      addonId = "{292b92dc-b295-45e6-add6-a5ce6911a544}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3958866/copywebtables-0.1.1.xpi";
      sha256 = "5606074ebc94ef45cf7454565d25e0cfae6e25dd74bbbf3db1c803cbba86c39e";
      meta = with lib;
      {
        homepage = "https://github.com/nirantak/copytables";
        description = "Select table cells, rows and columns with your mouse or from a context menu. Copy as rich text, HTML, CSV and TSV";
        license = licenses.mit;
        mozPermissions = [
          "clipboardRead"
          "clipboardWrite"
          "contextMenus"
          "webNavigation"
          "storage"
          "*://*/*"
          "file://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "csgo-trader-steam-trading" = buildFirefoxXpiAddon {
      pname = "csgo-trader-steam-trading";
      version = "3.4.2";
      addonId = "{988dd4f5-e8d5-49bf-a766-ff75b0e19fe2}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4578256/csgo_trader_steam_trading-3.4.2.xpi";
      sha256 = "593ac26167275ff9f5925dc6c9b797acd6ad92401911347523a9f97a95807d4b";
      meta = with lib;
      {
        homepage = "https://csgotrader.app/";
        description = "Extension to help with CS2 trading, trade-lock countdown, in-browser inspect, doppler phases, prices, float values, etc";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "notifications"
          "alarms"
          "unlimitedStorage"
          "*://steamcommunity.com/*/inventory"
          "*://steamcommunity.com/*/inventory/*"
          "*://steamcommunity.com/tradeoffer/*"
          "*://steamcommunity.com/*/tradeoffers*"
          "*://steamcommunity.com/market/listings/*"
          "*://steamcommunity.com/id/*/*"
          "*://steamcommunity.com/id/*"
          "*://steamcommunity.com/profiles/*/*"
          "*://steamcommunity.com/profiles/*"
          "*://steamcommunity.com/groups/*"
          "*://steamcommunity.com/sharedfiles/filedetails/*"
          "*://steamcommunity.com/chat/*"
          "*://steamcommunity.com/dev/apikey*"
          "*://steamcommunity.com/dev/registerkey*"
          "*://steamcommunity.com/dev/revokekey*"
          "*://steamcommunity.com/groups/*/discussions/*"
          "*://steamcommunity.com/app/*/discussions/*"
          "*://steamcommunity.com/app/*/tradingforum/*"
          "*://steamcommunity.com/app/*/eventcomments/*"
          "*://steamcommunity.com/openid/login*"
          "*://steamcommunity.com/id/*/friends*"
          "*://steamcommunity.com/profiles/*/friends*"
          "*://steamcommunity.com/market/"
          "*://steamcommunity.com/market"
          "*://steamcommunity.com/market/search*"
          "*://steamcommunity.com/id/*/inventoryhistory*"
          "*://steamcommunity.com/id/*/tradehistory*"
          "*://csgotraders.net/mytrades*"
          "*://csgotraders.net/*"
        ];
        platforms = platforms.all;
      };
    };
    "csgofloat" = buildFirefoxXpiAddon {
      pname = "csgofloat";
      version = "5.8.1";
      addonId = "{194d0dc6-7ada-41c6-88b8-95d7636fe43c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4575548/csgofloat-5.8.1.xpi";
      sha256 = "6bfcfb61d0a0b026fcf75cc55ccd13904dd421a32bc3f158e4414a9be7b65013";
      meta = with lib;
      {
        homepage = "https://csgofloat.com";
        description = "Shows the float value, paint seed, and screenshots of Counter-Strike (CS:GO &amp; CS2) items on the Steam Market or Inventories";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "scripting"
          "alarms"
          "declarativeNetRequestWithHostAccess"
          "*://*.steamcommunity.com/market/listings/730/*"
          "*://*.steamcommunity.com/id/*/tradehistory*"
          "*://*.steamcommunity.com/profiles/*/tradehistory*"
          "*://*.steamcommunity.com/id/*/inventory*"
          "*://*.steamcommunity.com/profiles/*/inventory*"
          "*://*.steamcommunity.com/tradeoffer/*"
          "*://*.steamcommunity.com/*/tradeoffers/*"
          "*://*.steamcommunity.com/id/*"
          "*://*.steamcommunity.com/profiles/*"
          "*://*.csfloat.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "cssviewer-quantum" = buildFirefoxXpiAddon {
      pname = "cssviewer-quantum";
      version = "1.2resigned1";
      addonId = "CSSViewer@quantum";
      url = "https://addons.mozilla.org/firefox/downloads/file/4275453/cssviewer_quantum-1.2resigned1.xpi";
      sha256 = "62eb243533215e4205fbdbadd6fe67fed1964d3a9b07bbc022aa9e6f02e11fa5";
      meta = with lib;
      {
        homepage = "https://github.com/mohsenkhanpour/CSSViewer";
        description = "A simple yet powerful CSS property viewer. For Firefox Quantum";
        license = licenses.mpl20;
        mozPermissions = [
          "tabs"
          "http://*/*"
          "https://*/*"
          "file://*/*"
          "contextMenus"
        ];
        platforms = platforms.all;
      };
    };
    "ctrl-number-to-switch-tabs" = buildFirefoxXpiAddon {
      pname = "ctrl-number-to-switch-tabs";
      version = "1.0.2";
      addonId = "{84601290-bec9-494a-b11c-1baa897a9683}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4192880/ctrl_number_to_switch_tabs-1.0.2.xpi";
      sha256 = "777d01ddedaf027436f4651814cfe94658552ee311beec745753633401550a68";
      meta = with lib;
      {
        homepage = "https://github.com/AbigailBuccaneer/firefox-ctrlnumber";
        description = "Adds keyboard shortcut Ctrl+1 to switch to the first tab, Ctrl+2 to switch to the second, and so on. Ctrl+9 switches to the last tab.";
        license = licenses.mit;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "custom-new-tab-page" = buildFirefoxXpiAddon {
      pname = "custom-new-tab-page";
      version = "1.0.0";
      addonId = "custom-new-tab-page@mint.as";
      url = "https://addons.mozilla.org/firefox/downloads/file/3669474/custom_new_tab_page-1.0.0.xpi";
      sha256 = "0b9181b0af51628f1c8e4f0c28bf1f342b1e0d1e5de05c1e7aaab3bb474f4814";
      meta = with lib;
      {
        homepage = "https://github.com/methodgrab/firefox-custom-new-tab-page";
        description = "Specify a custom URL to be shown when opening a new tab, **without changing the address bar content**.";
        license = licenses.isc;
        mozPermissions = [ "storage" ];
        platforms = platforms.all;
      };
    };
    "cyberfeeder" = buildFirefoxXpiAddon {
      pname = "cyberfeeder";
      version = "5.2.0";
      addonId = "{fa19efb8-df2c-4f6a-ae08-6796a25ccdd6}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4608862/cyberfeeder-5.2.0.xpi";
      sha256 = "53b97ee903159c86751928b8924d0df806c2828e7cb35e2d4dd8207e9697da2d";
      meta = with lib;
      {
        description = "UI/UX improvements for jinteki.net.";
        license = licenses.mit;
        mozPermissions = [
          "scripting"
          "activeTab"
          "storage"
          "downloads"
          "https://*.jinteki.net/*"
        ];
        platforms = platforms.all;
      };
    };
    "danish-dictionary" = buildFirefoxXpiAddon {
      pname = "danish-dictionary";
      version = "2.9";
      addonId = "danish@dictionaries.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4489588/dansk_ordbog-2.9.xpi";
      sha256 = "880da26ac82e00bca036ca4e3997940ec8e57d437e8b3814d077e41008f2cdf2";
      meta = with lib;
      {
        homepage = "https://mozilladanmark.dk/stavekontrol/";
        description = "Danish dictionary for Firefox, Thunderbird and other Mozilla products.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "danish-language-pack" = buildFirefoxXpiAddon {
      pname = "danish-language-pack";
      version = "145.0.20251103.141854";
      addonId = "langpack-da@firefox.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4611789/dansk_da_language_pack-145.0.20251103.141854.xpi";
      sha256 = "12b92998b2a5fe681e538bfa47a832d302c53ad6976ee5c0a2612f9dca2cd70a";
      meta = with lib;
      {
        description = "Firefox Language Pack for Dansk (da) – Danish";
        license = licenses.mpl20;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "dark-background-light-text" = buildFirefoxXpiAddon {
      pname = "dark-background-light-text";
      version = "0.7.6";
      addonId = "jid1-QoFqdK4qzUfGWQ@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3722915/dark_background_light_text-0.7.6.xpi";
      sha256 = "1821db8eb7fb7910ca3e2ef7da283a2300e05a398c0e8c58763e0226da7dcd5b";
      meta = with lib;
      {
        homepage = "https://github.com/m-khvoinitsky/dark-background-light-text-extension";
        description = "Make every web page (or just the pages you want) display light text on dark backgrounds. All color variations are fully customizable.";
        license = licenses.mpl20;
        mozPermissions = [
          "<all_urls>"
          "tabs"
          "storage"
          "browserSettings"
          "webRequest"
          "webRequestBlocking"
        ];
        platforms = platforms.all;
      };
    };
    "dark-mode-webextension" = buildFirefoxXpiAddon {
      pname = "dark-mode-webextension";
      version = "0.5.4";
      addonId = "{174b2d58-b983-4501-ab4b-07e71203cb43}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4587807/dark_mode_webextension-0.5.4.xpi";
      sha256 = "1b614c05c713d5f27ca738b8a260095b1ee982fe6f20994b26ae74af14ae9d9d";
      meta = with lib;
      {
        homepage = "https://mybrowseraddon.com/dark-mode.html";
        description = "A global dark theme for the web";
        license = licenses.mpl20;
        mozPermissions = [ "storage" "contextMenus" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "dark-mode-website-switcher" = buildFirefoxXpiAddon {
      pname = "dark-mode-website-switcher";
      version = "2.0";
      addonId = "dark-mode-website-switcher@rugk.github.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/3878543/dark_mode_website_switcher-2.0.xpi";
      sha256 = "be18aeadee3248fa1e2866eac7011f8008311f82f0456fd4fcb796511218a16e";
      meta = with lib;
      {
        homepage = "https://github.com/rugk/website-dark-mode-switcher";
        description = "Adjusts the website's color scheme, so that all websites are dark by default, if they have a special design for that. It makes websites look dark even with a light system style.";
        license = licenses.mit;
        mozPermissions = [ "storage" "browserSettings" ];
        platforms = platforms.all;
      };
    };
    "dark-scroll-for-tweetdeck" = buildFirefoxXpiAddon {
      pname = "dark-scroll-for-tweetdeck";
      version = "2.0.0";
      addonId = "{759d3eb8-baf1-49e0-938b-0f963fdac3ae}";
      url = "https://addons.mozilla.org/firefox/downloads/file/1754743/dark_scroll_for_tweetdeck-2.0.0.xpi";
      sha256 = "e0f4e625eda09e9c8300ef650373d5a582a8c77c18eba572aa39d0bd8e3eb596";
      meta = with lib;
      {
        description = "Makes the scrollbars on TweetDeck and other sites dark in Firefox. This should be done by the site itself, not by an addon :(\n\nImage based on Scroll by Juan Pablo Bravo, CL https://thenounproject.com/term/scroll/18607/";
        license = licenses.lgpl3;
        mozPermissions = [ "activeTab" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "darkcloud" = buildFirefoxXpiAddon {
      pname = "darkcloud";
      version = "1.6.6";
      addonId = "{534c6d6e-de02-417d-a38e-4007d33914b6}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4333468/darkcloud-1.6.6.xpi";
      sha256 = "f1960e87c73b73fed40a943f9a078e9077d90818fd683f7bddab826d37153334";
      meta = with lib;
      {
        homepage = "http://acroma.rf.gd/darkcloud";
        description = "Changes soundcloud.com to a dark theme.";
        license = licenses.mpl20;
        mozPermissions = [ "*://*.soundcloud.com/*" ];
        platforms = platforms.all;
      };
    };
    "darkreader" = buildFirefoxXpiAddon {
      pname = "darkreader";
      version = "4.9.112";
      addonId = "addon@darkreader.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4598977/darkreader-4.9.112.xpi";
      sha256 = "dc1fc27b5e61662f1e1e8a60cbf8e11a77443888e40603f88db7c6b9e4ecb437";
      meta = with lib;
      {
        homepage = "https://darkreader.org/";
        description = "Dark mode for every website. Take care of your eyes, use dark theme for night and daily browsing.";
        license = licenses.mit;
        mozPermissions = [
          "alarms"
          "contextMenus"
          "storage"
          "tabs"
          "theme"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "dashlane" = buildFirefoxXpiAddon {
      pname = "dashlane";
      version = "6.2542.1";
      addonId = "jetpack-extension@dashlane.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4598943/dashlane-6.2542.1.xpi";
      sha256 = "1567fda7b316c1246c775f6359c6ce8e9d660dfa2fb9781718b9d408e527c444";
      meta = with lib;
      {
        homepage = "https://www.dashlane.com";
        description = "Dashlane makes the internet easier. Save all your passwords, fill forms fast, and keep your data accessible and safe.";
        license = {
          shortName = "dashlane";
          fullName = "Dashlane Terms of Service";
          url = "https://www.dashlane.com/terms";
          free = false;
        };
        mozPermissions = [
          "http://*/*"
          "https://*/*"
          "contextMenus"
          "cookies"
          "idle"
          "privacy"
          "storage"
          "tabs"
          "unlimitedStorage"
          "scripting"
          "webRequest"
          "webRequestBlocking"
        ];
        platforms = platforms.all;
      };
    };
    "dearrow" = buildFirefoxXpiAddon {
      pname = "dearrow";
      version = "2.1.11";
      addonId = "deArrow@ajay.app";
      url = "https://addons.mozilla.org/firefox/downloads/file/4597677/dearrow-2.1.11.xpi";
      sha256 = "a9f386c3d8ef128a571ede229a0d2f14bedb1c8ad646f43fb82282ae92992242";
      meta = with lib;
      {
        homepage = "https://dearrow.ajay.app";
        description = "Crowdsourcing titles and thumbnails to be descriptive and not sensational";
        license = licenses.lgpl3;
        mozPermissions = [
          "storage"
          "unlimitedStorage"
          "alarms"
          "https://sponsor.ajay.app/*"
          "https://dearrow-thumb.ajay.app/*"
          "https://*.googlevideo.com/*"
          "https://*.youtube.com/*"
          "https://www.youtube-nocookie.com/embed/*"
          "scripting"
        ];
        platforms = platforms.all;
      };
    };
    "decentraleyes" = buildFirefoxXpiAddon {
      pname = "decentraleyes";
      version = "3.0.0";
      addonId = "jid1-BoFifL9Vbdl2zQ@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4392113/decentraleyes-3.0.0.xpi";
      sha256 = "6f2efed90696ac7f8ca7efb8ab308feb3bdf182350b3acfdf4050c09cc02f113";
      meta = with lib;
      {
        homepage = "https://decentraleyes.org";
        description = "Protects you against tracking through \"free\", centralized, content delivery. It prevents a lot of requests from reaching networks like Google Hosted Libraries, and serves local files to keep sites from breaking. Complements regular content blockers.";
        license = licenses.mpl20;
        mozPermissions = [
          "privacy"
          "webNavigation"
          "webRequestBlocking"
          "webRequest"
          "unlimitedStorage"
          "storage"
          "tabs"
        ];
        platforms = platforms.all;
      };
    };
    "deutsch-de-language-pack" = buildFirefoxXpiAddon {
      pname = "deutsch-de-language-pack";
      version = "145.0.20251103.141854";
      addonId = "langpack-de@firefox.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4611792/deutsch_de_language_pack-145.0.20251103.141854.xpi";
      sha256 = "8e69c00b8ff21fcecf352efbd23ab95eca18b6beea4b4fdb63864efe265b7199";
      meta = with lib;
      {
        description = "Firefox Language Pack for Deutsch (de) – German";
        license = licenses.mpl20;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "df-youtube" = buildFirefoxXpiAddon {
      pname = "df-youtube";
      version = "1.13.504";
      addonId = "dfyoutube@example.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3449086/df_youtube-1.13.504.xpi";
      sha256 = "5b10ae345c2fe1151bb760313738b9b3860a781bbc54276e95cfedba65f2cdf3";
      meta = with lib;
      {
        description = "Allow yourself to focus while using YouTube for work, recreation or education.  Disable autoplay, remove sidebar, hide feed, comments, and more.";
        license = licenses.mpl20;
        mozPermissions = [
          "https://api.mailgun.net/*"
          "storage"
          "tabs"
          "notifications"
          "https://www.youtube.com/*"
          "https://www.youtube.com/?*"
          "https://www.youtube.com/watch*"
        ];
        platforms = platforms.all;
      };
    };
    "dictionaries" = buildFirefoxXpiAddon {
      pname = "dictionaries";
      version = "6.1.0";
      addonId = "revir.qing@gmail.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4595692/dictionaries-6.1.0.xpi";
      sha256 = "9681b6e70cb835ae3a559746d053cc71cc38b320e3c1c32d6cbd7793d611d89f";
      meta = with lib;
      {
        homepage = "https://github.com/revir/dictionaries";
        description = "Dictionariez: This extension help you reading articles, looking up words of any language in various dictionaries, and exporting words to Anki, facilitating your language learning process.";
        license = licenses.gpl2;
        mozPermissions = [
          "activeTab"
          "tabs"
          "storage"
          "contextMenus"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "dictionary-german" = buildFirefoxXpiAddon {
      pname = "dictionary-german";
      version = "2.1";
      addonId = "de-DE@dictionaries.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4034565/dictionary_german-2.1.xpi";
      sha256 = "00ef6eb3c10171a87fb22ab6e516846678b73c56ae828cc19d11e32e43b8457a";
      meta = with lib;
      {
        description = "German Dictionary (new Orthography) for spellchecking in Firefox";
        license = licenses.lgpl21;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "dictionary-spanish" = buildFirefoxXpiAddon {
      pname = "dictionary-spanish";
      version = "3.2.9";
      addonId = "es-es@dictionaries.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4413333/diccionario_de_espanol_espana-3.2.9.xpi";
      sha256 = "83a8f9117d7224728507d90990a7dfecd84a05aa55f9dd8ccc1bc199a163e739";
      meta = with lib;
      {
        homepage = "http://www.proyectonave.es/productos/extensiones/diccionario-es-ES";
        description = "Spanish/Spain Dictionary";
        license = licenses.mpl20;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "disable-facebook-news-feed" = buildFirefoxXpiAddon {
      pname = "disable-facebook-news-feed";
      version = "3.3";
      addonId = "{85cd2b5d-b3bd-4037-8335-ced996a95092}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4015709/disable_facebook_news_feed-3.3.xpi";
      sha256 = "8706de4ac241ff223ab9983b22c5805fcc8afb8477e574d9f873065fa72d4dbb";
      meta = with lib;
      {
        description = "Removes News Feed from Facebook. Saves hours of scrolling.";
        license = licenses.mpl20;
        mozPermissions = [ "*://*.facebook.com/*" ];
        platforms = platforms.all;
      };
    };
    "disable-javascript" = buildFirefoxXpiAddon {
      pname = "disable-javascript";
      version = "2.3.2resigned1";
      addonId = "{41f9e51d-35e4-4b29-af66-422ff81c8b41}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4273529/disable_javascript-2.3.2resigned1.xpi";
      sha256 = "3fe160035a3bcafbf3acb11e9d672e7ce022afc21444ec66b0eb99f72dd40466";
      meta = with lib;
      {
        homepage = "https://github.com/dpacassi/disable-javascript";
        description = "Adds the ability to disable JavaScript for specific sites or specific tabs.\nYou can customize the default JS state (on or off), the disable behavior (by domain or by tab) and much more.";
        license = licenses.mit;
        mozPermissions = [
          "<all_urls>"
          "activeTab"
          "storage"
          "tabs"
          "webRequest"
          "webRequestBlocking"
          "menus"
          "contextMenus"
        ];
        platforms = platforms.all;
      };
    };
    "disconnect" = buildFirefoxXpiAddon {
      pname = "disconnect";
      version = "20.3.1.2";
      addonId = "2.0@disconnect.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/4240055/disconnect-20.3.1.2.xpi";
      sha256 = "5fe7ac089f9de8a10520813b527e76d95248aba8c8414e2dc2c359c505ca3b31";
      meta = with lib;
      {
        homepage = "https://disconnect.me/";
        description = "Make the web faster, more private, and more secure.";
        license = licenses.gpl3;
        mozPermissions = [
          "tabs"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "http://*/*"
          "https://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "display-_anchors" = buildFirefoxXpiAddon {
      pname = "display-_anchors";
      version = "1.4resigned1";
      addonId = "display-anchors@robwu.nl";
      url = "https://addons.mozilla.org/firefox/downloads/file/4271984/display__anchors-1.4resigned1.xpi";
      sha256 = "5028274d94e887319937d4dcdeb3a06d21746523ac5e104fb4775eb22d943c60";
      meta = with lib;
      {
        homepage = "https://github.com/Rob--W/display-anchors";
        description = "Displays anchors for all content in the current web page without breaking the layout.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "notifications"
          "contextMenus"
          "activeTab"
        ];
        platforms = platforms.all;
      };
    };
    "docsafterdark" = buildFirefoxXpiAddon {
      pname = "docsafterdark";
      version = "1.1.1";
      addonId = "{e8ffc3db-2875-4c7f-af38-d03e7f7f8ab9}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4420694/docsafterdark-1.1.1.xpi";
      sha256 = "4b64f97b110beb5552a1326f0bc772d185b1a39279c330d4b54b68a8f7ec7285";
      meta = with lib;
      {
        homepage = "https://waymondrang.com/docsafterdark/";
        description = "Modern, dark mode for Google Docs";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "activeTab"
          "*://docs.google.com/document/*"
        ];
        platforms = platforms.all;
      };
    };
    "don-t-fuck-with-paste" = buildFirefoxXpiAddon {
      pname = "don-t-fuck-with-paste";
      version = "2.7";
      addonId = "DontFuckWithPaste@raim.ist";
      url = "https://addons.mozilla.org/firefox/downloads/file/3630212/don_t_fuck_with_paste-2.7.xpi";
      sha256 = "ef17dcef7e2034a25982a106e54d19e24c9f226434a396a808195ef0de021a40";
      meta = with lib;
      {
        homepage = "https://github.com/aaronraimist/DontFuckWithPaste";
        description = "This add-on stops websites from blocking copy and paste for password fields and other input fields.";
        license = licenses.mit;
        mozPermissions = [ "storage" "tabs" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "download-with-jdownloader" = buildFirefoxXpiAddon {
      pname = "download-with-jdownloader";
      version = "0.3.6";
      addonId = "{03e07985-30b0-4ae0-8b3e-0c7519b9bdf6}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4558896/download_with_jdownloader-0.3.6.xpi";
      sha256 = "42c6b77c604e1bd6a2486dda75df772ff72c2de228939454e81afa6ccfa11dcc";
      meta = with lib;
      {
        homepage = "https://webextension.org/listing/download-with.html?from=jdownloader";
        description = "when activated, interrupts the built-in download manager to direct links to JDownloader";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "nativeMessaging"
          "notifications"
          "downloads"
          "contextMenus"
          "activeTab"
          "scripting"
        ];
        platforms = platforms.all;
      };
    };
    "downthemall" = buildFirefoxXpiAddon {
      pname = "downthemall";
      version = "4.13.1";
      addonId = "{DDC359D1-844A-42a7-9AA1-88A850A938A8}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4370602/downthemall-4.13.1.xpi";
      sha256 = "ae0dbb3446bf96fdce8f9da9f82d492d8f21aa903fb971c7d5e84ea5cb637164";
      meta = with lib;
      {
        homepage = "https://www.downthemall.org/";
        description = "The Mass Downloader for your browser";
        license = licenses.gpl2;
        mozPermissions = [
          "<all_urls>"
          "contextMenus"
          "downloads"
          "downloads.open"
          "history"
          "menus"
          "notifications"
          "sessions"
          "storage"
          "tabs"
          "theme"
          "webNavigation"
        ];
        platforms = platforms.all;
      };
    };
    "dracula-dark-colorscheme" = buildFirefoxXpiAddon {
      pname = "dracula-dark-colorscheme";
      version = "1.11";
      addonId = "{b743f56d-1cc1-4048-8ba6-f9c2ab7aa54d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4408557/dracula_dark_colorscheme-1.11.xpi";
      sha256 = "111b1c2bc773fb0af562c2c859343e59d8a90d1a446119697f880d1771253e59";
      meta = with lib;
      {
        homepage = "https://draculatheme.com/firefox";
        description = "Official Dracula theme for firefox.";
        license = licenses.cc-by-nc-sa-30;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "dualsub" = buildFirefoxXpiAddon {
      pname = "dualsub";
      version = "2.65.2";
      addonId = "{104db41e-43f7-4484-bda8-a59536364925}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4610346/dualsub-2.65.2.xpi";
      sha256 = "cb7115b5e7ca7c62af666338bd1e114652e902a7ad785445d7c76a122e5b937d";
      meta = with lib;
      {
        homepage = "https://www.dualsub.xyz/en/";
        description = "Display dual subtitles on video websites.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "storage"
          "https://www.youtube.com/*"
          "https://m.youtube.com/*"
          "https://www.ardmediathek.de/*"
          "https://www.bilibili.com/*"
          "https://www.coursera.org/*"
          "https://www.iflix.com/*"
          "https://www.iq.com/*"
          "https://www.udemy.com/*"
          "https://www.viki.com/*"
          "https://www.youku.tv/*"
          "https://www.zdf.de/*"
          "https://wetv.vip/*"
        ];
        platforms = platforms.all;
      };
    };
    "duckduckgo-privacy-essentials" = buildFirefoxXpiAddon {
      pname = "duckduckgo-privacy-essentials";
      version = "2025.8.25";
      addonId = "jid1-ZAdIEUB7XOzOJw@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4576912/duckduckgo_for_firefox-2025.8.25.xpi";
      sha256 = "ba48e37aff7a6a590770dcc557d3d349a1cdbffb58d3ee82827388b9807144fb";
      meta = with lib;
      {
        homepage = "https://duckduckgo.com/app";
        description = "Actively protects your data in your current browser";
        license = licenses.asl20;
        mozPermissions = [
          "contextMenus"
          "webRequest"
          "webRequestBlocking"
          "*://*/*"
          "webNavigation"
          "activeTab"
          "tabs"
          "storage"
          "<all_urls>"
          "alarms"
        ];
        platforms = platforms.all;
      };
    };
    "earth-view-from-google" = buildFirefoxXpiAddon {
      pname = "earth-view-from-google";
      version = "2.18.8resigned1";
      addonId = "{44ec79ad-72a9-471d-962d-49e7e5501d97}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4272651/earth_view_from_google-2.18.8resigned1.xpi";
      sha256 = "5af6c059c80a0f61405c1cb75987bbb0c3f8f7a79d29ebebdaf9ab478fcc722c";
      meta = with lib;
      {
        homepage = "https://earthview.withgoogle.com/";
        description = "Experience a beautiful image from Google Earth every time you open a new tab.";
        license = licenses.asl20;
        mozPermissions = [ "https://www.gstatic.com/prettyearth/*" ];
        platforms = platforms.all;
      };
    };
    "ebates" = buildFirefoxXpiAddon {
      pname = "ebates";
      version = "5.67.3";
      addonId = "{35d6291e-1d4b-f9b4-c52f-77e6410d1326}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4546027/ebates-5.67.3.xpi";
      sha256 = "7745045e1508730a06d790c870717c8544165976fde1a0f725fc8e482a014b1c";
      meta = with lib;
      {
        homepage = "https://www.rakuten.com";
        description = "Start shopping smarter with Cash Back and coupons. By clicking Add to Firefox you agree to the Rakuten Extension Terms &amp; Conditions";
        license = licenses.mpl20;
        mozPermissions = [
          "tabs"
          "webNavigation"
          "webRequest"
          "storage"
          "cookies"
          "alarms"
          "scripting"
          "<all_urls>"
          "https://*.rakuten.com/*"
          "https://*.rakuten.co.uk/*"
        ];
        platforms = platforms.all;
      };
    };
    "ebates-express-cash-back" = buildFirefoxXpiAddon {
      pname = "ebates-express-cash-back";
      version = "7.8.1";
      addonId = "ebatesca@ebates.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3952935/ebates_express_cash_back-7.8.1.xpi";
      sha256 = "7d0b79886ea02e3b97ae3734978f300e514c11e94946a5681ab7a9d98147d713";
      meta = with lib;
      {
        homepage = "https://www.rakuten.ca/";
        description = "Always forgetting Cash Back?\nLet us help. Shop like you normally would at your favourite stores and we’ll alert you when Cash Back is available. Trust us, you’ll never forget Cash Back again!";
        license = licenses.mpl11;
        mozPermissions = [
          "cookies"
          "tabs"
          "webNavigation"
          "webRequest"
          "storage"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "ecosia" = buildFirefoxXpiAddon {
      pname = "ecosia";
      version = "6.2.0";
      addonId = "{d04b0b40-3dab-4f0b-97a6-04ec3eddbfb0}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4589297/ecosia_the_green_search-6.2.0.xpi";
      sha256 = "83fd5a5a71692283a3e75a6eb01157eb2281c01f000fd94193074d02db9cd230";
      meta = with lib;
      {
        homepage = "http://www.ecosia.org";
        description = "This extension adds Ecosia.org as the default search engine to your browser — it’s completely free!";
        license = licenses.mpl20;
        mozPermissions = [ "storage" "contextMenus" "*://*.ecosia.org/*" ];
        platforms = platforms.all;
      };
    };
    "edit-with-emacs" = buildFirefoxXpiAddon {
      pname = "edit-with-emacs";
      version = "1.16";
      addonId = "{8dd384e7-fc9e-4b6a-a744-497edc3408c3}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3708541/edit_with_emacs1-1.16.xpi";
      sha256 = "f670a66c37e139f3d40fe963b0e9d77d4f84ac92e02f1f97434480a23cb85b94";
      meta = with lib;
      {
        homepage = "https://github.com/stsquad/emacs_chrome";
        description = "Allow user to edit web-page textareas with Emacs (and other editors).";
        license = licenses.gpl3;
        mozPermissions = [
          "tabs"
          "contextMenus"
          "notifications"
          "http://penguin.linux.test/edit/*"
          "http://127.0.0.1/edit/*"
          "clipboardRead"
          "http://*/*"
          "https://*/*"
          "file://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "elasticvue" = buildFirefoxXpiAddon {
      pname = "elasticvue";
      version = "1.10.0";
      addonId = "{2879bc11-6e9e-4d73-82c9-1ed8b78df296}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4603875/elasticvue-1.10.0.xpi";
      sha256 = "dcb768adc122d06c9db1337b34087809746b7f06ef5f7682e117c8003c2ea84d";
      meta = with lib;
      {
        homepage = "https://elasticvue.com/";
        description = "Elasticvue is a free and simple elasticsearch gui for your browser";
        license = licenses.mit;
        mozPermissions = [ "http://*/*" "https://*/*" ];
        platforms = platforms.all;
      };
    };
    "enhanced-github" = buildFirefoxXpiAddon {
      pname = "enhanced-github";
      version = "6.1.0";
      addonId = "{72bd91c9-3dc5-40a8-9b10-dec633c0873f}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4297236/enhanced_github-6.1.0.xpi";
      sha256 = "8ebf2ff7602e1747f3cc329e7c99acf7348d019ec456e5639d9d90af0b7afec3";
      meta = with lib;
      {
        homepage = "https://github.com/softvar/enhanced-github";
        description = "Display repo size, size of each file, download link and option to copy file contents";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "webRequest"
          "webNavigation"
          "*://*.github.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "enhanced-h264ify" = buildFirefoxXpiAddon {
      pname = "enhanced-h264ify";
      version = "2.2.1";
      addonId = "{9a41dee2-b924-4161-a971-7fb35c053a4a}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4295701/enhanced_h264ify-2.2.1.xpi";
      sha256 = "68bf0cd6b2c26de24f263eb76848886665423b73c3f055633dcdbde51d2a35a9";
      meta = with lib;
      {
        homepage = "https://github.com/alextrv/enhanced-h264ify";
        description = "Choose what video codec YouTube should play for you";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "*://*.youtube.com/*"
          "*://*.youtube-nocookie.com/*"
          "*://*.youtu.be/*"
        ];
        platforms = platforms.all;
      };
    };
    "enhancer-for-nebula" = buildFirefoxXpiAddon {
      pname = "enhancer-for-nebula";
      version = "1.7.3";
      addonId = "nebula-enhancer@piber.at";
      url = "https://addons.mozilla.org/firefox/downloads/file/4588872/enhancer_for_nebula-1.7.3.xpi";
      sha256 = "1a5e711868fb7d16fd151218cd800a459248ca22b0816dc21ea78c6106100cca";
      meta = with lib;
      {
        homepage = "https://github.com/cpiber/NebulaEnhance#readme";
        description = "Enhancer for Nebula. Adds quality of life features to the nebula player.";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "*://content.api.nebula.app/*"
          "*://*.nebula.tv/*"
          "*://*.nebula.app/*"
          "*://*.youtube.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "export-cookies-txt" = buildFirefoxXpiAddon {
      pname = "export-cookies-txt";
      version = "0.3.2";
      addonId = "{36bdf805-c6f2-4f41-94d2-9b646342c1dc}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3403419/export_cookies_txt-0.3.2.xpi";
      sha256 = "8bb7d83fc0185c8e789ff1c81d8905cf0bba69294cebec861cca7b45abf1d2b7";
      meta = with lib;
      {
        homepage = "https://github.com/rotemdan/ExportCookies";
        description = "Export cookies to a Netscape format cookies.txt file.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "cookies"
          "downloads"
          "tabs"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "export-tabs-urls-and-titles" = buildFirefoxXpiAddon {
      pname = "export-tabs-urls-and-titles";
      version = "0.2.12";
      addonId = "{17165bd9-9b71-4323-99a5-3d4ce49f3d75}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3398882/export_tabs_urls_and_titles-0.2.12.xpi";
      sha256 = "ff71ff6e300bf00e02ba79e127073f918aec79f951b749b2f06add006e773ac9";
      meta = with lib;
      {
        homepage = "https://github.com/alct/export-tabs-urls";
        description = "List the URLs of all the open tabs and copy that list to clipboard or export it to a file.\n\nFeatures:\n- include titles\n- custom format (e.g. markdown, html…)\n- filter tabs\n- limit to current window\n- list non-HTTP(s) URLs\n- ignore pinned tabs";
        license = licenses.gpl3;
        mozPermissions = [ "clipboardWrite" "notifications" "storage" "tabs" ];
        platforms = platforms.all;
      };
    };
    "exstatic" = buildFirefoxXpiAddon {
      pname = "exstatic";
      version = "0.0.10";
      addonId = "{8a4101fc-747b-42b0-8f48-184df8cba172}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4244429/exstatic-0.0.10.xpi";
      sha256 = "7dbfa0a0ef15c63b5ebb2f10e92f1d2c5f5388d57274cc04339f1413e8b74dde";
      meta = with lib;
      {
        homepage = "https://github.com/KamWithK/exSTATic";
        description = "Zero effort language learning IMMERSION statistic collection and visualisation!\n\nYou read and get pretty stats and graphs to show your progress :)";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "unlimitedStorage"
          "tabs"
          "scripting"
          "downloads"
          "https://kamwithk.github.io/exSTATic/tracker.html"
          "file:///*/exSTATic/*/tracker.html"
          "file:///*/fjiikigkdpahddfcembbapebejanfnhf/*/tracker.html"
          "https://ttu-ebook.web.app/**"
          "https://reader.ttsu.app/**"
          "file:///**/ttu-ebook.web.app/**"
          "file:///**/reader.ttsu.app/**"
          "https://*/Manga/**.html"
          "file:///**/Manga/**.html"
          "https://kamwithk.github.io/exSTATic/stats.html"
          "file:///*/exSTATic/*/stats.html"
          "file:///*/fjiikigkdpahddfcembbapebejanfnhf/*/stats.html"
          "https://kamwithk.github.io/exSTATic/settings.html"
          "file:///*/exSTATic/*/settings.html"
          "file:///*/fjiikigkdpahddfcembbapebejanfnhf/*/settings.html"
        ];
        platforms = platforms.all;
      };
    };
    "external-application" = buildFirefoxXpiAddon {
      pname = "external-application";
      version = "0.6.0";
      addonId = "{65b77238-bb05-470a-a445-ec0efe1d66c4}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4523435/external_application-0.6.0.xpi";
      sha256 = "5b3813b6a409b8d06cc57df3769c787ec0f646add6a31cfa762a14cc3cec043a";
      meta = with lib;
      {
        homepage = "https://webextension.org/listing/external-application-button.html";
        description = "A highly customizable external application button and context-menu items";
        license = licenses.mpl20;
        mozPermissions = [
          "activeTab"
          "storage"
          "contextMenus"
          "nativeMessaging"
          "downloads"
          "notifications"
          "declarativeNetRequestWithHostAccess"
          "scripting"
        ];
        platforms = platforms.all;
      };
    };
    "facebook-container" = buildFirefoxXpiAddon {
      pname = "facebook-container";
      version = "2.3.12";
      addonId = "@contain-facebook";
      url = "https://addons.mozilla.org/firefox/downloads/file/4451874/facebook_container-2.3.12.xpi";
      sha256 = "3369bd865877860e6d7d38399d5902b300d3d5737acb2d1342ff5beb1d3780c1";
      meta = with lib;
      {
        homepage = "https://github.com/mozilla/contain-facebook";
        description = "Prevent Facebook from tracking you around the web. The Facebook Container extension for Firefox helps you take control and isolate your web activity from Facebook.";
        license = licenses.mpl20;
        mozPermissions = [
          "<all_urls>"
          "browsingData"
          "contextualIdentities"
          "cookies"
          "management"
          "storage"
          "tabs"
          "webRequestBlocking"
          "webRequest"
        ];
        platforms = platforms.all;
      };
    };
    "facebook-tracking-removal" = buildFirefoxXpiAddon {
      pname = "facebook-tracking-removal";
      version = "1.13.0";
      addonId = "{bb1b80be-e6b3-40a1-9b6e-9d4073343f0b}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4305679/facebook_tracking_removal-1.13.0.xpi";
      sha256 = "b0a963fa7f4850514166f26b46fa942efceefbb2876d15f176668548fb8100da";
      meta = with lib;
      {
        homepage = "https://github.com/mgziminsky/FacebookTrackingRemoval";
        description = "Removes Ads and the user interaction tracking on Facebook™.\nModified elements can optionally have a custom CSS style applied to them so that cleaned items can be more easily identified.";
        license = licenses.gpl3;
        mozPermissions = [
          "alarms"
          "declarativeNetRequestWithHostAccess"
          "scripting"
          "storage"
          "webNavigation"
          "*://*.facebook.com/*"
          "*://*.messenger.com/*"
          "*://*.facebookwkhpilnemxj7asaniu7vnjjbiltxjqhye3mhbshg7kx5tfyd.onion/*"
        ];
        platforms = platforms.all;
      };
    };
    "fake-filler" = buildFirefoxXpiAddon {
      pname = "fake-filler";
      version = "4.1.0";
      addonId = "{7efbd09d-90ad-47fa-b91a-08c472bdf566}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4330661/fake_filler-4.1.0.xpi";
      sha256 = "e9580664551e42719df5bbc962e201dfa0d6db03bc414cb1c89a61b9597a0e3a";
      meta = with lib;
      {
        homepage = "https://fakefiller.com";
        description = "A form filler that fills all form inputs (textboxes, textareas, radio buttons, dropdowns, etc.) with fake and randomly generated data.\n\nThe purpose of this extension is to help developers and testers test forms quickly and easily.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "contextMenus"
          "activeTab"
          "storage"
          "scripting"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "fastforwardteam" = buildFirefoxXpiAddon {
      pname = "fastforwardteam";
      version = "0.2383";
      addonId = "addon@fastforward.team";
      url = "https://addons.mozilla.org/firefox/downloads/file/4258067/fastforwardteam-0.2383.xpi";
      sha256 = "eec6328df3df1afe2cb6a331f6907669d804235551ea766d48655f8f831caf28";
      meta = with lib;
      {
        homepage = "https://fastforward.team";
        description = "Don't waste time with compliance. Use FastForward to skip annoying URL \"shorteners\".";
        license = licenses.unlicense;
        mozPermissions = [
          "alarms"
          "storage"
          "webNavigation"
          "tabs"
          "declarativeNetRequestWithHostAccess"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "faststream" = buildFirefoxXpiAddon {
      pname = "faststream";
      version = "1.3.66";
      addonId = "faststream@andrews";
      url = "https://addons.mozilla.org/firefox/downloads/file/4611224/faststream-1.3.66.xpi";
      sha256 = "8ded7ff0536f41bcea46fa3d7b5df887ca96f9b2a69a298589f0fa69570d9261";
      meta = with lib;
      {
        homepage = "https://faststream.online/";
        description = "Stream videos without buffering in the browser. An extension that gives you a better, accessible video player designed for your needs.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "storage"
          "tabs"
          "webRequest"
          "declarativeNetRequest"
          "downloads"
          "cookies"
          "contextualIdentities"
          "https://www.bilibili.com/*"
          "https://www.bilibili.tv/*"
          "https://www.facebook.com/*"
          "https://www.instagram.com/*"
          "https://www.youtube.com/*"
          "https://youtube.com/*"
          "https://m.youtube.com/*"
          "https://music.youtube.com/*"
          "https://www.youtube-nocookie.com/*"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "fediact" = buildFirefoxXpiAddon {
      pname = "fediact";
      version = "0.9.8.7";
      addonId = "{cca112bb-1ca6-4593-a2f1-38d808a19dda}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4049927/fediact-0.9.8.7.xpi";
      sha256 = "c0b0891d049a3ad9b8c7716c7f2b20d27d4082030bf806dd773561e51acfb387";
      meta = with lib;
      {
        homepage = "https://github.com/Lartsch/FediAct";
        description = "Simplifies interactions on other Mastodon instances than your own. Visit https://github.com/lartsch/FediAct for more.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "alarms"
          "tabs"
          "https://*/*"
          "http://*/*"
          "*://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "feedbroreader" = buildFirefoxXpiAddon {
      pname = "feedbroreader";
      version = "4.16.3";
      addonId = "{a9c2ad37-e940-4892-8dce-cd73c6cbbc0c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4254656/feedbroreader-4.16.3.xpi";
      sha256 = "1d588e721f68bdc965fb44d29376485502c622d5f26de33ca9312328530ade11";
      meta = with lib;
      {
        homepage = "http://nodetics.com/feedbro";
        description = "Advanced Feed Reader - Read news &amp; blogs or any RSS/Atom/RDF source.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "tabs"
          "http://*/"
          "https://*/"
          "storage"
          "unlimitedStorage"
          "notifications"
          "webRequest"
          "webRequestBlocking"
        ];
        platforms = platforms.all;
      };
    };
    "ff2mpv" = buildFirefoxXpiAddon {
      pname = "ff2mpv";
      version = "6.0.0";
      addonId = "ff2mpv@yossarian.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4394631/ff2mpv-6.0.0.xpi";
      sha256 = "f5edb75698ebd73d7a6d4034a37636022019adde712379b7a43e741b2a179b9d";
      meta = with lib;
      {
        homepage = "https://github.com/woodruffw/ff2mpv";
        description = "Tries to play links in mpv.\n\nPress the toolbar button to play the current URL in mpv. Otherwise, right click on a URL and use the context  item to play an arbitrary URL.\n\nYou'll need the native client here: github.com/woodruffw/ff2mpv";
        license = licenses.mit;
        mozPermissions = [
          "nativeMessaging"
          "contextMenus"
          "activeTab"
          "storage"
          "scripting"
        ];
        platforms = platforms.all;
      };
    };
    "ficlab" = buildFirefoxXpiAddon {
      pname = "ficlab";
      version = "1.0.111";
      addonId = "ficlab-helper@mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4414535/ficlab-1.0.111.xpi";
      sha256 = "b00599ecf7ec30d43ada122c8d17de224eab508cee8732ddfbb8e1b1d6e0c95c";
      meta = with lib;
      {
        homepage = "https://www.ficlab.com/";
        description = "Download fanfiction as ebook files from a number of popular sites. Simple to use, with beautiful results.";
        license = {
          shortName = "ficlab";
          fullName = "Custom License for FicLab";
          url = "https://addons.mozilla.org/en-US/firefox/addon/ficlab/license/";
          free = false;
        };
        mozPermissions = [
          "downloads"
          "storage"
          "<all_urls>"
          "https://*.fanfiction.net/*"
          "https://*.fictionpress.com/*"
          "https://www.fimfiction.net/*"
          "https://literotica.com/*"
          "https://*.literotica.com/*"
          "https://archiveofourown.org/*"
          "https://www.archiveofourown.org/*"
          "https://starslibrary.net/*"
          "https://www.starslibrary.net/*"
          "https://www.asianfanfics.com/*"
          "https://www.inkitt.com/*"
          "https://getinkspired.com/*"
          "https://www.getinkspired.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "finicky" = buildFirefoxXpiAddon {
      pname = "finicky";
      version = "0.2.0";
      addonId = "{294f2459-f2cf-4ab1-a822-342896cf0326}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4504197/finicky-0.2.0.xpi";
      sha256 = "22de0a386d92c9a69d45ad4338ef82d54c9cbc3cdfb416044f5e7ed5d3838e37";
      meta = with lib;
      {
        homepage = "https://github.com/johnste/finicky";
        description = "The Official Finicky Browser Extension. Requires Finicky (macOS only). Opens links in other applications by right clicking them or clicking them while pressing alt.";
        license = licenses.mit;
        mozPermissions = [ "contextMenus" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "firefox-color" = buildFirefoxXpiAddon {
      pname = "firefox-color";
      version = "2.1.7";
      addonId = "FirefoxColor@mozilla.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3643624/firefox_color-2.1.7.xpi";
      sha256 = "b7fb07b6788f7233dd6223e780e189b4c7b956c25c40493c28d7020493249292";
      meta = with lib;
      {
        homepage = "https://color.firefox.com";
        description = "Build, save and share beautiful Firefox themes.";
        license = licenses.mpl20;
        mozPermissions = [
          "theme"
          "storage"
          "tabs"
          "https://color.firefox.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "firefox-translations" = buildFirefoxXpiAddon {
      pname = "firefox-translations";
      version = "1.3.4buildid20230720.091143";
      addonId = "firefox-translations-addon@mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4141509/firefox_translations-1.3.4buildid20230720.091143.xpi";
      sha256 = "d2ad4d71079754aec1fab2a03294a5ab5992bd377c57561cfa331e61b5c440e3";
      meta = with lib;
      {
        homepage = "https://blog.mozilla.org/en/mozilla/local-translation-add-on-project-bergamot/";
        description = "Translate websites in your browser, privately, without using the cloud. The functionality from this extension is now integrated into Firefox.";
        license = licenses.mpl20;
        mozPermissions = [
          "<all_urls>"
          "tabs"
          "webNavigation"
          "storage"
          "mozillaAddons"
          "contextMenus"
        ];
        platforms = platforms.all;
      };
    };
    "firemonkey" = buildFirefoxXpiAddon {
      pname = "firemonkey";
      version = "2.74";
      addonId = "firemonkey@eros.man";
      url = "https://addons.mozilla.org/firefox/downloads/file/4425870/firemonkey-2.74.xpi";
      sha256 = "138cbf38ec97c13ed00ad4b3753739896ba102b07ee9fdd789ca5561235273d0";
      meta = with lib;
      {
        homepage = "https://github.com/erosman/firemonkey";
        description = "Super Lightweight User Script and Style Manager";
        license = licenses.mpl20;
        mozPermissions = [
          "clipboardWrite"
          "cookies"
          "downloads"
          "idle"
          "menus"
          "notifications"
          "storage"
          "tabs"
          "unlimitedStorage"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "<all_urls>"
          "https://greasyfork.org/*/scripts/*"
          "https://sleazyfork.org/*/scripts/*"
          "*://*/*.user.js"
          "*://*/*.user.css"
          "file:///*.user.js"
          "file:///*.user.css"
        ];
        platforms = platforms.all;
      };
    };
    "firenvim" = buildFirefoxXpiAddon {
      pname = "firenvim";
      version = "0.2.16";
      addonId = "firenvim@lacamb.re";
      url = "https://addons.mozilla.org/firefox/downloads/file/4279173/firenvim-0.2.16.xpi";
      sha256 = "080b45e4863c5905431d5712ee563737387b32e787e8c2054270e3d672f08848";
      meta = with lib;
      {
        description = "Turn Firefox into a Neovim client.";
        license = licenses.gpl3;
        mozPermissions = [ "nativeMessaging" "storage" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "flagfox" = buildFirefoxXpiAddon {
      pname = "flagfox";
      version = "6.1.91";
      addonId = "{1018e4d6-728f-4b20-ad56-37578a4de76b}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4588494/flagfox-6.1.91.xpi";
      sha256 = "477abdf4c57a85f58a47b66574c4696124a3a4f505d7a650439b3079f0021d3d";
      meta = with lib;
      {
        homepage = "https://flagfox.wordpress.com/";
        description = "Displays a country flag depicting the location of the current website's server and provides a multitude of tools such as site safety checks, whois, translation, similar sites, validation, URL shortening, and more...";
        license = {
          shortName = "flagfox";
          fullName = "Flagfox License";
          url = "https://addons.mozilla.org/en-US/firefox/addon/flagfox/license/";
          free = false;
        };
        mozPermissions = [
          "storage"
          "clipboardRead"
          "clipboardWrite"
          "menus"
          "contextMenus"
          "notifications"
          "tabs"
          "webRequest"
          "dns"
          "cookies"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "floccus" = buildFirefoxXpiAddon {
      pname = "floccus";
      version = "5.7.0";
      addonId = "floccus@handmadeideas.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4565831/floccus-5.7.0.xpi";
      sha256 = "fc76e53b54eb9c60f3ddc9306d6be201af21b6375dd85e457ab38a5003a45f7b";
      meta = with lib;
      {
        homepage = "https://floccus.org";
        description = "Securely synchronize bookmarks across Chrome, Firefox, Edge, and more using your own cloud storage.";
        license = licenses.mpl20;
        mozPermissions = [
          "*://*/*"
          "alarms"
          "bookmarks"
          "storage"
          "unlimitedStorage"
          "tabs"
          "tabGroups"
          "identity"
        ];
        platforms = platforms.all;
      };
    };
    "forget_me_not" = buildFirefoxXpiAddon {
      pname = "forget_me_not";
      version = "2.2.8";
      addonId = "forget-me-not@lusito.info";
      url = "https://addons.mozilla.org/firefox/downloads/file/3577046/forget_me_not-2.2.8.xpi";
      sha256 = "0784456f4f992c143b7897ea7879ce6324d9cce295c29a848e7ed55d9c762be3";
      meta = with lib;
      {
        homepage = "https://github.com/Lusito/forget-me-not/";
        description = "Make the browser forget website data (like cookies, local storage, etc.), except for the data you want to keep by adding domains to a whitelist, graylist, blacklist, or redlist.";
        license = licenses.zlib;
        mozPermissions = [
          "storage"
          "tabs"
          "browsingData"
          "cookies"
          "downloads"
          "history"
          "notifications"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "contextualIdentities"
          "<all_urls>"
          "https://lusito.github.io/web-ext-translator/*"
        ];
        platforms = platforms.all;
      };
    };
    "form-history-control" = buildFirefoxXpiAddon {
      pname = "form-history-control";
      version = "2.5.11.0";
      addonId = "formhistory@yahoo.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4480664/form_history_control-2.5.11.0.xpi";
      sha256 = "50699d6d9d637f4a5048247b204c12dae85a444b82ba302c0d4d24e561920b91";
      meta = with lib;
      {
        homepage = "https://stephanmahieu.github.io/fhc-home/";
        description = "Manage form history entries (search, edit, cleanup, export/import) and easy text formfiller.\n\nAuto-save text entered in any form while typing to allow fast recovery when disaster strikes.";
        license = licenses.mit;
        mozPermissions = [
          "menus"
          "activeTab"
          "tabs"
          "storage"
          "alarms"
          "clipboardWrite"
          "*://*/*"
          "file:///*"
        ];
        platforms = platforms.all;
      };
    };
    "foxy-gestures" = buildFirefoxXpiAddon {
      pname = "foxy-gestures";
      version = "1.2.12";
      addonId = "{e839c3f9-298e-4cd0-99e0-464431cb7c34}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3855097/foxy_gestures-1.2.12.xpi";
      sha256 = "f6bd22ab66c779425dbda853a91cd12014dc245f253b7fc822f5c8366f1203ea";
      meta = with lib;
      {
        homepage = "https://github.com/marklieberman/foxygestures";
        description = "Mouse gestures for Firefox. A web extension alternative to FireGestures created by a long time FireGestures user.";
        license = licenses.gpl3;
        mozPermissions = [
          "browserSettings"
          "cookies"
          "contextualIdentities"
          "sessions"
          "storage"
          "tabs"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "foxyproxy-standard" = buildFirefoxXpiAddon {
      pname = "foxyproxy-standard";
      version = "9.2";
      addonId = "foxyproxy@eric.h.jung";
      url = "https://addons.mozilla.org/firefox/downloads/file/4472757/foxyproxy_standard-9.2.xpi";
      sha256 = "8db1c64799a60f7121d51a6e9f6b041871598344927c95afe830c27880f0885d";
      meta = with lib;
      {
        homepage = "https://getfoxyproxy.org";
        description = "FoxyProxy is an open-source, advanced proxy management tool that completely replaces Firefox's limited proxying capabilities. No paid accounts are necessary; bring your own proxies or buy from any vendor. The original proxy tool, since 2006.";
        license = licenses.gpl2;
        mozPermissions = [
          "contextMenus"
          "downloads"
          "notifications"
          "proxy"
          "storage"
          "tabs"
          "webRequest"
          "webRequestAuthProvider"
        ];
        platforms = platforms.all;
      };
    };
    "foxytab" = buildFirefoxXpiAddon {
      pname = "foxytab";
      version = "2.31";
      addonId = "foxytab@eros.man";
      url = "https://addons.mozilla.org/firefox/downloads/file/4066782/foxytab-2.31.xpi";
      sha256 = "5d8e5499bf4ccb6571d00a9ea885445fcb532c5dd090d5c57621d69098a4c77a";
      meta = with lib;
      {
        homepage = "https://github.com/erosman/support";
        description = "Collection of Tab Related Actions e.g. Duplicate, Close Duplicates, Close to the Left, Copy Title, Merge Windows, Save as PDF, Copy Urls Tab/All/Left/Right, Host keep/close/close other, Sort by URL/Title, Asce/Desc, Move, Reload, Reload Timer";
        license = licenses.mpl20;
        mozPermissions = [
          "bookmarks"
          "clipboardWrite"
          "contextualIdentities"
          "cookies"
          "downloads"
          "menus"
          "notifications"
          "storage"
          "tabs"
          "tabHide"
          "theme"
          "unlimitedStorage"
          "webRequest"
          "webRequestBlocking"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "fraidycat" = buildFirefoxXpiAddon {
      pname = "fraidycat";
      version = "1.1.10";
      addonId = "{94060031-effe-4b93-89b4-9cd570217a8d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3783967/fraidycat-1.1.10.xpi";
      sha256 = "2bf975fef065290e19d5e70722021fc65e8499bececbdd56c616462d5bf834f1";
      meta = with lib;
      {
        homepage = "https://fraidyc.at/";
        description = "Follow from afar. Follow blogs, wikis, Twitter, Instagram, Tumblr - anyone on nearly any blog-like network - from your browser. No notifications, no unread messages, no 'inbox'. Just a single page overview of all your follows.";
        license = licenses.mit;
        mozPermissions = [
          "http://*/"
          "https://*/"
          "https://m.facebook.com/*"
          "https://*.fbcdn.net/*"
          "https://www.instagram.com/*"
          "https://www.reddit.com/*"
          "https://pbs.twimg.com/*"
          "https://twitter.com/*"
          "storage"
          "tabs"
          "unlimitedStorage"
          "webRequest"
          "webRequestBlocking"
          "https://fraidyc.at/s/*"
          "*://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "frame-extension" = buildFirefoxXpiAddon {
      pname = "frame-extension";
      version = "0.12.1";
      addonId = "{77691beb-4c53-48de-ab20-6589a537717a}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4340672/frame_extension-0.12.1.xpi";
      sha256 = "8cf0529ccd4add0a412cc3b0b5fd22f1d5a0cbc871642254a31458ed93c2488b";
      meta = with lib;
      {
        homepage = "https://github.com/floating/frame";
        description = "This extension connects web apps to Frame. Frame is an Ethereum wallet that runs as a native desktop application. It manages all of your accounts, tokens and items and allows to seamlessly and securely connect them any app.";
        license = licenses.gpl3;
        mozPermissions = [
          "activeTab"
          "alarms"
          "idle"
          "scripting"
          "file://*/*"
          "http://*/*"
          "https://*/*"
          "http://twitter.com/*"
          "https://twitter.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "frankerfacez" = buildFirefoxXpiAddon {
      pname = "frankerfacez";
      version = "4.79.1.0";
      addonId = "frankerfacez@frankerfacez.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4599743/frankerfacez-4.79.1.0.xpi";
      sha256 = "6787c1093ce4d840cb2ba5fed670a10d5385274775fb8cf0f46d6232aae8ae8e";
      meta = with lib;
      {
        homepage = "https://www.frankerfacez.com";
        description = "The Twitch Enhancement Suite - Get custom emotes and tons of new features you'll never want to go without.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [ "storage" "unlimitedStorage" "*://*.twitch.tv/*" ];
        platforms = platforms.all;
      };
    };
    "freedom-website-blocker" = buildFirefoxXpiAddon {
      pname = "freedom-website-blocker";
      version = "17.0.12";
      addonId = "{37cf1a46-0300-4893-a483-248807035bbf}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3765143/freedom_website_blocker-17.0.12.xpi";
      sha256 = "658e6b08d76e57fff7093ab50b692eacafd73e3c93d86e950b6aca6f8db8c76f";
      meta = with lib;
      {
        homepage = "https://freedom.to/";
        description = "The Freedom website blocker gives you control over distracting websites, so you can focus on what matters most.";
        license = {
          shortName = "freedom.to";
          fullName = "freedom.to Terms of Service";
          url = "https://freedom.to/terms";
          free = false;
        };
        mozPermissions = [
          "webRequest"
          "webRequestBlocking"
          "*://*/*"
          "storage"
          "notifications"
        ];
        platforms = platforms.all;
      };
    };
    "french-dictionary" = buildFirefoxXpiAddon {
      pname = "french-dictionary";
      version = "7.0b";
      addonId = "fr-dicollecte@dictionaries.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3581786/dictionnaire_francais1-7.0b.xpi";
      sha256 = "e0e90b88b177dc1b268b019c8672eb1be943f12e174ad474dbdc46f0e6fbaa6f";
      meta = with lib;
      {
        homepage = "https://grammalecte.net";
        description = "Spelling dictionary for the French language.";
        license = licenses.mpl20;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "french-language-pack" = buildFirefoxXpiAddon {
      pname = "french-language-pack";
      version = "145.0.20251103.141854";
      addonId = "langpack-fr@firefox.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4611768/francais_language_pack-145.0.20251103.141854.xpi";
      sha256 = "dd0aa148e1c583ef5c05d13efef95dd4c14f4249e88d890fd75582a2fbc290eb";
      meta = with lib;
      {
        description = "Firefox Language Pack for Français (fr) – French";
        license = licenses.mpl20;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "furiganaize" = buildFirefoxXpiAddon {
      pname = "furiganaize";
      version = "0.7.2";
      addonId = "{a2503cd4-4083-4c2f-bef2-37767a569867}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4032306/furiganaize-0.7.2.xpi";
      sha256 = "7545bc418f2afbc576b0e762f2b2fa0545d5d94f3f80737e5356d087a5951c0b";
      meta = with lib;
      {
        homepage = "https://github.com/kuanyui/Furiganaize";
        description = "Auto insert furigana (振り仮名) on Japanese kanji.";
        license = licenses.mit;
        mozPermissions = [
          "http://*/*"
          "https://*/*"
          "file://*/*"
          "<all_urls>"
          "activeTab"
          "tabs"
          "storage"
        ];
        platforms = platforms.all;
      };
    };
    "gaidhlig-language-pack" = buildFirefoxXpiAddon {
      pname = "gaidhlig-language-pack";
      version = "145.0.20251103.141854";
      addonId = "langpack-gd@firefox.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4611807/gaidhlig_language_pack-145.0.20251103.141854.xpi";
      sha256 = "7cbb36abe33c70be03a5a1f3aba981eedd7f53b7ef801680e6ac9f7835c57df2";
      meta = with lib;
      {
        description = "Firefox Language Pack for Gàidhlig (gd) – Scottish Gaelic";
        license = licenses.mpl20;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "gemini-in-sidebar" = buildFirefoxXpiAddon {
      pname = "gemini-in-sidebar";
      version = "1.0.0";
      addonId = "{6668aea4-9581-44e0-8477-5f037252ccb5}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4279824/gemini_in_sidebar-1.0.0.xpi";
      sha256 = "a6e6bbf99fd9eb1dd3afd157652c029e6eb5e2952d956f445a5d3d903e724d67";
      meta = with lib;
      {
        homepage = "https://gemini.google.com/";
        description = "Displays Gemini in the sidebar, provides customizable keyboard shortcut and toggle button.";
        license = licenses.mit;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "geminize" = buildFirefoxXpiAddon {
      pname = "geminize";
      version = "1.0.4";
      addonId = "{c72d8561-58ba-4250-b5b2-13cfea0b6c4e}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3708150/geminize-1.0.4.xpi";
      sha256 = "2a65389bde2db1333a8341b147a9919daf1356876771195d7c20f61e75ebc139";
      meta = with lib;
      {
        homepage = "https://gitlab.com/nocylah/geminize";
        description = "Explore Project Gemini sites from Firefox!";
        license = licenses.mit;
        mozPermissions = [ "activeTab" "storage" "webNavigation" ];
        platforms = platforms.all;
      };
    };
    "gesturefy" = buildFirefoxXpiAddon {
      pname = "gesturefy";
      version = "3.2.16";
      addonId = "{506e023c-7f2b-40a3-8066-bc5deb40aebe}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4602457/gesturefy-3.2.16.xpi";
      sha256 = "eb320794c28c6926185e49b7419005ab1fe78b17aa10b79e6ac0a0f6296f6c40";
      meta = with lib;
      {
        homepage = "https://github.com/Robbendebiene/Gesturefy";
        description = "Navigate, operate, and browse faster with mouse gestures! A customizable mouse gesture add-on with a variety of different commands.";
        license = licenses.gpl3;
        mozPermissions = [
          "<all_urls>"
          "storage"
          "notifications"
          "browserSettings"
        ];
        platforms = platforms.all;
      };
    };
    "ghostery" = buildFirefoxXpiAddon {
      pname = "ghostery";
      version = "10.5.16";
      addonId = "firefox@ghostery.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4606960/ghostery-10.5.16.xpi";
      sha256 = "ad2dbd7d9985f8e707f6ca52706ce9f9b4d00d8b85aef693a187363398b737df";
      meta = with lib;
      {
        homepage = "http://www.ghostery.com/";
        description = "The best privacy tool and ad blocker extension for Firefox. Stop trackers, speed up websites and block ads everywhere including YouTube and Facebook.";
        license = licenses.mpl20;
        mozPermissions = [
          "alarms"
          "cookies"
          "storage"
          "scripting"
          "tabs"
          "activeTab"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "unlimitedStorage"
          "http://*/*"
          "https://*/*"
          "ws://*/*"
          "wss://*/*"
          "*://www.youtube.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "ghosttext" = buildFirefoxXpiAddon {
      pname = "ghosttext";
      version = "24.8.10";
      addonId = "ghosttext@bfred.it";
      url = "https://addons.mozilla.org/firefox/downloads/file/4334686/ghosttext-24.8.10.xpi";
      sha256 = "86bfd2d31bf60c88e4ae72dbc1636977e88ce5603d01cf87b981db5b5bb98e21";
      meta = with lib;
      {
        homepage = "https://github.com/fregante/GhostText";
        description = "Use your text editor to write in your browser. Everything you type in the editor will be instantly updated in the browser (and vice versa).";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "contextMenus"
          "scripting"
          "storage"
          "http://localhost:4001/*"
        ];
        platforms = platforms.all;
      };
    };
    "gitako-github-file-tree" = buildFirefoxXpiAddon {
      pname = "gitako-github-file-tree";
      version = "3.12.1";
      addonId = "{983bd86b-9d6f-4394-92b8-63d844c4ce4c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4315380/gitako_github_file_tree-3.12.1.xpi";
      sha256 = "68bb06929b08d9c3aff55fdff411b4dc2f57e1752af358b018ab5003fbfeef69";
      meta = with lib;
      {
        homepage = "https://github.com/EnixCoda/Gitako";
        description = "Gitako is a file tree extension for GitHub, available on Firefox, Chrome, and Edge.\n\nVideo intro: https://youtu.be/r4Ein-s2pN0\nHomepage: https://github.com/EnixCoda/Gitako";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "contextMenus"
          "activeTab"
          "*://*.github.com/*"
          "*://gitako.enix.one/*"
          "*://*.sentry.io/*"
          "https://github.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "github-file-icons" = buildFirefoxXpiAddon {
      pname = "github-file-icons";
      version = "1.5.2";
      addonId = "{85860b32-02a8-431a-b2b1-40fbd64c9c69}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4238111/github_file_icons-1.5.2.xpi";
      sha256 = "b7ad067981605e5396439bcc356a759c7cc7872a65ef6ad5eb4b6243239920b3";
      meta = with lib;
      {
        homepage = "https://github.com/xxhomey19/github-file-icon";
        description = "A Firefox Add-On which gives different filetypes different icons to GitHub, Gitlab, Bitbucket, gitea and gogs.";
        license = licenses.mit;
        mozPermissions = [
          "contextMenus"
          "storage"
          "activeTab"
          "https://github.com/*"
          "https://gitlab.com/*"
          "https://*.gogs.io/*"
          "https://*.gitea.io/*"
        ];
        platforms = platforms.all;
      };
    };
    "github-isometric-contributions" = buildFirefoxXpiAddon {
      pname = "github-isometric-contributions";
      version = "1.1.31";
      addonId = "isometric-contributions@jasonlong.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/4326182/github_isometric_contributions-1.1.31.xpi";
      sha256 = "bb55818eb558344debfbd0c19ae7ae287ba4d6fa3d119904fe088220c3661be8";
      meta = with lib;
      {
        description = "Renders an isometric pixel view of GitHub contribution graphs.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "contextMenus"
          "activeTab"
          "https://github.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "github-issue-link-status" = buildFirefoxXpiAddon {
      pname = "github-issue-link-status";
      version = "25.3.18";
      addonId = "issue-link-status@bfred.it";
      url = "https://addons.mozilla.org/firefox/downloads/file/4456710/github_issue_link_status-25.3.18.xpi";
      sha256 = "a42c55ef8b7a0f548a9d0c9a1c998289ff2f5f6220a07bc3e5378d9988df3345";
      meta = with lib;
      {
        homepage = "https://github.com/fregante/github-issue-link-status";
        description = "Colorize issue and PR links to see their status (open, closed, merged)";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "contextMenus"
          "activeTab"
          "https://github.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "gloc" = buildFirefoxXpiAddon {
      pname = "gloc";
      version = "10.0.15";
      addonId = "{bc2166c4-e7a2-46d5-ad9e-342cef57f1f7}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4508999/gloc-10.0.15.xpi";
      sha256 = "3671b1cb99d37f50e644c87c7cae6262b7c64d251123fd382558bf0cdc771149";
      meta = with lib;
      {
        homepage = "https://github.com/kas-elvirov/gloc";
        description = "Github Gloc - counts locs on GitHub pages";
        license = licenses.gpl2;
        mozPermissions = [ "storage" "*://github.com/*" ];
        platforms = platforms.all;
      };
    };
    "gnome-shell-integration" = buildFirefoxXpiAddon {
      pname = "gnome-shell-integration";
      version = "12.1";
      addonId = "chrome-gnome-shell@gnome.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4591252/gnome_shell_integration-12.1.xpi";
      sha256 = "815bfc08a2a78ca7a7a7d59c5404a2066bbac6173113c19f1eae3a6b7a839db5";
      meta = with lib;
      {
        homepage = "https://gnome.pages.gitlab.gnome.org/gnome-browser-integration/pages/gnome-browser-integration.html";
        description = "This extension provides integration with GNOME Shell and the corresponding extensions repository https://extensions.gnome.org";
        license = licenses.gpl3;
        mozPermissions = [
          "nativeMessaging"
          "notifications"
          "storage"
          "tabs"
          "https://extensions.gnome.org/*"
          "https://extensions-next.gnome.org/*"
        ];
        platforms = platforms.all;
      };
    };
    "gnu_terry_pratchett" = buildFirefoxXpiAddon {
      pname = "gnu_terry_pratchett";
      version = "0.5resigned1";
      addonId = "jid1-HGPgB0x6133Hig@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4270754/gnu_terry_pratchett-0.5resigned1.xpi";
      sha256 = "0a3a5cfd4d958bfb69e784b50b5bf03a82ebb0f5649e28d5140c50791cc349e8";
      meta = with lib;
      {
        description = "Display the X-Clacks-Overhead in Clacks Semaphore";
        license = licenses.gpl2;
        mozPermissions = [ "webRequest" "tabs" "alarms" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "google-cal-event-merge" = buildFirefoxXpiAddon {
      pname = "google-cal-event-merge";
      version = "2.2.1";
      addonId = "{8b4a69b6-0502-45e6-ba61-92c041c46ac3}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3286178/google_cal_event_merge-2.2.1.xpi";
      sha256 = "ab8096ae6e5e822dcabacf74bf9e566e49cc9baf94b37b33e574dfec8086ecd8";
      meta = with lib;
      {
        description = "Chrome extension that visually merges the same event on multiple Google Calendars into one event.\n\nSource: https://github.com/imightbeamy/gcal-multical-event-merge";
        license = licenses.gpl3;
        mozPermissions = [
          "https://www.google.com/calendar/*"
          "https://calendar.google.com/*"
          "storage"
          "https://calendar.google.com/calendar/*"
        ];
        platforms = platforms.all;
      };
    };
    "google-container" = buildFirefoxXpiAddon {
      pname = "google-container";
      version = "1.5.4";
      addonId = "@contain-google";
      url = "https://addons.mozilla.org/firefox/downloads/file/3736912/google_container-1.5.4.xpi";
      sha256 = "47a7c0e85468332a0d949928d8b74376192cde4abaa14280002b3aca4ec814d0";
      meta = with lib;
      {
        homepage = "https://github.com/containers-everywhere/contain-google";
        description = "THIS IS NOT AN OFFICIAL ADDON FROM MOZILLA!\nIt is a fork of the Facebook Container addon.\n\nPrevent Google from tracking you around the web. The Google Container extension helps you take control and isolate your web activity from Google.";
        license = licenses.mpl20;
        mozPermissions = [
          "<all_urls>"
          "contextualIdentities"
          "cookies"
          "management"
          "tabs"
          "webRequestBlocking"
          "webRequest"
          "storage"
        ];
        platforms = platforms.all;
      };
    };
    "gopass-bridge" = buildFirefoxXpiAddon {
      pname = "gopass-bridge";
      version = "2.1.0";
      addonId = "{eec37db0-22ad-4bf1-9068-5ae08df8c7e9}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4389774/gopass_bridge-2.1.0.xpi";
      sha256 = "ae2fe0296eea9ef73695bb57c52d9ba930c18d89d58d65c8014104cb8b0e74a1";
      meta = with lib;
      {
        homepage = "https://github.com/gopasspw/gopassbridge";
        description = "Gopass Bridge allows searching, inserting and managing login credentials from the gopass password manager.";
        license = licenses.mit;
        mozPermissions = [
          "<all_urls>"
          "activeTab"
          "clipboardWrite"
          "storage"
          "nativeMessaging"
          "notifications"
          "webRequest"
          "webRequestBlocking"
          "http://*/*"
          "https://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "grammarly" = buildFirefoxXpiAddon {
      pname = "grammarly";
      version = "8.934.0";
      addonId = "87677a2c52b84ad3a151a4a72f5bd3c4@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4585019/grammarly_1-8.934.0.xpi";
      sha256 = "1e11cd65a222e3b29588259b41ae07fd5e1e7e8cf04bd2bdd1aa09424a326f43";
      meta = with lib;
      {
        homepage = "http://grammarly.com";
        description = "From blank page to polished draft, Grammarly’s AI helps you write faster and stronger. Get real-time grammar fixes, tone transformations, and instant content generation right where you write in Firefox.";
        license = {
          shortName = "grammarly";
          fullName = "Grammarly Terms of Service and License Agreement";
          url = "https://www.grammarly.com/terms";
          free = false;
        };
        mozPermissions = [
          "http://*/*"
          "https://*/*"
          "tabs"
          "notifications"
          "cookies"
          "identity"
          "storage"
          "<all_urls>"
          "*://*.atlassian.net/*"
          "*://mail.google.com/*"
          "*://*.mail.google.com/*"
          "*://quora.com/*"
          "*://*.quora.com/*"
          "*://*.slack.com/*"
          "*://*.blackboard.com/*"
          "*://*.blogger.com/*"
          "*://publish.buffer.com/*"
          "*://*.publish.buffer.com/*"
          "*://facebook.com/*"
          "*://*.facebook.com/*"
          "*://calendar.google.com/*"
          "*://*.calendar.google.com/*"
          "*://keep.google.com/*"
          "*://*.keep.google.com/*"
          "*://intercom.io/*"
          "*://*.intercom.io/*"
          "*://linkedin.com/*"
          "*://*.linkedin.com/*"
          "*://medium.com/*"
          "*://*.medium.com/*"
          "*://messenger.com/*"
          "*://*.messenger.com/*"
          "*://teams.microsoft.com/*"
          "*://*.teams.microsoft.com/*"
          "*://translate.google.com/*"
          "*://*.translate.google.com/*"
          "*://reddit.com/*"
          "*://*.reddit.com/*"
          "*://youtube.com/*"
          "*://*.youtube.com/*"
          "*://twitter.com/*"
          "*://*.twitter.com/*"
          "*://x.com/*"
          "*://*.x.com/*"
          "*://*.lightning.force.com/*"
          "*://trello.com/*"
          "*://*.trello.com/*"
          "*://upwork.com/*"
          "*://*.upwork.com/*"
          "*://web.whatsapp.com/*"
          "*://*.web.whatsapp.com/*"
          "*://wix.com/*"
          "*://*.wix.com/*"
          "*://wordpress.com/*"
          "*://*.wordpress.com/*"
          "*://*.zendesk.com/*"
          "*://wattpad.com/*"
          "*://*.wattpad.com/*"
          "*://onlinechatdashboard.com/*"
          "*://*.onlinechatdashboard.com/*"
          "*://wordcounter.net/*"
          "*://*.wordcounter.net/*"
          "*://fiverr.com/*"
          "*://*.fiverr.com/*"
          "*://educationperfect.com/*"
          "*://*.educationperfect.com/*"
          "*://apclassroom.collegeboard.org/*"
          "*://*.apclassroom.collegeboard.org/*"
          "*://studio.youtube.com/*"
          "*://*.studio.youtube.com/*"
          "*://chat.google.com/*"
          "*://*.chat.google.com/*"
          "*://twitch.tv/*"
          "*://*.twitch.tv/*"
          "*://papago.naver.com/*"
          "*://*.papago.naver.com/*"
          "*://readworks.org/*"
          "*://*.readworks.org/*"
          "*://app.nearpod.com/*"
          "*://*.app.nearpod.com/*"
          "*://mail.aol.com/*"
          "*://*.mail.aol.com/*"
          "*://github.com/*"
          "*://*.github.com/*"
          "*://coursera.org/*"
          "*://*.coursera.org/*"
          "*://commonlit.org/*"
          "*://*.commonlit.org/*"
          "*://classroom.google.com/*"
          "*://*.classroom.google.com/*"
          "*://app.seesaw.me/*"
          "*://*.app.seesaw.me/*"
          "*://forms.office.com/*"
          "*://*.forms.office.com/*"
          "*://outlook.live.com/*"
          "*://*.outlook.live.com/*"
          "*://outlook.office.com/*"
          "*://*.outlook.office.com/*"
          "*://docs.google.com/document/*"
          "*://docs.google.com/*"
          "https://*.overleaf.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "granted" = buildFirefoxXpiAddon {
      pname = "granted";
      version = "1.1.2";
      addonId = "{b5e0e8de-ebfe-4306-9528-bcc18241a490}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4086622/granted-1.1.2.xpi";
      sha256 = "f24bcab717460ec99cc0e70efa079fa8a6cf5f5af6c3e6b9532578714fb8f7bc";
      meta = with lib;
      {
        description = "View multiple cloud accounts and regions in a single browser.";
        license = licenses.mit;
        mozPermissions = [ "contextualIdentities" "cookies" "tabs" "storage" ];
        platforms = platforms.all;
      };
    };
    "greasemonkey" = buildFirefoxXpiAddon {
      pname = "greasemonkey";
      version = "4.13";
      addonId = "{e4a8a97b-f2ed-450b-b12d-ee082ba24781}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4332091/greasemonkey-4.13.xpi";
      sha256 = "31b9e9521eac579114ed20616851f4f984229fbe6d8ebd4dc4799eb48c59578c";
      meta = with lib;
      {
        homepage = "http://www.greasespot.net/";
        description = "Customize the way a web page displays or behaves, by using small bits of JavaScript.";
        license = licenses.mit;
        mozPermissions = [
          "<all_urls>"
          "clipboardWrite"
          "cookies"
          "downloads"
          "notifications"
          "storage"
          "tabs"
          "unlimitedStorage"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
        ];
        platforms = platforms.all;
      };
    };
    "gruvbox-dark-theme" = buildFirefoxXpiAddon {
      pname = "gruvbox-dark-theme";
      version = "1.1";
      addonId = "{eb8c4a94-e603-49ef-8e81-73d3c4cc04ff}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3595905/gruvbox_dark_theme-1.1.xpi";
      sha256 = "de417b35a4747f5c51b2b73dd8db9d484953fcd8909f0c7d936ca7fc6f8ca4e2";
      meta = with lib;
      {
        homepage = "https://codeberg.org/calvinchd/GruvboxDarkFirefoxTheme";
        description = "Gruvbox dark theme for Firefox. Using https://github.com/morhetz/gruvbox color palette";
        license = licenses.cc-by-30;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "gsconnect" = buildFirefoxXpiAddon {
      pname = "gsconnect";
      version = "8";
      addonId = "gsconnect@andyholmes.github.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/3626312/gsconnect-8.xpi";
      sha256 = "68b2fe0a9e064ccf869af5a9021f4d90661b8b05ca330c39d852a6cc1aa92274";
      meta = with lib;
      {
        homepage = "https://github.com/andyholmes/gnome-shell-extension-gsconnect";
        description = "Share links with GSConnect, direct to the browser or by SMS. Requires at least v7 of the Gnome Shell extension to function.";
        license = licenses.gpl2;
        mozPermissions = [ "nativeMessaging" "tabs" "contextMenus" ];
        platforms = platforms.all;
      };
    };
    "h264ify" = buildFirefoxXpiAddon {
      pname = "h264ify";
      version = "1.1.0";
      addonId = "jid1-TSgSxBhncsPBWQ@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3398929/h264ify-1.1.0.xpi";
      sha256 = "87bd3c4ab1a2359c01a1d854d7db8428b44316fef5b2ac09e228c5318c57a515";
      meta = with lib;
      {
        description = "Makes YouTube stream H.264 videos instead of VP8/VP9 videos";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "*://*.youtube.com/*"
          "*://*.youtube-nocookie.com/*"
          "*://*.youtu.be/*"
        ];
        platforms = platforms.all;
      };
    };
    "hackontext" = buildFirefoxXpiAddon {
      pname = "hackontext";
      version = "1.4";
      addonId = "hackontext@d3vil0p3r";
      url = "https://addons.mozilla.org/firefox/downloads/file/4488137/hackontext-1.4.xpi";
      sha256 = "c80926181e09adf7243289290c372b5aef5b4fb224bd8b7e812940137d6b5a88";
      meta = with lib;
      {
        homepage = "https://github.com/D3vil0per/hackontext";
        description = "Copy parameters to your favourite infosec tool.";
        license = licenses.gpl3;
        mozPermissions = [
          "contextMenus"
          "activeTab"
          "cookies"
          "webRequest"
          "tabs"
          "clipboardWrite"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "hacktools" = buildFirefoxXpiAddon {
      pname = "hacktools";
      version = "0.4.0";
      addonId = "{f1423c11-a4e2-4709-a0f8-6d6a68c83d08}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3901885/hacktools-0.4.0.xpi";
      sha256 = "96cfad19c851e4c3788ebe34eca7a268414c3cf642137133f30a6c3fcbccefe3";
      meta = with lib;
      {
        homepage = "https://github.com/LasCC/Hack-Tools";
        description = "Hacktools, is a web extension facilitating your web application penetration tests, it includes cheat sheets as well as all the tools used during a test such as XSS payloads, Reverse shells to test your web application.";
        license = licenses.lgpl3;
        mozPermissions = [ "devtools" ];
        platforms = platforms.all;
      };
    };
    "hcfy" = buildFirefoxXpiAddon {
      pname = "hcfy";
      version = "10.14.1";
      addonId = "{0982b844-4f35-48b7-9811-6832d916f21c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4334571/hcfy-10.14.1.xpi";
      sha256 = "3ac441b21c1d5423ea96a7cafd1cbc74bc895990e5d7dfd58167cb43c88fb255";
      meta = with lib;
      {
        homepage = "https://hcfy.ai";
        description = "一站式划词 / 截图 / 网页全文 / 音视频 AI 翻译扩展，支持谷歌、DeepL、ChatGPT、百度等 9 个国内外主流翻译服务，均可用于全文翻译。能在 PDF 里使用。支持辅助键、快捷键、悬浮取词。";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "<all_urls>"
          "contextMenus"
          "storage"
          "clipboardWrite"
          "clipboardRead"
          "webRequest"
          "webRequestBlocking"
          "alarms"
        ];
        platforms = platforms.all;
      };
    };
    "header-editor" = buildFirefoxXpiAddon {
      pname = "header-editor";
      version = "5.2.7";
      addonId = "headereditor-amo@addon.firefoxcn.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4589105/header_editor-5.2.7.xpi";
      sha256 = "7edc8aa17e79dc3271fa3ece87b9c4f1ad1cc2ac68574723d565c764048fbdc1";
      meta = with lib;
      {
        homepage = "https://he.firefoxcn.net/en/";
        description = "Manage browser's requests, include modify the request headers and response headers, redirect requests, cancel requests";
        license = licenses.gpl2;
        mozPermissions = [
          "tabs"
          "storage"
          "unlimitedStorage"
          "webRequest"
          "webRequestBlocking"
          "declarativeNetRequest"
          "*://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "history-cleaner" = buildFirefoxXpiAddon {
      pname = "history-cleaner";
      version = "1.7.0";
      addonId = "{a138007c-5ff6-4d10-83d9-0afaf0efbe5e}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4403189/history_cleaner-1.7.0.xpi";
      sha256 = "9ea2580067ebb99273e5a5b1a68e3e647b8e057d7246a58c6512599c07fcf14d";
      meta = with lib;
      {
        homepage = "https://github.com/Rayquaza01/HistoryCleaner";
        description = "Deletes browsing history older than a specified number of days.";
        license = licenses.mit;
        mozPermissions = [ "history" "storage" "idle" "alarms" ];
        platforms = platforms.all;
      };
    };
    "historyblock" = buildFirefoxXpiAddon {
      pname = "historyblock";
      version = "2.2";
      addonId = "historyblock@kain";
      url = "https://addons.mozilla.org/firefox/downloads/file/4579697/historyblock-2.2.xpi";
      sha256 = "66bb3778b63adc8e4695b69cb54c063dc8ae3ea7f24ed17c0b44955b1135a407";
      meta = with lib;
      {
        homepage = "https://github.com/kainsavage/HistoryBlock";
        description = "Cover your tracks!";
        license = licenses.mpl20;
        mozPermissions = [
          "sessions"
          "tabs"
          "history"
          "storage"
          "contextMenus"
        ];
        platforms = platforms.all;
      };
    };
    "hls-stream-detector" = buildFirefoxXpiAddon {
      pname = "hls-stream-detector";
      version = "2.11.7";
      addonId = "@m3u8link";
      url = "https://addons.mozilla.org/firefox/downloads/file/4136128/hls_stream_detector-2.11.7.xpi";
      sha256 = "6d7163dc6cd0eb82d951c551cffc2c796023117b071c20eee8e20c4e11155c49";
      meta = with lib;
      {
        description = "This addon provides an easy way to keep track of manifests and subtitles used by various streaming protocols. Also allows for detecting custom file types and downloading media files.";
        license = licenses.mpl20;
        mozPermissions = [
          "<all_urls>"
          "clipboardWrite"
          "downloads"
          "notifications"
          "storage"
          "tabs"
          "webRequest"
        ];
        platforms = platforms.all;
      };
    };
    "holodex-plus" = buildFirefoxXpiAddon {
      pname = "holodex-plus";
      version = "0.5";
      addonId = "{7ff078b3-b3e9-44df-a646-45c702b2e17c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4281538/holodex_plus-0.5.xpi";
      sha256 = "1cb2bdf9fed54dc92c9866f3a362152999c3cf182c871d003907bfcd70e27065";
      meta = with lib;
      {
        homepage = "https://holodex.net";
        description = "Holodex.net companion extension for enhancing the viewing experience";
        license = licenses.mit;
        mozPermissions = [
          "tabs"
          "storage"
          "webRequest"
          "webRequestBlocking"
          "contextMenus"
          "*://*.youtube.com/*"
          "*://*.holodex.net/*"
          "*://*.youtube.com/embed/*"
          "*://*.youtube.com/live_chat*"
        ];
        platforms = platforms.all;
      };
    };
    "hoppscotch" = buildFirefoxXpiAddon {
      pname = "hoppscotch";
      version = "0.37";
      addonId = "postwoman-firefox@postwoman.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/4395029/hoppscotch-0.37.xpi";
      sha256 = "41895cd06f65d47e3c61e71d5e9ba1312590f7c51aaa165fe63ec925fd6cc030";
      meta = with lib;
      {
        homepage = "https://github.com/hoppscotch/hoppscotch-extension";
        description = "Removes CORS restrictions for cross-origin requests, particularly those to localhost. It essentially allows Hoppscotch to make requests that might otherwise be blocked by the browser's security policies.";
        license = licenses.mit;
        mozPermissions = [ "storage" "tabs" "cookies" "scripting" ];
        platforms = platforms.all;
      };
    };
    "hover-zoom-plus" = buildFirefoxXpiAddon {
      pname = "hover-zoom-plus";
      version = "1.1.7";
      addonId = "{92e6fe1c-6e1d-44e1-8bc6-d309e59406af}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4581092/hover_zoom_plus-1.1.7.xpi";
      sha256 = "79ac3986a289f0b9d2bd9d7b116e4d4242e7c0d376298cdeb66dba012521934d";
      meta = with lib;
      {
        homepage = "https://github.com/extesy/hoverzoom/";
        description = "Zoom images/videos on all your favorite websites (Facebook, Amazon, etc). Simply hover your mouse over the image to enlarge it.";
        license = licenses.mit;
        mozPermissions = [
          "declarativeNetRequest"
          "scripting"
          "storage"
          "tabs"
          "unlimitedStorage"
          "<all_urls>"
          "*://*.facebook.com/*"
          "*://*.flickr.com/*"
          "*://*.flickr.net/*"
          "*://*.search.yahoo.com/*"
          "*://*.search.yahoo.co.jp/*"
          "*://*.deviantart.com/*"
          "*://*.google.ad/*"
          "*://*.google.ae/*"
          "*://*.google.am/*"
          "*://*.google.as/*"
          "*://*.google.at/*"
          "*://*.google.az/*"
          "*://*.google.ba/*"
          "*://*.google.be/*"
          "*://*.google.bg/*"
          "*://*.google.bi/*"
          "*://*.google.bj/*"
          "*://*.google.bs/*"
          "*://*.google.ca/*"
          "*://*.google.cat/*"
          "*://*.google.cd/*"
          "*://*.google.cf/*"
          "*://*.google.cg/*"
          "*://*.google.ch/*"
          "*://*.google.ci/*"
          "*://*.google.cl/*"
          "*://*.google.cn/*"
          "*://*.google.co.bw/*"
          "*://*.google.co.ck/*"
          "*://*.google.co.cr/*"
          "*://*.google.co.id/*"
          "*://*.google.co.il/*"
          "*://*.google.co.in/*"
          "*://*.google.co.jp/*"
          "*://*.google.co.ke/*"
          "*://*.google.co.kr/*"
          "*://*.google.co.ls/*"
          "*://*.google.co.ma/*"
          "*://*.google.co.mz/*"
          "*://*.google.co.nz/*"
          "*://*.google.co.th/*"
          "*://*.google.co.tz/*"
          "*://*.google.co.ug/*"
          "*://*.google.co.uk/*"
          "*://*.google.co.uz/*"
          "*://*.google.co.ve/*"
          "*://*.google.co.vi/*"
          "*://*.google.co.za/*"
          "*://*.google.co.zm/*"
          "*://*.google.co.zw/*"
          "*://*.google.com.af/*"
          "*://*.google.com.ag/*"
          "*://*.google.com.ai/*"
          "*://*.google.com.ar/*"
          "*://*.google.com.au/*"
          "*://*.google.com.bd/*"
          "*://*.google.com.bh/*"
          "*://*.google.com.bn/*"
          "*://*.google.com.bo/*"
          "*://*.google.com.br/*"
          "*://*.google.com.by/*"
          "*://*.google.com.bz/*"
          "*://*.google.com.co/*"
          "*://*.google.com.cu/*"
          "*://*.google.com.cy/*"
          "*://*.google.com.do/*"
          "*://*.google.com.ec/*"
          "*://*.google.com.eg/*"
          "*://*.google.com.et/*"
          "*://*.google.com.fj/*"
          "*://*.google.com.gh/*"
          "*://*.google.com.gi/*"
          "*://*.google.com.gt/*"
          "*://*.google.com.hk/*"
          "*://*.google.com.jm/*"
          "*://*.google.com.kh/*"
          "*://*.google.com.kw/*"
          "*://*.google.com.lb/*"
          "*://*.google.com.ly/*"
          "*://*.google.com.mt/*"
          "*://*.google.com.mx/*"
          "*://*.google.com.my/*"
          "*://*.google.com.na/*"
          "*://*.google.com.nf/*"
          "*://*.google.com.ng/*"
          "*://*.google.com.ni/*"
          "*://*.google.com.np/*"
          "*://*.google.com.om/*"
          "*://*.google.com.pa/*"
          "*://*.google.com.pe/*"
          "*://*.google.com.ph/*"
          "*://*.google.com.pk/*"
          "*://*.google.com.pr/*"
          "*://*.google.com.py/*"
          "*://*.google.com.qa/*"
          "*://*.google.com.sa/*"
          "*://*.google.com.sb/*"
          "*://*.google.com.sg/*"
          "*://*.google.com.sl/*"
          "*://*.google.com.sv/*"
          "*://*.google.com.tj/*"
          "*://*.google.com.tr/*"
          "*://*.google.com.tw/*"
          "*://*.google.com.ua/*"
          "*://*.google.com.uy/*"
          "*://*.google.com.vc/*"
          "*://*.google.com.vn/*"
          "*://*.google.com/*"
          "*://*.google.cz/*"
          "*://*.google.de/*"
          "*://*.google.dj/*"
          "*://*.google.dk/*"
          "*://*.google.dm/*"
          "*://*.google.dz/*"
          "*://*.google.ee/*"
          "*://*.google.es/*"
          "*://*.google.fi/*"
          "*://*.google.fm/*"
          "*://*.google.fr/*"
          "*://*.google.ga/*"
          "*://*.google.ge/*"
          "*://*.google.gg/*"
          "*://*.google.gl/*"
          "*://*.google.gm/*"
          "*://*.google.gp/*"
          "*://*.google.gr/*"
          "*://*.google.gy/*"
          "*://*.google.hn/*"
          "*://*.google.hr/*"
          "*://*.google.ht/*"
          "*://*.google.hu/*"
          "*://*.google.ie/*"
          "*://*.google.im/*"
          "*://*.google.is/*"
          "*://*.google.it.ao/*"
          "*://*.google.it/*"
          "*://*.google.je/*"
          "*://*.google.jo/*"
          "*://*.google.kg/*"
          "*://*.google.ki/*"
          "*://*.google.kz/*"
          "*://*.google.la/*"
          "*://*.google.li/*"
          "*://*.google.lk/*"
          "*://*.google.lt/*"
          "*://*.google.lu/*"
          "*://*.google.lv/*"
          "*://*.google.md/*"
          "*://*.google.me/*"
          "*://*.google.mg/*"
          "*://*.google.mk/*"
          "*://*.google.mn/*"
          "*://*.google.ms/*"
          "*://*.google.mu/*"
          "*://*.google.mv/*"
          "*://*.google.mw/*"
          "*://*.google.nl/*"
          "*://*.google.no/*"
          "*://*.google.nr/*"
          "*://*.google.nu/*"
          "*://*.google.pl/*"
          "*://*.google.pn/*"
          "*://*.google.ps/*"
          "*://*.google.pt/*"
          "*://*.google.ro/*"
          "*://*.google.rs/*"
          "*://*.google.ru/*"
          "*://*.google.rw/*"
          "*://*.google.sc/*"
          "*://*.google.se/*"
          "*://*.google.sh/*"
          "*://*.google.si/*"
          "*://*.google.sk/*"
          "*://*.google.sm/*"
          "*://*.google.sn/*"
          "*://*.google.st/*"
          "*://*.google.td/*"
          "*://*.google.tg/*"
          "*://*.google.tk/*"
          "*://*.google.tl/*"
          "*://*.google.tm/*"
          "*://*.google.to/*"
          "*://*.google.tt/*"
          "*://*.google.vg/*"
          "*://*.google.vu/*"
          "*://*.google.ws/*"
          "*://beryl-themes.org/*"
          "*://blenderstuff.org/*"
          "*://box-look.org/*"
          "*://cli-apps.org/*"
          "*://compiz-themes.org/*"
          "*://debian-art.org/*"
          "*://e17-stuff.org/*"
          "*://ede-look.org/*"
          "*://eyeos-apps.org/*"
          "*://gentoo-art.org/*"
          "*://gimpstuff.org/*"
          "*://gnome-look.org/*"
          "*://gtk-apps.org/*"
          "*://inkscapestuff.org/*"
          "*://java-apps.org/*"
          "*://kde-apps.org/*"
          "*://kde-files.org/*"
          "*://kde-look.org/*"
          "*://kubuntu-art.org/*"
          "*://linuxmint-art.org/*"
          "*://mandriva-art.org/*"
          "*://opendesktop.org/*"
          "*://qt-apps.org/*"
          "*://scribusstuff.org/*"
          "*://server-apps.org/*"
          "*://suse-art.org/*"
          "*://ubuntu-art.org/*"
          "*://wine-apps.org/*"
          "*://xfce-look.org/*"
          "*://*.gamekult.com/*"
          "*://*.imdb.com/*"
          "*://*.imdb.de/*"
          "*://*.imdb.it/*"
          "*://*.imdb.es/*"
          "*://*.imdb.fr/*"
          "*://*.imdb.pt/*"
          "*://manager.co.th/*"
          "*://*.myspace.com/*"
          "*://*.baidu.com/*"
          "*://*.amazon.com/*"
          "*://*.amazon.com.au/*"
          "*://*.amazon.com.br/*"
          "*://*.amazon.com.mx/*"
          "*://*.amazon.com.tr/*"
          "*://*.amazon.ae/*"
          "*://*.amazon.ca/*"
          "*://*.amazon.cn/*"
          "*://*.amazon.de/*"
          "*://*.amazon.eg/*"
          "*://*.amazon.es/*"
          "*://*.amazon.fr/*"
          "*://*.amazon.co.jp/*"
          "*://*.amazon.co.uk/*"
          "*://*.amazon.in/*"
          "*://*.amazon.it/*"
          "*://*.amazon.nl/*"
          "*://*.amazon.sg/*"
          "*://*.photos.live.com/*"
          "*://*.hi5.com/*"
          "*://*.play.com/*"
          "*://*.ebay.at/*"
          "*://*.ebay.be/*"
          "*://*.ebay.ch/*"
          "*://*.ebay.co.th/*"
          "*://*.ebay.co.uk/*"
          "*://*.ebay.com.au/*"
          "*://*.ebay.com.hk/*"
          "*://*.ebay.com.my/*"
          "*://*.ebay.com.sg/*"
          "*://*.ebay.com/*"
          "*://*.ebay.de/*"
          "*://*.ebay.es/*"
          "*://*.ebay.fr/*"
          "*://*.ebay.ie/*"
          "*://*.ebay.in/*"
          "*://*.ebay.it/*"
          "*://*.ebay.nl/*"
          "*://*.ebay.ph/*"
          "*://*.ebay.pl/*"
          "*://*.allocine.fr/*"
          "*://*.filmstarts.de/*"
          "*://*.sensacine.com/*"
          "*://*.flixster.com/*"
          "*://*.rottentomatoes.com/*"
          "*://*.gamespot.com/*"
          "*://*.x.com/*"
          "*://*.twitter.com/*"
          "*://*.tweetdeck.com/*"
          "*://gifbin.com/*"
          "*://*.ravelry.com/*"
          "*://*.jeuxvideo.com/*"
          "*://*.beautify.it/*"
          "*://*.cnet.com/*"
          "*://*.last.fm/*"
          "*://*.lastfm.com.br/*"
          "*://*.lastfm.com.tr/*"
          "*://*.lastfm.de/*"
          "*://*.lastfm.es/*"
          "*://*.lastfm.fr/*"
          "*://*.lastfm.it/*"
          "*://*.lastfm.jp/*"
          "*://*.lastfm.pl/*"
          "*://*.lastfm.ru/*"
          "*://*.lastfm.se/*"
          "*://*.musicme.com/*"
          "*://*.tinypic.com/*"
          "*://*.photobucket.com/*"
          "*://*.backpage.com/*"
          "*://*.wretch.cc/*"
          "*://*.events-gallery.ch/*"
          "*://*.knowyourmeme.com/*"
          "*://*.tshirthell.com/*"
          "*://*.threadless.com/*"
          "*://*.viedemerde.fr/*"
          "*://*.fmylife.com/*"
          "*://*.vitadimerda.it/*"
          "*://*.vayamierdadevida.com/*"
          "*://*.fanformittliv.com/*"
          "*://*.xing.com/*"
          "*://*.stern.de/*"
          "*://*.deadspin.com/*"
          "*://*.gawker.com/*"
          "*://*.gizmodo.com.au/*"
          "*://*.gizmodo.com/*"
          "*://*.gizmodo.de/*"
          "*://*.gizmodo.jp/*"
          "*://*.gizmodo.pl/*"
          "*://*.io9.com/*"
          "*://*.jalopnik.com/*"
          "*://*.jezebel.com/*"
          "*://*.kotaku.com/*"
          "*://*.lifehacker.com/*"
          "*://*.nintendolife.com/*"
          "*://*.skyrock.com/*"
          "*://*.leboncoin.fr/*"
          "*://*.linkedin.com/*"
          "*://*.phapit.com/*"
          "*://*.reddit.com/*"
          "*://*.fukung.net/*"
          "*://*.fanbox.cc/*"
          "*://*.pixiv.net/*"
          "*://*.pixivision.net/*"
          "*://*.vroid.com/*"
          "*://*.rakuten.co.jp/*"
          "*://*.rakuten.com/*"
          "*://copainsdavant.linternaute.com/*"
          "*://*.engadget.com/*"
          "*://*.joystiq.com/*"
          "*://*.switched.com/*"
          "*://*.tuaw.com/*"
          "*://*.badoo.com/*"
          "*://*.hotornot.com/*"
          "*://*.steamcommunity.com/*"
          "*://*.steampowered.com/*"
          "*://*.1x.com/*"
          "*://*.wired.com/*"
          "*://*.maxmodels.pl/*"
          "*://*.digart.pl/*"
          "*://*.favstar.fm/*"
          "*://*.tweetmeme.com/*"
          "*://*.cyworld.com/*"
          "*://*.cyworld.co.kr/*"
          "*://*.cyworld.co.cn/*"
          "*://*.fotolog.com/*"
          "*://*.panoramio.com/*"
          "*://*.oxd.in/*"
          "*://*.vk.com/*"
          "*://*.vkontakte.ru/*"
          "*://*.plurk.com/*"
          "*://*.bebo.com/*"
          "*://*.okcupid.com/*"
          "*://*.paheal.net/*"
          "*://*.feedly.com/*"
          "*://*.inkbunny.net/*"
          "*://*.instructables.com/*"
          "*://*.nofrag.com/*"
          "*://*.pict.mobi/*"
          "*://*.zing.vn/*"
          "*://*.bandpage.com/*"
          "*://*.rootmusic.com/fb/*"
          "*://*.liveshare.com/*"
          "*://*.weheartit.com/*"
          "*://*.funnyjunk.com/*"
          "*://*.02blog.it/*"
          "*://*.06blog.it/*"
          "*://*.artsblog.it/*"
          "*://*.autoblog.it/*"
          "*://*.bebeblog.it/*"
          "*://*.benessereblog.it/*"
          "*://*.betsblog.it/*"
          "*://*.booksblog.it/*"
          "*://*.calcioblog.it/*"
          "*://*.cineblog.it/*"
          "*://*.clickblog.it/*"
          "*://*.comicsblog.it/*"
          "*://*.crimeblog.it/*"
          "*://*.deluxeblog.it/*"
          "*://*.designerblog.it/*"
          "*://*.downloadblog.it/*"
          "*://*.ecoblog.it/*"
          "*://*.fashionblog.it/*"
          "*://*.finanzablog.it/*"
          "*://*.gadgetblog.it/*"
          "*://*.gamesblog.it/*"
          "*://*.gossipblog.it/*"
          "*://*.gustoblog.it/*"
          "*://*.happyblog.it/*"
          "*://*.melablog.it/*"
          "*://*.mobileblog.it/*"
          "*://*.motoblog.it/*"
          "*://*.motorsportblog.it/*"
          "*://*.ossblog.it/*"
          "*://*.outdoorblog.it/*"
          "*://*.pinkblog.it/*"
          "*://*.polisblog.it/*"
          "*://*.queerblog.it/*"
          "*://*.softblog.it/*"
          "*://*.soldiblog.it/*"
          "*://*.soundsblog.it/*"
          "*://*.toysblog.it/*"
          "*://*.travelblog.it/*"
          "*://*.tvblog.it/*"
          "*://*.yelp.ae/*"
          "*://*.yelp.at/*"
          "*://*.yelp.be/*"
          "*://*.yelp.ca/*"
          "*://*.yelp.ch/*"
          "*://*.yelp.cn/*"
          "*://*.yelp.co.cz/*"
          "*://*.yelp.co.jp/*"
          "*://*.yelp.co.nz/*"
          "*://*.yelp.co.uk/*"
          "*://*.yelp.com.au/*"
          "*://*.yelp.com.pl/*"
          "*://*.yelp.com/*"
          "*://*.yelp.de/*"
          "*://*.yelp.dk/*"
          "*://*.yelp.es/*"
          "*://*.yelp.fi/*"
          "*://*.yelp.fr/*"
          "*://*.yelp.ie/*"
          "*://*.yelp.in/*"
          "*://*.yelp.it/*"
          "*://*.yelp.nl/*"
          "*://*.yelp.no/*"
          "*://*.yelp.pt/*"
          "*://*.yelp.ru/*"
          "*://*.yelp.se/*"
          "*://*.hwzone.co.il/*"
          "*://*.spinchat.com/*"
          "*://*.spin.de/*"
          "*://*.etsy.com/*"
          "*://*.asos.com/*"
          "*://*.asos.fr/*"
          "*://*.asos.de/*"
          "*://*.pinterest.ca/*"
          "*://*.pinterest.ch/*"
          "*://*.pinterest.co.in/*"
          "*://*.pinterest.co.kr/*"
          "*://*.pinterest.co.nz/*"
          "*://*.pinterest.co.uk/*"
          "*://*.pinterest.com.au/*"
          "*://*.pinterest.com.mx/*"
          "*://*.pinterest.com/*"
          "*://*.pinterest.cz/*"
          "*://*.pinterest.de/*"
          "*://*.pinterest.dk/*"
          "*://*.pinterest.es/*"
          "*://*.pinterest.fi/*"
          "*://*.pinterest.fr/*"
          "*://*.pinterest.ie/*"
          "*://*.pinterest.it/*"
          "*://*.pinterest.jp/*"
          "*://*.pinterest.nl/*"
          "*://*.pinterest.pt/*"
          "*://*.pinterest.ru/*"
          "*://*.pinterest.se/*"
          "*://*.500px.com/*"
          "*://*.modelmayhem.com/*"
          "*://*.yam.com/*"
          "*://mail.google.com/*"
          "*://*.8tracks.com/*"
          "*://*.gameblog.fr/*"
          "*://*.diasp.eu/*"
          "*://*.diasp.org/*"
          "*://*.joindiaspora.com/*"
          "*://*.memecrunch.com/*"
          "*://*.jeuxvideo.fr/*"
          "*://*.boardgamegeek.com/*"
          "*://*.rpggeek.com/*"
          "*://*.videogamegeek.com/*"
          "*://*.e621.net/*"
          "*://*.e6ai.net/*"
          "*://*.e926.net/*"
          "*://danbooru.donmai.us/*"
          "*://*.jootix.com/*"
          "*://*.bing.com/*"
          "*://*.xuite.net/*"
          "*://*.craigslist.org/*"
          "*://*.zinio.com/*"
          "*://*.dribbble.com/*"
          "*://*.pixnet.net/*"
          "*://*.dropbox.com/*"
          "*://*.newegg.ca/*"
          "*://*.newegg.com/*"
          "*://*.newegg.com.cn/*"
          "*://*.furaffinity.net/*"
          "*://*.furrynetwork.com/*"
          "*://*.taobao.com/*"
          "*://*.tmall.com/*"
          "*://*.lazygirls.info/*"
          "*://*.zhihu.com/*"
          "*://*.hupu.com/*"
          "*://*.weibo.com/*"
          "*://*.douban.com/*"
          "*://*.github.com/*"
          "*://*.freepik.com/*"
          "*://*.weasyl.com/*"
          "*://*.quora.com/*"
          "*://*.wallbase.cc/*"
          "*://*.wallhaven.cc/*"
          "*://*.blu-ray.com/*"
          "*://*.minitokyo.net/*"
          "*://*.animepaper.net/*"
          "*://*.choualbox.com/*"
          "*://*.yandex.at/*"
          "*://*.yandex.au/*"
          "*://*.yandex.be/*"
          "*://*.yandex.ca/*"
          "*://*.yandex.ch/*"
          "*://*.yandex.cl/*"
          "*://*.yandex.cn/*"
          "*://*.yandex.co.hu/*"
          "*://*.yandex.co.id/*"
          "*://*.yandex.co.il/*"
          "*://*.yandex.co.kr/*"
          "*://*.yandex.co.nz/*"
          "*://*.yandex.co.uk/*"
          "*://*.yandex.co.za/*"
          "*://*.yandex.co/*"
          "*://*.yandex.com.ar/*"
          "*://*.yandex.com.au/*"
          "*://*.yandex.com.br/*"
          "*://*.yandex.com.eg/*"
          "*://*.yandex.com.gr/*"
          "*://*.yandex.com.hk/*"
          "*://*.yandex.com.mx/*"
          "*://*.yandex.com.my/*"
          "*://*.yandex.com.pe/*"
          "*://*.yandex.com.ph/*"
          "*://*.yandex.com.sg/*"
          "*://*.yandex.com.tr/*"
          "*://*.yandex.com.tw/*"
          "*://*.yandex.com.ve/*"
          "*://*.yandex.com.vn/*"
          "*://*.yandex.com/*"
          "*://*.yandex.cz/*"
          "*://*.yandex.de/*"
          "*://*.yandex.dk/*"
          "*://*.yandex.es/*"
          "*://*.yandex.fi/*"
          "*://*.yandex.fr/*"
          "*://*.yandex.ie/*"
          "*://*.yandex.in/*"
          "*://*.yandex.it/*"
          "*://*.yandex.jp/*"
          "*://*.yandex.net/*"
          "*://*.yandex.nl/*"
          "*://*.yandex.pt/*"
          "*://*.yandex.rs/*"
          "*://*.yandex.ru/*"
          "*://*.yandex.se/*"
          "*://*.yandex.sk/*"
          "*://*.yandex.ua/*"
          "*://*.kununu.com/*"
          "*://miiverse.nintendo.net/*"
          "*://*.fetlife.com/*"
          "*://*.kenmarcus.com/*"
          "*://*.zenfolio.com/*"
          "*://*.escapistmagazine.com/*"
          "*://*.d3.ru/*"
          "*://*.dirty.ru/*"
          "*://*.slickdeals.net/*"
          "*://*.flipkart.com/*"
          "*://*.artuk.org/*"
          "*://*.n11.com/*"
          "*://*.carrefoursa.com/*"
          "*://ask.fm/*"
          "*://*.artlimited.net/*"
          "*://*.instagram.com/*"
          "*://kephost.com/*"
          "*://*.visualart.me/*"
          "*://*.visualart.ro/*"
          "*://*.photo.net/*"
          "*://*.gettyimages.ae/*"
          "*://*.gettyimages.at/*"
          "*://*.gettyimages.be/*"
          "*://*.gettyimages.ca/*"
          "*://*.gettyimages.ch/*"
          "*://*.gettyimages.cn/*"
          "*://*.gettyimages.co.cz/*"
          "*://*.gettyimages.co.jp/*"
          "*://*.gettyimages.co.nz/*"
          "*://*.gettyimages.co.uk/*"
          "*://*.gettyimages.com.au/*"
          "*://*.gettyimages.com.pl/*"
          "*://*.gettyimages.com/*"
          "*://*.gettyimages.de/*"
          "*://*.gettyimages.dk/*"
          "*://*.gettyimages.es/*"
          "*://*.gettyimages.fi/*"
          "*://*.gettyimages.fr/*"
          "*://*.gettyimages.ie/*"
          "*://*.gettyimages.in/*"
          "*://*.gettyimages.it/*"
          "*://*.gettyimages.nl/*"
          "*://*.gettyimages.no/*"
          "*://*.gettyimages.pt/*"
          "*://*.gettyimages.ru/*"
          "*://*.gettyimages.se/*"
          "*://*.pixabay.com/*"
          "*://*.freeimages.com/*"
          "*://*.artstation.com/*"
          "*://*.artfol.co/*"
          "*://*.artsper.com/*"
          "*://*.istockphoto.com/*"
          "*://*.everystockphoto.com/*"
          "*://*.smugmug.com/*"
          "*://*.cgcookie.com/*"
          "*://*.dreamstime.com/*"
          "*://*.cgsociety.org/*"
          "*://*.mobypicture.com/*"
          "*://*.foursquare.com/*"
          "*://*.metmuseum.org/*"
          "*://*.wookmark.com/*"
          "*://*.stocksnap.io/*"
          "*://*.stocksnap.com/*"
          "*://*.pexels.com/*"
          "*://stock.adobe.com/*"
          "*://*.3dtotal.com/*"
          "*://*.fubiz.net/*"
          "*://*.drawcrowd.com/*"
          "*://*.wykop.pl/*"
          "*://9gag.com/*"
          "*://app.hiptest.com/*"
          "*://*.booru.org/*"
          "*://*.gelbooru.com/*"
          "*://*.mspabooru.com/*"
          "*://*.safebooru.org/*"
          "*://*.xbooru.com/*"
          "*://*.depositphotos.com/*"
          "*://*.airbnb.ae/*"
          "*://*.airbnb.am/*"
          "*://*.airbnb.at/*"
          "*://*.airbnb.az/*"
          "*://*.airbnb.ba/*"
          "*://*.airbnb.be/*"
          "*://*.airbnb.ca/*"
          "*://*.airbnb.cat/*"
          "*://*.airbnb.ch/*"
          "*://*.airbnb.cl/*"
          "*://*.airbnb.cn/*"
          "*://*.airbnb.co.cr/*"
          "*://*.airbnb.co.id/*"
          "*://*.airbnb.co.in/*"
          "*://*.airbnb.co.kr/*"
          "*://*.airbnb.co.nz/*"
          "*://*.airbnb.co.uk/*"
          "*://*.airbnb.co.ve/*"
          "*://*.airbnb.co.za/*"
          "*://*.airbnb.com.ar/*"
          "*://*.airbnb.com.au/*"
          "*://*.airbnb.com.bo/*"
          "*://*.airbnb.com.br/*"
          "*://*.airbnb.com.bz/*"
          "*://*.airbnb.com.co/*"
          "*://*.airbnb.com.ec/*"
          "*://*.airbnb.com.ee/*"
          "*://*.airbnb.com.gt/*"
          "*://*.airbnb.com.hk/*"
          "*://*.airbnb.com.hn/*"
          "*://*.airbnb.com.mt/*"
          "*://*.airbnb.com.my/*"
          "*://*.airbnb.com.ni/*"
          "*://*.airbnb.com.pa/*"
          "*://*.airbnb.com.pe/*"
          "*://*.airbnb.com.ph/*"
          "*://*.airbnb.com.py/*"
          "*://*.airbnb.com.ro/*"
          "*://*.airbnb.com.sg/*"
          "*://*.airbnb.com.sv/*"
          "*://*.airbnb.com.tr/*"
          "*://*.airbnb.com.tw/*"
          "*://*.airbnb.com.ua/*"
          "*://*.airbnb.com/*"
          "*://*.airbnb.cz/*"
          "*://*.airbnb.de/*"
          "*://*.airbnb.dk/*"
          "*://*.airbnb.es/*"
          "*://*.airbnb.fi/*"
          "*://*.airbnb.fr/*"
          "*://*.airbnb.gr/*"
          "*://*.airbnb.gy/*"
          "*://*.airbnb.hu/*"
          "*://*.airbnb.ie/*"
          "*://*.airbnb.is/*"
          "*://*.airbnb.it/*"
          "*://*.airbnb.jp/*"
          "*://*.airbnb.lt/*"
          "*://*.airbnb.lv/*"
          "*://*.airbnb.mx/*"
          "*://*.airbnb.nl/*"
          "*://*.airbnb.no/*"
          "*://*.airbnb.pl/*"
          "*://*.airbnb.pt/*"
          "*://*.airbnb.rs/*"
          "*://*.airbnb.ru/*"
          "*://*.airbnb.se/*"
          "*://*.airbnb.si/*"
          "*://*.booking.com/*"
          "*://*.publicdomainpictures.net/*"
          "*://*.avopix.ae/*"
          "*://*.avopix.at/*"
          "*://*.avopix.be/*"
          "*://*.avopix.ca/*"
          "*://*.avopix.ch/*"
          "*://*.avopix.cn/*"
          "*://*.avopix.co.cz/*"
          "*://*.avopix.co.jp/*"
          "*://*.avopix.co.nz/*"
          "*://*.avopix.co.uk/*"
          "*://*.avopix.com.au/*"
          "*://*.avopix.com.pl/*"
          "*://*.avopix.com/*"
          "*://*.avopix.de/*"
          "*://*.avopix.dk/*"
          "*://*.avopix.es/*"
          "*://*.avopix.fi/*"
          "*://*.avopix.fr/*"
          "*://*.avopix.ie/*"
          "*://*.avopix.in/*"
          "*://*.avopix.it/*"
          "*://*.avopix.nl/*"
          "*://*.avopix.no/*"
          "*://*.avopix.pt/*"
          "*://*.avopix.ru/*"
          "*://*.avopix.se/*"
          "*://*.bakashots.me/*"
          "*://*.fanart.tv/*"
          "*://*.fotki.com/*"
          "*://*.free-images.com/*"
          "*://*.galerie-sakura.com/*"
          "*://*.lostfilm.info/*"
          "*://*.lostfilm.run/*"
          "*://*.lostfilm.tv/*"
          "*://*.meetup.com/*"
          "*://*.nasa.gov/*"
          "*://*.photoblink.com/*"
          "*://*.photoforum.ru/*"
          "*://*.photo-forum.net/*"
          "*://*.photopost.cz/*"
          "*://*.photosight.ru/*"
          "*://*.picturepush.com/*"
          "*://*.tuchong.com/*"
          "*://*.wireimage.co.in/*"
          "*://*.wireimage.com.au/*"
          "*://*.wireimage.com.pt/*"
          "*://*.wireimage.com/*"
          "*://*.wireimage.de/*"
          "*://*.wireimage.es/*"
          "*://*.wireimage.fr/*"
          "*://*.wireimage.it/*"
          "*://*.wireimage.jp/*"
          "*://*.wireimage.se/*"
          "*://*.wysp.ws/*"
          "*://*.tripadvisor.at/*"
          "*://*.tripadvisor.be/*"
          "*://*.tripadvisor.ca/*"
          "*://*.tripadvisor.ch/*"
          "*://*.tripadvisor.cl/*"
          "*://*.tripadvisor.cn/*"
          "*://*.tripadvisor.co.hu/*"
          "*://*.tripadvisor.co.id/*"
          "*://*.tripadvisor.co.il/*"
          "*://*.tripadvisor.co.kr/*"
          "*://*.tripadvisor.co.nz/*"
          "*://*.tripadvisor.co.uk/*"
          "*://*.tripadvisor.co.za/*"
          "*://*.tripadvisor.co/*"
          "*://*.tripadvisor.com.ar/*"
          "*://*.tripadvisor.com.au/*"
          "*://*.tripadvisor.com.br/*"
          "*://*.tripadvisor.com.eg/*"
          "*://*.tripadvisor.com.gr/*"
          "*://*.tripadvisor.com.hk/*"
          "*://*.tripadvisor.com.mx/*"
          "*://*.tripadvisor.com.my/*"
          "*://*.tripadvisor.com.pe/*"
          "*://*.tripadvisor.com.ph/*"
          "*://*.tripadvisor.com.sg/*"
          "*://*.tripadvisor.com.tr/*"
          "*://*.tripadvisor.com.tw/*"
          "*://*.tripadvisor.com.ve/*"
          "*://*.tripadvisor.com.vn/*"
          "*://*.tripadvisor.com/*"
          "*://*.tripadvisor.cz/*"
          "*://*.tripadvisor.de/*"
          "*://*.tripadvisor.dk/*"
          "*://*.tripadvisor.es/*"
          "*://*.tripadvisor.fi/*"
          "*://*.tripadvisor.fr/*"
          "*://*.tripadvisor.ie/*"
          "*://*.tripadvisor.in/*"
          "*://*.tripadvisor.it/*"
          "*://*.tripadvisor.jp/*"
          "*://*.tripadvisor.nl/*"
          "*://*.tripadvisor.pt/*"
          "*://*.tripadvisor.rs/*"
          "*://*.tripadvisor.ru/*"
          "*://*.tripadvisor.se/*"
          "*://*.tripadvisor.sk/*"
          "*://*.freerangestock.com/*"
          "*://*.joemonster.org/*"
          "*://*.vox.com/*"
          "*://*.behance.net/*"
          "*://*.goodreads.com/*"
          "*://*.pikwizard.com/*"
          "*://*.thingiverse.com/*"
          "*://*.derpibooru.org/*"
          "*://*.aminus3.com/*"
          "*://*.livememe.com/*"
          "*://*.8ch.net/*"
          "*://*.8kun.top/*"
          "*://*.giphy.com/*"
          "*://*.imageevent.com/*"
          "*://*.aol.com/*"
          "*://*.govdeals.com/*"
          "*://*.minds.com/*"
          "*://*.gitlab.com/*"
          "*://*.phorio.com/*"
          "*://*.wallapop.com/*"
          "*://*.gog.com/*"
          "*://*.picclick.at/*"
          "*://*.picclick.be/*"
          "*://*.picclick.ca/*"
          "*://*.picclick.ch/*"
          "*://*.picclick.co.uk/*"
          "*://*.picclick.com.au/*"
          "*://*.picclick.com/*"
          "*://*.picclick.de/*"
          "*://*.picclick.es/*"
          "*://*.picclick.fr/*"
          "*://*.picclick.ie/*"
          "*://*.picclick.it/*"
          "*://*.picclick.nl/*"
          "*://*.loc.gov/*"
          "*://*.duitang.com/*"
          "*://*.wdl.org/*"
          "*://*.hibid.com/*"
          "*://*.maxsold.com/*"
          "*://*.myanimelist.net/*"
          "*://*.themoviedb.org/*"
          "*://*.twibooru.org/*"
          "*://*.catawiki.com/*"
          "*://*.qwant.com/*"
          "*://*.duckduckgo.com/*"
          "*://*.sogou.cn/*"
          "*://*.sogou.com/*"
          "*://docs.google.com/spreadsheets/*"
          "*://*.naver.com/*"
          "*://*.allegro.pl/*"
          "*://*.startpage.com/*"
          "*://*.redgifs.com/*"
          "*://*.you.com/*"
          "*://*.wikifeet.com/*"
          "*://*.wikifeetx.com/*"
          "*://*.mywikifeet.com/*"
          "*://*.gfycat.com/*"
          "*://*.tipeee.com/*"
          "*://*.pic2.me/*"
          "*://*.celebs-place.com/*"
          "*://*.viewbug.com/*"
          "*://*.shein.com/*"
          "*://*.huaban.com/*"
          "*://*.bnf.fr/*"
          "*://*.tiktok.com/*"
          "*://*.unlimphotos.com/*"
          "*://*.eksisozluk.com/*"
          "*://*.moddb.com/*"
          "*://*.indiedb.com/*"
          "*://*.motherless.com/*"
          "*://*.tnaflix.com/*"
          "*://*.2gis.com/*"
          "*://*.2gis.ae/*"
          "*://*.2gis.az/*"
          "*://*.2gis.cl/*"
          "*://*.2gis.cz/*"
          "*://*.2gis.kg/*"
          "*://*.2gis.kz/*"
          "*://*.2gis.ru/*"
          "*://*.2gis.uz/*"
          "*://*.urbi-bh.com/*"
          "*://*.urbi-kw.com/*"
          "*://*.urbi-qa.com/*"
          "*://*.urbi-sa.com/*"
          "*://*.rule34.xxx/*"
          "*://*.boredpanda.com/*"
          "*://*.yiffer.xyz/*"
          "*://*.homeexchange.com/*"
          "*://*.homeexchange.fr/*"
          "*://*.homeexchange.it/*"
          "*://*.fandom.com/*"
          "*://*.temu.com/*"
          "*://*.fotocommunity.com/*"
          "*://*.fotocommunity.de/*"
          "*://*.fotocommunity.es/*"
          "*://*.fotocommunity.fr/*"
          "*://*.fotocommunity.it/*"
          "*://*.ecranlarge.com/*"
          "*://*.hejto.pl/*"
          "*://*.geograph.org/*"
          "*://*.geograph.org.uk/*"
          "*://*.geograph.org.gg/*"
          "*://*.geograph.ie/*"
          "*://*.hlipp.de/*"
          "*://*.canmore.org.uk/*"
          "*://*.head-fi.org/*"
          "*://*.etejo.com/*"
          "*://*.wildcritters.ws/*"
          "*://*.auscelebs.net/*"
          "*://*.douyin.com/*"
          "*://*.picsart.com/*"
          "*://*.lemon8-app.com/*"
          "*://*.gcsurplus.ca/*"
          "*://*.iwara.tv/*"
          "*://*.usbeketrica.com/*"
          "*://*.letterboxd.com/*"
          "*://*.figma.com/files/*"
          "*://*.kleinanzeigen.de/*"
          "*://*.tenor.com/*"
          "*://*.trakt.tv/*"
          "*://*.vsco.co/*"
          "*://*.woot.com/*"
          "*://*.vero.co/*"
          "*://*.anichart.net/*"
          "*://*.anilist.co/*"
          "*://*.freeimage.host/*"
          "*://drive.google.com/*"
          "*://*.findagrave.com/*"
          "*://*.ldlc.com/*"
          "*://*.mubi.com/*"
          "*://*.tapas.io/*"
          "*://*.sspai.com/*"
          "*://*.bsky.app/*"
          "*://*.onzemondial.com/*"
          "*://*.cineserie.com/*"
          "*://*.opendata.hauts-de-seine.fr/*"
          "*://*.nature.com/*"
          "*://*.galerie9art.fr/*"
          "*://*.worldatlas.com/*"
          "*://*.kotnauction.com/*"
          "*://*.techradar.com/*"
          "*://*.inoreader.com/*"
          "*://*.unsplash.com/*"
          "*://*.defense.gov/*"
          "*://*.mil/*"
          "*://*.la-croix.com/*"
          "*://*.routard.com/*"
          "*://podcasts.apple.com/*"
          "*://apps.apple.com/*"
          "*://books.apple.com/*"
          "*://music.apple.com/*"
          "*://*.monuments-nationaux.fr/*"
          "*://*.phys.org/*"
          "*://*.medicalxpress.com/*"
          "*://*.sciencex.com/*"
          "*://*.techxplore.com/*"
          "*://*.spotify.com/*"
          "*://*.songkick.com/*"
          "*://*.nextdoor.com/*"
          "*://*.polona.pl/*"
          "*://*.raindrop.io/*"
          "*://*.stackoverflow.com/*"
          "*://*.uinotes.com/*"
          "*://*.meiye.art/*"
          "*://*.lummi.ai/*"
          "*://*.search.brave.com/*"
          "*://*.civitai.com/*"
          "*://*.civitai.green/*"
          "*://*.ui.cn/*"
          "*://*.bidspotter.com/*"
          "*://*.nexusmods.com/*"
          "*://*.aliexpress.com/*"
          "*://*.yupoo.com/*"
          "*://*.pokellector.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "hulu-ad-blocker" = buildFirefoxXpiAddon {
      pname = "hulu-ad-blocker";
      version = "1.0.0";
      addonId = "{a1541a5e-68f8-480d-8f10-784f93079060}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3933295/hulu_ad_blocker_firefox-1.0.0.xpi";
      sha256 = "c741eeac7c8f13af4bb5d5fdafa0b4f7f90d137f5604d28b03ad344832e2ab1d";
      meta = with lib;
      {
        homepage = "https://www.huluadblocker.com";
        description = "Block All Hulu Ads, Stream Freely!";
        license = licenses.mpl20;
        mozPermissions = [ "https://*/*" "http://*/*" ];
        platforms = platforms.all;
      };
    };
    "hyperchat" = buildFirefoxXpiAddon {
      pname = "hyperchat";
      version = "3.1.1";
      addonId = "{14a15c41-13f4-498e-986c-7f00435c4d00}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4553316/hyperchat-3.1.1.xpi";
      sha256 = "659381b936445560ad62ff3141e57d7498f7fc18599c4d47b38ec596836208cf";
      meta = with lib;
      {
        homepage = "https://livetl.app/hyperchat/";
        description = "Improved YouTube chat with CPU/RAM optimizations, customization options, and cutting-edge features!";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "https://www.youtube.com/live_chat*"
          "https://www.youtube.com/live_chat_replay*"
          "https://studio.youtube.com/live_chat*"
          "https://studio.youtube.com/live_chat_replay*"
          "https://www.youtube.com/embed/hyperchat_embed?*"
        ];
        platforms = platforms.all;
      };
    };
    "i-auto-fullscreen" = buildFirefoxXpiAddon {
      pname = "i-auto-fullscreen";
      version = "2.0.4";
      addonId = "{809d8a54-1e2d-4fbb-81b4-36ff597b225f}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3853680/i_auto_fullscreen-2.0.4.xpi";
      sha256 = "7e5c9895eac6dac3b1e852e7bc5408b28b559dff9fd26de620157ab7e432169f";
      meta = with lib;
      {
        homepage = "https://github.com/insiderser/AutoFullscreen/";
        description = "Open all Firefox windows in full screen mode";
        license = licenses.mit;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "i-dont-care-about-cookies" = buildFirefoxXpiAddon {
      pname = "i-dont-care-about-cookies";
      version = "3.5.0";
      addonId = "jid1-KKzOGWgsW3Ao4Q@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4202634/i_dont_care_about_cookies-3.5.0.xpi";
      sha256 = "4de284454217fc4bee0744fb0aad8e0e10fa540dc03251013afc3ee4c20e49b0";
      meta = with lib;
      {
        homepage = "https://www.i-dont-care-about-cookies.eu/";
        description = "Get rid of cookie warnings from almost all websites!";
        license = licenses.gpl3;
        mozPermissions = [
          "tabs"
          "storage"
          "http://*/*"
          "https://*/*"
          "notifications"
          "webRequest"
          "webRequestBlocking"
          "webNavigation"
        ];
        platforms = platforms.all;
      };
    };
    "i2p-in-private-browsing" = buildFirefoxXpiAddon {
      pname = "i2p-in-private-browsing";
      version = "2.8.2";
      addonId = "i2ppb@eyedeekay.github.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/4441161/i2p_in_private_browsing-2.8.2.xpi";
      sha256 = "6a81e998f3cf37d4a606175c8e5e7c3b0ab3b12c48473956caa9726ddc3f0438";
      meta = with lib;
      {
        homepage = "https://github.com/eyedeekay/i2psetproxy.js";
        description = "Uses Container Tabs to set up a browser to use I2P conveniently and safely by setting up an I2P-powered Private Browsing mode, inspired by the similar feature in Brave. Requires an I2P router on the host system.";
        license = licenses.mit;
        mozPermissions = [
          "theme"
          "alarms"
          "browsingData"
          "bookmarks"
          "contextMenus"
          "management"
          "notifications"
          "proxy"
          "privacy"
          "storage"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "contextualIdentities"
          "cookies"
          "history"
          "tabs"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "iina-open-in-mpv" = buildFirefoxXpiAddon {
      pname = "iina-open-in-mpv";
      version = "2.4.3";
      addonId = "{d66c8515-1e0d-408f-82ee-2682f2362726}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4415443/iina_open_in_mpv-2.4.3.xpi";
      sha256 = "8289779568ce6a432c0d8f900d5b52e92d0f8659188531057900591356900d39";
      meta = with lib;
      {
        homepage = "https://github.com/Baldomo/open-in-mpv";
        description = "Open videos and audio files in the mpv player and other compatible players.";
        license = licenses.gpl3;
        mozPermissions = [
          "tabs"
          "activeTab"
          "contextMenus"
          "storage"
          "scripting"
        ];
        platforms = platforms.all;
      };
    };
    "image-search-options" = buildFirefoxXpiAddon {
      pname = "image-search-options";
      version = "3.0.12";
      addonId = "{4a313247-8330-4a81-948e-b79936516f78}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3059971/image_search_options-3.0.12.xpi";
      sha256 = "1fbdd8597fc32b1be11302a958ea3ba2b010edcfeb432c299637b2c58c6fd068";
      meta = with lib;
      {
        homepage = "http://saucenao.com/";
        description = "A customizable reverse image search tool that conveniently presents a variety of top image search engines.";
        license = licenses.mpl11;
        mozPermissions = [
          "storage"
          "contextMenus"
          "activeTab"
          "tabs"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "imagus" = buildFirefoxXpiAddon {
      pname = "imagus";
      version = "0.9.8.74";
      addonId = "{00000f2a-7cde-4f20-83ed-434fcb420d71}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3547888/imagus-0.9.8.74.xpi";
      sha256 = "2b754aa4fca1c99e86d7cdc6d8395e534efd84c394d5d62a1653f9ed519f384e";
      meta = with lib;
      {
        homepage = "https://tiny.cc/Imagus";
        description = "With a simple mouse-over you can enlarge images and display images/videos from links.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "*://*/*"
          "downloads"
          "history"
          "storage"
          "<all_urls>"
          "https://*/search*"
          "https://duckduckgo.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "immersive-translate" = buildFirefoxXpiAddon {
      pname = "immersive-translate";
      version = "1.22.4";
      addonId = "{5efceaa7-f3a2-4e59-a54b-85319448e305}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4601644/immersive_translate-1.22.4.xpi";
      sha256 = "d859e1299f354748963e043424d1d32c7a0158a0e063bd3bfe2a9649a2394ead";
      meta = with lib;
      {
        homepage = "https://immersivetranslate.com";
        description = "Free Translate Website, Translate PDF &amp; Epub eBook, Translate Video Subtitles in Bilingual";
        license = {
          shortName = "immersive-translate";
          fullName = "End-User License Agreement for Immersive Translate";
          url = "https://addons.mozilla.org/en-US/firefox/addon/immersive-translate/eula/";
          free = false;
        };
        knownVulnerabilities = [
          "Information leakage, see https://www.binance.com/en/square/post/28079094872802"
        ];
        mozPermissions = [
          "<all_urls>"
          "storage"
          "activeTab"
          "contextMenus"
          "webRequest"
          "webRequestBlocking"
          "file:///*"
          "*://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "improved-tube" = buildFirefoxXpiAddon {
      pname = "improved-tube";
      version = "4.1350";
      addonId = "{3c6bf0cc-3ae2-42fb-9993-0d33104fdcaf}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4583940/youtube_addon-4.1350.xpi";
      sha256 = "4ffb4231deecf25172bc7334bc2cb8ef3c58a57a501bf3d3fe4698aae9e003af";
      meta = with lib;
      {
        homepage = "https://github.com/code4charity/YouTube-Extension/";
        description = "Youtube Extension. Powerful but lightweight. Enrich your Youtube and content selection. Make YouTube tidy and smart! (Layout, Filters, Shortcuts, Playlist)";
        license = {
          shortName = "improved-tube";
          fullName = "ImprovedTube License";
          url = "https://github.com/code-charity/youtube/blob/master/LICENSE";
          free = false;
        };
        mozPermissions = [
          "contextMenus"
          "storage"
          "https://www.youtube.com/*"
          "https://m.youtube.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "impulse-blocker" = buildFirefoxXpiAddon {
      pname = "impulse-blocker";
      version = "1.2.0";
      addonId = "{3a7ab27c-6a20-4d24-9fda-5e38f8992556}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3710342/impulse_blocker-1.2.0.xpi";
      sha256 = "b6be12a475fdc57197ed753a75cdde9143d3e0f6ddbca07a02cc8ed87decd27a";
      meta = with lib;
      {
        homepage = "https://github.com/raicem/impulse-blocker";
        description = "Block distracting websites. Just list the sites you want Impulse Blocker to pause or completely avoid.";
        license = licenses.mit;
        mozPermissions = [
          "<all_urls>"
          "webRequest"
          "webRequestBlocking"
          "storage"
          "tabs"
        ];
        platforms = platforms.all;
      };
    };
    "incognito-normal" = buildFirefoxXpiAddon {
      pname = "incognito-normal";
      version = "1.2.1resigned1";
      addonId = "@incognitonormal";
      url = "https://addons.mozilla.org/firefox/downloads/file/4277691/incognito_normal-1.2.1resigned1.xpi";
      sha256 = "210270aadc1e3228919de46fafb8fdd74ccd3b3a5e436325ade052c0c7b027d1";
      meta = with lib;
      {
        description = "Quickly switch current tab, link or search text to Google from incognito window to normal window, or vice versa.";
        license = licenses.mpl20;
        mozPermissions = [ "tabs" "contextMenus" ];
        platforms = platforms.all;
      };
    };
    "indie-wiki-buddy" = buildFirefoxXpiAddon {
      pname = "indie-wiki-buddy";
      version = "3.13.8";
      addonId = "{cb31ec5d-c49a-4e5a-b240-16c767444f62}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4585291/indie_wiki_buddy-3.13.8.xpi";
      sha256 = "edadaabaaa32aa43b148231abb2e9e60b0677da9e65d9cee68f95e97b2195a1a";
      meta = with lib;
      {
        homepage = "https://getindie.wiki/";
        description = "Helping you discover quality, independent wikis!\n\nWhen visiting a Fandom wiki, Indie Wiki Buddy redirects or alerts you of independent alternatives. It also filters search engine results. BreezeWiki is also supported, to reduce clutter on Fandom.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "webRequest"
          "notifications"
          "scripting"
          "https://*.fandom.com/*"
          "https://*.fextralife.com/*"
          "https://*.neoseeker.com/*"
          "https://breezewiki.com/*"
          "https://antifandom.com/*"
          "https://bw.artemislena.eu/*"
          "https://breezewiki.catsarch.com/*"
          "https://breezewiki.esmailelbob.xyz/*"
          "https://breezewiki.frontendfriendly.xyz/*"
          "https://bw.hamstro.dev/*"
          "https://breeze.hostux.net/*"
          "https://breezewiki.hyperreal.coffee/*"
          "https://breeze.mint.lgbt/*"
          "https://breezewiki.nadeko.net/*"
          "https://nerd.whatever.social/*"
          "https://breeze.nohost.network/*"
          "https://z.opnxng.com/*"
          "https://bw.projectsegfau.lt/*"
          "https://breezewiki.pussthecat.org/*"
          "https://bw.vern.cc/*"
          "https://breeze.whateveritworks.org/*"
          "https://breezewiki.woodland.cafe/*"
          "https://*.bing.com/search*"
          "https://search.brave.com/search*"
          "https://*.duckduckgo.com/*"
          "https://*.ecosia.org/*"
          "https://kagi.com/search*"
          "https://*.qwant.com/*"
          "https://*.search.yahoo.com/*"
          "https://*.startpage.com/*"
          "https://*.ya.ru/*"
          "https://*.yandex.az/*"
          "https://*.yandex.by/*"
          "https://*.yandex.co.il/*"
          "https://*.yandex.com.am/*"
          "https://*.yandex.com.ge/*"
          "https://*.yandex.com.tr/*"
          "https://*.yandex.com/*"
          "https://*.yandex.ee/*"
          "https://*.yandex.eu/*"
          "https://*.yandex.fr/*"
          "https://*.yandex.kz/*"
          "https://*.yandex.lt/*"
          "https://*.yandex.lv/*"
          "https://*.yandex.md/*"
          "https://*.yandex.ru/*"
          "https://*.yandex.tj/*"
          "https://*.yandex.tm/*"
          "https://*.yandex.uz/*"
          "https://www.google.com/search*"
          "https://www.google.ad/search*"
          "https://www.google.ae/search*"
          "https://www.google.com.af/search*"
          "https://www.google.com.ag/search*"
          "https://www.google.com.ai/search*"
          "https://www.google.al/search*"
          "https://www.google.am/search*"
          "https://www.google.co.ao/search*"
          "https://www.google.com.ar/search*"
          "https://www.google.as/search*"
          "https://www.google.at/search*"
          "https://www.google.com.au/search*"
          "https://www.google.az/search*"
          "https://www.google.ba/search*"
          "https://www.google.com.bd/search*"
          "https://www.google.be/search*"
          "https://www.google.bf/search*"
          "https://www.google.bg/search*"
          "https://www.google.com.bh/search*"
          "https://www.google.bi/search*"
          "https://www.google.bj/search*"
          "https://www.google.com.bn/search*"
          "https://www.google.com.bo/search*"
          "https://www.google.com.br/search*"
          "https://www.google.bs/search*"
          "https://www.google.bt/search*"
          "https://www.google.co.bw/search*"
          "https://www.google.by/search*"
          "https://www.google.com.bz/search*"
          "https://www.google.ca/search*"
          "https://www.google.cd/search*"
          "https://www.google.cf/search*"
          "https://www.google.cg/search*"
          "https://www.google.ch/search*"
          "https://www.google.ci/search*"
          "https://www.google.co.ck/search*"
          "https://www.google.cl/search*"
          "https://www.google.cm/search*"
          "https://www.google.cn/search*"
          "https://www.google.com.co/search*"
          "https://www.google.co.cr/search*"
          "https://www.google.com.cu/search*"
          "https://www.google.cv/search*"
          "https://www.google.com.cy/search*"
          "https://www.google.cz/search*"
          "https://www.google.de/search*"
          "https://www.google.dj/search*"
          "https://www.google.dk/search*"
          "https://www.google.dm/search*"
          "https://www.google.com.do/search*"
          "https://www.google.dz/search*"
          "https://www.google.com.ec/search*"
          "https://www.google.ee/search*"
          "https://www.google.com.eg/search*"
          "https://www.google.es/search*"
          "https://www.google.com.et/search*"
          "https://www.google.fi/search*"
          "https://www.google.com.fj/search*"
          "https://www.google.fm/search*"
          "https://www.google.fr/search*"
          "https://www.google.ga/search*"
          "https://www.google.ge/search*"
          "https://www.google.gg/search*"
          "https://www.google.com.gh/search*"
          "https://www.google.com.gi/search*"
          "https://www.google.gl/search*"
          "https://www.google.gm/search*"
          "https://www.google.gr/search*"
          "https://www.google.com.gt/search*"
          "https://www.google.gy/search*"
          "https://www.google.com.hk/search*"
          "https://www.google.hn/search*"
          "https://www.google.hr/search*"
          "https://www.google.ht/search*"
          "https://www.google.hu/search*"
          "https://www.google.co.id/search*"
          "https://www.google.ie/search*"
          "https://www.google.co.il/search*"
          "https://www.google.im/search*"
          "https://www.google.co.in/search*"
          "https://www.google.iq/search*"
          "https://www.google.is/search*"
          "https://www.google.it/search*"
          "https://www.google.je/search*"
          "https://www.google.com.jm/search*"
          "https://www.google.jo/search*"
          "https://www.google.co.jp/search*"
          "https://www.google.co.ke/search*"
          "https://www.google.com.kh/search*"
          "https://www.google.ki/search*"
          "https://www.google.kg/search*"
          "https://www.google.co.kr/search*"
          "https://www.google.com.kw/search*"
          "https://www.google.kz/search*"
          "https://www.google.la/search*"
          "https://www.google.com.lb/search*"
          "https://www.google.li/search*"
          "https://www.google.lk/search*"
          "https://www.google.co.ls/search*"
          "https://www.google.lt/search*"
          "https://www.google.lu/search*"
          "https://www.google.lv/search*"
          "https://www.google.com.ly/search*"
          "https://www.google.co.ma/search*"
          "https://www.google.md/search*"
          "https://www.google.me/search*"
          "https://www.google.mg/search*"
          "https://www.google.mk/search*"
          "https://www.google.ml/search*"
          "https://www.google.com.mm/search*"
          "https://www.google.mn/search*"
          "https://www.google.ms/search*"
          "https://www.google.com.mt/search*"
          "https://www.google.mu/search*"
          "https://www.google.mv/search*"
          "https://www.google.mw/search*"
          "https://www.google.com.mx/search*"
          "https://www.google.com.my/search*"
          "https://www.google.co.mz/search*"
          "https://www.google.com.na/search*"
          "https://www.google.com.ng/search*"
          "https://www.google.com.ni/search*"
          "https://www.google.ne/search*"
          "https://www.google.nl/search*"
          "https://www.google.no/search*"
          "https://www.google.com.np/search*"
          "https://www.google.nr/search*"
          "https://www.google.nu/search*"
          "https://www.google.co.nz/search*"
          "https://www.google.com.om/search*"
          "https://www.google.com.pa/search*"
          "https://www.google.com.pe/search*"
          "https://www.google.com.pg/search*"
          "https://www.google.com.ph/search*"
          "https://www.google.com.pk/search*"
          "https://www.google.pl/search*"
          "https://www.google.pn/search*"
          "https://www.google.com.pr/search*"
          "https://www.google.ps/search*"
          "https://www.google.pt/search*"
          "https://www.google.com.py/search*"
          "https://www.google.com.qa/search*"
          "https://www.google.ro/search*"
          "https://www.google.ru/search*"
          "https://www.google.rw/search*"
          "https://www.google.com.sa/search*"
          "https://www.google.com.sb/search*"
          "https://www.google.sc/search*"
          "https://www.google.se/search*"
          "https://www.google.com.sg/search*"
          "https://www.google.sh/search*"
          "https://www.google.si/search*"
          "https://www.google.sk/search*"
          "https://www.google.com.sl/search*"
          "https://www.google.sn/search*"
          "https://www.google.so/search*"
          "https://www.google.sm/search*"
          "https://www.google.sr/search*"
          "https://www.google.st/search*"
          "https://www.google.com.sv/search*"
          "https://www.google.td/search*"
          "https://www.google.tg/search*"
          "https://www.google.co.th/search*"
          "https://www.google.com.tj/search*"
          "https://www.google.tl/search*"
          "https://www.google.tm/search*"
          "https://www.google.tn/search*"
          "https://www.google.to/search*"
          "https://www.google.com.tr/search*"
          "https://www.google.tt/search*"
          "https://www.google.com.tw/search*"
          "https://www.google.co.tz/search*"
          "https://www.google.com.ua/search*"
          "https://www.google.co.ug/search*"
          "https://www.google.co.uk/search*"
          "https://www.google.com.uy/search*"
          "https://www.google.co.uz/search*"
          "https://www.google.com.vc/search*"
          "https://www.google.co.ve/search*"
          "https://www.google.vg/search*"
          "https://www.google.co.vi/search*"
          "https://www.google.com.vn/search*"
          "https://www.google.vu/search*"
          "https://www.google.ws/search*"
          "https://www.google.rs/search*"
          "https://www.google.co.za/search*"
          "https://www.google.co.zm/search*"
          "https://www.google.co.zw/search*"
          "https://www.google.cat/search*"
        ];
        platforms = platforms.all;
      };
    };
    "inkah" = buildFirefoxXpiAddon {
      pname = "inkah";
      version = "1.0.43";
      addonId = "{de5bbbad-7c53-468e-9d8d-9d737cf5ba81}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4042120/inkah-1.0.43.xpi";
      sha256 = "1288b01b67be6bd6930fb45b969ece86547bc696619754911f4183b5daa05d5a";
      meta = with lib;
      {
        homepage = "https://www.inkah.com";
        description = "Look up Chinese &amp; Korean words. Split sentences into their individual words. Learn while browsing the web by hovering words and learn from Youtube and Netflix with double subtitles.";
        license = {
          shortName = "inkah";
          fullName = "Inkah Terms of Service";
          url = "https://www.inkah.com/terms-of";
          free = false;
        };
        mozPermissions = [ "storage" "tabs" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "instapaper-official" = buildFirefoxXpiAddon {
      pname = "instapaper-official";
      version = "3.1.3";
      addonId = "{d0210f13-a970-4f1e-8322-0f76ec80adde}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4381949/instapaper_official-3.1.3.xpi";
      sha256 = "ce344ecddaf1e894b628345b909224b4120528d94844d6ef10abdbdd88b43ba1";
      meta = with lib;
      {
        description = "Instapaper is a simple tool for saving web pages to read later on your iPhone, iPad, Android, computer, or Kindle. The Instapaper browser extension may be used to save the current page directly into your Instapaper account.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "storage"
          "activeTab"
          "contextMenus"
          "http://*/*"
          "https://*/*"
          "http://twitter.com/*"
          "https://twitter.com/*"
          "http://x.com/*"
          "https://x.com/*"
          "https://news.ycombinator.com/*"
          "https://lobste.rs/*"
        ];
        platforms = platforms.all;
      };
    };
    "ipfs-companion" = buildFirefoxXpiAddon {
      pname = "ipfs-companion";
      version = "3.3.0";
      addonId = "ipfs-firefox-addon@lidel.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4587033/ipfs_companion-3.3.0.xpi";
      sha256 = "9e4de48314886a9d6b69bfb1c4903802669dbf50406da6c7a14949ceec788a1e";
      meta = with lib;
      {
        homepage = "https://github.com/ipfs/ipfs-companion";
        description = "Harness the power of IPFS in your browser";
        license = licenses.cc0;
        mozPermissions = [
          "alarms"
          "idle"
          "tabs"
          "notifications"
          "proxy"
          "storage"
          "unlimitedStorage"
          "contextMenus"
          "clipboardWrite"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
        ];
        platforms = platforms.all;
      };
    };
    "ipvfoo" = buildFirefoxXpiAddon {
      pname = "ipvfoo";
      version = "2.29";
      addonId = "ipvfoo@pmarks.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4609505/ipvfoo-2.29.xpi";
      sha256 = "35b7c9802dca0931e0e107c6d50e6786c7dfe3cc8c31c8b1d4a8018f32bf33b8";
      meta = with lib;
      {
        homepage = "https://github.com/pmarks-net/ipvfoo";
        description = "Display the server IP address, with a realtime summary of IPv4, IPv6, and HTTPS information across all page elements.";
        license = licenses.asl20;
        mozPermissions = [
          "contextMenus"
          "storage"
          "webNavigation"
          "webRequest"
        ];
        platforms = platforms.all;
      };
    };
    "istilldontcareaboutcookies" = buildFirefoxXpiAddon {
      pname = "istilldontcareaboutcookies";
      version = "1.1.7";
      addonId = "idcac-pub@guus.ninja";
      url = "https://addons.mozilla.org/firefox/downloads/file/4606669/istilldontcareaboutcookies-1.1.7.xpi";
      sha256 = "159754a3dea6538e0433db5b06bdafdf1d86d6df93ed01f21a9b1da200c8e1a9";
      meta = with lib;
      {
        homepage = "https://github.com/OhMyGuus/I-Dont-Care-About-Cookies";
        description = "Community version of the popular extension \"I don't care about cookies\"  \n\nhttps://github.com/OhMyGuus/I-Dont-Care-About-Cookies";
        license = licenses.gpl3;
        mozPermissions = [
          "tabs"
          "storage"
          "http://*/*"
          "https://*/*"
          "notifications"
          "webRequest"
          "webRequestBlocking"
          "webNavigation"
        ];
        platforms = platforms.all;
      };
    };
    "jabref" = buildFirefoxXpiAddon {
      pname = "jabref";
      version = "2.5";
      addonId = "@jabfox";
      url = "https://addons.mozilla.org/firefox/downloads/file/3898690/jabref-2.5.xpi";
      sha256 = "959f38cdf9fcc516261105947bbbf0356693b05a5e8024f2e9fd044566b120a1";
      meta = with lib;
      {
        homepage = "http://www.jabref.org/";
        description = "Browser extension for users of the bibliographic reference manager JabRef.\nIt automatically identifies and extracts bibliographic information on websites and sends them to JabRef with one click.";
        license = licenses.agpl3Plus;
        mozPermissions = [
          "<all_urls>"
          "activeTab"
          "tabs"
          "webNavigation"
          "storage"
          "nativeMessaging"
          "http://*/*"
          "https://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "javascript-restrictor" = buildFirefoxXpiAddon {
      pname = "javascript-restrictor";
      version = "0.21";
      addonId = "jsr@javascriptrestrictor";
      url = "https://addons.mozilla.org/firefox/downloads/file/4515410/javascript_restrictor-0.21.xpi";
      sha256 = "5f032f9f3bd06f20f0470ca51ae3e538cbbf3d123294dbed91eef1d9b36c2b71";
      meta = with lib;
      {
        homepage = "https://jshelter.org";
        description = "JShelter controls the APIs provided by the browser. The goal is to improve the privacy and security of the user running the extension.";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "tabs"
          "webRequest"
          "webRequestBlocking"
          "webNavigation"
          "dns"
          "<all_urls>"
          "notifications"
        ];
        platforms = platforms.all;
      };
    };
    "joplin-web-clipper" = buildFirefoxXpiAddon {
      pname = "joplin-web-clipper";
      version = "2.11.2";
      addonId = "{8419486a-54e9-11e8-9401-ac9e17909436}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4094039/joplin_web_clipper-2.11.2.xpi";
      sha256 = "ed95819cd4ecab2c6d002debba8c333a7646274a51d4cf9b9da4a0385cb91a24";
      meta = with lib;
      {
        homepage = "https://joplinapp.org";
        description = "Capture and save web pages and screenshots from your browser to Joplin. The Joplin application is required to get this extension working - https://joplinapp.org";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "tabs"
          "http://*/"
          "https://*/"
          "<all_urls>"
          "storage"
        ];
        platforms = platforms.all;
      };
    };
    "js-search-extension" = buildFirefoxXpiAddon {
      pname = "js-search-extension";
      version = "0.1";
      addonId = "{479ec4ee-fd16-4f95-b172-dd39fbd921ad}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3718212/js_search_extension-0.1.xpi";
      sha256 = "07d68e168d7137434cf5096efed581daa836a31096b0ca3f39a76a58e08b3ff5";
      meta = with lib;
      {
        homepage = "https://js.extension.sh";
        description = "The ultimate search extension for Javascript!";
        mozPermissions = [ "tabs" ];
        platforms = platforms.all;
      };
    };
    "jump-cutter" = buildFirefoxXpiAddon {
      pname = "jump-cutter";
      version = "1.31.0";
      addonId = "jump-cutter@example.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4589595/jump_cutter-1.31.0.xpi";
      sha256 = "cd05deda9ad8c3bb39456a2f30318f8c85f46558bcde57b3f500e3837fb10064";
      meta = with lib;
      {
        description = "Watch videos up to 2x faster by automatically skipping long pauses between sentences";
        license = licenses.agpl3Plus;
        mozPermissions = [ "storage" "scripting" "http://*/*" "https://*/*" ];
        platforms = platforms.all;
      };
    };
    "justdeleteme" = buildFirefoxXpiAddon {
      pname = "justdeleteme";
      version = "1.6.0";
      addonId = "{6f54ad3f-042f-408f-8f06-ab631fe1a64f}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4525473/justdeleteme-1.6.0.xpi";
      sha256 = "6341537b3e6eea6135d3e1d19db6a2ac0304bf0bdb5f86179f1ea16d7ca21179";
      meta = with lib;
      {
        description = "JustDeleteMe.xyz extension for Firefox-based browsers.";
        license = licenses.mit;
        mozPermissions = [ "activeTab" "<all_urls>" "webNavigation" ];
        platforms = platforms.all;
      };
    };
    "kagi-privacy-pass" = buildFirefoxXpiAddon {
      pname = "kagi-privacy-pass";
      version = "1.0.8";
      addonId = "privacypass@kagi.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4590992/kagi_privacy_pass-1.0.8.xpi";
      sha256 = "cef78a0a5ac989e0c6f32602a9a45e5a0f760591f9bd0ee4d1f6603c5b9a4018";
      meta = with lib;
      {
        homepage = "https://kagi.com";
        description = "Enables use of Privacy Pass to authenticate with Kagi Search.";
        license = licenses.mit;
        mozPermissions = [
          "declarativeNetRequestWithHostAccess"
          "storage"
          "alarms"
          "webRequest"
          "cookies"
        ];
        platforms = platforms.all;
      };
    };
    "kagi-search" = buildFirefoxXpiAddon {
      pname = "kagi-search";
      version = "0.7.6";
      addonId = "search@kagi.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4429158/kagi_search_for_firefox-0.7.6.xpi";
      sha256 = "51cac0f2f57e3d7671d502df66a6019a8ed3a280e690249f09dcda0fb570990f";
      meta = with lib;
      {
        homepage = "https://kagi.com";
        description = "A simple helper extension for setting Kagi as a default search engine, and automatically logging in to Kagi in private browsing windows.";
        license = licenses.mit;
        mozPermissions = [
          "cookies"
          "declarativeNetRequestWithHostAccess"
          "webRequest"
          "storage"
          "contextMenus"
        ];
        platforms = platforms.all;
      };
    };
    "kagi-translate" = buildFirefoxXpiAddon {
      pname = "kagi-translate";
      version = "0.1.3";
      addonId = "{bd6be57d-91d7-41d2-b61d-3ba20f7942e5}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4588125/kagi_translate-0.1.3.xpi";
      sha256 = "0e79ee54425895ef2e26c43ec29c9cc07588f04c8c24bd45664f27d2e026262b";
      meta = with lib;
      {
        homepage = "https://kagi.com";
        description = "Translate text and webpages directly in your browser using Kagi's private translation engine. No tracking, no data collection.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "storage"
          "contextMenus"
          "cookies"
          "scripting"
          "notifications"
          "webNavigation"
          "https://*/*"
          "http://*/*"
          "*://*/*"
          "*://www.youtube.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "karakeep" = buildFirefoxXpiAddon {
      pname = "karakeep";
      version = "1.2.6";
      addonId = "addon@karakeep.app";
      url = "https://addons.mozilla.org/firefox/downloads/file/4509061/karakeep-1.2.6.xpi";
      sha256 = "d3c2fbf3bb81a827a32f8f7385134036bc0cafd5d8102163073e6144be442734";
      meta = with lib;
      {
        homepage = "https://karakeep.app";
        description = "An extension to bookmark links to karakeep.app";
        license = licenses.agpl3Only;
        mozPermissions = [ "storage" "tabs" "contextMenus" ];
        platforms = platforms.all;
      };
    };
    "keepa" = buildFirefoxXpiAddon {
      pname = "keepa";
      version = "4.19";
      addonId = "amptra@keepa.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4257674/keepa-4.19.xpi";
      sha256 = "7fe354647e4a4074812c272bd70d2fa59ee6fefe2c2228fc21f6c1f76619f283";
      meta = with lib;
      {
        homepage = "https://Keepa.com";
        description = "→ Price History charts \n→ Price Drop &amp; Availability Alerts\n→ Over 1 billion tracked products\n→ Supports Amazon .com | .co.uk | .de | .co.jp | .fr | .ca | .it | .es | .in | .mx";
        license = {
          shortName = "keepa";
          fullName = "License for Keepa.com - Amazon Price Tracker";
          url = "https://addons.mozilla.org/en-CA/firefox/addon/keepa/license/";
          free = false;
        };
        mozPermissions = [
          "notifications"
          "cookies"
          "webRequest"
          "webRequestBlocking"
          "storage"
          "contextMenus"
          "*://*.keepa.com/*"
          "*://*.amazon.com/*"
          "*://*.amzn.com/*"
          "*://*.amazon.co.uk/*"
          "*://*.amazon.de/*"
          "*://*.amazon.fr/*"
          "*://*.amazon.it/*"
          "*://*.amazon.ca/*"
          "*://*.amazon.com.mx/*"
          "*://*.amazon.es/*"
          "*://*.amazon.cn/*"
          "*://*.amazon.co.jp/*"
          "*://*.amazon.in/*"
          "*://*.amazon.com.br/*"
          "*://*.amazon.nl/*"
          "*://*.amazon.com.au/*"
        ];
        platforms = platforms.all;
      };
    };
    "keepass-helper" = buildFirefoxXpiAddon {
      pname = "keepass-helper";
      version = "1.4resigned1";
      addonId = "{e56fa932-ad2c-4cfa-b0d7-a35db1d9b0f6}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4273653/keepass_helper_url_in_title-1.4resigned1.xpi";
      sha256 = "8811193376573323610d0c1bd043c3977b6fa15fd804b37b0c4749aa9aed1fab";
      meta = with lib;
      {
        description = "Puts a hostname or a URL in the window title.\nIt does not modify the title of a tab, just the window title.\nIt does not inject any JavaScript code to a website, so it can't corrupt, nor can it be corrupted by it.";
        license = licenses.mpl20;
        mozPermissions = [ "tabs" "storage" ];
        platforms = platforms.all;
      };
    };
    "keepassxc-browser" = buildFirefoxXpiAddon {
      pname = "keepassxc-browser";
      version = "1.9.10";
      addonId = "keepassxc-browser@keepassxc.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4592023/keepassxc_browser-1.9.10.xpi";
      sha256 = "38926e2225ba92da0962e6675a90e1e9bf1e3b280b88014c27f3aa727f212542";
      meta = with lib;
      {
        homepage = "https://keepassxc.org/";
        description = "Official browser plugin for the KeePassXC password manager (https://keepassxc.org).";
        license = licenses.gpl3;
        mozPermissions = [
          "activeTab"
          "clipboardWrite"
          "contextMenus"
          "cookies"
          "nativeMessaging"
          "notifications"
          "storage"
          "tabs"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "https://*/*"
          "http://*/*"
          "https://api.github.com/"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "keeper-password-manager" = buildFirefoxXpiAddon {
      pname = "keeper-password-manager";
      version = "17.3.1";
      addonId = "KeeperFFStoreExtension@KeeperSecurityInc";
      url = "https://addons.mozilla.org/firefox/downloads/file/4603743/keeper_password_manager-17.3.1_QL4elsD.xpi";
      sha256 = "5cd5d84b6dc580154b4786ebc53f868b72bd881508b27e6ec95c2c47f6062245";
      meta = with lib;
      {
        homepage = "http://keepersecurity.com/";
        description = "Protect and autofill passwords with the world's most trusted and #1 downloaded secure password manager and digital vault.";
        license = {
          shortName = "keeper-password-manager";
          fullName = "End-User License Agreement for Keeper® Password Manager & Digital Vault";
          url = "https://addons.mozilla.org/en-US/firefox/addon/keeper-password-manager/eula/";
          free = false;
        };
        mozPermissions = [
          "contextMenus"
          "tabs"
          "alarms"
          "idle"
          "storage"
          "browsingData"
          "webNavigation"
          "scripting"
          "clipboardWrite"
          "http://*/*"
          "https://*/*"
          "webRequest"
          "webRequestBlocking"
          "<all_urls>"
          "https://keepersecurity.com/vault/*"
          "https://keepersecurity.eu/vault/*"
          "https://keepersecurity.com.au/vault/*"
          "https://keepersecurity.ca/vault/*"
          "https://keepersecurity.jp/vault/*"
          "https://govcloud.keepersecurity.us/vault/*"
        ];
        platforms = platforms.all;
      };
    };
    "keybase" = buildFirefoxXpiAddon {
      pname = "keybase";
      version = "1.10.17resigned1";
      addonId = "keybase@keybase.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/4272716/keybase_for_firefox-1.10.17resigned1.xpi";
      sha256 = "b401ae32963446ad03a37d4e57619e785c74b1522e85430176765117064edd46";
      meta = with lib;
      {
        homepage = "https://keybase.io/docs/extension";
        description = "A secure chat button for every profile.";
        license = licenses.bsd2;
        mozPermissions = [
          "activeTab"
          "contextMenus"
          "declarativeContent"
          "nativeMessaging"
          "storage"
          "https://reddit.com/*"
          "https://*.reddit.com/*"
          "https://twitter.com/*"
          "https://www.facebook.com/*"
          "https://github.com/*"
          "https://news.ycombinator.com/user*"
          "https://keybase.io/*"
        ];
        platforms = platforms.all;
      };
    };
    "kiss-translator" = buildFirefoxXpiAddon {
      pname = "kiss-translator";
      version = "2.0.5";
      addonId = "{fb25c100-22ce-4d5a-be7e-75f3d6f0fc13}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4610158/kiss_translator-2.0.5.xpi";
      sha256 = "9b69f81424492813bace4344fba9c275ebbc503d6f0a3e4fff5772eb2ddac17a";
      meta = with lib;
      {
        homepage = "https://github.com/fishjar/kiss-translator";
        description = "A simple bilingual translation extension &amp; Greasemonkey script";
        license = licenses.gpl3;
        mozPermissions = [
          "<all_urls>"
          "storage"
          "contextMenus"
          "scripting"
          "declarativeNetRequest"
          "file://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "kristofferhagen-nord-theme" = buildFirefoxXpiAddon {
      pname = "kristofferhagen-nord-theme";
      version = "2.0";
      addonId = "{e410fec2-1cbd-4098-9944-e21e708418af}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3365523/kristofferhagen_nord_theme-2.0.xpi";
      sha256 = "60b123e10d4e99deed1c4414ac784664ae5e0e0c196cd8610c468f2fa116c935";
      meta = with lib;
      {
        homepage = "https://github.com/kristofferhagen/firefox-nord-theme";
        description = "Firefox theme inspired by https://www.nordtheme.com/";
        license = licenses.cc-by-30;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "laboratory-by-mozilla" = buildFirefoxXpiAddon {
      pname = "laboratory-by-mozilla";
      version = "3.0.8";
      addonId = "1b2383b324c8520974ee097e46301d5ca4e076de387c02886f1c6b1503671586@pokeinthe.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/3716439/laboratory_by_mozilla-3.0.8.xpi";
      sha256 = "b75b09012587686df87afef671bf9f0e27a9812e94781d425032a36f38a5aba2";
      meta = with lib;
      {
        homepage = "https://github.com/april/laboratory";
        description = "Because good website security shouldn't only be available to mad scientists! Laboratory is a WebExtension that helps you generate a Content Security Policy (CSP) header for your website.";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "tabs"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "ftp://*/*"
          "http://*/*"
          "https://*/*"
          "ws://*/*"
          "wss://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "languagetool" = buildFirefoxXpiAddon {
      pname = "languagetool";
      version = "9.0.1";
      addonId = "languagetool-webextension@languagetool.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4538560/languagetool-9.0.1.xpi";
      sha256 = "c3dffe8754fe377a641fd54ed5858246efc0358212356a20b1dcfca14530fa95";
      meta = with lib;
      {
        homepage = "https://languagetool.org";
        description = "With this extension you can check text with the free style and grammar checker LanguageTool. It finds many errors that a simple spell checker cannot detect, like mixing up there/their, a/an, or repeating a word.";
        license = {
          shortName = "languagetool";
          fullName = "Custom License for LanguageTool";
          url = "https://languagetool.org/legal/";
          free = false;
        };
        mozPermissions = [
          "activeTab"
          "storage"
          "contextMenus"
          "scripting"
          "alarms"
          "http://*/*"
          "https://*/*"
          "file:///*"
          "*://docs.google.com/document/*"
          "*://docs.google.com/presentation/*"
          "*://languagetool.org/*"
        ];
        platforms = platforms.all;
      };
    };
    "lastpass-password-manager" = buildFirefoxXpiAddon {
      pname = "lastpass-password-manager";
      version = "4.147.2";
      addonId = "support@lastpass.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4602959/lastpass_password_manager-4.147.2.xpi";
      sha256 = "bb779789289e7fc39f1590d933bc6b1ac59e096ae537a55bb1ae4947f196cea0";
      meta = with lib;
      {
        homepage = "https://lastpass.com/";
        description = "LastPass, an award-winning password manager, saves your passwords and gives you secure access from every computer and mobile device.";
        license = {
          shortName = "unfree";
          fullName = "Unfree";
          url = "https://addons.mozilla.org/en-US/firefox/addon/lastpass-password-manager/license/";
          free = false;
        };
        mozPermissions = [
          "tabs"
          "idle"
          "notifications"
          "contextMenus"
          "scripting"
          "storage"
          "nativeMessaging"
          "privacy"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "alarms"
          "http://*/*"
          "https://*/*"
          "https://lastpass.com/vault/*"
          "https://lastpass.com/migrate/*"
          "https://lastpass.com/*"
          "https://backoffice.lastpass.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "leechblock-ng" = buildFirefoxXpiAddon {
      pname = "leechblock-ng";
      version = "1.7.1";
      addonId = "leechblockng@proginosko.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4601510/leechblock_ng-1.7.1.xpi";
      sha256 = "e24b5d92d1b23ed23223a2283e29de125905313004ebf598012c37ea92a4e81c";
      meta = with lib;
      {
        homepage = "https://www.proginosko.com/leechblock/";
        description = "LeechBlock NG is a simple productivity tool designed to block those time-wasting sites that can suck the life out of your working day. All you need to do is specify which sites to block and when to block them.";
        license = licenses.mpl20;
        mozPermissions = [
          "alarms"
          "menus"
          "storage"
          "tabs"
          "unlimitedStorage"
          "webNavigation"
          "<all_urls>"
          "*://*/*lb-custom*"
        ];
        platforms = platforms.all;
      };
    };
    "lesspass" = buildFirefoxXpiAddon {
      pname = "lesspass";
      version = "11.0.10";
      addonId = "contact@lesspass.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4469049/lesspass-11.0.10.xpi";
      sha256 = "2bc5fef7c74f770b2b2394fcbc7cd758a219f158784aaffff63c1942f96f38e8";
      meta = with lib;
      {
        homepage = "https://github.com/lesspass/lesspass";
        description = "Use LessPass add-on to generate complex passwords and log in  automatically to all your sites";
        license = licenses.gpl3;
        mozPermissions = [ "activeTab" ];
        platforms = platforms.all;
      };
    };
    "lexicon" = buildFirefoxXpiAddon {
      pname = "lexicon";
      version = "1.7.0";
      addonId = "{b2f51f6b-a485-43dd-bebd-eb1ea3e9d9d2}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4457540/lexicon-1.7.0.xpi";
      sha256 = "57cffe22da553de6d1661d3eba60624d7736a3510fc1ea5247961583ba62463d";
      meta = with lib;
      {
        homepage = "https://github.com/akvedi/lexicon";
        description = "Quickly Define Words While You Browse By Just Double Clicking On The Word, Create and Organize Your Own Word Bank With Personal Dictionary";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "https://www.google.com/"
          "https://www.bing.com/"
          "contextMenus"
          "activeTab"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "libkey-nomad" = buildFirefoxXpiAddon {
      pname = "libkey-nomad";
      version = "1.50.0";
      addonId = "{f282d54d-83cc-45f5-b3e5-65888de1682b}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4580919/libkey_nomad-1.50.0.xpi";
      sha256 = "5050bb7a72c1682164cc4d7a518e12ebef6fb769f6967ee4df7216b0e1067d16";
      meta = with lib;
      {
        homepage = "https://thirdiron.com/libkey-nomad/";
        description = "One-click access to millions of scholarly articles.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "storage"
          "alarms"
          "http://*/*"
          "https://*/*"
          "file://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "libredirect" = buildFirefoxXpiAddon {
      pname = "libredirect";
      version = "3.2.0";
      addonId = "7esoorv3@alefvanoon.anonaddy.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/4522826/libredirect-3.2.0.xpi";
      sha256 = "ba4cf8fe97275d7082fea085a09796481122845455df1af524a7210fff3ecf3c";
      meta = with lib;
      {
        homepage = "https://libredirect.github.io";
        description = "Redirects YouTube, Twitter, TikTok... requests to alternative privacy friendly frontends.";
        license = licenses.gpl3;
        mozPermissions = [
          "webRequest"
          "webRequestBlocking"
          "storage"
          "clipboardWrite"
          "contextMenus"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "limit-limit-distracting-sites" = buildFirefoxXpiAddon {
      pname = "limit-limit-distracting-sites";
      version = "0.1.4";
      addonId = "{26ebede3-10ce-443c-bb0e-7f490cad0ec8}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3531148/limit_limit_distracting_sites-0.1.4.xpi";
      sha256 = "2e56919cab89815e80e4f0119d950e542697eb0b8dc1d63bfb9e34ccc80ad0bf";
      meta = with lib;
      {
        homepage = "https://freedom.to";
        description = "Limit your time spent on distracting sites. Limit is an extension that allows you to set time limits for distracting websites.";
        license = {
          shortName = "unfree";
          fullName = "Unfree";
          url = "https://freedom.to/terms";
          free = false;
        };
        mozPermissions = [
          "tabs"
          "activeTab"
          "storage"
          "idle"
          "notifications"
          "*://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "lingq-importer2" = buildFirefoxXpiAddon {
      pname = "lingq-importer2";
      version = "2.3.32";
      addonId = "{e84c7711-c738-409a-879d-3f20cb087563}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4592753/lingq_importer2-2.3.32.xpi";
      sha256 = "16209f88e27d1f5573176edb518167d4c3e894c12799788fad5c7898221b0579";
      meta = with lib;
      {
        homepage = "https://www.lingq.com/";
        description = "Automatically import foreign language pages, videos, movies from the web &amp; study them with LingQ's web &amp; mobile language learning apps.";
        license = licenses.gpl3;
        mozPermissions = [
          "activeTab"
          "cookies"
          "storage"
          "scripting"
          "https://*.netflix.com/*"
          "https://*.primevideo.com/*"
          "https://*.youtube.com/*"
          "https://*.lingq.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "link-cleaner" = buildFirefoxXpiAddon {
      pname = "link-cleaner";
      version = "1.6resigned1";
      addonId = "{6d85dea2-0fb4-4de3-9f8c-264bce9a2296}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4272011/link_cleaner-1.6resigned1.xpi";
      sha256 = "16dbaf948c31ed586e64301d5809d7b11dd07014bf5edb5f7b1b4bfa30d40ff0";
      meta = with lib;
      {
        homepage = "https://github.com/idlewan/link_cleaner";
        description = "Clean URLs that are about to be visited:\n- removes utm_* parameters\n- on item pages of aliexpress and amazon, removes tracking parameters\n- skip redirect pages of facebook, steam and reddit";
        license = licenses.gpl3;
        mozPermissions = [ "<all_urls>" "webRequest" "webRequestBlocking" ];
        platforms = platforms.all;
      };
    };
    "link-gopher" = buildFirefoxXpiAddon {
      pname = "link-gopher";
      version = "2.6.2";
      addonId = "linkgopher@oooninja.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4183832/link_gopher-2.6.2.xpi";
      sha256 = "66f9bb417854da5bc1d0174aa3bb81ecff61c11b043f54af17ad99e8d40ab969";
      meta = with lib;
      {
        homepage = "http://sites.google.com/site/linkgopher/";
        description = "Extracts all links from web page, sorts them, removes duplicates, and displays them in a new tab for inspection or copy and paste into other systems.";
        license = licenses.gpl3;
        mozPermissions = [ "scripting" ];
        platforms = platforms.all;
      };
    };
    "linkding-extension" = buildFirefoxXpiAddon {
      pname = "linkding-extension";
      version = "1.15.0";
      addonId = "{61a05c39-ad45-4086-946f-32adb0a40a9d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4591150/linkding_extension-1.15.0.xpi";
      sha256 = "e862a55951621d74cdf26cb6b70bad63e4391855c98b78bf3dca2c45899492b7";
      meta = with lib;
      {
        homepage = "https://github.com/sissbruecker/linkding-extension/";
        description = "Companion extension for the linkding bookmark manager";
        license = licenses.mit;
        mozPermissions = [
          "tabs"
          "storage"
          "contextMenus"
          "http://*/*"
          "https://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "linkding-injector" = buildFirefoxXpiAddon {
      pname = "linkding-injector";
      version = "1.3.6";
      addonId = "{19561335-5a63-4b4e-8182-1eced17f9b47}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4606187/linkding_injector-1.3.6.xpi";
      sha256 = "32bb0e9560fa07a6dccdd8dcbfec687bdd3545e1a4ee5e078d41e785575545dd";
      meta = with lib;
      {
        homepage = "https://github.com/Fivefold/linkding-injector";
        description = "Injects search results from the linkding bookmark service into search pages like google and duckduckgo";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "*://duckduckgo.com/*"
          "*://search.brave.com/*"
          "*://kagi.com/*"
          "*://www.qwant.com/*"
          "*://*/search?*"
          "*://*/search"
          "*://*.google.com/*"
          "*://*.google.ad/*"
          "*://*.google.ae/*"
          "*://*.google.com.af/*"
          "*://*.google.com.ag/*"
          "*://*.google.com.ai/*"
          "*://*.google.al/*"
          "*://*.google.am/*"
          "*://*.google.co.ao/*"
          "*://*.google.com.ar/*"
          "*://*.google.as/*"
          "*://*.google.at/*"
          "*://*.google.com.au/*"
          "*://*.google.az/*"
          "*://*.google.ba/*"
          "*://*.google.com.bd/*"
          "*://*.google.be/*"
          "*://*.google.bf/*"
          "*://*.google.bg/*"
          "*://*.google.com.bh/*"
          "*://*.google.bi/*"
          "*://*.google.bj/*"
          "*://*.google.com.bn/*"
          "*://*.google.com.bo/*"
          "*://*.google.com.br/*"
          "*://*.google.bs/*"
          "*://*.google.bt/*"
          "*://*.google.co.bw/*"
          "*://*.google.by/*"
          "*://*.google.com.bz/*"
          "*://*.google.ca/*"
          "*://*.google.cd/*"
          "*://*.google.cf/*"
          "*://*.google.cg/*"
          "*://*.google.ch/*"
          "*://*.google.ci/*"
          "*://*.google.co.ck/*"
          "*://*.google.cl/*"
          "*://*.google.cm/*"
          "*://*.google.cn/*"
          "*://*.google.com.co/*"
          "*://*.google.co.cr/*"
          "*://*.google.com.cu/*"
          "*://*.google.cv/*"
          "*://*.google.com.cy/*"
          "*://*.google.cz/*"
          "*://*.google.de/*"
          "*://*.google.dj/*"
          "*://*.google.dk/*"
          "*://*.google.dm/*"
          "*://*.google.com.do/*"
          "*://*.google.dz/*"
          "*://*.google.com.ec/*"
          "*://*.google.ee/*"
          "*://*.google.com.eg/*"
          "*://*.google.es/*"
          "*://*.google.com.et/*"
          "*://*.google.fi/*"
          "*://*.google.com.fj/*"
          "*://*.google.fm/*"
          "*://*.google.fr/*"
          "*://*.google.ga/*"
          "*://*.google.ge/*"
          "*://*.google.gg/*"
          "*://*.google.com.gh/*"
          "*://*.google.com.gi/*"
          "*://*.google.gl/*"
          "*://*.google.gm/*"
          "*://*.google.gr/*"
          "*://*.google.com.gt/*"
          "*://*.google.gy/*"
          "*://*.google.com.hk/*"
          "*://*.google.hn/*"
          "*://*.google.hr/*"
          "*://*.google.ht/*"
          "*://*.google.hu/*"
          "*://*.google.co.id/*"
          "*://*.google.ie/*"
          "*://*.google.co.il/*"
          "*://*.google.im/*"
          "*://*.google.coIn/*"
          "*://*.google.iq/*"
          "*://*.google.is/*"
          "*://*.google.it/*"
          "*://*.google.je/*"
          "*://*.google.com.jm/*"
          "*://*.google.jo/*"
          "*://*.google.co.jp/*"
          "*://*.google.co.ke/*"
          "*://*.google.com.kh/*"
          "*://*.google.ki/*"
          "*://*.google.kg/*"
          "*://*.google.co.kr/*"
          "*://*.google.com.kw/*"
          "*://*.google.kz/*"
          "*://*.google.la/*"
          "*://*.google.com.lb/*"
          "*://*.google.li/*"
          "*://*.google.lk/*"
          "*://*.google.co.ls/*"
          "*://*.google.lt/*"
          "*://*.google.lu/*"
          "*://*.google.lv/*"
          "*://*.google.com.ly/*"
          "*://*.google.co.ma/*"
          "*://*.google.md/*"
          "*://*.google.me/*"
          "*://*.google.mg/*"
          "*://*.google.mk/*"
          "*://*.google.ml/*"
          "*://*.google.com.mm/*"
          "*://*.google.mn/*"
          "*://*.google.ms/*"
          "*://*.google.com.mt/*"
          "*://*.google.mu/*"
          "*://*.google.mv/*"
          "*://*.google.mw/*"
          "*://*.google.com.mx/*"
          "*://*.google.com.my/*"
          "*://*.google.co.mz/*"
          "*://*.google.com.na/*"
          "*://*.google.com.ng/*"
          "*://*.google.com.ni/*"
          "*://*.google.ne/*"
          "*://*.google.nl/*"
          "*://*.google.no/*"
          "*://*.google.com.np/*"
          "*://*.google.nr/*"
          "*://*.google.nu/*"
          "*://*.google.co.nz/*"
          "*://*.google.com.om/*"
          "*://*.google.com.pa/*"
          "*://*.google.com.pe/*"
          "*://*.google.com.pg/*"
          "*://*.google.com.ph/*"
          "*://*.google.com.pk/*"
          "*://*.google.pl/*"
          "*://*.google.pn/*"
          "*://*.google.com.pr/*"
          "*://*.google.ps/*"
          "*://*.google.pt/*"
          "*://*.google.com.py/*"
          "*://*.google.com.qa/*"
          "*://*.google.ro/*"
          "*://*.google.ru/*"
          "*://*.google.rw/*"
          "*://*.google.com.sa/*"
          "*://*.google.com.sb/*"
          "*://*.google.sc/*"
          "*://*.google.se/*"
          "*://*.google.com.sg/*"
          "*://*.google.sh/*"
          "*://*.google.si/*"
          "*://*.google.sk/*"
          "*://*.google.com.sl/*"
          "*://*.google.sn/*"
          "*://*.google.so/*"
          "*://*.google.sm/*"
          "*://*.google.sr/*"
          "*://*.google.st/*"
          "*://*.google.com.sv/*"
          "*://*.google.td/*"
          "*://*.google.tg/*"
          "*://*.google.co.th/*"
          "*://*.google.com.tj/*"
          "*://*.google.tl/*"
          "*://*.google.tm/*"
          "*://*.google.tn/*"
          "*://*.google.to/*"
          "*://*.google.com.tr/*"
          "*://*.google.tt/*"
          "*://*.google.com.tw/*"
          "*://*.google.co.tz/*"
          "*://*.google.com.ua/*"
          "*://*.google.co.ug/*"
          "*://*.google.co.uk/*"
          "*://*.google.com.uy/*"
          "*://*.google.co.uz/*"
          "*://*.google.com.vc/*"
          "*://*.google.co.ve/*"
          "*://*.google.vg/*"
          "*://*.google.co.vi/*"
          "*://*.google.com.vn/*"
          "*://*.google.vu/*"
          "*://*.google.ws/*"
          "*://*.google.rs/*"
          "*://*.google.co.za/*"
          "*://*.google.co.zm/*"
          "*://*.google.co.zw/*"
          "*://*.google.cat/*"
        ];
        platforms = platforms.all;
      };
    };
    "linkhints" = buildFirefoxXpiAddon {
      pname = "linkhints";
      version = "1.3.3";
      addonId = "linkhints@lydell.github.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/4346988/linkhints-1.3.3.xpi";
      sha256 = "209e50c4f9b9162d5ce0ebf4097518f51ae74129c29d920019497f6323871e6b";
      meta = with lib;
      {
        homepage = "https://lydell.github.io/LinkHints";
        description = "Click with your keyboard.";
        license = licenses.mit;
        mozPermissions = [ "<all_urls>" "storage" ];
        platforms = platforms.all;
      };
    };
    "linkwarden" = buildFirefoxXpiAddon {
      pname = "linkwarden";
      version = "1.3.3";
      addonId = "jordanlinkwarden@gmail.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4485947/linkwarden-1.3.3.xpi";
      sha256 = "4f1f38cf8a86e2b709d4f25c3f3040e4abaa9e2e62f0f5d5a4995eb42d8e0cfd";
      meta = with lib;
      {
        description = "The browser extension for Linkwarden.";
        license = licenses.agpl3Only;
        mozPermissions = [
          "storage"
          "activeTab"
          "tabs"
          "bookmarks"
          "contextMenus"
          "<all_urls>"
          "http://*/*"
          "https://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "livetl" = buildFirefoxXpiAddon {
      pname = "livetl";
      version = "9.0.8";
      addonId = "{ae865fed-3ca7-4701-bb86-f129e77deef5}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4553317/livetl-9.0.8.xpi";
      sha256 = "35b0c499dae8039afc3130e6ae454158b414c894c3d999ec8834d8dbd2769f83";
      meta = with lib;
      {
        homepage = "https://livetl.app/";
        description = "Get live translations for YouTube and Twitch streams, crowdsourced from multilingual viewers!";
        license = licenses.agpl3Only;
        mozPermissions = [
          "storage"
          "webRequest"
          "webRequestBlocking"
          "https://www.youtube.com/*?*"
          "https://www.youtube.com/youtubei/v1/live_chat/get_live_chat/*"
          "https://www.youtube.com/youtubei/v1/live_chat/get_live_chat_replay/*"
          "https://www.twitch.tv/*"
          "https://www.youtube.com/live_chat*"
          "https://www.youtube.com/live_chat_replay*"
          "https://studio.youtube.com/live_chat*"
          "https://studio.youtube.com/live_chat_replay*"
          "https://www.youtube.com/error*?*"
        ];
        platforms = platforms.all;
      };
    };
    "localcdn" = buildFirefoxXpiAddon {
      pname = "localcdn";
      version = "2.6.82";
      addonId = "{b86e4813-687a-43e6-ab65-0bde4ab75758}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4582489/localcdn_fork_of_decentraleyes-2.6.82.xpi";
      sha256 = "2106e0826419eb1877d99c689b9c198bd483bfffab6ab9c3242b3fad674f325c";
      meta = with lib;
      {
        homepage = "https://www.localcdn.org";
        description = "Emulates remote frameworks (e.g. jQuery, Bootstrap, AngularJS) and delivers them as local resource. Prevents unnecessary 3rd party requests to Google, StackPath, MaxCDN and more. Prepared rules for uBlock Origin/uMatrix.";
        license = licenses.mpl20;
        mozPermissions = [
          "*://*/*"
          "privacy"
          "storage"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
        ];
        platforms = platforms.all;
      };
    };
    "lovely-forks" = buildFirefoxXpiAddon {
      pname = "lovely-forks";
      version = "3.7.3";
      addonId = "github-forks-addon@musicallyut.in";
      url = "https://addons.mozilla.org/firefox/downloads/file/4257592/lovely_forks-3.7.3.xpi";
      sha256 = "ab9a444acbaa2bebf1bea88a1d41edd9f35208b05510522ab574fdf4cae3058d";
      meta = with lib;
      {
        homepage = "https://github.com/musically-ut/lovely-forks";
        description = "Show notable forks of Github projects.";
        license = licenses.mpl20;
        mozPermissions = [ "storage" "*://github.com/*" ];
        platforms = platforms.all;
      };
    };
    "mailvelope" = buildFirefoxXpiAddon {
      pname = "mailvelope";
      version = "6.2.0";
      addonId = "jid1-AQqSMBYb0a8ADg@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4600809/mailvelope-6.2.0.xpi";
      sha256 = "3ca29990e1f191977d420d9661c3516f05159b5b4341c7066686b9f71f799080";
      meta = with lib;
      {
        homepage = "https://www.mailvelope.com/";
        description = "Protect your email conversations and attachments on Gmail, Nextcloud, Outlook and more with PGP and end-to-end encryption.";
        license = licenses.gpl3;
        mozPermissions = [
          "alarms"
          "identity"
          "scripting"
          "storage"
          "tabs"
          "webNavigation"
        ];
        platforms = platforms.all;
      };
    };
    "mal-sync" = buildFirefoxXpiAddon {
      pname = "mal-sync";
      version = "0.12.0";
      addonId = "{c84d89d9-a826-4015-957b-affebd9eb603}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4491278/mal_sync-0.12.0.xpi";
      sha256 = "55087d44de5af98a9b74da6ea02b3c7f2d7f45277ee181e8059d3e81ee4092b0";
      meta = with lib;
      {
        homepage = "https://github.com/lolamtisch/MALSync";
        description = "MAL-Sync enables automatic episode tracking between MyAnimeList/Anilist/Kitsu/Simkl and multiple anime streaming websites.";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "alarms"
          "notifications"
          "declarativeNetRequestWithHostAccess"
          "*://myanimelist.net/anime/*"
          "*://myanimelist.net/manga/*"
          "*://myanimelist.net/animelist/*"
          "*://myanimelist.net/mangalist/*"
          "*://myanimelist.net/anime.php?id=*"
          "*://myanimelist.net/manga.php?id=*"
          "*://myanimelist.net/character/*"
          "*://myanimelist.net/people/*"
          "*://myanimelist.net/search/*"
          "*://malsync.moe/mal/oauth*"
          "*://malsync.moe/anilist/oauth*"
          "*://malsync.moe/shikimori/oauth*"
          "*://anilist.co/*"
          "*://kitsu.app/*"
          "*://simkl.com/*"
          "*://malsync.moe/pwa*"
          "*://*.crunchyroll.com/*"
          "*://mangadex.org/*"
          "*://*.gogoanime.tv/*"
          "*://*.gogoanime.io/*"
          "*://*.gogoanime.in/*"
          "*://*.gogoanime.se/*"
          "*://*.gogoanime.sh/*"
          "*://*.gogoanime.video/*"
          "*://*.gogoanime.movie/*"
          "*://*.gogoanime.so/*"
          "*://*.gogoanime.ai/*"
          "*://*.gogoanime.vc/*"
          "*://*.gogoanime.pe/*"
          "*://*.gogoanime.wiki/*"
          "*://*.gogoanime.cm/*"
          "*://*.gogoanime.film/*"
          "*://*.gogoanime.fi/*"
          "*://*.gogoanime.gg/*"
          "*://*.gogoanime.sk/*"
          "*://*.gogoanime.lu/*"
          "*://*.gogoanime.tel/*"
          "*://*.gogoanime.ee/*"
          "*://*.gogoanime.dk/*"
          "*://*.gogoanime.ar/*"
          "*://*.gogoanime.bid/*"
          "*://*.gogoanimes.co/*"
          "*://*.animego.to/*"
          "*://*.gogoanime.gr/*"
          "*://*.gogoanime.llc/*"
          "*://*.gogoanime.cl/*"
          "*://*.gogoanime.hu/*"
          "*://*.gogoanime.vet/*"
          "*://*.gogoanimehd.to/*"
          "*://*.gogoanime3.net/*"
          "*://*.gogoanimehd.io/*"
          "*://*.anitaku.to/*"
          "*://*.anitaku.so/*"
          "*://*.gogoanime3.co/*"
          "*://*.anitaku.pe/*"
          "*://*.gogoanime3.cc/*"
          "*://*.anitaku.bz/*"
          "*://*.www.turkanime.tv/video/*"
          "*://*.www.turkanime.tv/anime/*"
          "*://*.www.turkanime.net/video/*"
          "*://*.www.turkanime.net/anime/*"
          "*://*.www.turkanime.co/video/*"
          "*://*.www.turkanime.co/anime/*"
          "*://app.emby.media/*"
          "*://app.emby.tv/*"
          "*://app.plex.tv/*"
          "*://www.netflix.com/*"
          "*://animepahe.com/play/*"
          "*://animepahe.com/anime/*"
          "*://animepahe.ru/play/*"
          "*://animepahe.ru/anime/*"
          "*://animepahe.org/play/*"
          "*://animepahe.org/anime/*"
          "*://*.animeflv.net/anime/*"
          "*://*.animeflv.net/ver/*"
          "*://jkanime.net/*"
          "*://proxer.me/*"
          "*://proxer.net/*"
          "*://*.aniflix.tv/*"
          "*://*.aniflix.cc/*"
          "*://*.kaas.am/*"
          "*://*.kaas.ro/*"
          "*://*.kaas.to/*"
          "*://*.kickassanime.ro/*"
          "*://*.kickassanime.am/*"
          "*://*.kickassanimes.io/*"
          "*://*.kickassanime.mx/*"
          "*://*.kaa.mx/*"
          "*://shinden.pl/episode/*"
          "*://shinden.pl/series/*"
          "*://shinden.pl/titles/*"
          "*://shinden.pl/epek/*"
          "*://voiranime.com/*"
          "*://*.voiranime.com/*"
          "*://www.viz.com/*"
          "*://www.animezone.pl/odcinki/*"
          "*://www.animezone.pl/odcinek/*"
          "*://www.animezone.pl/anime/*"
          "*://anime-odcinki.pl/anime/*"
          "*://serimanga.com/*"
          "*://mangadenizi.com/*"
          "*://*.mangadenizi.net/*"
          "*://moeclip.com/*"
          "*://mangalivre.net/*"
          "*://tmofans.com/*"
          "*://lectortmo.com/*"
          "*://visortmo.com/*"
          "*://gastronomiaporpaises.com/*"
          "*://releasingcars.com/*"
          "*://mundorecetascuriosas.com/*"
          "*://lupitaalosfogones.com/*"
          "*://cocinarporelmundo.com/*"
          "*://disfrutacocina.com/*"
          "*://recetascuriosas.com/*"
          "*://lacocinadelupita.com/*"
          "*://mynewsrecipes.com/*"
          "*://recipestravelworld.com/*"
          "*://recipestraveling.com/*"
          "*://recetaspaises.com/*"
          "*://worldrecipesu.com/*"
          "*://techinroll.com/*"
          "*://vsrecipes.com/*"
          "*://mygamesinfo.com/*"
          "*://gamesnk.com/*"
          "*://otakuworldgames.com/*"
          "*://animalcanine.com/*"
          "*://cook2love.com/*"
          "*://wtechnews.com/*"
          "*://animationforyou.com/*"
          "*://fanaticmanga.com/*"
          "*://mistermanga.com/*"
          "*://enginepassion.com/*"
          "*://motornk.com/*"
          "*://recipesnk.com/*"
          "*://panicmanga.com/*"
          "*://worldmangas.com/*"
          "*://anitoc.com/*"
          "*://cookerready.com/*"
          "*://cooker2love.com/*"
          "*://infopetworld.com/*"
          "*://infogames2you.com/*"
          "*://almtechnews.com/*"
          "*://animation2you.com/*"
          "*://recipesdo.com/*"
          "*://vgmotor.com/*"
          "*://myotakuinfo.com/*"
          "*://otakworld.com/*"
          "*://cookermania.com/*"
          "*://motorbakery.com/*"
          "*://recipesist.com/*"
          "*://motorpi.com/*"
          "*://dariusmotor.com/*"
          "*://recipesaniki.com/*"
          "*://cocinaconlupita.com/*"
          "*://recetasdelupita.com/*"
          "*://gamesxo.com/*"
          "*://fitfooders.com/*"
          "*://checkingcars.com/*"
          "*://keepfooding.com/*"
          "*://feelthecook.com/*"
          "*://recetchef.com/*"
          "*://motoroilblood.com/*"
          "*://anisurion.com/*"
          "*://recipescoaching.com/*"
          "*://anitirion.com/*"
          "*://cookernice.com/*"
          "*://animalsside.com/*"
          "*://paleomotor.com/*"
          "*://otakunice.com/*"
          "*://sucrecipes.com/*"
          "*://recetasviaje.com/*"
          "*://animalslegacy.com/*"
          "*://worldcuisineis.com/*"
          "*://eligeunnombre.com/*"
          "*://cyclingresolution.com/*"
          "*://comollamarle.com/*"
          "*://fashionandcomplements.com/*"
          "*://gamesnacion.com/*"
          "*://topamotor.com/*"
          "*://motorwithpassion.com/*"
          "*://gamesnewses.com/*"
          "*://technewsroll.com/*"
          "*://infonombre.com/*"
          "*://animationdraw.com/*"
          "*://recetasdegina.com/*"
          "*://mislyfashion.com/*"
          "*://techingro.com/*"
          "*://motoralm.com/*"
          "*://tocanimation.com/*"
          "*://letsmotorgo.com/*"
          "*://zonatmo.com/*"
          "*://mangaplus.shueisha.co.jp/*"
          "*://*.japscan.ws/*"
          "*://www.hulu.com/*"
          "*://www.hidive.com/*"
          "*://mangakatana.com/manga/*"
          "*://*.manga4life.com/*"
          "*://bato.to/*"
          "*://mangapark.net/*"
          "*://animexin.vip/*"
          "*://animexin.xyz/*"
          "*://animexinax.com/*"
          "*://animexin.top/*"
          "*://animexin.dev/*"
          "*://monoschinos.com/*"
          "*://monoschinos2.com/*"
          "*://smotret-anime.org/catalog/*"
          "*://smotret-anime.online/catalog/*"
          "*://smotret-anime.com/catalog/*"
          "*://anime365.ru/catalog/*"
          "*://anime-365.ru/catalog/*"
          "*://smotret-anime.ru/catalog/*"
          "*://smotretanime.ru/catalog/*"
          "*://animefire.net/*"
          "*://animefire.plus/*"
          "*://otakufr.co/*"
          "*://otakufr.cc/*"
          "*://mangatx.com/*"
          "*://manhuafast.com/*"
          "*://tranimeizle.net/*"
          "*://www.tranimeizle.net/*"
          "*://tranimeizle.co/*"
          "*://www.tranimeizle.co/*"
          "*://*.tranimeizle.top/*"
          "*://*.animestreamingfr.fr/*"
          "*://furyosociety.com/*"
          "*://www.animeid.tv/*"
          "*://myanimelist.net/anime/*/*/episode/*"
          "*://*.animeunity.it/anime/*"
          "*://*.animeunity.tv/anime/*"
          "*://*.animeunity.cc/anime/*"
          "*://*.animeunity.to/anime/*"
          "*://*.animeunity.so/anime/*"
          "*://*.mangahere.cc/manga/*"
          "*://*.fanfox.net/manga/*"
          "*://*.mangafox.la/manga/*"
          "*://desu-online.pl/*"
          "*://wuxiaworld.site/novel/*"
          "*://lscomic.com/*"
          "*://en.leviatanscans.com/*"
          "*://reaperscans.com/*"
          "*://lynxscans.com/*"
          "*://zeroscans.com/*"
          "*://reader.deathtollscans.net/*"
          "*://manhuaplus.com/manga*"
          "*://readm.org/manga/*"
          "*://www.readm.org/manga/*"
          "*://*.readm.today/manga/*"
          "*://tioanime.com/anime/*"
          "*://tioanime.com/ver/*"
          "*://*.mangasee123.com/manga*"
          "*://*.mangasee123.com/read-online*"
          "*://*.okanime.com/animes/*"
          "*://*.okanime.com/movies/*"
          "*://*.okanime.tv/animes/*"
          "*://*.okanime.tv/movies/*"
          "*://bs.to/serie/*"
          "*://asura.gg/*"
          "*://*.asurascans.com/*"
          "*://*.asuracomics.com/*"
          "*://asuratoon.com/*"
          "*://*.asuracomic.net/*"
          "*://an1me.nl/*"
          "*://an1me.to/*"
          "*://mangajar.com/manga/*"
          "*://mangajar.pro/manga/*"
          "*://*.otakustv.com/anime/*"
          "*://demo.komga.org/*"
          "*://animewho.com/*"
          "*://fumetsu.pl/anime/*"
          "*://frixysubs.pl/*"
          "*://guya.moe/*"
          "*://cubari.moe/*"
          "*://guya.cubari.moe/*"
          "*://mangahub.io/*"
          "*://comick.app/*"
          "*://comick.ink/*"
          "*://comick.cc/*"
          "*://comick.io/*"
          "*://www.bentomanga.com/*"
          "*://bentomanga.com/*"
          "*://mangasushi.net/manga*"
          "*://tritinia.com/manga*"
          "*://readmanhua.net/manga*"
          "*://flamecomics.com/*"
          "*://flamecomics.me/*"
          "*://flamecomics.xyz/*"
          "*://immortalupdates.com/manga*"
          "*://aniwatch.to/*"
          "*://aniwatch.nz/*"
          "*://aniwatch.se/*"
          "*://hianime.to/*"
          "*://hianime.nz/*"
          "*://hianime.mn/*"
          "*://hianime.sx/*"
          "*://hianime.bz/*"
          "*://hianime.pe/*"
          "*://hianimez.to/*"
          "*://hianimez.is/*"
          "*://kitsune.tv/*"
          "*://beta.kitsune.tv/*"
          "*://lhtranslation.net/manga*"
          "*://mangas-origines.fr/oeuvre*"
          "*://*.bluesolo.org/manga/*"
          "*://disasterscans.com/*"
          "*://dynasty-scans.com/*"
          "*://aniworld.to/*"
          "*://betteranime.net/anime/*"
          "*://*.manga.bilibili.com/*"
          "*://mangareader.to/*"
          "*://animeonsen.xyz/*"
          "*://www.animeonsen.xyz/*"
          "*://*.animetoast.cc/*"
          "*://luminousscans.com/*"
          "*://luminousscans.gg/*"
          "*://luminous-scans.com/*"
          "*://*.animeworld.tv/play/*"
          "*://*.animeworld.so/play/*"
          "*://*.animeworld.ac/play/*"
          "*://mangabuddy.com/*"
          "*://vvww.toonanime.cc/*"
          "*://*.adkami.com/*"
          "*://kaguya.app/*"
          "*://hdrezka.ag/animation/*"
          "*://sovetromantica.com/anime/*"
          "*://ani.wtf/anime/*"
          "*://animationdigitalnetwork.fr/*"
          "*://animationdigitalnetwork.de/*"
          "*://animationdigitalnetwork.com/*"
          "*://aniyan.net/*"
          "*://docchi.pl/*"
          "*://franime.fr/*"
          "*://fmteam.fr/*"
          "*://www.animelon.com/*"
          "*://animelon.com/*"
          "*://animenosub.to/*"
          "*://anime-sama.fr/*"
          "*://mangafire.to/*"
          "*://projectsuki.com/*"
          "*://animebuff.ru/anime/*"
          "*://animeonegai.com/*"
          "*://www.animeonegai.com/*"
          "*://*.animeko.co/*"
          "*://animego.org/anime/*"
          "*://animego.me/anime/*"
          "*://*.luciferdonghua.in/*"
          "*://*.luciferdonghua.co.in/*"
          "*://neoxscans.com/*"
          "*://*.neoxscans.net/*"
          "*://www.hinatasoul.com/anime*"
          "*://www.hinatasoul.com/videos/*"
          "*://ogladajanime.pl/*"
          "*://hachi.moe/*"
          "*://witanime.sbs/*"
          "*://witanime.pics/*"
          "*://suwayomi-webui-preview.github.io/*"
          "*://manhuaus.com/*"
          "*://*.taiyo.moe/*"
          "*://*.animesonline.in/*"
          "*://*.miruro.to/*"
          "*://*.miruro.tv/*"
          "*://*.miruro.online/*"
          "*://latanime.org/*"
          "*://*.mangaread.org/manga/*"
          "*://q1n.net/*"
          "*://templescan.net/*"
          "*://scyllacomics.xyz/*"
          "*://vortexscans.org/*"
          "*://weebcentral.com/*"
          "*://demo.kavitareader.com/*"
          "*://rawkuma.com/*"
          "*://aninexus.to/*"
          "*://animekai.to/*"
          "*://watch.hikaritv.xyz/*"
          "*://hikari.gg/*"
          "*://*.anidream.cc/*"
          "*://*.openload.co/*"
          "*://*.openload.pw/*"
          "*://*.streamango.com/*"
          "*://*.mp4upload.com/*"
          "*://*.mcloud.to/*"
          "*://*.mcloud.bz/*"
          "*://*.static.crunchyroll.com/*"
          "*://*.vidstreaming.io/*"
          "*://*.vidstreaming.link/*"
          "*://*.xstreamcdn.com/*"
          "*://*.gcloud.live/*"
          "*://*.oload.tv/*"
          "*://*.mail.ru/*"
          "*://*.myvi.ru/*"
          "*://*.myvi.tv/*"
          "*://*.sibnet.ru/*"
          "*://*.tune.pk/*"
          "*://*.tune.ke/*"
          "*://*.vimple.ru/*"
          "*://*.href.li/*"
          "*://*.vk.com/*"
          "*://*.cloudvideo.tv/*"
          "*://*.fembed.net/*"
          "*://*.fembed.com/*"
          "*://*.animeproxy.info/*"
          "*://*.feurl.com/*"
          "*://*.embedsito.com/v/*"
          "*://*.fcdn.stream/v/*"
          "*://*.fcdn.stream/e/*"
          "*://*.vaplayer.xyz/v/*"
          "*://*.vaplayer.xyz/e/*"
          "*://*.femax20.com/v/*"
          "*://*.femax20.com/e/*"
          "*://*.fplayer.info/*"
          "*://*.dutrag.com/*"
          "*://*.diasfem.com/*"
          "*://*.fembed-hd.com/*"
          "*://*.fembed9hd.com/*"
          "*://suzihaza.com/v/*"
          "*://vanfem.com/v/*"
          "*://*.youpload.co/*"
          "*://*.yourupload.com/*"
          "*://*.vidlox.me/*"
          "*://*.kwik.cx/*"
          "*://*.kwik.si/*"
          "*://*.mega.nz/*"
          "*://*.animeflv.net/*"
          "*://*.jwplayerhls.com/*"
          "*://*.hqq.tv/*"
          "*://waaw.tv/*"
          "*://*.jkanime.net/*"
          "*://*.ok.ru/*"
          "*://*.novelplanet.me/*"
          "*://*.stream.proxer.me/*"
          "*://*.stream.proxer.net/*"
          "*://*.stream-service.proxer.me/*"
          "*://verystream.com/*"
          "*://*.animeultima.eu/e/*"
          "*://*.animeultima.eu/faststream/*"
          "*://*.animeultima.to/e/*"
          "*://*.animeultima.to/faststream/*"
          "*://*.vidoza.net/*"
          "*://*.videzz.net/*"
          "*://gounlimited.to/*"
          "*://www.ani-stream.com/*"
          "*://animedaisuki.moe/embed/*"
          "*://www.dailymotion.com/embed/*"
          "*://geo.dailymotion.com/*"
          "*://vev.io/embed/*"
          "*://vev.red/embed/*"
          "*://jwpstream.com/jwps/yplayer.php*"
          "*://www.vaplayer.xyz/v/*"
          "*://vaplayer.me/*"
          "*://mp4.sh/embed/*"
          "*://embed.mystream.to/*"
          "*://*.bitchute.com/embed/*"
          "*://*.streamcherry.com/embed/*"
          "*://*.clipwatching.com/*"
          "*://*.flix555.com/*"
          "*://*.vshare.io/v/*"
          "*://ebd.cda.pl/*"
          "*://www.lycoris.cafe/*"
          "*://*.replay.watch/*"
          "*://*.playhydrax.com/*"
          "*://hydrax.net/*"
          "*://*.geoip.redirect-ads.com/*"
          "*://*.streamium.xyz/*"
          "*://kodik.info/*"
          "*://aniboom.one/*"
          "*://smotret-anime.org/translations/embed/*"
          "*://smotret-anime.online/translations/embed/*"
          "*://smotret-anime.com/translations/embed/*"
          "*://anime365.ru/translations/embed/*"
          "*://anime-365.ru/translations/embed/*"
          "*://*.pstream.net/e/*"
          "*://fusevideo.net/e/*"
          "*://fusevideo.io/e/*"
          "*://*.animefever.tv/embed/*"
          "*://*.haloani.ru/*"
          "*://*.moeclip.com/v/*"
          "*://*.moeclip.com/embed/*"
          "*://*.mixdrop.co/e/*"
          "*://*.mixdrop.to/e/*"
          "*://*.mdbekjwqa.pw/e/*"
          "*://*.mdfx9dc8n.net/e/*"
          "*://*.mdzsmutpcvykb.net/e/*"
          "*://*.mixdropjmk.pw/e/*"
          "*://*.mixdrop21.net/e/*"
          "*://*.mixdrop.si/e/*"
          "*://*.mixdrop.nu/e/*"
          "*://*.mixdrop.sx/e/*"
          "*://*.mixdrop.ms/e/*"
          "*://*.mixdrop.ps/e/*"
          "*://*.mixdrop.my/e/*"
          "*://gdriveplayer.me/embed*"
          "*://sendvid.net/v/*"
          "*://sendvid.com/embed/*"
          "*://streamz.cc/*"
          "*://*.vidbm.com/embed-*"
          "*://*.vidbem.com/embed-*"
          "*://*.cloudhost.to/*/mediaplayer/*/_embed.php?*"
          "*://*.letsupload.co/*/mediaplayer/*/_embed.php?*"
          "*://streamtape.com/*"
          "*://streamtape.net/*"
          "*://streamtape.xyz/*"
          "*://streamtape.to/*"
          "*://strcloud.in/*"
          "*://strcloud.link/*"
          "*://streamta.pe/*"
          "*://strtape.tech/*"
          "*://strtapeadblock.club/*"
          "*://strtapeadblock.me/*"
          "*://streamta.site/*"
          "*://scloud.online/*"
          "*://strtpe.link/*"
          "*://stape.me/*"
          "*://stape.fun/*"
          "*://streamtapeadblock.art/*"
          "*://reproductor.monoschinos.com/*"
          "*://uptostream.com/iframe/*"
          "*://easyload.io/e/*"
          "*://*.googleusercontent.com/gadgets/*"
          "*://animedesu.pl/player/desu.php?v=*"
          "*://*.plyr.link/*"
          "*://v.vvid.cc/*"
          "*://*.okanime.com/cdn/*/embed/?*"
          "*://*.gogo-stream.com/*"
          "*://*.gogo-play.net/*"
          "*://*.gogo-play.tv/*"
          "*://*.streamani.net/*"
          "*://*.streamani.io/*"
          "*://*.goload.one/*"
          "*://*.goload.pro/*"
          "*://*.goload.io/*"
          "*://*.gogoplay1.com/*"
          "*://*.gogoplay2.com/*"
          "*://*.gogoplay4.com/*"
          "*://*.gogoplay5.com/*"
          "*://*.gogoplay.io/*"
          "*://*.gogohd.net/*"
          "*://*.gogohd.pro/*"
          "*://*.gembedhd.com/*"
          "*://*.playgo1.cc/*"
          "*://*.anihdplay.com/*"
          "*://*.playtaku.net/*"
          "*://*.playtaku.online/*"
          "*://*.gotaku1.com/*"
          "*://*.goone.pro/*"
          "*://*.embtaku.pro/*"
          "*://*.embtaku.com/*"
          "*://*.s3taku.com/*"
          "*://*.s3embtaku.pro/*"
          "*://vivo.sx/embed/*"
          "*://play.api-web.site/*"
          "*://vidstream.pro/embed/*"
          "*://vidstream.pro/e/*"
          "*://vidstreamz.online/embed/*"
          "*://vidstreamz.online/e/*"
          "*://vizcloud.ru/embed/*"
          "*://vizcloud.ru/e/*"
          "*://vizcloud2.ru/embed/*"
          "*://vizcloud2.ru/e/*"
          "*://vizcloud.online/embed/*"
          "*://vizcloud.online/e/*"
          "*://vizstream.ru/embed/*"
          "*://vizstream.ru/e/*"
          "*://vizcloud.xyz/embed/*"
          "*://vizcloud.xyz/e/*"
          "*://vizcloud.cloud/embed/*"
          "*://vizcloud.cloud/e/*"
          "*://vizcloud.co/embed/*"
          "*://vizcloud.co/e/*"
          "*://vidplay.site/e/*"
          "*://vidplay.lol/e/*"
          "*://vidplay.online/e/*"
          "*://a9bfed0818.nl/e/*"
          "*://vid142.site/e/*"
          "*://vid1a52.site/e/*"
          "*://vid2a41.site/e/*"
          "*://streamsb.net/*"
          "*://streamsb.com/*"
          "*://sbembed.com/*"
          "*://sbembed1.com/*"
          "*://sbvideo.net/*"
          "*://sbplay.org/*"
          "*://sbplay.one/*"
          "*://sbplay1.com/*"
          "*://sbplay2.com/*"
          "*://embedsb.com/*"
          "*://watchsb.com/*"
          "*://sbplay2.xyz/*"
          "*://sbfull.com/e/*"
          "*://ssbstream.net/*"
          "*://streamsss.net/*"
          "*://sbanh.com/e/*"
          "*://sblongvu.com/e/*"
          "*://sbchill.com/e/*"
          "*://sbone.pro/e/*"
          "*://sbani.pro/e/*"
          "*://dood.to/*"
          "*://dood.watch/*"
          "*://doodstream.com/*"
          "*://dood.la/*"
          "*://*.dood.video/*"
          "*://dood.ws/e/*"
          "*://dood.sh/e/*"
          "*://dood.so/e/*"
          "*://dood.pm/e/*"
          "*://dood.wf/e/*"
          "*://dood.re/e/*"
          "*://dooood.com/e/*"
          "*://dood.li/e/*"
          "*://youtube.googleapis.com/embed/*drive.google.com*"
          "*://hdvid.tv/*"
          "*://vidfast.co/*"
          "*://supervideo.tv/*"
          "*://jetload.net/*"
          "*://saruch.co/*"
          "*://vidmoly.me/*"
          "*://vidmoly.to/*"
          "*://upstream.to/*"
          "*://abcvideo.cc/*"
          "*://aparat.cam/*"
          "*://www.aparat.com/video/video/embed/*"
          "*://vudeo.net/*"
          "*://voe.sx/e/*"
          "*://gamoneinterrupted.com/e/*"
          "*://crownmakermacaronicism.com/e/*"
          "*://generatesnitrosate.com/e/*"
          "*://yodelswartlike.com/e/*"
          "*://cigarlessarefy.com/e/*"
          "*://valeronevijao.com/e/*"
          "*://strawberriesporail.com/e/*"
          "*://timberwoodanotia.com/e/*"
          "*://phenomenalityuniform.com/e/*"
          "*://nonesnanking.com/e/*"
          "*://kathleenmemberhistory.com/e/*"
          "*://bradleyviewdoctor.com/e/*"
          "*://seanshowcould.com/e/*"
          "*://johntryopen.com/e/*"
          "*://morganoperationface.com/e/*"
          "*://brookethoughi.com/e/*"
          "*://jamesstartstudent.com/e/*"
          "*://ryanagoinvolve.com/e/*"
          "*://jasonresponsemeasure.com/e/*"
          "*://shannonpersonalcost.com/e/*"
          "*://brucevotewithin.com/e/*"
          "*://rebeccaneverbase.com/e/*"
          "*://loriwithinfamily.com/e/*"
          "*://bethshouldercan.com/e/*"
          "*://sandratableother.com/e/*"
          "*://robertordercharacter.com/e/*"
          "*://maxfinishseveral.com/e/*"
          "*://alejandrocenturyoil.com/e/*"
          "*://heatherwholeinvolve.com/e/*"
          "*://nathanfromsubject.com/e/*"
          "*://jennifercertaindevelopment.com/e/*"
          "*://richardsignfish.com/e/*"
          "*://sarahnewspaperbeat.com/e/*"
          "*://diananatureforeign.com/e/*"
          "*://jonathansociallike.com/e/*"
          "*://mariatheserepublican.com/e/*"
          "*://vidoo.tv/*"
          "*://nxload.com/*"
          "*://videobin.co/*"
          "*://uqload.com/*"
          "*://evoload.io/*"
          "*://kaa-play.me/*"
          "*://kaavid.com/*"
          "*://vidnethub.net/*"
          "*://vidco.pro/*"
          "*://omegadthree.com/*"
          "*://krussdomi.com/*"
          "*://*.animeshouse.net/gcloud/*"
          "*://*.animeshouse.net/playerBlue/*"
          "*://*.animeshouse.net/mp4/*"
          "*://*.animeshouse.net/ah-clp-new/*"
          "*://animato.me/embed/*"
          "*://kimanime.ru/AnimeIframe/*"
          "*://vidcloud.spb.ru/*"
          "*://*.streamhd.cc/*"
          "*://*.rapid-cloud.ru/*"
          "*://*.rapid-cloud.co/*"
          "*://videovard.sx/*"
          "*://videovard.to/*"
          "*://streamlare.com/e/*"
          "*://betteranime.net/player*"
          "*://streamzz.to/*"
          "*://protonvideo.to/iframe/*"
          "*://ninjastream.to/watch/*"
          "*://harajuku.pl/*"
          "*://vupload.com/*"
          "*://*.turkanime.net/player/*"
          "*://*.turkanime.co/player/*"
          "*://*.turkanime.co/embed/*"
          "*://play.cozyplayer.com/*"
          "*://odnoklassniki.ru/*"
          "*://myalucard.xyz/*"
          "*://uploads.mobi/*"
          "*://iframe.mediadelivery.net/embed/*"
          "*://*.yfvf.com/*"
          "*://waaw.to/*"
          "*://suzihaza.com/*"
          "*://*.solidfiles.com/*"
          "*://www.animeworld.tv/api/episode/serverPlayerAnimeWorld?id=*"
          "*://www.animeworld.so/api/episode/serverPlayerAnimeWorld?id=*"
          "*://www.animeworld.ac/api/episode/serverPlayerAnimeWorld?id=*"
          "*://filemoon.sx/e/*"
          "*://filemoon.sx/lol/*"
          "*://kerapoxy.cc/e/*"
          "*://kerapoxy.cc/lol/*"
          "*://vpcxz19p.xyz/e/*"
          "*://vpcxz19p.xyz/lol/*"
          "*://filemoon.top/e/*"
          "*://filemoon.top/lol/*"
          "*://fmoonembed.pro/e/*"
          "*://fmoonembed.pro/lol/*"
          "*://rgeyyddl.skin/e/*"
          "*://rgeyyddl.skin/lol/*"
          "*://designparty.sx/e/*"
          "*://designparty.sx/lol/*"
          "*://c4qhk0je.xyz/e/*"
          "*://c4qhk0je.xyz/lol/*"
          "*://1azayf9w.xyz/e/*"
          "*://1azayf9w.xyz/lol/*"
          "*://81u6xl9d.xyz/e/*"
          "*://81u6xl9d.xyz/lol/*"
          "*://gorro-chfzoaas.fun/e/*"
          "*://gorro-chfzoaas.fun/lol/*"
          "*://z7ihwgqj.fun/*"
          "*://mb.toonanime.xyz/dist/*"
          "*://aniyan.net/jwplayer/*"
          "*://*.googlevideo.com/videoplayback?*"
          "*://animenosub.upn.one/#*"
          "*://*.streamhide.to/e/*"
          "*://megacloud.tv/*"
          "*://megacloud.club/*"
          "*://megacloud.blog/*"
          "*://vixcloud.cc/*"
          "*://vixcloud.co/*"
          "*://yonaplay.org/*"
          "*://*.4shared.com/*"
          "*://*.videa.hu/*"
          "*://*.soraplay.xyz/*"
          "*://streamwish.to/e/*"
          "*://sfastwish.com/e/*"
          "*://awish.pro/e/*"
          "*://hlswish.com/e/*"
          "*://swishsrv.com/e/*"
          "*://alions.pro/v/*"
          "*://megaf.cc/e/*"
          "*://rogeriobetin.com/*"
          "*://nvlabs-fi-cdn.q9x.in/*"
          "*://oneupload.to/*"
          "*://player.vimeo.com/*"
          "*://fle-rvd0i9o8-moo.com/*"
          "*://dhtpre.com/*"
          "*://*.bunniescdn.online/*"
          "*://megaup.cc/e/*"
          "*://boosterx.stream/*"
        ];
        platforms = platforms.all;
      };
    };
    "markdownload" = buildFirefoxXpiAddon {
      pname = "markdownload";
      version = "3.2.0";
      addonId = "{1c5e4c6f-5530-49a3-b216-31ce7d744db0}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4006297/markdownload-3.2.0.xpi";
      sha256 = "d5df4544d1775242872cb3be968188ba281684d5b741da45392b4364278d7119";
      meta = with lib;
      {
        homepage = "https://github.com/deathau/markdown-clipper";
        description = "This extension works like a web clipper, but it downloads articles in a markdown format. Turndown and Readability.js are used as core libraries. It is not guaranteed to work with all websites.";
        license = licenses.asl20;
        mozPermissions = [
          "<all_urls>"
          "activeTab"
          "downloads"
          "storage"
          "contextMenus"
          "clipboardWrite"
        ];
        platforms = platforms.all;
      };
    };
    "material-icons-for-github" = buildFirefoxXpiAddon {
      pname = "material-icons-for-github";
      version = "1.10.5";
      addonId = "{eac6e624-97fa-4f28-9d24-c06c9b8aa713}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4519503/material_icons_for_github-1.10.5.xpi";
      sha256 = "46b53d7a87ae88266eb3e0dd8fc371e2ab10d221c22029802843995604eea958";
      meta = with lib;
      {
        homepage = "https://github.com/Claudiohbsantos/github-material-icons-extension";
        description = "Replace the file/folder icons on github file browsers with icons representing the file's type and which tool it is used by.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "activeTab"
          "scripting"
          "*://github.com/*"
          "*://bitbucket.org/*"
          "*://dev.azure.com/*"
          "*://*.visualstudio.com/*"
          "*://gitea.com/*"
          "*://gitlab.com/*"
          "*://gitee.com/*"
          "*://sourceforge.net/*"
        ];
        platforms = platforms.all;
      };
    };
    "matte-black-red" = buildFirefoxXpiAddon {
      pname = "matte-black-red";
      version = "2022.2.23";
      addonId = "{a7589411-c5f6-41cf-8bdc-f66527d9d930}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3913593/matte_black_red-2022.2.23.xpi";
      sha256 = "1dd32994ec6e006544efe15efcfa96145c929ff65366a05d3b5c0e44c6a59ac6";
      meta = with lib;
      {
        homepage = "https://elijahlopez.ca/";
        description = "A modern dark / Matte Black theme with a red accent color.\nClick my name for more accents (request if not available).";
        license = licenses.cc-by-nc-sa-30;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "maya-dark" = buildFirefoxXpiAddon {
      pname = "maya-dark";
      version = "1.0";
      addonId = "{0f4f1bc1-0466-48f9-83a8-756f5f611c97}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3947037/maya_dark-1.0.xpi";
      sha256 = "d55ffe09d2e73735b0b8cc654894fddd30ef0a3b5589809364095c5e77239464";
      meta = with lib;
      {
        description = "Deep purple pink solid theme. Hopefully comfortable to use and fairly easy on the eyes.";
        license = licenses.cc-by-30;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "maya-light" = buildFirefoxXpiAddon {
      pname = "maya-light";
      version = "1.0";
      addonId = "{80daef64-2ecc-4722-aab4-bc860d1578c7}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3947054/maya_light-1.0.xpi";
      sha256 = "611241d87321f7d1e86324f425eb0a8f6ef86a747c48bd3b38edd10eb7486276";
      meta = with lib;
      {
        description = "Soft pastel pink light theme with a few darker Evil maya accents. Fairly bright but should be comfortable for most users.";
        license = licenses.cc-by-30;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "mergify" = buildFirefoxXpiAddon {
      pname = "mergify";
      version = "1.0.30";
      addonId = "d1b33d6a57c463f0daef4abfb625edddd1c2d5d9@mergify.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4571024/mergify-1.0.30.xpi";
      sha256 = "cf3aba6f9846406841c8a4471be032732c19603e4a2c8a6418868933155d955f";
      meta = with lib;
      {
        description = "Mergify extension for GitHub";
        license = licenses.asl20;
        mozPermissions = [
          "https://github.com/*"
          "https://dashboard.mergify.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "metager-suche" = buildFirefoxXpiAddon {
      pname = "metager-suche";
      version = "1.22";
      addonId = "firefoxextension@metager.de";
      url = "https://addons.mozilla.org/firefox/downloads/file/4604176/metager_suche-1.22.xpi";
      sha256 = "10dbb162df42484de05fb3e2c5a1daebbd1bdcc1a204b4d1ca2de1d6a5dc17d5";
      meta = with lib;
      {
        homepage = "https://metager.org/kontakt";
        description = "Privacy has never been so easy. Sets MetaGer as your default search engine and manages search settings for you.";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "cookies"
          "webRequest"
          "declarativeNetRequestWithHostAccess"
          "alarms"
          "https://metager.org/*"
          "https://metager.de/*"
          "https://metager.de/meta/settings"
          "https://metager.de/*/meta/settings"
          "https://metager.de/meta/settings?*"
          "https://metager.de/*/meta/settings?*"
          "https://metager.org/meta/settings"
          "https://metager.org/*/meta/settings"
          "https://metager.org/meta/settings?*"
          "https://metager.org/*/meta/settings?*"
          "https://metager.org/meta/meta.ger3?*"
          "https://metager.org/*/meta/meta.ger3?*"
          "https://metager.de/meta/meta.ger3?*"
          "https://metager.de/*/meta/meta.ger3?*"
          "https://metager.org/keys/*"
          "https://metager.org/*/keys/*"
        ];
        platforms = platforms.all;
      };
    };
    "metamask" = buildFirefoxXpiAddon {
      pname = "metamask";
      version = "13.4.0";
      addonId = "webextension@metamask.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/4590988/ether_metamask-13.4.0.xpi";
      sha256 = "1de19bcbf20e2dc1fb156a0978ddbe8e53874c66fda350062881504cc7004477";
      meta = with lib;
      {
        description = "The most secure wallet for crypto, NFTs, and DeFi, trusted by millions of users";
        mozPermissions = [
          "storage"
          "unlimitedStorage"
          "clipboardWrite"
          "http://*/*"
          "https://*/*"
          "ws://*/*"
          "wss://*/*"
          "activeTab"
          "webRequest"
          "webRequestBlocking"
          "*://*.eth/"
          "notifications"
          "identity"
          "file://*/*"
          "*://connect.trezor.io/*/popup.html*"
        ];
        platforms = platforms.all;
      };
    };
    "modrinthify" = buildFirefoxXpiAddon {
      pname = "modrinthify";
      version = "1.7.3";
      addonId = "{5183707f-8a46-4092-8c1f-e4515bcebbad}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4604284/modrinthify-1.7.3.xpi";
      sha256 = "e28bfa56acc18c438dbe802b30e1d6f0d94a2d5dbba39a9c61eb417b20f54bd7";
      meta = with lib;
      {
        homepage = "https://github.com/devBoi76/modrinthify";
        description = "Automatically searches Modrinth for Curseforge mods and displays Modrinth notifications in the toolbar!";
        license = licenses.mit;
        mozPermissions = [
          "https://api.modrinth.com/v2/*"
          "storage"
          "alarms"
          "*://*.curseforge.com/minecraft/*"
          "*://*.spigotmc.org/*"
        ];
        platforms = platforms.all;
      };
    };
    "momentumdash" = buildFirefoxXpiAddon {
      pname = "momentumdash";
      version = "2.25.3";
      addonId = "momentum@momentumdash.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4594753/momentumdash-2.25.3.xpi";
      sha256 = "3d5547b99b595ce8e3840766f45328980097fc1697e6b4f4c30cc45a596f3690";
      meta = with lib;
      {
        homepage = "https://momentumdash.com";
        description = "Transform your browser into a beautifully designed tab that helps you feel calm, keep focus, and stay energized.";
        license = {
          shortName = "momentum";
          fullName = "Momentum Terms of Use";
          url = "https://momentumdash.com/legal";
          free = false;
        };
        mozPermissions = [
          "unlimitedStorage"
          "https://*.momentumdash.com/*"
          "alarms"
          "idle"
        ];
        platforms = platforms.all;
      };
    };
    "move-unloaded-tabs-for-tst" = buildFirefoxXpiAddon {
      pname = "move-unloaded-tabs-for-tst";
      version = "2.4";
      addonId = "{731bf636-c808-4c86-b02f-af462eccc963}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3531247/move_unloaded_tabs_for_tst-2.4.xpi";
      sha256 = "9c1c5d8a8ae4a27428e7c1f7e8c1671b40bed388dafac35900f3b80c5118fa7b";
      meta = with lib;
      {
        homepage = "https://github.com/Lej77/move-unloaded-tabs-for-tree-style-tab";
        description = "Move tabs in the Tree Style Tab Sidebar without them becoming active.";
        license = licenses.gpl3;
        mozPermissions = [ "storage" ];
        platforms = platforms.all;
      };
    };
    "movie-web" = buildFirefoxXpiAddon {
      pname = "movie-web";
      version = "1.1.4";
      addonId = "{b0a674f9-f848-9cfd-0feb-583d211308b0}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4286163/cfu_flix_movie_web_extension-1.1.4.xpi";
      sha256 = "bcd95a93684307bae03f02069ca519d115f279810de2011c62853d5fd5c5fb52";
      meta = with lib;
      {
        homepage = "https://e-z.bio/pnda";
        description = "Enhance your streaming experience with just one click\n\n• Greatly increase the list of sources available.\n• Start using the website without any friction.\n• Enjoy other supported websites or self-hosts.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "declarativeNetRequest"
          "activeTab"
          "cookies"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "mtab" = buildFirefoxXpiAddon {
      pname = "mtab";
      version = "1.9.1";
      addonId = "contact@maxhu.dev";
      url = "https://addons.mozilla.org/firefox/downloads/file/4608985/mtab-1.9.1.xpi";
      sha256 = "6e1503d467b95006d8284641c7b8bbe8b2e112329aed253690abd899bca920c5";
      meta = with lib;
      {
        homepage = "https://github.com/maxhu08/mtab";
        description = "a simple configurable new tab extension";
        license = licenses.mit;
        mozPermissions = [ "storage" "bookmarks" ];
        platforms = platforms.all;
      };
    };
    "multi-account-containers" = buildFirefoxXpiAddon {
      pname = "multi-account-containers";
      version = "8.3.4";
      addonId = "@testpilot-containers";
      url = "https://addons.mozilla.org/firefox/downloads/file/4607779/multi_account_containers-8.3.4.xpi";
      sha256 = "c7d1018e7856ac6b27b26eccedd85222398398b00ce7344e93cbb1495d8ea632";
      meta = with lib;
      {
        homepage = "https://github.com/mozilla/multi-account-containers/#readme";
        description = "Firefox Multi-Account Containers lets you keep parts of your online life separated into color-coded tabs. Cookies are separated by container, allowing you to use the web with multiple accounts and integrate Mozilla VPN for an extra layer of privacy.";
        license = licenses.mpl20;
        mozPermissions = [
          "<all_urls>"
          "activeTab"
          "cookies"
          "contextMenus"
          "contextualIdentities"
          "history"
          "idle"
          "management"
          "storage"
          "unlimitedStorage"
          "tabs"
          "webRequestBlocking"
          "webRequest"
        ];
        platforms = platforms.all;
      };
    };
    "multiple-tab-handler" = buildFirefoxXpiAddon {
      pname = "multiple-tab-handler";
      version = "3.2.1";
      addonId = "multipletab@piro.sakura.ne.jp";
      url = "https://addons.mozilla.org/firefox/downloads/file/4499918/multiple_tab_handler-3.2.1.xpi";
      sha256 = "3dc3ea9cac0f036198e2dabceb2fab0d9811f5604b48e76219ac8748a0c96ba6";
      meta = with lib;
      {
        homepage = "http://piro.sakura.ne.jp/xul/_multipletab.html.en";
        description = "Allows you to select tabs by dragging and do something.";
        license = licenses.mpl20;
        mozPermissions = [
          "activeTab"
          "contextualIdentities"
          "cookies"
          "menus"
          "menus.overrideContext"
          "notifications"
          "storage"
          "tabs"
        ];
        platforms = platforms.all;
      };
    };
    "multiselect-for-youtube" = buildFirefoxXpiAddon {
      pname = "multiselect-for-youtube";
      version = "3.7";
      addonId = "{1b84391e-7c49-4ff3-abab-07bd0a4523e4}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4363742/multiselect_for_youtube-3.7.xpi";
      sha256 = "8fc92ee9527afcadd4b77ba8e6da65c2410574611dbe208af975b70b33e6f900";
      meta = with lib;
      {
        homepage = "https://ms4yt.com/";
        description = "Move, sort, and copy videos in your playlists faster and easier.";
        license = licenses.mpl20;
        mozPermissions = [ "storage" "https://www.youtube.com/*" ];
        platforms = platforms.all;
      };
    };
    "musescore-downloader" = buildFirefoxXpiAddon {
      pname = "musescore-downloader";
      version = "0.26.0";
      addonId = "{69856097-6e10-42e9-acc7-0c063550c7b8}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3818223/musescore_downloader-0.26.0.xpi";
      sha256 = "2d7d1d70d953231aa7464f89a33154b78019baeee855284bfe9dd2db505a8e76";
      meta = with lib;
      {
        homepage = "https://github.com/Xmader/musescore-downloader#readme";
        description = "download sheet music from musescore.com for free, no login or Musescore Pro required | 免登录、免 Musescore Pro，免费下载 musescore.com 上的曲谱";
        license = licenses.mit;
        mozPermissions = [ "*://*.musescore.com/*/*" ];
        platforms = platforms.all;
      };
    };
    "muzli" = buildFirefoxXpiAddon {
      pname = "muzli";
      version = "31.0.40";
      addonId = "firefox@muz.li";
      url = "https://addons.mozilla.org/firefox/downloads/file/4348703/muzli_design_inspiration_hub-31.0.40.xpi";
      sha256 = "e2e27cedb9ec5da9cca55d96deeb9d776ed7e9326d924bf0cd56d0f33b1a27c7";
      meta = with lib;
      {
        homepage = "https://muz.li";
        description = "Your daily dose of design with industry news, tools, and inspiration - all in one place.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [ "storage" "alarms" ];
        platforms = platforms.all;
      };
    };
    "native-mathml" = buildFirefoxXpiAddon {
      pname = "native-mathml";
      version = "1.9.6";
      addonId = "jid1-fGtBdrROY6E1gA@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4048711/native_mathml-1.9.6.xpi";
      sha256 = "fa2d2ceebd65b2e9a682dc8fcd606942f969552825c7edecaf4ef679cab06cac";
      meta = with lib;
      {
        homepage = "https://github.com/fred-wang/webextension-native-mathml";
        description = "Force MathJax/KaTeX/MediaWIki to use native MathML rendering.";
        license = licenses.mpl20;
        mozPermissions = [ "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "nekocap" = buildFirefoxXpiAddon {
      pname = "nekocap";
      version = "1.18.1";
      addonId = "nekocaption@gmail.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4553284/nekocap-1.18.1.xpi";
      sha256 = "893bbbe069eb7e990b9229362e42c54c900d9e72f391902895e92920c388cbc2";
      meta = with lib;
      {
        homepage = "https://nekocap.com";
        description = "Create and upload community captions for YouTube videos (and more) with this easy to use extension that supports SSA/ASS rendering.";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "webNavigation"
          "identity"
          "https://*.youtube.com/*"
          "https://*.tver.jp/*"
          "https://*.nicovideo.jp/*"
          "https://*.vimeo.com/*"
          "https://*.bilibili.com/*"
          "https://*.netflix.com/*"
          "https://*.primevideo.com/*"
          "https://*.twitter.com/*"
          "https://*.x.com/*"
          "https://*.wetv.vip/*"
          "https://*.tiktok.com/*"
          "https://*.iq.com/*"
          "https://*.abema.tv/*"
          "https://*.dailymotion.com/*"
          "https://*.bilibili.tv/*"
          "https://*.nogidoga.com/*"
          "https://*.cu.tbs.co.jp/*"
          "https://*.instagram.com/*"
          "https://*.unext.jp/*"
          "https://*.lemino.docomo.ne.jp/*"
          "https://*.oned.net/*"
          "https://*.archive.org/*"
        ];
        platforms = platforms.all;
      };
    };
    "new-tab-override" = buildFirefoxXpiAddon {
      pname = "new-tab-override";
      version = "17.0.0";
      addonId = "newtaboverride@agenedia.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4442226/new_tab_override-17.0.0.xpi";
      sha256 = "bde74725d1ce497a1da8aad46522488c03d6157c541a96297e20b9c849c0531c";
      meta = with lib;
      {
        homepage = "https://www.soeren-hentzschel.at/firefox-webextensions/new-tab-override/";
        description = "New Tab Override allows you to set the page that shows whenever you open a new tab.";
        license = licenses.mpl20;
        mozPermissions = [
          "browserSettings"
          "cookies"
          "history"
          "menus"
          "storage"
          "tabs"
        ];
        platforms = platforms.all;
      };
    };
    "new-window-without-toolbar" = buildFirefoxXpiAddon {
      pname = "new-window-without-toolbar";
      version = "1.3.0";
      addonId = "new-window-without-toolbar@tkrkt.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/1738301/new_window_without_toolbar-1.3.0.xpi";
      sha256 = "f3504d65c0ac0fa22c37629b6767091b03802a5f15edb0f92dd1caa90a76fa91";
      meta = with lib;
      {
        description = "Open current page in new window without toolbar.";
        license = licenses.mit;
        mozPermissions = [
          "tabs"
          "contextMenus"
          "contextualIdentities"
          "cookies"
          "storage"
        ];
        platforms = platforms.all;
      };
    };
    "new-zealand-english-dict" = buildFirefoxXpiAddon {
      pname = "new-zealand-english-dict";
      version = "1.0.1.3resigned1";
      addonId = "en-NZ@dictionaries.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4270296/new_zealand_english_dict-1.0.1.3resigned1.xpi";
      sha256 = "d072da080ed290c0982b28b4d51cbd384419d8f25a1e7ba69c702a74dbba389f";
      meta = with lib;
      {
        description = "New Zealand English Dictionary 1.0.1 for Firefox.";
        license = licenses.lgpl21;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "new_tongwentang" = buildFirefoxXpiAddon {
      pname = "new_tongwentang";
      version = "2.4.0";
      addonId = "tongwen@softcup";
      url = "https://addons.mozilla.org/firefox/downloads/file/4411434/new_tongwentang-2.4.0.xpi";
      sha256 = "123a357d2d6b96c87bc044208015cca2992ce1b4fd1bd5a04ba3eefd77786e05";
      meta = with lib;
      {
        homepage = "https://github.com/softcup/New-Tongwentang-for-Firefox";
        description = "Traditional and Simplified Chinese Converter";
        license = licenses.mit;
        mozPermissions = [
          "contextMenus"
          "downloads"
          "notifications"
          "storage"
          "tabs"
          "unlimitedStorage"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "news-feed-eradicator" = buildFirefoxXpiAddon {
      pname = "news-feed-eradicator";
      version = "2.2.7";
      addonId = "@news-feed-eradicator";
      url = "https://addons.mozilla.org/firefox/downloads/file/4300135/news_feed_eradicator-2.2.7.xpi";
      sha256 = "99fa2dab867cdb5f50cbf2d4ec1ff632d57a9b9c73371786e8f098f1c5b24522";
      meta = with lib;
      {
        homepage = "https://west.io/news-feed-eradicator";
        description = "Find yourself spending too much time on Facebook? Eradicate distractions by replacing your entire news feed with an inspiring quote";
        license = licenses.mit;
        mozPermissions = [ "storage" ];
        platforms = platforms.all;
      };
    };
    "newtab-adapter" = buildFirefoxXpiAddon {
      pname = "newtab-adapter";
      version = "1.3.0";
      addonId = "newtab-adapter@gdh1995.cn";
      url = "https://addons.mozilla.org/firefox/downloads/file/3632463/newtab_adapter-1.3.0.xpi";
      sha256 = "43cee7feffb204155961be4a0f1ef441abc5e19b340c348c28c97b5cbddd86ca";
      meta = with lib;
      {
        homepage = "https://github.com/gdh1995/vimium-c-helpers/tree/master/newtab";
        description = "Take over browser's new tab settings and open another configurable URL";
        license = licenses.mit;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "ng-inspect" = buildFirefoxXpiAddon {
      pname = "ng-inspect";
      version = "1.1resigned1";
      addonId = "jid1-v6jvJrqACQCakw@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4270648/ng_inspect-1.1resigned1.xpi";
      sha256 = "bbdd8f09ba7503788b687349fee8e41530bacfb29c642db1b4729b0904a780df";
      meta = with lib;
      {
        homepage = "https://github.com/christophehurpeau/ng-inspect";
        description = "Inspect the angular scope in the developper tools inspector";
        license = licenses.mit;
        mozPermissions = [ "contextMenus" "tabs" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "nicothin-space" = buildFirefoxXpiAddon {
      pname = "nicothin-space";
      version = "1.1.2";
      addonId = "{22b0eca1-8c02-4c0d-a5d7-6604ddd9836e}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4226329/nicothin_space-1.1.2.xpi";
      sha256 = "47b285c9e2612d5b3b2ac3620f7e01fd8afcf29a7bac296f8d97077830cdd972";
      meta = with lib;
      {
        homepage = "https://github.com/nicoth-in/Dark-Space-Theme";
        description = "Animated stars in dark theme.\nSeamless video background with particles moving around. Enjoy.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "nighttab" = buildFirefoxXpiAddon {
      pname = "nighttab";
      version = "7.3.0";
      addonId = "{47bf427e-c83d-457d-9b3d-3db4118574bd}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3848032/nighttab-7.3.0.xpi";
      sha256 = "ef53db7d9276a9f21533f8b21bc67114965c959802c0d2a92b8fce6cebed800d";
      meta = with lib;
      {
        homepage = "https://github.com/zombieFox/nightTab";
        description = "A neutral new tab page accented with a chosen colour. Customise the layout, style, background and bookmarks in nightTab.";
        license = licenses.gpl3;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "nitter-redirect" = buildFirefoxXpiAddon {
      pname = "nitter-redirect";
      version = "1.1.5";
      addonId = "{513646f8-fb87-4135-a41e-4cf1d1ccccf2}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3614778/nitter_redirect-1.1.5.xpi";
      sha256 = "a85d0c99d4e99c7dd3907af63ce2c88653af4723f564d68a4a1b1d5bce2b995e";
      meta = with lib;
      {
        homepage = "https://github.com/SimonBrazell/nitter-redirect";
        description = "Redirects Twitter requests to Nitter, the privacy friendly alternative.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "webRequest"
          "webRequestBlocking"
          "*://twitter.com/*"
          "*://www.twitter.com/*"
          "*://mobile.twitter.com/*"
          "*://pbs.twimg.com/*"
          "*://video.twimg.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "nixpkgs-pr-tracker" = buildFirefoxXpiAddon {
      pname = "nixpkgs-pr-tracker";
      version = "0.1.2";
      addonId = "nixpkgs-pr-tracker@tahayassine.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/4560332/nixpkgs_pr_tracker-0.1.2.xpi";
      sha256 = "91a0b64787f503c3f3d89dfefe36a4bfc6bb1724e9e87fd01a1e8a5e79e1a7c8";
      meta = with lib;
      {
        description = "Shows which branch a Nixpkgs PR is merged into.";
        license = licenses.mit;
        mozPermissions = [ "storage" "https://github.com/*" ];
        platforms = platforms.all;
      };
    };
    "no-pdf-download" = buildFirefoxXpiAddon {
      pname = "no-pdf-download";
      version = "1.0.6";
      addonId = "{b9b25e4a-bdf4-4270-868c-3f619eaf437d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3020560/no_pdf_download-1.0.6.xpi";
      sha256 = "fa27b6729178a23ccf2eee07cd7650d841fc6040f2e5adfb919931b671ed79e6";
      meta = with lib;
      {
        homepage = "https://github.com/MorbZ/no-pdf-download";
        description = "Opens all PDF files directly in the browser.";
        license = licenses.mit;
        mozPermissions = [ "webRequest" "webRequestBlocking" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "nord123" = buildFirefoxXpiAddon {
      pname = "nord123";
      version = "1.1";
      addonId = "{3360db90-83f8-4291-8872-377ba50fb47c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3692469/nord123-1.1.xpi";
      sha256 = "08016b531c3c63b320f065f115bd326a56856a1c4e3cb442d4d14c998ccd7012";
      meta = with lib;
      {
        description = "A theme with the nord color scheme.";
        license = licenses.cc-by-30;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "nos2x-fox" = buildFirefoxXpiAddon {
      pname = "nos2x-fox";
      version = "1.17.0";
      addonId = "{fdacee2c-bab4-490d-bc4b-ecdd03d5d68a}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4425924/nos2x_fox-1.17.0.xpi";
      sha256 = "d707acbbb8ee9c218eb56db2bade324b939da10eed61928a253db9c771f8ff94";
      meta = with lib;
      {
        homepage = "https://github.com/diegogurpegui/nos2x-firefox";
        description = "Nostr Signer Extension (for Firefox)";
        license = licenses.publicDomain;
        mozPermissions = [ "storage" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "noscript" = buildFirefoxXpiAddon {
      pname = "noscript";
      version = "13.2.2";
      addonId = "{73a6fe31-595d-460b-a920-fcc0f8843232}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4597669/noscript-13.2.2.xpi";
      sha256 = "f5ae80f2858057a3c8ebbafc12269659003f937e1cd781e05c01cc668e025c70";
      meta = with lib;
      {
        homepage = "https://noscript.net";
        description = "The best security you can get in a web browser! Allow potentially malicious web content to run only from sites you trust. Protect yourself against XSS other web security exploits.";
        license = licenses.gpl2;
        mozPermissions = [
          "contextMenus"
          "storage"
          "tabs"
          "unlimitedStorage"
          "scripting"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "webRequestFilterResponse"
          "webRequestFilterResponse.serviceWorkerScript"
          "dns"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "notifier-for-github" = buildFirefoxXpiAddon {
      pname = "notifier-for-github";
      version = "24.4.24";
      addonId = "{8d1582b2-ff2a-42e0-ba40-42f4ebfe921b}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4269410/notifier_for_github-24.4.24.xpi";
      sha256 = "db67b2867fbf39a92db382e4ad77ab39ff44a7369eb6b525bff1a8995dbeb1e9";
      meta = with lib;
      {
        homepage = "https://github.com/sindresorhus/notifier-for-github";
        description = "Get notified about new GitHub notifications";
        license = licenses.mit;
        mozPermissions = [ "alarms" "storage" ];
        platforms = platforms.all;
      };
    };
    "notion-web-clipper" = buildFirefoxXpiAddon {
      pname = "notion-web-clipper";
      version = "0.3.2";
      addonId = "{4b547b2c-e114-4344-9b70-09b2fe0785f3}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3768048/notion_web_clipper-0.3.2.xpi";
      sha256 = "3bc63fff7b75d04c1575092ff4fee3e3c487f0b5e4b6f51a9374b31844dfacc0";
      meta = with lib;
      {
        homepage = "https://www.notion.so/web-clipper";
        description = "Use our Web Clipper to save any website into Notion.";
        license = {
          shortName = "notion-web-clipper";
          fullName = "Notion Terms and Privacy";
          url = "https://www.notion.so/Terms-and-Privacy-28ffdd083dc3473e9c2da6ec011b58ac";
          free = false;
        };
        mozPermissions = [
          "activeTab"
          "storage"
          "cookies"
          "https://*.notion.so/"
          "https://*.notion.so/*"
        ];
        platforms = platforms.all;
      };
    };
    "nyaa-linker" = buildFirefoxXpiAddon {
      pname = "nyaa-linker";
      version = "2.3.0";
      addonId = "Metacor.Code@gmail.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4561966/nyaa_linker-2.3.0.xpi";
      sha256 = "ee0fc88fd21230f752a9276e71843ca74d3eeb7778a3466cd5f4438740722446";
      meta = with lib;
      {
        description = "Adds a button to Anime and Manga database websites that opens a relevant Nyaa search";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "tabs"
          "*://*.myanimelist.net/*"
          "*://*.anilist.co/*"
          "*://*.kitsu.app/*"
          "*://*.anime-planet.com/*"
          "*://*.animenewsnetwork.com/encyclopedia/*"
          "*://*.anidb.net/*"
          "*://*.livechart.me/*"
        ];
        platforms = platforms.all;
      };
    };
    "octolinker" = buildFirefoxXpiAddon {
      pname = "octolinker";
      version = "6.10.5";
      addonId = "octolinker@stefanbuck.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4029754/octolinker-6.10.5.xpi";
      sha256 = "36a953c5bd3a60648a45ec04fb131664f54f2d31caf26853c2b3d438d50674c1";
      meta = with lib;
      {
        homepage = "https://octolinker.vercel.app";
        description = "It turns language-specific module-loading statements like include, require or import into links. Depending on the language it will either redirect you to the referenced file or to an external website like a manual page or another service.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "https://github.com/"
          "https://api.github.com/"
          "https://gist.github.com/"
          "https://octolinker-api.now.sh/"
          "https://github.com/*"
          "https://gist.github.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "octotree" = buildFirefoxXpiAddon {
      pname = "octotree";
      version = "8.2.2";
      addonId = "jid1-Om7eJGwA1U8Akg@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4589089/octotree-8.2.2.xpi";
      sha256 = "a16688d42842c09a2e388f0ec99ae8b3d35598ebf3704ac19b63dd81e094efbd";
      meta = with lib;
      {
        homepage = "https://github.com/buunguyen/octotree/";
        description = "GitHub on steroids";
        mozPermissions = [
          "https://api.github.com/*"
          "https://www.octotree.io/*"
          "storage"
          "contextMenus"
          "activeTab"
          "https://github.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "offline-qr-code-generator" = buildFirefoxXpiAddon {
      pname = "offline-qr-code-generator";
      version = "1.9";
      addonId = "offline-qr-code@rugk.github.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/4349427/offline_qr_code_generator-1.9.xpi";
      sha256 = "448c63fbd4036ed913b85a93ea57480fd7a8f8dbcaa7d8a24f99b34443a9fad1";
      meta = with lib;
      {
        homepage = "https://github.com/rugk/offline-qr-code";
        description = "This add-on allows you to quickly generate a QR code offline with the URL of the open tab or any (selected) other text! 👍\r\n\r\nIt works completely offline protecting your privacy and has a big range of features like colored QR codes!";
        license = licenses.mit;
        mozPermissions = [ "activeTab" "storage" "menus" ];
        platforms = platforms.all;
      };
    };
    "okta-browser-plugin" = buildFirefoxXpiAddon {
      pname = "okta-browser-plugin";
      version = "6.44.0";
      addonId = "plugin@okta.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4583741/okta_browser_plugin-6.44.0.xpi";
      sha256 = "fb88e080f94f0b5e9f8b823a1769a6b1a5c52e9450e05985fcc5951da85a4439";
      meta = with lib;
      {
        homepage = "https://www.okta.com";
        description = "Okta Browser Plugin";
        license = {
          shortName = "okta";
          fullName = "Various Okta Agreements";
          url = "https://www.okta.com/agreements/";
          free = false;
        };
        mozPermissions = [
          "tabs"
          "cookies"
          "https://*/"
          "http://*/"
          "storage"
          "unlimitedStorage"
          "webRequest"
          "webRequestBlocking"
          "webNavigation"
        ];
        platforms = platforms.all;
      };
    };
    "old-reddit-redirect" = buildFirefoxXpiAddon {
      pname = "old-reddit-redirect";
      version = "2.0.9";
      addonId = "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4526031/old_reddit_redirect-2.0.9.xpi";
      sha256 = "91e7554b85b79201f72c175f6e5f6f493b3330ee833b8289fb6417d991add50a";
      meta = with lib;
      {
        homepage = "https://github.com/tom-james-watson/old-reddit-redirect";
        description = "Ensure Reddit always loads the old design";
        license = licenses.mit;
        mozPermissions = [
          "declarativeNetRequestWithHostAccess"
          "https://old.reddit.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "omnisearch" = buildFirefoxXpiAddon {
      pname = "omnisearch";
      version = "1.4.5";
      addonId = "{5bc8d6f7-79e6-42b0-a64e-06a05dc2db5d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3925614/omnisearch-1.4.5.xpi";
      sha256 = "11b1ed044efc29ce48a2206049959700f59c33f5d631087fc83efea5b2d02696";
      meta = with lib;
      {
        homepage = "https://github.com/alyssaxuu/omni";
        description = "Supercharge Firefox with commands, shortcuts, and more";
        license = licenses.mit;
        mozPermissions = [
          "tabs"
          "activeTab"
          "bookmarks"
          "browsingData"
          "history"
          "search"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "omnivore" = buildFirefoxXpiAddon {
      pname = "omnivore";
      version = "2.10.0";
      addonId = "save-extension@omnivore.app";
      url = "https://addons.mozilla.org/firefox/downloads/file/4246656/omnivore-2.10.0.xpi";
      sha256 = "31142640e86215823150bd9dd3fac003cc0d2dd6735bb36c6f42c1c215916ca4";
      meta = with lib;
      {
        homepage = "https://omnivore.app/";
        description = "Omnivore is the read-it-later app for serious readers. Distraction free. Privacy focused. Open source.";
        license = licenses.gpl3;
        mozPermissions = [
          "activeTab"
          "storage"
          "contextMenus"
          "https://*/**"
          "http://*/**"
        ];
        platforms = platforms.all;
      };
    };
    "omori-headspace-by-lemon" = buildFirefoxXpiAddon {
      pname = "omori-headspace-by-lemon";
      version = "1.0";
      addonId = "{f1b7aef0-b095-4976-af76-27f6344a128e}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4069986/omori_headspace_by_lemon-1.0.xpi";
      sha256 = "1840478ad9fff5e6f31930ee7c8ffd6a84f504bac0cd30646a6919eae7ee95f3";
      meta = with lib;
      {
        description = "This theme will skin your UI to look like the Headspace sky from OMORI!";
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "one-click-wayback" = buildFirefoxXpiAddon {
      pname = "one-click-wayback";
      version = "0.2";
      addonId = "tom@tom.tf";
      url = "https://addons.mozilla.org/firefox/downloads/file/3658464/one_click_wayback-0.2.xpi";
      sha256 = "652adb4b0b1358f47fdb9ab0fd4ff9ab4cfdabde785219b7819849cbb6467e82";
      meta = with lib;
      {
        homepage = "https://git.sr.ht/~tomf/one-click-wayback";
        description = "View cached versions of your current page in the Wayback Machine.";
        license = licenses.mpl20;
        mozPermissions = [ "activeTab" ];
        platforms = platforms.all;
      };
    };
    "onepassword-password-manager" = buildFirefoxXpiAddon {
      pname = "onepassword-password-manager";
      version = "8.11.15.5";
      addonId = "{d634138d-c276-4fc8-924b-40a0ea21d284}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4602298/1password_x_password_manager-8.11.15.5.xpi";
      sha256 = "c2a491c4d7b3b4bc99629b3219ac1db5efe3de2edd2c867da8a02b639be47e2b";
      meta = with lib;
      {
        homepage = "https://1password.com";
        description = "The best way to experience 1Password in your browser. Easily sign in to sites, generate passwords, and store secure information, including logins, credit cards, notes, and more.";
        license = {
          shortName = "1pwd";
          fullName = "Service Agreement for 1Password users and customers";
          url = "https://1password.com/legal/terms-of-service/";
          free = false;
        };
        mozPermissions = [
          "<all_urls>"
          "alarms"
          "clipboardWrite"
          "contextMenus"
          "downloads"
          "idle"
          "management"
          "nativeMessaging"
          "notifications"
          "privacy"
          "scripting"
          "storage"
          "tabs"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "https://*/*"
          "http://localhost/*"
          "https://*.1password.ca/*"
          "https://*.1password.com/*"
          "https://*.1password.eu/*"
          "https://*.b5dev.ca/*"
          "https://*.b5dev.com/*"
          "https://*.b5dev.eu/*"
          "https://*.b5local.com/*"
          "https://*.b5staging.com/*"
          "https://*.b5test.ca/*"
          "https://*.b5test.com/*"
          "https://*.b5test.eu/*"
          "https://*.b5rev.com/*"
          "https://app.kolide.com/*"
          "https://auth.kolide.com/*"
          "https://www.director.ai/?*"
          "https://www.director.ai/"
          "https://www.director.ai/complete-1password-pairing?*"
          "https://www.director.ai/complete-1password-pairing"
          "https://autofill.me/*"
        ];
        platforms = platforms.all;
      };
    };
    "onetab" = buildFirefoxXpiAddon {
      pname = "onetab";
      version = "1.83";
      addonId = "extension@one-tab.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4175239/onetab-1.83.xpi";
      sha256 = "e8f6a0dc442cda9309a5cbb5980207affd95ec98ba1f1dd390cecebfb07d0379";
      meta = with lib;
      {
        homepage = "http://www.one-tab.com";
        description = "OneTab - Too many tabs? Convert tabs to a list and reduce browser memory";
        license = {
          shortName = "onetab";
          fullName = "Custom License for OneTab";
          url = "https://addons.mozilla.org/en-US/firefox/addon/onetab/license/";
          free = false;
        };
        mozPermissions = [ "unlimitedStorage" "storage" "tabs" "contextMenus" ];
        platforms = platforms.all;
      };
    };
    "open-in-browser" = buildFirefoxXpiAddon {
      pname = "open-in-browser";
      version = "2.11";
      addonId = "openinbrowser@www.spasche.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/3481016/open_in_browser-2.11.xpi";
      sha256 = "8abbcbfcaffd63d0501e77ae5748ec52ce4df465a83433e2063542ed74a7ce4f";
      meta = with lib;
      {
        homepage = "https://github.com/Rob--W/open-in-browser";
        description = "Offers the possibility to display documents in the browser window.";
        license = licenses.mpl20;
        mozPermissions = [
          "history"
          "menus"
          "sessions"
          "storage"
          "tabs"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "open-in-freedium" = buildFirefoxXpiAddon {
      pname = "open-in-freedium";
      version = "1.1.0";
      addonId = "freedium-browser-extension@wywywywy.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4214075/open_in_freedium-1.1.0.xpi";
      sha256 = "b396390f5c86a4433554f56c4816ef8527b50e1808761e3f9a68d4859192f1a1";
      meta = with lib;
      {
        homepage = "https://github.com/wywywywy/freedium-browser-extension";
        description = "Easily open Medium articles in Freedium to bypass restrictions";
        license = licenses.mit;
        mozPermissions = [ "contextMenus" "storage" ];
        platforms = platforms.all;
      };
    };
    "open-in-vlc" = buildFirefoxXpiAddon {
      pname = "open-in-vlc";
      version = "0.4.4";
      addonId = "{6b954d17-d17c-4a19-8fe6-ee8052a562d6}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4473229/open_in_vlc-0.4.4.xpi";
      sha256 = "f315912714ad8b926aa3188f4f0267c7b1815d6e945b6f299641518b3a70d174";
      meta = with lib;
      {
        homepage = "https://webextension.org/listing/open-in-vlc.html";
        description = "Adds a context menu item to send audio/video streams directly to VLC media player";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "contextMenus"
          "nativeMessaging"
          "webRequest"
          "scripting"
        ];
        platforms = platforms.all;
      };
    };
    "open-url-in-container" = buildFirefoxXpiAddon {
      pname = "open-url-in-container";
      version = "1.0.3";
      addonId = "{f069aec0-43c5-4bbf-b6b4-df95c4326b98}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3566167/open_url_in_container-1.0.3.xpi";
      sha256 = "687211a5fe6ee08c2b3060292858474b27f91383296bc1b6ba0391c00abc2697";
      meta = with lib;
      {
        description = "This extension enables support for opening links in specific containers using custom protocol handler. It works for terminal, OS shortcuts and regular HTML pages.";
        license = licenses.mpl20;
        mozPermissions = [ "contextualIdentities" "cookies" ];
        platforms = platforms.all;
      };
    };
    "org-capture" = buildFirefoxXpiAddon {
      pname = "org-capture";
      version = "0.2.2resigned1";
      addonId = "{ddefd400-12ea-4264-8166-481f23abaa87}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4272196/org_capture-0.2.2resigned1.xpi";
      sha256 = "eac6fdbfb90ff92862228acb7e8d265f1326ddcc4b86f87455d74ae448a22f45";
      meta = with lib;
      {
        homepage = "https://github.com/sprig/org-capture-extension";
        description = "A helper for capturing things via org-protocol in emacs: First, set up: http://orgmode.org/worg/org-contrib/org-protocol.html or https://github.com/sprig/org-capture-extension\n\nSee https://youtu.be/zKDHto-4wsU for example usage";
        license = licenses.mit;
        mozPermissions = [ "activeTab" "storage" ];
        platforms = platforms.all;
      };
    };
    "overbitewx" = buildFirefoxXpiAddon {
      pname = "overbitewx";
      version = "0.4.2resigned1";
      addonId = "overbitewx@floodgap.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4272731/overbitewx-0.4.2resigned1.xpi";
      sha256 = "130335ef18502c7bc50a3f67e91305075f1aedaf359c53c3745b46c689eb0d1a";
      meta = with lib;
      {
        description = "Re-enables the Gopher protocol in Firefox 56 and above, allowing you to enter Gopher URLs and click on Gopher links. Because WebExtensions does not yet have a TCP sockets API, this version redirects your requests to the Floodgap Public Gopher Proxy.";
        license = licenses.mpl20;
        mozPermissions = [ "tabs" ];
        platforms = platforms.all;
      };
    };
    "overview" = buildFirefoxXpiAddon {
      pname = "overview";
      version = "0.5.1resigned1";
      addonId = "{2df83d0b-1ccb-47bb-81c4-1c29f5485776}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4272954/overview-0.5.1resigned1.xpi";
      sha256 = "a65032b723f1d6c94e7a8a2dab1130fc56b6daddd0a48403c1d8a60158321e36";
      meta = with lib;
      {
        homepage = "https://gitlab.petton.fr/DamienCassou/overview";
        description = "Give an overview of a page's headings in a sidebar. The sidebar has links towards each heading in the current page, making it easy to understand the structure and navigate inside the page.";
        license = licenses.mit;
        mozPermissions = [ "activeTab" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "pakkujs" = buildFirefoxXpiAddon {
      pname = "pakkujs";
      version = "2025.9.2";
      addonId = "{646d57f4-d65c-4f0d-8e80-5800b92cfdaa}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4584135/pakkujs-2025.9.2.xpi";
      sha256 = "6ad8de86c433ed39bcefc7f03014db8aa118502de7b8ed96429498d62268e572";
      meta = with lib;
      {
        homepage = "http://s.xmcp.ltd/pakkujs/?src=amo_homepage";
        description = "瞬间过滤B站(bilibili.com)刷屏的相似弹幕，还你清爽的弹幕视频体验。\t\n*a tweak for a Chinese website. Please ignore this add-on if you are not a user of bilibili.com.*";
        license = licenses.gpl3;
        mozPermissions = [
          "notifications"
          "storage"
          "contextMenus"
          "scripting"
          "declarativeNetRequestWithHostAccess"
          "*://*.bilibili.com/*"
          "https://www.bilibili.com/robots.txt?pakku_sandbox"
        ];
        platforms = platforms.all;
      };
    };
    "paperpile" = buildFirefoxXpiAddon {
      pname = "paperpile";
      version = "1.0.85";
      addonId = "firefox-production@paperpile.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4593252/paperpile_addon-1.0.85.xpi";
      sha256 = "21f3bbe476e11ba67ab5d58cbd64311a6b9a8efe00c2dc719270875c9fc775af";
      meta = with lib;
      {
        homepage = "https://paperpile.com/?welcome";
        description = "Collect, organize, annotate and cite your research papers in Firefox.";
        license = {
          shortName = "paperpile-tos";
          fullName = "Paperpile Terms of Service";
          url = "https://paperpile.com/tos/";
          free = false;
        };
        mozPermissions = [
          "contextMenus"
          "tabs"
          "scripting"
          "<all_urls>"
          "storage"
          "unlimitedStorage"
          "declarativeNetRequestWithHostAccess"
          "*://app.paperpile.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "passbolt" = buildFirefoxXpiAddon {
      pname = "passbolt";
      version = "5.6.0";
      addonId = "passbolt@passbolt.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4594043/passbolt-5.6.0.xpi";
      sha256 = "9a11a3f6fd353b3fbed89f564c3c9d629182ca31d57b7898a2e2b7d91951d209";
      meta = with lib;
      {
        homepage = "https://www.passbolt.com";
        description = "Passbolt is an open source password manager designed for collaboration. Securely create, manage and monitor your passwords. Share them instantly with your team.";
        mozPermissions = [
          "activeTab"
          "clipboardWrite"
          "tabs"
          "storage"
          "unlimitedStorage"
          "*://*/*"
          "alarms"
          "cookies"
        ];
        platforms = platforms.all;
      };
    };
    "passff" = buildFirefoxXpiAddon {
      pname = "passff";
      version = "1.23";
      addonId = "passff@invicem.pro";
      url = "https://addons.mozilla.org/firefox/downloads/file/4591422/passff-1.23.xpi";
      sha256 = "696d3d99735dabce398f025d1531f42bcddb86f81c29f4bc7b242697915501db";
      meta = with lib;
      {
        homepage = "https://codeberg.org/PassFF/passff";
        description = "Add-on that allows users of the unix password manager 'pass' to access their password store from Firefox";
        license = licenses.gpl2;
        mozPermissions = [
          "<all_urls>"
          "clipboardWrite"
          "contextMenus"
          "contextualIdentities"
          "nativeMessaging"
          "storage"
          "tabs"
          "webRequest"
          "webRequestBlocking"
        ];
        platforms = platforms.all;
      };
    };
    "pay-by-privacy" = buildFirefoxXpiAddon {
      pname = "pay-by-privacy";
      version = "2.4.15";
      addonId = "privacy@privacy.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4512297/pay_by_privacy-2.4.15.xpi";
      sha256 = "ba3b81ca9b9dc1405328ae82a922e488efcc3388c428c0d6cdad75102a4767db";
      meta = with lib;
      {
        homepage = "https://privacy.com";
        description = "Privacy's Firefox add-on allows you to generate a new virtual card number with 1-click on any checkout page. Keep your payment info safe from data breaches, shady merchants, and sneaky subscription billing.";
        license = {
          shortName = "pay-by-privacy";
          fullName = "Custom License for Privacy | Protect Your Payments";
          url = "https://addons.mozilla.org/en-US/firefox/addon/pay-by-privacy/license/";
          free = false;
        };
        mozPermissions = [
          "storage"
          "tabs"
          "activeTab"
          "cookies"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "peertubeify" = buildFirefoxXpiAddon {
      pname = "peertubeify";
      version = "0.6.1resigned1";
      addonId = "{01175c8e-4506-4263-bad9-d3ddfd4f5a5f}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4275922/peertubeify-0.6.1resigned1.xpi";
      sha256 = "d1752ebf0851b770be57c51e3d1dff7b61a69c12829dada885687c18d4f232b9";
      meta = with lib;
      {
        homepage = "https://gitlab.com/Ealhad/peertubeify";
        description = "PeerTubeify allows to redirect between YouTube and PeerTube and across PeerTube instances, automatically or by displaying a link.\n\nDon't forget to set your preferences :)\n\nPeerTubeify is not affiliated with PeerTube.";
        license = licenses.gpl3;
        mozPermissions = [
          "activeTab"
          "storage"
          "<all_urls>"
          "webRequest"
          "webRequestBlocking"
          "*://*.youtube.com/*"
          "*://*.invidio.us/*"
          "https://*/videos/watch/*"
        ];
        platforms = platforms.all;
      };
    };
    "penetration-testing-kit" = buildFirefoxXpiAddon {
      pname = "penetration-testing-kit";
      version = "8.9.3";
      addonId = "{1ab3d165-d664-4bf2-adb7-fed77f46116f}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4491823/penetration_testing_kit-8.9.3.xpi";
      sha256 = "3d4e48361e278d4040dc5acdc0d6cef024d8d1b1a0acdcc258123cccf09b307b";
      meta = with lib;
      {
        homepage = "https://pentestkit.co.uk/";
        description = "Attention! This version is no longer supported. Use /firefox/addon/owasp-penetration-testing-kit/ extension instead.";
        license = licenses.mit;
        mozPermissions = [
          "<all_urls>"
          "activeTab"
          "cookies"
          "notifications"
          "storage"
          "unlimitedStorage"
          "tabs"
          "webRequest"
          "webRequestBlocking"
          "scripting"
        ];
        platforms = platforms.all;
      };
    };
    "persistentpin" = buildFirefoxXpiAddon {
      pname = "persistentpin";
      version = "1.1.2";
      addonId = "{b8f5b973-7a28-4787-8e94-fdb7504e3991}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4552052/persistentpin-1.1.2.xpi";
      sha256 = "9b21f1c3bef4cc1f14091395ad33140c2a2928d1275f77d8b2d3cbda03bec878";
      meta = with lib;
      {
        homepage = "https://github.com/Faerbit/persistentpin-webextension";
        description = "Pins the same websites across browser restarts.";
        license = licenses.mit;
        mozPermissions = [ "storage" "tabs" "contextMenus" ];
        platforms = platforms.all;
      };
    };
    "pinboard" = buildFirefoxXpiAddon {
      pname = "pinboard";
      version = "5.0.0";
      addonId = "{5158522f-7494-41b1-89ff-00d4cc1d87d3}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3581599/pinboard-5.0.0.xpi";
      sha256 = "767db6bcd7d4ad32478c5a38d513feeea638d1ceff231a97f40fd010a1499e59";
      meta = with lib;
      {
        homepage = "https://browsernative.com/mozilla-firefox-extensions/";
        description = "Unofficial Firefox add-on for Pinboard.in. Bookmark web pages &amp; add notes easily. Keyboard command: Alt + p";
        license = licenses.mpl20;
        mozPermissions = [ "activeTab" "menus" ];
        platforms = platforms.all;
      };
    };
    "pipewire-screenaudio" = buildFirefoxXpiAddon {
      pname = "pipewire-screenaudio";
      version = "0.3.4";
      addonId = "pipewire-screenaudio@icenjim";
      url = "https://addons.mozilla.org/firefox/downloads/file/4186504/pipewire_screenaudio-0.3.4.xpi";
      sha256 = "a74714514f490b6d5c36e32b88510ae3e5e7f1afdcb29c2041a836d3aa484cbe";
      meta = with lib;
      {
        homepage = "https://github.com/IceDBorn/pipewire-screenaudio";
        description = "Passthrough pipewire audio to WebRTC screenshare";
        license = licenses.gpl3;
        mozPermissions = [ "nativeMessaging" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "plasma-integration" = buildFirefoxXpiAddon {
      pname = "plasma-integration";
      version = "1.9.1";
      addonId = "plasma-browser-integration@kde.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4298512/plasma_integration-1.9.1.xpi";
      sha256 = "394a3525185679dd5430d05f980ab6be19d96557560fe86208c21a8807669b33";
      meta = with lib;
      {
        homepage = "http://kde.org";
        description = "Multitask efficiently by controlling browser functions from the Plasma desktop.";
        license = licenses.gpl3;
        mozPermissions = [
          "nativeMessaging"
          "notifications"
          "storage"
          "downloads"
          "tabs"
          "<all_urls>"
          "contextMenus"
          "*://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "play-to-kodi4" = buildFirefoxXpiAddon {
      pname = "play-to-kodi4";
      version = "1.9.2resigned1";
      addonId = "{ba707b6e-571d-47c9-a31d-7b94807d6ee2}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4272730/play_to_kodi4-1.9.2resigned1.xpi";
      sha256 = "56c79b228994ed369231be9536e5c4bcbdc43363737d5f49f1961ea3b738e148";
      meta = with lib;
      {
        homepage = "https://github.com/maciex/play-to-kodi";
        description = "Play, queue and remote control your favourite online media on Kodi / XBMC.\n\nThis is a port of an add-on developed originally for Google Chrome.";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "tabs"
          "*://www.googleapis.com/*"
          "http://*/*"
          "contextMenus"
          "<all_urls>"
          "http://www.liveleak.com/view*"
          "*://*.facebook.com/*"
          "*://www.youtube.com/*"
          "*://soundcloud.com/*"
          "*://streamcloud.eu/*"
          "*://mycloudplayers.com/*"
          "*://*.khanacademy.org/*"
          "*://*.hulu.com/watch/*"
          "*://*.animelab.com/player/*"
          "*://*.lynda.com/*"
          "*://*.urgantshow.ru/page/*"
          "*://*.kino-live.org/*"
          "*://*.vessel.com/*"
          "*://*.cda.pl/*"
          "*://*.xnxx.com/*"
          "*://*.seasonvar.ru/*"
          "*://solarmoviez.to/*"
          "*://vivo.sx/*"
          "*://*.pornhub.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "playback-speed" = buildFirefoxXpiAddon {
      pname = "playback-speed";
      version = "1.4.4";
      addonId = "playbackSpeed@waldemar.b";
      url = "https://addons.mozilla.org/firefox/downloads/file/3864607/playback_speed-1.4.4.xpi";
      sha256 = "49f195fe05ada13b39505f2c0aa44631e287f7d19a2242085e7725443ecc1cfd";
      meta = with lib;
      {
        homepage = "https://github.com/fx4waldi/playbackSpeed";
        description = "Control the speed of video playback.";
        license = licenses.gpl2;
        mozPermissions = [ "tabs" "activeTab" "storage" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "polish-dictionary" = buildFirefoxXpiAddon {
      pname = "polish-dictionary";
      version = "1.0.20160228.2resigned1";
      addonId = "pl@dictionaries.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4270222/polish_spellchecker_dictionary-1.0.20160228.2resigned1.xpi";
      sha256 = "bb3142c5249221856314efc1f362a33a0c315b30ff07133b33440d016e8f9972";
      meta = with lib;
      {
        homepage = "http://www.aviary.pl/";
        description = "Polish spell-check dictionary for Firefox, Thunderbird and SeaMonkey.";
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "polkadot-js" = buildFirefoxXpiAddon {
      pname = "polkadot-js";
      version = "0.61.5";
      addonId = "{7e3ce1f0-15fb-4fb1-99c6-25774749ec6d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4546151/polkadot_js_extension-0.61.5.xpi";
      sha256 = "8de6b3f4e9d1f158d65881bcf8c223b58b4b5547e9612186baf9ea9be6a0be71";
      meta = with lib;
      {
        homepage = "https://github.com/polkadot-js/extension";
        description = "Manage your Polkadot accounts outside of dapps. Injects the accounts and allows signs transactions for a specific account.";
        mozPermissions = [ "storage" "tabs" "http://*/*" "https://*/*" ];
        platforms = platforms.all;
      };
    };
    "print-edit-we" = buildFirefoxXpiAddon {
      pname = "print-edit-we";
      version = "29.7";
      addonId = "printedit-we@DW-dev";
      url = "https://addons.mozilla.org/firefox/downloads/file/4479263/print_edit_we-29.7.xpi";
      sha256 = "fadb392e13666274d09646f5ee34bf07c38a8a152a30c6afc4e23e43b0cb463a";
      meta = with lib;
      {
        description = "Edit the contents of a web page prior to printing or saving. Elements in the web page can be edited, formatted, hidden or deleted. Unwanted content, such as adverts and sidebars, can easily be removed.";
        license = licenses.gpl2;
        mozPermissions = [
          "<all_urls>"
          "tabs"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "contextMenus"
          "notifications"
          "storage"
        ];
        platforms = platforms.all;
      };
    };
    "print-friendly-pdf" = buildFirefoxXpiAddon {
      pname = "print-friendly-pdf";
      version = "6.6.3";
      addonId = "jid0-YQz0l1jthOIz179ehuitYAOdBEs@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4588195/print_friendly_pdf-6.6.3.xpi";
      sha256 = "ca51fdd920f030726b8b5b8a2a8d53b2af0976f581a62233e7d1e4ca945984b7";
      meta = with lib;
      {
        homepage = "https://www.printfriendly.com/";
        description = "Make web pages printer-friendly, convert to PDFs, or capture full page screenshots. Remove ads for clean pages ready to print or save as PDFs.";
        license = {
          shortName = "print-friendly-pdf";
          fullName = "Custom License for Print Friendly & PDF";
          url = "https://addons.mozilla.org/en-US/firefox/addon/print-friendly-pdf/license/";
          free = false;
        };
        mozPermissions = [
          "activeTab"
          "contextMenus"
          "scripting"
          "storage"
          "unlimitedStorage"
        ];
        platforms = platforms.all;
      };
    };
    "print-to-pdf-document" = buildFirefoxXpiAddon {
      pname = "print-to-pdf-document";
      version = "0.1.1";
      addonId = "{9ab38051-cd73-4e46-b7bd-dc147f6f6b29}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3985408/print_to_pdf_document-0.1.1.xpi";
      sha256 = "d4d37118865ae9a2c6dd38b4898b8ca65a49894833935b7194713cc478e78dd4";
      meta = with lib;
      {
        homepage = "https://mybrowseraddon.com/print-to-pdf.html";
        description = "Easily print any page to PDF with just one click!";
        license = licenses.mpl20;
        mozPermissions = [ "tabs" "storage" "<all_urls>" "contextMenus" ];
        platforms = platforms.all;
      };
    };
    "privacy-badger" = buildFirefoxXpiAddon {
      pname = "privacy-badger";
      version = "2025.9.2";
      addonId = "jid1-MnnxcxisBPnSXQ@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4570378/privacy_badger17-2025.9.2.xpi";
      sha256 = "a7bcc6a8138373cc3721089baee846df228ca7ca9ca87e10b946c20811bd2d0f";
      meta = with lib;
      {
        homepage = "https://privacybadger.org/";
        description = "Automatically learns to block hidden trackers. Made by the leading digital rights nonprofit EFF to stop companies from spying on you.";
        license = licenses.gpl3;
        mozPermissions = [
          "<all_urls>"
          "alarms"
          "privacy"
          "storage"
          "tabs"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "https://*.facebook.com/*"
          "http://*.facebook.com/*"
          "https://*.messenger.com/*"
          "http://*.messenger.com/*"
          "*://*.facebookcorewwwi.onion/*"
          "https://docs.google.com/*"
          "http://docs.google.com/*"
          "https://mail.google.com/*"
          "http://mail.google.com/*"
          "https://www.google.com/*"
          "http://www.google.com/*"
          "https://www.google.ad/*"
          "http://www.google.ad/*"
          "https://www.google.ae/*"
          "http://www.google.ae/*"
          "https://www.google.com.af/*"
          "http://www.google.com.af/*"
          "https://www.google.com.ag/*"
          "http://www.google.com.ag/*"
          "https://www.google.com.ai/*"
          "http://www.google.com.ai/*"
          "https://www.google.al/*"
          "http://www.google.al/*"
          "https://www.google.am/*"
          "http://www.google.am/*"
          "https://www.google.co.ao/*"
          "http://www.google.co.ao/*"
          "https://www.google.com.ar/*"
          "http://www.google.com.ar/*"
          "https://www.google.as/*"
          "http://www.google.as/*"
          "https://www.google.at/*"
          "http://www.google.at/*"
          "https://www.google.com.au/*"
          "http://www.google.com.au/*"
          "https://www.google.az/*"
          "http://www.google.az/*"
          "https://www.google.ba/*"
          "http://www.google.ba/*"
          "https://www.google.com.bd/*"
          "http://www.google.com.bd/*"
          "https://www.google.be/*"
          "http://www.google.be/*"
          "https://www.google.bf/*"
          "http://www.google.bf/*"
          "https://www.google.bg/*"
          "http://www.google.bg/*"
          "https://www.google.com.bh/*"
          "http://www.google.com.bh/*"
          "https://www.google.bi/*"
          "http://www.google.bi/*"
          "https://www.google.bj/*"
          "http://www.google.bj/*"
          "https://www.google.com.bn/*"
          "http://www.google.com.bn/*"
          "https://www.google.com.bo/*"
          "http://www.google.com.bo/*"
          "https://www.google.com.br/*"
          "http://www.google.com.br/*"
          "https://www.google.bs/*"
          "http://www.google.bs/*"
          "https://www.google.bt/*"
          "http://www.google.bt/*"
          "https://www.google.co.bw/*"
          "http://www.google.co.bw/*"
          "https://www.google.by/*"
          "http://www.google.by/*"
          "https://www.google.com.bz/*"
          "http://www.google.com.bz/*"
          "https://www.google.ca/*"
          "http://www.google.ca/*"
          "https://www.google.cd/*"
          "http://www.google.cd/*"
          "https://www.google.cf/*"
          "http://www.google.cf/*"
          "https://www.google.cg/*"
          "http://www.google.cg/*"
          "https://www.google.ch/*"
          "http://www.google.ch/*"
          "https://www.google.ci/*"
          "http://www.google.ci/*"
          "https://www.google.co.ck/*"
          "http://www.google.co.ck/*"
          "https://www.google.cl/*"
          "http://www.google.cl/*"
          "https://www.google.cm/*"
          "http://www.google.cm/*"
          "https://www.google.cn/*"
          "http://www.google.cn/*"
          "https://www.google.com.co/*"
          "http://www.google.com.co/*"
          "https://www.google.co.cr/*"
          "http://www.google.co.cr/*"
          "https://www.google.com.cu/*"
          "http://www.google.com.cu/*"
          "https://www.google.cv/*"
          "http://www.google.cv/*"
          "https://www.google.com.cy/*"
          "http://www.google.com.cy/*"
          "https://www.google.cz/*"
          "http://www.google.cz/*"
          "https://www.google.de/*"
          "http://www.google.de/*"
          "https://www.google.dj/*"
          "http://www.google.dj/*"
          "https://www.google.dk/*"
          "http://www.google.dk/*"
          "https://www.google.dm/*"
          "http://www.google.dm/*"
          "https://www.google.com.do/*"
          "http://www.google.com.do/*"
          "https://www.google.dz/*"
          "http://www.google.dz/*"
          "https://www.google.com.ec/*"
          "http://www.google.com.ec/*"
          "https://www.google.ee/*"
          "http://www.google.ee/*"
          "https://www.google.com.eg/*"
          "http://www.google.com.eg/*"
          "https://www.google.es/*"
          "http://www.google.es/*"
          "https://www.google.com.et/*"
          "http://www.google.com.et/*"
          "https://www.google.fi/*"
          "http://www.google.fi/*"
          "https://www.google.com.fj/*"
          "http://www.google.com.fj/*"
          "https://www.google.fm/*"
          "http://www.google.fm/*"
          "https://www.google.fr/*"
          "http://www.google.fr/*"
          "https://www.google.ga/*"
          "http://www.google.ga/*"
          "https://www.google.ge/*"
          "http://www.google.ge/*"
          "https://www.google.gg/*"
          "http://www.google.gg/*"
          "https://www.google.com.gh/*"
          "http://www.google.com.gh/*"
          "https://www.google.com.gi/*"
          "http://www.google.com.gi/*"
          "https://www.google.gl/*"
          "http://www.google.gl/*"
          "https://www.google.gm/*"
          "http://www.google.gm/*"
          "https://www.google.gr/*"
          "http://www.google.gr/*"
          "https://www.google.com.gt/*"
          "http://www.google.com.gt/*"
          "https://www.google.gy/*"
          "http://www.google.gy/*"
          "https://www.google.com.hk/*"
          "http://www.google.com.hk/*"
          "https://www.google.hn/*"
          "http://www.google.hn/*"
          "https://www.google.hr/*"
          "http://www.google.hr/*"
          "https://www.google.ht/*"
          "http://www.google.ht/*"
          "https://www.google.hu/*"
          "http://www.google.hu/*"
          "https://www.google.co.id/*"
          "http://www.google.co.id/*"
          "https://www.google.ie/*"
          "http://www.google.ie/*"
          "https://www.google.co.il/*"
          "http://www.google.co.il/*"
          "https://www.google.im/*"
          "http://www.google.im/*"
          "https://www.google.co.in/*"
          "http://www.google.co.in/*"
          "https://www.google.iq/*"
          "http://www.google.iq/*"
          "https://www.google.is/*"
          "http://www.google.is/*"
          "https://www.google.it/*"
          "http://www.google.it/*"
          "https://www.google.je/*"
          "http://www.google.je/*"
          "https://www.google.com.jm/*"
          "http://www.google.com.jm/*"
          "https://www.google.jo/*"
          "http://www.google.jo/*"
          "https://www.google.co.jp/*"
          "http://www.google.co.jp/*"
          "https://www.google.co.ke/*"
          "http://www.google.co.ke/*"
          "https://www.google.com.kh/*"
          "http://www.google.com.kh/*"
          "https://www.google.ki/*"
          "http://www.google.ki/*"
          "https://www.google.kg/*"
          "http://www.google.kg/*"
          "https://www.google.co.kr/*"
          "http://www.google.co.kr/*"
          "https://www.google.com.kw/*"
          "http://www.google.com.kw/*"
          "https://www.google.kz/*"
          "http://www.google.kz/*"
          "https://www.google.la/*"
          "http://www.google.la/*"
          "https://www.google.com.lb/*"
          "http://www.google.com.lb/*"
          "https://www.google.li/*"
          "http://www.google.li/*"
          "https://www.google.lk/*"
          "http://www.google.lk/*"
          "https://www.google.co.ls/*"
          "http://www.google.co.ls/*"
          "https://www.google.lt/*"
          "http://www.google.lt/*"
          "https://www.google.lu/*"
          "http://www.google.lu/*"
          "https://www.google.lv/*"
          "http://www.google.lv/*"
          "https://www.google.com.ly/*"
          "http://www.google.com.ly/*"
          "https://www.google.co.ma/*"
          "http://www.google.co.ma/*"
          "https://www.google.md/*"
          "http://www.google.md/*"
          "https://www.google.me/*"
          "http://www.google.me/*"
          "https://www.google.mg/*"
          "http://www.google.mg/*"
          "https://www.google.mk/*"
          "http://www.google.mk/*"
          "https://www.google.ml/*"
          "http://www.google.ml/*"
          "https://www.google.com.mm/*"
          "http://www.google.com.mm/*"
          "https://www.google.mn/*"
          "http://www.google.mn/*"
          "https://www.google.ms/*"
          "http://www.google.ms/*"
          "https://www.google.com.mt/*"
          "http://www.google.com.mt/*"
          "https://www.google.mu/*"
          "http://www.google.mu/*"
          "https://www.google.mv/*"
          "http://www.google.mv/*"
          "https://www.google.mw/*"
          "http://www.google.mw/*"
          "https://www.google.com.mx/*"
          "http://www.google.com.mx/*"
          "https://www.google.com.my/*"
          "http://www.google.com.my/*"
          "https://www.google.co.mz/*"
          "http://www.google.co.mz/*"
          "https://www.google.com.na/*"
          "http://www.google.com.na/*"
          "https://www.google.com.ng/*"
          "http://www.google.com.ng/*"
          "https://www.google.com.ni/*"
          "http://www.google.com.ni/*"
          "https://www.google.ne/*"
          "http://www.google.ne/*"
          "https://www.google.nl/*"
          "http://www.google.nl/*"
          "https://www.google.no/*"
          "http://www.google.no/*"
          "https://www.google.com.np/*"
          "http://www.google.com.np/*"
          "https://www.google.nr/*"
          "http://www.google.nr/*"
          "https://www.google.nu/*"
          "http://www.google.nu/*"
          "https://www.google.co.nz/*"
          "http://www.google.co.nz/*"
          "https://www.google.com.om/*"
          "http://www.google.com.om/*"
          "https://www.google.com.pa/*"
          "http://www.google.com.pa/*"
          "https://www.google.com.pe/*"
          "http://www.google.com.pe/*"
          "https://www.google.com.pg/*"
          "http://www.google.com.pg/*"
          "https://www.google.com.ph/*"
          "http://www.google.com.ph/*"
          "https://www.google.com.pk/*"
          "http://www.google.com.pk/*"
          "https://www.google.pl/*"
          "http://www.google.pl/*"
          "https://www.google.pn/*"
          "http://www.google.pn/*"
          "https://www.google.com.pr/*"
          "http://www.google.com.pr/*"
          "https://www.google.ps/*"
          "http://www.google.ps/*"
          "https://www.google.pt/*"
          "http://www.google.pt/*"
          "https://www.google.com.py/*"
          "http://www.google.com.py/*"
          "https://www.google.com.qa/*"
          "http://www.google.com.qa/*"
          "https://www.google.ro/*"
          "http://www.google.ro/*"
          "https://www.google.ru/*"
          "http://www.google.ru/*"
          "https://www.google.rw/*"
          "http://www.google.rw/*"
          "https://www.google.com.sa/*"
          "http://www.google.com.sa/*"
          "https://www.google.com.sb/*"
          "http://www.google.com.sb/*"
          "https://www.google.sc/*"
          "http://www.google.sc/*"
          "https://www.google.se/*"
          "http://www.google.se/*"
          "https://www.google.com.sg/*"
          "http://www.google.com.sg/*"
          "https://www.google.sh/*"
          "http://www.google.sh/*"
          "https://www.google.si/*"
          "http://www.google.si/*"
          "https://www.google.sk/*"
          "http://www.google.sk/*"
          "https://www.google.com.sl/*"
          "http://www.google.com.sl/*"
          "https://www.google.sn/*"
          "http://www.google.sn/*"
          "https://www.google.so/*"
          "http://www.google.so/*"
          "https://www.google.sm/*"
          "http://www.google.sm/*"
          "https://www.google.sr/*"
          "http://www.google.sr/*"
          "https://www.google.st/*"
          "http://www.google.st/*"
          "https://www.google.com.sv/*"
          "http://www.google.com.sv/*"
          "https://www.google.td/*"
          "http://www.google.td/*"
          "https://www.google.tg/*"
          "http://www.google.tg/*"
          "https://www.google.co.th/*"
          "http://www.google.co.th/*"
          "https://www.google.com.tj/*"
          "http://www.google.com.tj/*"
          "https://www.google.tl/*"
          "http://www.google.tl/*"
          "https://www.google.tm/*"
          "http://www.google.tm/*"
          "https://www.google.tn/*"
          "http://www.google.tn/*"
          "https://www.google.to/*"
          "http://www.google.to/*"
          "https://www.google.com.tr/*"
          "http://www.google.com.tr/*"
          "https://www.google.tt/*"
          "http://www.google.tt/*"
          "https://www.google.com.tw/*"
          "http://www.google.com.tw/*"
          "https://www.google.co.tz/*"
          "http://www.google.co.tz/*"
          "https://www.google.com.ua/*"
          "http://www.google.com.ua/*"
          "https://www.google.co.ug/*"
          "http://www.google.co.ug/*"
          "https://www.google.co.uk/*"
          "http://www.google.co.uk/*"
          "https://www.google.com.uy/*"
          "http://www.google.com.uy/*"
          "https://www.google.co.uz/*"
          "http://www.google.co.uz/*"
          "https://www.google.com.vc/*"
          "http://www.google.com.vc/*"
          "https://www.google.co.ve/*"
          "http://www.google.co.ve/*"
          "https://www.google.vg/*"
          "http://www.google.vg/*"
          "https://www.google.co.vi/*"
          "http://www.google.co.vi/*"
          "https://www.google.com.vn/*"
          "http://www.google.com.vn/*"
          "https://www.google.vu/*"
          "http://www.google.vu/*"
          "https://www.google.ws/*"
          "http://www.google.ws/*"
          "https://www.google.rs/*"
          "http://www.google.rs/*"
          "https://www.google.co.za/*"
          "http://www.google.co.za/*"
          "https://www.google.co.zm/*"
          "http://www.google.co.zm/*"
          "https://www.google.co.zw/*"
          "http://www.google.co.zw/*"
          "https://www.google.cat/*"
          "http://www.google.cat/*"
        ];
        platforms = platforms.all;
      };
    };
    "privacy-pass" = buildFirefoxXpiAddon {
      pname = "privacy-pass";
      version = "4.0.2";
      addonId = "{48748554-4c01-49e8-94af-79662bf34d50}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4258867/privacy_pass-4.0.2.xpi";
      sha256 = "48e832600bdd47639d17ed2a99ea74d2eb1e12728e8b743a7057420b7f72102f";
      meta = with lib;
      {
        homepage = "https://github.com/cloudflare/pp-browser-extension";
        description = "Client support for Privacy Pass anonymous authorization protocol.";
        license = licenses.bsd2;
        mozPermissions = [
          "<all_urls>"
          "storage"
          "tabs"
          "webRequest"
          "webRequestBlocking"
        ];
        platforms = platforms.all;
      };
    };
    "privacy-possum" = buildFirefoxXpiAddon {
      pname = "privacy-possum";
      version = "2019.7.18";
      addonId = "woop-NoopscooPsnSXQ@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3360398/privacy_possum-2019.7.18.xpi";
      sha256 = "0840a8c443e25d8a65da22ce1b557216456b900a699b3541e42e1b47e8cb6c0e";
      meta = with lib;
      {
        homepage = "https://github.com/cowlicks/privacypossum";
        description = "Privacy Possum monkey wrenches common commercial tracking methods by reducing and falsifying the data gathered by tracking companies.";
        license = licenses.gpl3;
        mozPermissions = [
          "tabs"
          "http://*/*"
          "https://*/*"
          "contextMenus"
          "webRequest"
          "webRequestBlocking"
          "webNavigation"
          "storage"
          "cookies"
          "*://twitter.com/*"
          "*://tweetdeck.twitter.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "privacy-redirect" = buildFirefoxXpiAddon {
      pname = "privacy-redirect";
      version = "1.1.49";
      addonId = "{b7f9d2cd-d772-4302-8c3f-eb941af36f76}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3815058/privacy_redirect-1.1.49.xpi";
      sha256 = "9f1cf6e58fa3f86d180b5b99549fa666fa853a827c48cb231558566b0c1c3c75";
      meta = with lib;
      {
        homepage = "https://github.com/SimonBrazell/privacy-redirect";
        description = "Redirects Twitter, YouTube, Instagram and more to privacy friendly alternatives.";
        license = licenses.gpl3Plus;
        mozPermissions = [
          "storage"
          "webRequest"
          "webRequestBlocking"
          "<all_urls>"
          "*://twitter.com/*"
          "*://www.twitter.com/*"
          "*://mobile.twitter.com/*"
          "*://pbs.twimg.com/*"
          "*://video.twimg.com/*"
          "*://invidious.snopyta.org/*"
          "*://invidious.xyz/*"
          "*://invidious.kavin.rocks/*"
          "*://tube.connect.cafe/*"
          "*://invidious.zapashcanon.fr/*"
          "*://invidiou.site/*"
          "*://vid.mint.lgbt/*"
          "*://invidious.site/*"
          "*://yewtu.be/*"
          "*://invidious.tube/*"
          "*://invidious.silkky.cloud/*"
          "*://invidious.himiko.cloud/*"
          "*://inv.skyn3t.in/*"
          "*://tube.incognet.io/*"
          "*://invidious.tinfoil-hat.net/*"
          "*://invidious.namazso.eu/*"
          "*://vid.puffyan.us/*"
          "*://dev.viewtube.io/*"
          "*://invidious.048596.xyz/*"
          "*://fz253lmuao3strwbfbmx46yu7acac2jz27iwtorgmbqlkurlclmancad.onion/*"
          "*://qklhadlycap4cnod.onion/*"
          "*://c7hqkpkpemu6e7emz5b4vyz7idjgdvgaaa3dyimmeojqbgpea3xqjoid.onion/*"
          "*://w6ijuptxiku4xpnnaetxvnkc5vqcdu7mgns2u77qefoixi63vbvnpnqd.onion/*"
        ];
        platforms = platforms.all;
      };
    };
    "privacy-settings" = buildFirefoxXpiAddon {
      pname = "privacy-settings";
      version = "0.3.8resigned1";
      addonId = "jid1-CKHySAadH4nL6Q@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4270684/privacy_settings-0.3.8resigned1.xpi";
      sha256 = "23cbe4241a4feca21d33b615399916bafddc4b1fc9f92ecbfc7640208588daff";
      meta = with lib;
      {
        homepage = "http://add0n.com/privacy-settings.html";
        description = "Alter Firefox's built-in privacy settings easily with a toolbar panel.";
        license = licenses.mpl20;
        mozPermissions = [ "privacy" "storage" "contextMenus" ];
        platforms = platforms.all;
      };
    };
    "private-grammar-checker-harper" = buildFirefoxXpiAddon {
      pname = "private-grammar-checker-harper";
      version = "0.70.0";
      addonId = "harper@writewithharper.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4606997/private_grammar_checker_harper-0.70.0.xpi";
      sha256 = "2bf711901379221aca0e566928d8aec76fc57f2e0a6d3b2a0bdd5be4d1e96370";
      meta = with lib;
      {
        homepage = "https://writewithharper.com";
        description = "A private grammar checker for 21st Century English";
        license = licenses.asl20;
        mozPermissions = [ "storage" "tabs" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "private-relay" = buildFirefoxXpiAddon {
      pname = "private-relay";
      version = "2.8.1";
      addonId = "private-relay@firefox.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4205650/private_relay-2.8.1.xpi";
      sha256 = "4a85ddc1cd19d2a156c4efe76225d424c0c32e700ab77601f8c1e50d7975cd9d";
      meta = with lib;
      {
        homepage = "https://relay.firefox.com/";
        description = "Firefox Relay lets you generate email aliases that forward to your real inbox. Use it to hide your real email address and protect yourself from hackers and unwanted mail.";
        license = licenses.mpl20;
        mozPermissions = [
          "<all_urls>"
          "storage"
          "menus"
          "contextMenus"
          "https://relay.firefox.com/"
          "https://relay.firefox.com/**"
          "https://relay.firefox.com/accounts/profile/**"
          "https://relay.firefox.com/accounts/settings/**"
        ];
        platforms = platforms.all;
      };
    };
    "profile-switcher" = buildFirefoxXpiAddon {
      pname = "profile-switcher";
      version = "1.3.1";
      addonId = "profile-switcher-ff@nd.ax";
      url = "https://addons.mozilla.org/firefox/downloads/file/3945999/profile_switcher-1.3.1.xpi";
      sha256 = "80ca410ad883a0a2a2dc50cb1f74474dd829223ce106a5911120461c30e4e64f";
      meta = with lib;
      {
        homepage = "https://github.com/null-dev/firefox-profile-switcher";
        description = "Create, manage and switch between browser profiles seamlessly.";
        license = licenses.gpl3;
        mozPermissions = [ "storage" "nativeMessaging" "tabs" ];
        platforms = platforms.all;
      };
    };
    "prometheus-formatter" = buildFirefoxXpiAddon {
      pname = "prometheus-formatter";
      version = "3.2.0";
      addonId = "prometheus-formatter@frederic-hemberger.de";
      url = "https://addons.mozilla.org/firefox/downloads/file/4409277/prometheus_formatter-3.2.0.xpi";
      sha256 = "f7a10896f573439f026b44f6911d1839fc4ea0583981eb0162bc13aa077d12e9";
      meta = with lib;
      {
        homepage = "https://github.com/fhemberger/prometheus-formatter";
        description = "Makes plain Prometheus/OpenMetrics endpoints easier to read.";
        license = licenses.mit;
        mozPermissions = [ "storage" "http://*/*" "https://*/*" ];
        platforms = platforms.all;
      };
    };
    "promnesia" = buildFirefoxXpiAddon {
      pname = "promnesia";
      version = "1.3.1";
      addonId = "{07c6b8e1-94f7-4bbf-8e91-26c0a8992ab5}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4298718/promnesia-1.3.1.xpi";
      sha256 = "1e98071a762cf21f772bab6fcd84fd878924cc5e58529edb2a93a509d1a2a6c1";
      meta = with lib;
      {
        homepage = "https://github.com/karlicoss/promnesia";
        description = "Enhancement of your browsing history";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "webNavigation"
          "contextMenus"
          "notifications"
          "bookmarks"
          "history"
          "scripting"
          "file:///*"
          "http://*/"
          "https://*/"
        ];
        platforms = platforms.all;
      };
    };
    "pronoundb" = buildFirefoxXpiAddon {
      pname = "pronoundb";
      version = "0.14.6";
      addonId = "firefox-addon@pronoundb.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4376744/pronoundb-0.14.6.xpi";
      sha256 = "5fb1f32c2584e90a1fc8ae5c5471584fa0d4ec0e6af80c6a2d1be8fe64c4ad00";
      meta = with lib;
      {
        homepage = "https://pronoundb.org";
        description = "PronounDB is a browser extension that helps people know each other's pronouns easily and instantly. Whether hanging out on a Twitch chat, or on any of the supported platforms, PronounDB will make your life easier.";
        license = licenses.bsd2;
        mozPermissions = [
          "activeTab"
          "storage"
          "https://*.pronoundb.org/*"
          "https://*.discord.com/*"
          "https://*.github.com/*"
          "https://*.modrinth.com/*"
          "https://*.twitch.tv/*"
          "https://*.twitter.com/*"
          "https://*.x.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "proton-pass" = buildFirefoxXpiAddon {
      pname = "proton-pass";
      version = "1.32.11";
      addonId = "78272b6fa58f4a1abaac99321d503a20@proton.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/4605215/proton_pass-1.32.11.xpi";
      sha256 = "c99a67060f80d2886432f76070923ba0d1f5b9fb0cefbe57983c55b678a106e3";
      meta = with lib;
      {
        homepage = "https://proton.me";
        description = "Free and unlimited password manager to keep your login credentials safe and manage them directly in your browser.";
        license = licenses.gpl3;
        mozPermissions = [
          "activeTab"
          "alarms"
          "scripting"
          "storage"
          "unlimitedStorage"
          "webRequest"
          "webRequestBlocking"
          "https://*/*"
          "http://*/*"
          "https://account.proton.me/*"
          "https://pass.proton.me/*"
        ];
        platforms = platforms.all;
      };
    };
    "proton-vpn" = buildFirefoxXpiAddon {
      pname = "proton-vpn";
      version = "1.2.10";
      addonId = "vpn@proton.ch";
      url = "https://addons.mozilla.org/firefox/downloads/file/4580763/proton_vpn_firefox_extension-1.2.10.xpi";
      sha256 = "63063ab30bf1b02aaaa54d3f3e7902811683093b10fdd55dc410345a8dcae1d5";
      meta = with lib;
      {
        homepage = "https://protonvpn.com/";
        description = "Secure your internet and protect your online privacy in one click.";
        license = licenses.gpl3;
        mozPermissions = [
          "idle"
          "notifications"
          "privacy"
          "scripting"
          "storage"
          "tabs"
          "webRequest"
          "activeTab"
          "webRequestBlocking"
          "https://account.protonvpn.com/*"
          "https://account.proton.me/*"
        ];
        platforms = platforms.all;
      };
    };
    "protondb-for-steam" = buildFirefoxXpiAddon {
      pname = "protondb-for-steam";
      version = "2.3.0";
      addonId = "{30280527-c46c-4e03-bb16-2e3ed94fa57c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4490230/protondb_for_steam-2.3.0.xpi";
      sha256 = "e5ab8d594cd71c7a345a6694620ad9c4a3abb97161a191b72484f5b934ba96c5";
      meta = with lib;
      {
        homepage = "https://github.com/tryton-vanmeer/ProtonDB-for-Steam#protondb-for-steam";
        description = "Shows ratings from protondb.com on Steam";
        license = licenses.lgpl3;
        mozPermissions = [
          "https://www.protondb.com/*"
          "https://store.steampowered.com/app/*"
          "https://store.steampowered.com/wishlist/*"
          "https://steamcommunity.com/id/*/games"
          "https://steamcommunity.com/id/*/games?tab=*"
        ];
        platforms = platforms.all;
      };
    };
    "protoots" = buildFirefoxXpiAddon {
      pname = "protoots";
      version = "1.2.3";
      addonId = "protoots@trans.rights";
      url = "https://addons.mozilla.org/firefox/downloads/file/4291719/protoots-1.2.3.xpi";
      sha256 = "c0e1fe1e08d38f253a7144d178a17d3dd9e4ea75ce3164cfa99b3193626c8912";
      meta = with lib;
      {
        homepage = "https://github.com/ItsVipra/ProToots";
        description = "puts pronouns next to usernames on mastodon";
        license = licenses.osl3;
        mozPermissions = [
          "storage"
          "https://en.pronouns.page/api/*"
          "*://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "purpleadblock" = buildFirefoxXpiAddon {
      pname = "purpleadblock";
      version = "2.6.7";
      addonId = "{a7399979-5203-4489-9861-b168187b52e1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4412968/purpleadblock-2.6.7.xpi";
      sha256 = "0740e6f56f1c918fa5448595a4efc1a982ade104634952d0194c53d79c765029";
      meta = with lib;
      {
        description = "Purple AdBlock is a adblock for Twitch.tv";
        license = licenses.gpl3;
        mozPermissions = [ "https://*.twitch.tv/*" "activeTab" "storage" ];
        platforms = platforms.all;
      };
    };
    "pushbullet" = buildFirefoxXpiAddon {
      pname = "pushbullet";
      version = "366";
      addonId = "jid1-BYcQOfYfmBMd9A@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4088745/pushbullet-366.xpi";
      sha256 = "556d3b42a71ac1c032cbcd0c91106a5773fbd07fb65a3362a908a89823cad96f";
      meta = with lib;
      {
        homepage = "https://www.pushbullet.com";
        description = "Pushbullet enables you to see your calls and texts on your computer and easily send links and files from your computer to phone.";
        license = licenses.mpl20;
        mozPermissions = [
          "activeTab"
          "contextMenus"
          "cookies"
          "notifications"
          "idle"
          "https://*.pushbullet.com/*"
          "http://*.pushbullet.com/*"
          "http://localhost:20807/*"
        ];
        platforms = platforms.all;
      };
    };
    "pwas-for-firefox" = buildFirefoxXpiAddon {
      pname = "pwas-for-firefox";
      version = "2.16.0";
      addonId = "firefoxpwa@filips.si";
      url = "https://addons.mozilla.org/firefox/downloads/file/4577733/pwas_for_firefox-2.16.0.xpi";
      sha256 = "241a538c93dc5e1eb3b5982c44df546a8755f315a6338bf2a68cf4cfc30915e2";
      meta = with lib;
      {
        homepage = "https://github.com/filips123/PWAsForFirefox";
        description = "A tool to install, manage and use Progressive Web Apps (PWAs) in Mozilla Firefox";
        license = licenses.mpl20;
        mozPermissions = [
          "http://*/*"
          "https://*/*"
          "nativeMessaging"
          "notifications"
          "storage"
        ];
        platforms = platforms.all;
      };
    };
    "pywalfox" = buildFirefoxXpiAddon {
      pname = "pywalfox";
      version = "2.0.11";
      addonId = "pywalfox@frewacom.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4061156/pywalfox-2.0.11.xpi";
      sha256 = "df6eab2d2224b23f442d5d6044f4718ec153c197c96191e2bfe0addb2b088137";
      meta = with lib;
      {
        homepage = "https://github.com/frewacom/Pywalfox";
        description = "Dynamic theming of Firefox using your Pywal colors";
        license = licenses.mpl20;
        mozPermissions = [
          "nativeMessaging"
          "theme"
          "storage"
          "tabs"
          "alarms"
          "*://*.duckduckgo.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "qr-code-address-bar" = buildFirefoxXpiAddon {
      pname = "qr-code-address-bar";
      version = "1.4";
      addonId = "{a218c3db-51ef-4170-804b-eb053fc9a2cd}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4563248/qr_code_address_bar-1.4.xpi";
      sha256 = "2b157be867216517315887e8d91ab894a7d62e6ec750af8c4aaf2b6b7360f936";
      meta = with lib;
      {
        description = "Adds a button to the address bar to get the current url as a qr code";
        license = licenses.gpl3;
        mozPermissions = [ "activeTab" "menus" ];
        platforms = platforms.all;
      };
    };
    "quality-of-rwth" = buildFirefoxXpiAddon {
      pname = "quality-of-rwth";
      version = "1.13.0";
      addonId = "quality-of-rwth@RcCookie";
      url = "https://addons.mozilla.org/firefox/downloads/file/4602184/quality_of_rwth-1.13.0.xpi";
      sha256 = "faffb77a83d674666bad5380b4b65bc02f255cfa9d1674cc3812f73cf775ed3b";
      meta = with lib;
      {
        description = "Makes RWTH websites more enjoyable";
        license = licenses.mit;
        mozPermissions = [
          "*://*.rwth-aachen.de/*"
          "*://*.rwth.video/*"
          "storage"
          "downloads"
          "webRequest"
          "webRequestBlocking"
        ];
        platforms = platforms.all;
      };
    };
    "qwant-search" = buildFirefoxXpiAddon {
      pname = "qwant-search";
      version = "7.1.2";
      addonId = "qwant-search-firefox@qwant.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4345028/qwant_the_search_engine-7.1.2.xpi";
      sha256 = "6b19d395926f4dec14c125c58e0f4484766fd575b8863011842e9c14da7844d5";
      meta = with lib;
      {
        homepage = "https://www.qwant.com/";
        description = "With this extension, Qwant becomes your default search engine on your browser! 🚀";
        license = licenses.gpl3;
        mozPermissions = [ "https://*.qwant.com/*" ];
        platforms = platforms.all;
      };
    };
    "qwant-tracker-blocker" = buildFirefoxXpiAddon {
      pname = "qwant-tracker-blocker";
      version = "8.1.0";
      addonId = "qwantcomforfirefox@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4374970/qwantcom_for_firefox-8.1.0.xpi";
      sha256 = "b5d90ab023b849febbea8660848f050401a956b8b236b617271fef6800dc2731";
      meta = with lib;
      {
        homepage = "https://help.qwant.com/en/docs/qwant-search/add-qwant-on-desktop/on-firefox/";
        description = "The Qwant extension sets qwant.com as your default search engine and blocks trackers.";
        license = licenses.gpl3;
        mozPermissions = [
          "declarativeNetRequest"
          "webNavigation"
          "storage"
          "tabs"
          "cookies"
          "https://*.qwant.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "rabattcorner" = buildFirefoxXpiAddon {
      pname = "rabattcorner";
      version = "2.1.7";
      addonId = "jid1-7eplFgLu6atoog@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4592458/rabattcorner-2.1.7.xpi";
      sha256 = "d9a3c397d84cd896661a1c2c5dc87b1ce7490e97bae0109a16be25f0ecfda533";
      meta = with lib;
      {
        homepage = "https://www.rabattcorner.ch";
        description = "Mit der Rabattcorner Cashback-Erinnerung kannst du beim Online-Shoppen bei über 800 Partnern Geld zurück bekommen.";
        license = licenses.mpl20;
        mozPermissions = [
          "cookies"
          "storage"
          "alarms"
          "tabs"
          "*://*.rabattcorner.ch/*"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "raindropio" = buildFirefoxXpiAddon {
      pname = "raindropio";
      version = "6.6.91";
      addonId = "jid0-adyhmvsP91nUO8pRv0Mn2VKeB84@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4570192/raindropio-6.6.91.xpi";
      sha256 = "643aa5fff66f0c41e648003127f44253b6eadf997d2632fb76ad390d2eaed1e4";
      meta = with lib;
      {
        homepage = "https://raindrop.io";
        description = "All-in-one bookmark manager";
        license = licenses.mpl20;
        mozPermissions = [ "contextMenus" "activeTab" "scripting" "storage" ];
        platforms = platforms.all;
      };
    };
    "re-enable-right-click" = buildFirefoxXpiAddon {
      pname = "re-enable-right-click";
      version = "0.6.6";
      addonId = "{278b0ae0-da9d-4cc6-be81-5aa7f3202672}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4555366/re_enable_right_click-0.6.6.xpi";
      sha256 = "49263636914d03aad975453667caee0f61a7339e27a7d63edc67f4bf7f88efcb";
      meta = with lib;
      {
        homepage = "https://webextension.org/listing/allow-right-click.html";
        description = "Re-enable the possibility to use the context menu on sites that overrides it";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "activeTab"
          "scripting"
          "contextMenus"
          "notifications"
        ];
        platforms = platforms.all;
      };
    };
    "react-devtools" = buildFirefoxXpiAddon {
      pname = "react-devtools";
      version = "6.1.1";
      addonId = "@react-devtools";
      url = "https://addons.mozilla.org/firefox/downloads/file/4432990/react_devtools-6.1.1.xpi";
      sha256 = "b2d69e220402bd6b8bc7d833948915b1d6dcabb453a1d50872a3db860fd92c46";
      meta = with lib;
      {
        homepage = "https://github.com/facebook/react";
        description = "React Developer Tools is a tool that allows you to inspect a React tree, including the component hierarchy, props, state, and more. To get started, just open the Firefox devtools and switch to the \"⚛️ Components\" or \"⚛️ Profiler\" tab.";
        license = licenses.mit;
        mozPermissions = [
          "scripting"
          "storage"
          "tabs"
          "clipboardWrite"
          "devtools"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "read-aloud" = buildFirefoxXpiAddon {
      pname = "read-aloud";
      version = "1.80.0";
      addonId = "{ddc62400-f22d-4dd3-8b4a-05837de53c2e}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4523988/read_aloud-1.80.0.xpi";
      sha256 = "e9d9cda76ee58d28659f3839208d3a62f07bb36290cc4d85b3c24a048f8c2525";
      meta = with lib;
      {
        description = "Read out loud the current web-page article with one click. Supports 40+ languages.";
        license = licenses.gpl3;
        mozPermissions = [
          "activeTab"
          "menus"
          "identity"
          "storage"
          "https://translate.google.com/"
          "https://piper.ttstool.com/"
        ];
        platforms = platforms.all;
      };
    };
    "readeck" = buildFirefoxXpiAddon {
      pname = "readeck";
      version = "2.5.5";
      addonId = "readeck@readeck.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4611397/readeck-2.5.5.xpi";
      sha256 = "8fb9e1b75fedb0af751bf30e2ddc18c648ff8aec5d6ca6e1d00da543e5a49534";
      meta = with lib;
      {
        homepage = "https://readeck.org/en/";
        description = "Readeck companion browser extension";
        license = licenses.lgpl3;
        mozPermissions = [
          "activeTab"
          "contextMenus"
          "scripting"
          "storage"
          "webRequest"
        ];
        platforms = platforms.all;
      };
    };
    "readwise-highlighter" = buildFirefoxXpiAddon {
      pname = "readwise-highlighter";
      version = "0.15.25";
      addonId = "team@readwise.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/4579487/readwise_highlighter-0.15.25.xpi";
      sha256 = "ece9919236ac1873a176dac09d45903cca7113584a3f7c3da9dc76eef114b836";
      meta = with lib;
      {
        homepage = "https://read.readwise.io";
        description = "The Readwise Highlighter is the official browser extension made by and maintained by the Readwise team that saves articles to your Reader account and enables you to optionally highlight the open web.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "<all_urls>"
          "activeTab"
          "background"
          "contextMenus"
          "notifications"
          "storage"
          "tabs"
          "unlimitedStorage"
        ];
        platforms = platforms.all;
      };
    };
    "recap" = buildFirefoxXpiAddon {
      pname = "recap";
      version = "2.8.5";
      addonId = "info@recapthelaw.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4514868/recap_195534-2.8.5.xpi";
      sha256 = "62f6d71f9618b2c2bad92c4e848026fccfd8e5836a23a57d5eb84d73ac0ca4ff";
      meta = with lib;
      {
        homepage = "https://free.law/recap/";
        description = "Turning PACER Around since 2009 to make it better and cheaper.";
        license = licenses.gpl3;
        mozPermissions = [
          "notifications"
          "storage"
          "unlimitedStorage"
          "activeTab"
          "tabs"
          "cookies"
          "scripting"
          "*://*.uscourts.gov/*"
          "*://ca1-showdoc.azurewebsites.us/*"
          "*://ca2-showdoc.azurewebsites.us/*"
          "*://ca3-showdoc.azurewebsites.us/*"
          "*://ca4-showdoc.azurewebsites.us/*"
          "*://ca5-showdoc.azurewebsites.us/*"
          "*://ca6-showdoc.azurewebsites.us/*"
          "*://ca7-showdoc.azurewebsites.us/*"
          "*://ca8-showdoc.azurewebsites.us/*"
          "*://ca9-showdoc.azurewebsites.us/*"
          "*://ca10-showdoc.azurewebsites.us/*"
          "*://ca11-showdoc.azurewebsites.us/*"
          "*://cafc-showdoc.azurewebsites.us/*"
          "*://cadc-showdoc.azurewebsites.us/*"
          "*://ca1-showdocservices.azurewebsites.us/*"
          "*://ca2-showdocservices.azurewebsites.us/*"
          "*://ca3-showdocservices.azurewebsites.us/*"
          "*://ca4-showdocservices.azurewebsites.us/*"
          "*://ca5-showdocservices.azurewebsites.us/*"
          "*://ca6-showdocservices.azurewebsites.us/*"
          "*://ca7-showdocservices.azurewebsites.us/*"
          "*://ca8-showdocservices.azurewebsites.us/*"
          "*://ca9-showdocservices.azurewebsites.us/*"
          "*://ca10-showdocservices.azurewebsites.us/*"
          "*://ca11-showdocservices.azurewebsites.us/*"
          "*://cafc-showdocservices.azurewebsites.us/*"
          "*://cadc-showdocservices.azurewebsites.us/*"
          "*://ca1-portal.powerappsportals.us/*"
          "*://ca2-portal.powerappsportals.us/*"
          "*://ca3-portal.powerappsportals.us/*"
          "*://ca4-portal.powerappsportals.us/*"
          "*://ca5-portal.powerappsportals.us/*"
          "*://ca6-portal.powerappsportals.us/*"
          "*://ca7-portal.powerappsportals.us/*"
          "*://ca8-portal.powerappsportals.us/*"
          "*://ca9-portal.powerappsportals.us/*"
          "*://ca10-portal.powerappsportals.us/*"
          "*://ca11-portal.powerappsportals.us/*"
          "*://cafc-portal.powerappsportals.us/*"
          "*://cadc-portal.powerappsportals.us/*"
          "*://ca1.fedcourts.us/*"
          "*://ca2.fedcourts.us/*"
          "*://ca3.fedcourts.us/*"
          "*://ca4.fedcourts.us/*"
          "*://ca5.fedcourts.us/*"
          "*://ca6.fedcourts.us/*"
          "*://ca7.fedcourts.us/*"
          "*://ca8.fedcourts.us/*"
          "*://ca9.fedcourts.us/*"
          "*://ca10.fedcourts.us/*"
          "*://ca11.fedcourts.us/*"
          "*://cafc.fedcourts.us/*"
          "*://cadc.fedcourts.us/*"
          "https://www.courtlistener.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "recoll-we" = buildFirefoxXpiAddon {
      pname = "recoll-we";
      version = "2.1";
      addonId = "recoll-we@recoll-org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3750059/recoll_we-2.1.xpi";
      sha256 = "6297f0ee0d167fa9815f0265d3e87ecac0a001d8c5b30e50d947e3b1996b4fd6";
      meta = with lib;
      {
        homepage = "https://www.lesbonscomptes.com/recoll/";
        description = "Enqueue visited WEB pages for storage and indexing by Recoll.";
        license = licenses.gpl2;
        mozPermissions = [
          "activeTab"
          "tabs"
          "webNavigation"
          "contextMenus"
          "notifications"
          "storage"
          "downloads"
          "*://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "reddit-comment-collapser" = buildFirefoxXpiAddon {
      pname = "reddit-comment-collapser";
      version = "5.1.2resigned1";
      addonId = "{a5b2e636-07e5-4331-93c1-6cf4074356c8}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4272010/reddit_comment_collapser-5.1.2resigned1.xpi";
      sha256 = "e29404a50c858d191584eb53c05bca1bd9648d8163cea8e6ed3b99b1faf4990b";
      meta = with lib;
      {
        homepage = "https://github.com/tom-james-watson/reddit-comment-collapser";
        description = "A more elegant solution for collapsing reddit comment trees.\n\nReddit Comment Collapser is free and open source. Contributions welcome - https://github.com/tom-james-watson/reddit-comment-collapser";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "https://*.reddit.com/"
          "http://*.reddit.com/*/comments/*"
          "https://*.reddit.com/*/comments/*"
        ];
        platforms = platforms.all;
      };
    };
    "reddit-enhancement-suite" = buildFirefoxXpiAddon {
      pname = "reddit-enhancement-suite";
      version = "5.24.8";
      addonId = "jid1-xUfzOsOFlzSOXg@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4424459/reddit_enhancement_suite-5.24.8.xpi";
      sha256 = "158405c50704a2cd2bc57c268a95b41dacba509b70d71d6ea280b04215bb8773";
      meta = with lib;
      {
        homepage = "https://redditenhancementsuite.com/";
        description = "Reddit Enhancement Suite (RES) is a suite of tools to enhance your Reddit browsing experience.";
        license = licenses.gpl3;
        mozPermissions = [
          "https://*.reddit.com/*"
          "cookies"
          "identity"
          "tabs"
          "history"
          "storage"
          "scripting"
          "unlimitedStorage"
        ];
        platforms = platforms.all;
      };
    };
    "reddit-moderator-toolbox" = buildFirefoxXpiAddon {
      pname = "reddit-moderator-toolbox";
      version = "6.1.22";
      addonId = "yes@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4605370/reddit_moderator_toolbox-6.1.22.xpi";
      sha256 = "dcb8a339660303634d66427f597a8a970a76da2a8e442c65cd52a655a6f6d794";
      meta = with lib;
      {
        homepage = "https://www.reddit.com/r/toolbox";
        description = "This is bundled extension of the /r/toolbox moderator tools for reddit.com\n\nContaining:\n\nMod Tools Enhanced\nMod Button\nMod Mail Pro\nMod Domain Tagger\nToolbox Notifier\nMod User Notes\nToolbox Config";
        license = licenses.asl20;
        mozPermissions = [
          "https://*.reddit.com/"
          "https://old.reddit.com/"
          "https://oauth.reddit.com/"
          "https://mod.reddit.com/"
          "cookies"
          "tabs"
          "storage"
          "unlimitedStorage"
          "notifications"
          "webNavigation"
          "alarms"
          "https://*.reddit.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "redirect-to-wiki-gg" = buildFirefoxXpiAddon {
      pname = "redirect-to-wiki-gg";
      version = "1.8.2";
      addonId = "genericredirector@ark.wiki.gg";
      url = "https://addons.mozilla.org/firefox/downloads/file/4583845/redirect_to_wiki_gg-1.8.2.xpi";
      sha256 = "579a2f6667b9af6709b8b048a730e24875dc272b6383793e82a4cb7cfadd1d78";
      meta = with lib;
      {
        homepage = "https://wiki.gg";
        description = "Redirects all requests from wikis that have moved to wiki.gg from their former host.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "*://*.gamepedia.com/*"
          "*://*.fandom.com/*"
          "webNavigation"
          "https://www.google.ad/search*"
          "https://www.google.ae/search*"
          "https://www.google.al/search*"
          "https://www.google.am/search*"
          "https://www.google.as/search*"
          "https://www.google.at/search*"
          "https://www.google.az/search*"
          "https://www.google.ba/search*"
          "https://www.google.be/search*"
          "https://www.google.bf/search*"
          "https://www.google.bg/search*"
          "https://www.google.bi/search*"
          "https://www.google.bj/search*"
          "https://www.google.bs/search*"
          "https://www.google.bt/search*"
          "https://www.google.by/search*"
          "https://www.google.ca/search*"
          "https://www.google.cat/search*"
          "https://www.google.cd/search*"
          "https://www.google.cf/search*"
          "https://www.google.cg/search*"
          "https://www.google.ch/search*"
          "https://www.google.ci/search*"
          "https://www.google.cl/search*"
          "https://www.google.cm/search*"
          "https://www.google.cn/search*"
          "https://www.google.co.ao/search*"
          "https://www.google.co.bw/search*"
          "https://www.google.co.ck/search*"
          "https://www.google.co.cr/search*"
          "https://www.google.co.id/search*"
          "https://www.google.co.il/search*"
          "https://www.google.co.in/search*"
          "https://www.google.co.jp/search*"
          "https://www.google.co.ke/search*"
          "https://www.google.co.kr/search*"
          "https://www.google.co.ls/search*"
          "https://www.google.co.ma/search*"
          "https://www.google.co.mz/search*"
          "https://www.google.co.nz/search*"
          "https://www.google.co.th/search*"
          "https://www.google.co.tz/search*"
          "https://www.google.co.ug/search*"
          "https://www.google.co.uk/search*"
          "https://www.google.co.uz/search*"
          "https://www.google.co.ve/search*"
          "https://www.google.co.vi/search*"
          "https://www.google.co.za/search*"
          "https://www.google.co.zm/search*"
          "https://www.google.co.zw/search*"
          "https://www.google.com.af/search*"
          "https://www.google.com.ag/search*"
          "https://www.google.com.ai/search*"
          "https://www.google.com.ar/search*"
          "https://www.google.com.au/search*"
          "https://www.google.com.bd/search*"
          "https://www.google.com.bh/search*"
          "https://www.google.com.bn/search*"
          "https://www.google.com.bo/search*"
          "https://www.google.com.br/search*"
          "https://www.google.com.bz/search*"
          "https://www.google.com.co/search*"
          "https://www.google.com.cu/search*"
          "https://www.google.com.cy/search*"
          "https://www.google.com.do/search*"
          "https://www.google.com.ec/search*"
          "https://www.google.com.eg/search*"
          "https://www.google.com.et/search*"
          "https://www.google.com.fj/search*"
          "https://www.google.com.gh/search*"
          "https://www.google.com.gi/search*"
          "https://www.google.com.gt/search*"
          "https://www.google.com.hk/search*"
          "https://www.google.com.jm/search*"
          "https://www.google.com.kh/search*"
          "https://www.google.com.kw/search*"
          "https://www.google.com.lb/search*"
          "https://www.google.com.ly/search*"
          "https://www.google.com.mm/search*"
          "https://www.google.com.mt/search*"
          "https://www.google.com.mx/search*"
          "https://www.google.com.my/search*"
          "https://www.google.com.na/search*"
          "https://www.google.com.ng/search*"
          "https://www.google.com.ni/search*"
          "https://www.google.com.np/search*"
          "https://www.google.com.om/search*"
          "https://www.google.com.pa/search*"
          "https://www.google.com.pe/search*"
          "https://www.google.com.pg/search*"
          "https://www.google.com.ph/search*"
          "https://www.google.com.pk/search*"
          "https://www.google.com.pr/search*"
          "https://www.google.com.py/search*"
          "https://www.google.com.qa/search*"
          "https://www.google.com.sa/search*"
          "https://www.google.com.sb/search*"
          "https://www.google.com.sg/search*"
          "https://www.google.com.sl/search*"
          "https://www.google.com.sv/search*"
          "https://www.google.com.tj/search*"
          "https://www.google.com.tr/search*"
          "https://www.google.com.tw/search*"
          "https://www.google.com.ua/search*"
          "https://www.google.com.uy/search*"
          "https://www.google.com.vc/search*"
          "https://www.google.com.vn/search*"
          "https://www.google.com/search*"
          "https://www.google.cv/search*"
          "https://www.google.cz/search*"
          "https://www.google.de/search*"
          "https://www.google.dj/search*"
          "https://www.google.dk/search*"
          "https://www.google.dm/search*"
          "https://www.google.dz/search*"
          "https://www.google.ee/search*"
          "https://www.google.es/search*"
          "https://www.google.fi/search*"
          "https://www.google.fm/search*"
          "https://www.google.fr/search*"
          "https://www.google.ga/search*"
          "https://www.google.ge/search*"
          "https://www.google.gg/search*"
          "https://www.google.gl/search*"
          "https://www.google.gm/search*"
          "https://www.google.gr/search*"
          "https://www.google.gy/search*"
          "https://www.google.hn/search*"
          "https://www.google.hr/search*"
          "https://www.google.ht/search*"
          "https://www.google.hu/search*"
          "https://www.google.ie/search*"
          "https://www.google.im/search*"
          "https://www.google.iq/search*"
          "https://www.google.is/search*"
          "https://www.google.it/search*"
          "https://www.google.je/search*"
          "https://www.google.jo/search*"
          "https://www.google.kg/search*"
          "https://www.google.ki/search*"
          "https://www.google.kz/search*"
          "https://www.google.la/search*"
          "https://www.google.li/search*"
          "https://www.google.lk/search*"
          "https://www.google.lt/search*"
          "https://www.google.lu/search*"
          "https://www.google.lv/search*"
          "https://www.google.md/search*"
          "https://www.google.me/search*"
          "https://www.google.mg/search*"
          "https://www.google.mk/search*"
          "https://www.google.ml/search*"
          "https://www.google.mn/search*"
          "https://www.google.ms/search*"
          "https://www.google.mu/search*"
          "https://www.google.mv/search*"
          "https://www.google.mw/search*"
          "https://www.google.ne/search*"
          "https://www.google.nl/search*"
          "https://www.google.no/search*"
          "https://www.google.nr/search*"
          "https://www.google.nu/search*"
          "https://www.google.pl/search*"
          "https://www.google.pn/search*"
          "https://www.google.ps/search*"
          "https://www.google.pt/search*"
          "https://www.google.ro/search*"
          "https://www.google.rs/search*"
          "https://www.google.ru/search*"
          "https://www.google.rw/search*"
          "https://www.google.sc/search*"
          "https://www.google.se/search*"
          "https://www.google.sh/search*"
          "https://www.google.si/search*"
          "https://www.google.sk/search*"
          "https://www.google.sm/search*"
          "https://www.google.sn/search*"
          "https://www.google.so/search*"
          "https://www.google.sr/search*"
          "https://www.google.st/search*"
          "https://www.google.td/search*"
          "https://www.google.tg/search*"
          "https://www.google.tl/search*"
          "https://www.google.tm/search*"
          "https://www.google.tn/search*"
          "https://www.google.to/search*"
          "https://www.google.tt/search*"
          "https://www.google.vg/search*"
          "https://www.google.vu/search*"
          "https://www.google.ws/search*"
          "https://*.duckduckgo.com/*"
          "https://*.fandom.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "redirector" = buildFirefoxXpiAddon {
      pname = "redirector";
      version = "3.5.3";
      addonId = "redirector@einaregilsson.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3535009/redirector-3.5.3.xpi";
      sha256 = "eddbd3d5944e748d0bd6ecb6d9e9cf0e0c02dced6f42db21aab64190e71c0f71";
      meta = with lib;
      {
        homepage = "http://einaregilsson.com/redirector/";
        description = "Automatically redirects to user-defined urls on certain pages";
        license = licenses.mit;
        mozPermissions = [
          "webRequest"
          "webRequestBlocking"
          "webNavigation"
          "storage"
          "tabs"
          "http://*/*"
          "https://*/*"
          "notifications"
        ];
        platforms = platforms.all;
      };
    };
    "reduxdevtools" = buildFirefoxXpiAddon {
      pname = "reduxdevtools";
      version = "3.2.10";
      addonId = "extension@redux.devtools";
      url = "https://addons.mozilla.org/firefox/downloads/file/4467343/reduxdevtools-3.2.10.xpi";
      sha256 = "ef2b10a2bc8b0d1a844d146e3eeaff407eaaa63cd0564db8eafd870c87a88956";
      meta = with lib;
      {
        homepage = "https://github.com/reduxjs/redux-devtools";
        description = "DevTools for Redux with actions history, undo and replay.";
        license = licenses.mit;
        mozPermissions = [
          "notifications"
          "contextMenus"
          "tabs"
          "storage"
          "devtools"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "refined-github" = buildFirefoxXpiAddon {
      pname = "refined-github";
      version = "25.10.2";
      addonId = "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4590019/refined_github-25.10.2.xpi";
      sha256 = "bb53d3d1f0b003a5ae705c79402d537141c191f76934bf7aec02b8e891bd16f7";
      meta = with lib;
      {
        homepage = "https://github.com/refined-github/refined-github";
        description = "Simplifies the GitHub interface and adds many useful features.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "scripting"
          "contextMenus"
          "activeTab"
          "alarms"
          "https://github.com/*"
          "https://gist.github.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "refined-saved-replies" = buildFirefoxXpiAddon {
      pname = "refined-saved-replies";
      version = "0.5";
      addonId = "refined-saved-replies@joshuakgoldberg.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4196051/refined_saved_replies-0.5.xpi";
      sha256 = "3d138dc371dd17cc85b8305a0afd39ee678c9588ef8bcc823e6010c74f332c61";
      meta = with lib;
      {
        description = "Adds a repository's .github/replies.yml to GitHub's Saved Replies feature.";
        license = licenses.mit;
        mozPermissions = [
          "https://github.com/*/*/issues/*"
          "https://github.com/*/*/pull/*"
        ];
        platforms = platforms.all;
      };
    };
    "remove-youtube-s-suggestions" = buildFirefoxXpiAddon {
      pname = "remove-youtube-s-suggestions";
      version = "4.3.64";
      addonId = "{21f1ba12-47e1-4a9b-ad4e-3a0260bbeb26}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4603192/remove_youtube_s_suggestions-4.3.64.xpi";
      sha256 = "088e0fcb424bbcdecf2b0500e0566e1a85666e51a6b04c3f9fff1a27193406d6";
      meta = with lib;
      {
        homepage = "https://lawrencehook.com/rys/";
        description = "Stop the YouTube rabbit hole. Customize YouTube's user interface to be less engaging.";
        license = licenses.mpl20;
        mozPermissions = [ "storage" "*://*.youtube.com/*" ];
        platforms = platforms.all;
      };
    };
    "return-youtube-dislikes" = buildFirefoxXpiAddon {
      pname = "return-youtube-dislikes";
      version = "3.0.0.18";
      addonId = "{762f9885-5a13-4abd-9c77-433dcd38b8fd}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4371820/return_youtube_dislikes-3.0.0.18.xpi";
      sha256 = "2d33977ce93276537543161f8e05c3612f71556840ae1eb98239284b8f8ba19e";
      meta = with lib;
      {
        description = "Returns ability to see dislike statistics on youtube";
        license = licenses.gpl3;
        mozPermissions = [
          "activeTab"
          "*://*.youtube.com/*"
          "storage"
          "*://returnyoutubedislikeapi.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "rsf-censorship-detector" = buildFirefoxXpiAddon {
      pname = "rsf-censorship-detector";
      version = "2.0.0";
      addonId = "collateral-freedom@rsf.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4148074/rsf_censorship_detector-2.0.0.xpi";
      sha256 = "d0b8acc119ad9a7540442535324c9ef6aed7f85a6511149058c504e6e0000135";
      meta = with lib;
      {
        homepage = "https://github.com/RSF-RWB/collateralfreedom";
        description = "Find access to blocked websites";
        license = licenses.gpl3;
        mozPermissions = [ "storage" "tabs" ];
        platforms = platforms.all;
      };
    };
    "rsshub-radar" = buildFirefoxXpiAddon {
      pname = "rsshub-radar";
      version = "1.10.3";
      addonId = "i@diygod.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/4197124/rsshub_radar-1.10.3.xpi";
      sha256 = "66a2aec4f67e27dd6a4a768ee8e87b3b321bac5385e3241b1664b95aae25077d";
      meta = with lib;
      {
        homepage = "https://github.com/DIYgod/RSSHub-Radar";
        description = "Easily find and subscribe to RSS and RSSHub.";
        license = licenses.mit;
        mozPermissions = [
          "tabs"
          "storage"
          "notifications"
          "alarms"
          "idle"
          "https://*/*"
          "http://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "rsspreview" = buildFirefoxXpiAddon {
      pname = "rsspreview";
      version = "3.34";
      addonId = "{7799824a-30fe-4c67-8b3e-7094ea203c94}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4591015/rsspreview-3.34.xpi";
      sha256 = "56689158d2b548769b42ca8e4cfc317cef87c16cd284bdf7ab6db2772a50e290";
      meta = with lib;
      {
        homepage = "https://github.com/aureliendavid/rsspreview";
        description = "Preview RSS feeds in-browser";
        license = licenses.mit;
        mozPermissions = [
          "<all_urls>"
          "webRequest"
          "webRequestBlocking"
          "storage"
          "tabs"
        ];
        platforms = platforms.all;
      };
    };
    "ruffle_rs" = buildFirefoxXpiAddon {
      pname = "ruffle_rs";
      version = "0.2.0.25294";
      addonId = "{b5501fd1-7084-45c5-9aa6-567c2fcf5dc6}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4602498/ruffle_rs-0.2.0.25294.xpi";
      sha256 = "dd8543243fd578a322423e5e3430b72d7d214a9ab2542743beae04dbd1637d4f";
      meta = with lib;
      {
        homepage = "https://ruffle.rs/";
        description = "Putting Flash back on the web.\n\nDesigned to be easy to use, this extension will seamlessly enable you to play flash content, with no extra configuration required!";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "scripting"
          "declarativeNetRequestWithHostAccess"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "rust-search-extension" = buildFirefoxXpiAddon {
      pname = "rust-search-extension";
      version = "2.0.2";
      addonId = "{04188724-64d3-497b-a4fd-7caffe6eab29}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4435641/rust_search_extension-2.0.2.xpi";
      sha256 = "10f521001a9fd9c7b8c5f8133daa74de01a5db33fb283b6b472b49c183e8418c";
      meta = with lib;
      {
        homepage = "https://rust.extension.sh";
        description = "The ultimate search extension for Rust\n\nSearch std docs, crates, builtin attributes, official books, and error codes, etc in your address bar instantly.\nhttps://rust.extension.sh";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "unlimitedStorage"
          "*://docs.rs/*"
          "*://doc.rust-lang.org/*"
          "*://rust.extension.sh/update"
        ];
        platforms = platforms.all;
      };
    };
    "saka-key" = buildFirefoxXpiAddon {
      pname = "saka-key";
      version = "1.26.3";
      addonId = "{46104586-98c3-407e-a349-290c9ff3594d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3582006/saka_key-1.26.3.xpi";
      sha256 = "9ea95fcd919100928ad5ca0dccad3700d627c28be2f2132f2e247e14009a4696";
      meta = with lib;
      {
        homepage = "https://github.com/lusakasa/saka-key";
        description = "A keyboard interface to the web";
        license = licenses.mit;
        mozPermissions = [
          "tabs"
          "activeTab"
          "sessions"
          "storage"
          "unlimitedStorage"
          "<all_urls>"
          "clipboardRead"
          "downloads"
          "cookies"
        ];
        platforms = platforms.all;
      };
    };
    "save-all-images-webextension" = buildFirefoxXpiAddon {
      pname = "save-all-images-webextension";
      version = "0.8.4";
      addonId = "{32af1358-428a-446d-873e-5f8eb5f2a72e}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4494884/save_all_images_webextension-0.8.4.xpi";
      sha256 = "56fb6f2eefd63046c48a1bc025c045b18f730a24284a3a5b7eaf346d496c834f";
      meta = with lib;
      {
        homepage = "https://webextension.org/listing/save-images.html";
        description = "Easily save images with a wide range of customization features, such as file size, dimensions, and image type.";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "activeTab"
          "notifications"
          "<all_urls>"
          "downloads"
          "unlimitedStorage"
        ];
        platforms = platforms.all;
      };
    };
    "save-page-we" = buildFirefoxXpiAddon {
      pname = "save-page-we";
      version = "28.11";
      addonId = "savepage-we@DW-dev";
      url = "https://addons.mozilla.org/firefox/downloads/file/4091842/save_page_we-28.11.xpi";
      sha256 = "26f9504711fa44014f8cb57053d0900153b446e62308ccf1f3d989c287771cfd";
      meta = with lib;
      {
        description = "Save a complete web page (as currently displayed) as a single HTML file that can be opened in any browser. Save a single page, multiple selected pages or a list of page URLs. Automate saving from command line.";
        license = licenses.gpl2;
        mozPermissions = [
          "http://*/*"
          "https://*/*"
          "file:///*"
          "tabs"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "downloads"
          "contextMenus"
          "notifications"
          "storage"
        ];
        platforms = platforms.all;
      };
    };
    "scots-language-pack" = buildFirefoxXpiAddon {
      pname = "scots-language-pack";
      version = "145.0.20251103.141854";
      addonId = "langpack-sco@firefox.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4611813/scots_language_pack-145.0.20251103.141854.xpi";
      sha256 = "fe34a56f6d0d0122af788ebd4d88f9c56270e09204293a564090fb87be5b8396";
      meta = with lib;
      {
        description = "Firefox Language Pack for Scots (sco)";
        license = licenses.mpl20;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "screenshot-capture-annotate" = buildFirefoxXpiAddon {
      pname = "screenshot-capture-annotate";
      version = "4.3.7.13";
      addonId = "jid0-GXjLLfbCoAx0LcltEdFrEkQdQPI@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4222998/screenshot_capture_annotate-4.3.7.13.xpi";
      sha256 = "d23fb0409975a10614703fe94c3f2071b9a2bd5eb3234b02a67b3149230f3b3a";
      meta = with lib;
      {
        homepage = "https://www.awesomescreenshot.com";
        description = "Full page screen capture and screen recorder 2 in 1. Share screencast video instantly.";
        license = licenses.mpl20;
        mozPermissions = [
          "activeTab"
          "tabs"
          "downloads"
          "<all_urls>"
          "storage"
          "unlimitedStorage"
          "clipboardWrite"
          "cookies"
          "http://*/*"
          "https://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "scroll_anywhere" = buildFirefoxXpiAddon {
      pname = "scroll_anywhere";
      version = "9.2";
      addonId = "juraj.masiar@gmail.com_ScrollAnywhere";
      url = "https://addons.mozilla.org/firefox/downloads/file/3938344/scroll_anywhere-9.2.xpi";
      sha256 = "614a7a13baad91a4015347ede83b66ae3e182679932cfc4ccd8fa5604ab38e91";
      meta = with lib;
      {
        homepage = "https://fastaddons.com/";
        description = "Scroll page without touching scroll-bar! \nPress Middle (Right / Left) mouse button anywhere on the page to scroll just like with scrollbar.\n\nFeatures also:\n- \"grab and drag\" scrolling\n- customizable scrollbars!\n- the Momentum auto-scroll";
        license = {
          shortName = "scroll-anywhere";
          fullName = "Scroll Anywhere License";
          url = "https://github.com/fastaddons/ScrollAnywhere/blob/master/LICENSE";
          free = false;
        };
        mozPermissions = [ "alarms" "storage" "activeTab" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "search-by-image" = buildFirefoxXpiAddon {
      pname = "search-by-image";
      version = "8.3.0";
      addonId = "{2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4591110/search_by_image-8.3.0.xpi";
      sha256 = "c437ead18bc2ca71d05fa4254dafc354be976ebffe95526271d5faeb61326939";
      meta = with lib;
      {
        homepage = "https://github.com/dessant/search-by-image#readme";
        description = "A powerful reverse image search tool, with support for various search engines, such as Google, Bing, Yandex, Baidu and TinEye.";
        license = licenses.gpl3;
        mozPermissions = [
          "alarms"
          "contextMenus"
          "storage"
          "unlimitedStorage"
          "tabs"
          "activeTab"
          "notifications"
          "webRequest"
          "webRequestBlocking"
          "<all_urls>"
          "scripting"
          "http://*/*"
          "https://*/*"
          "file:///*"
        ];
        platforms = platforms.all;
      };
    };
    "search-engines-helper" = buildFirefoxXpiAddon {
      pname = "search-engines-helper";
      version = "3.5.0";
      addonId = "{65a2d764-7358-455b-930d-5afa86fb5ed0}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4162613/search_engines_helper-3.5.0.xpi";
      sha256 = "f03822b7589cc2fbf6124e2dc1f48c52ec3674189936111e5336ed9e0b0622c8";
      meta = with lib;
      {
        homepage = "https://github.com/soufianesakhi/firefox-search-engines-helper";
        description = "Add a custom search engine and export/import all the search urls and icon urls for all search engines added to Firefox.";
        license = licenses.mit;
        mozPermissions = [ "contextMenus" "activeTab" "notifications" ];
        platforms = platforms.all;
      };
    };
    "semantic-scholar" = buildFirefoxXpiAddon {
      pname = "semantic-scholar";
      version = "0.3.9";
      addonId = "{881084f6-35f8-44c0-b249-15646548bdbf}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3669467/semantic_scholar-0.3.9.xpi";
      sha256 = "9f18f79117bddf77889c5a049bc835e6ed2fcaf0bfcf2ebbaee15585a7d9f6bf";
      meta = with lib;
      {
        homepage = "https://www.semanticscholar.org";
        description = "Quickly view research papers and search results on Semantic Scholar, the free, AI-powered academic search engine from the Allen Institute for AI (AI2).";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [ "activeTab" ];
        platforms = platforms.all;
      };
    };
    "session-sync" = buildFirefoxXpiAddon {
      pname = "session-sync";
      version = "3.1.12";
      addonId = "session-sync@gabrielivanica.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3352792/session_sync-3.1.12.xpi";
      sha256 = "08d32133a87cf91cd8cc17af21093a5abc8605c1c03efb01e2eafa8368b56d13";
      meta = with lib;
      {
        homepage = "https://github.com/ReDEnergy/SessionSync";
        description = "Save sessions as bookmarks and access them across devices.\nAdvanced Session Manager: edit, save, change, restore.\nIt can also be your best Bookmark Manager";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "bookmarks"
          "tabs"
          "clipboardWrite"
          "unlimitedStorage"
        ];
        platforms = platforms.all;
      };
    };
    "shaarli" = buildFirefoxXpiAddon {
      pname = "shaarli";
      version = "2.2.0";
      addonId = "shaarli@imirhil.fr";
      url = "https://addons.mozilla.org/firefox/downloads/file/4500528/shaarli-2.2.0.xpi";
      sha256 = "26a123b469718792c25b7382918fc2c20d7bc54dfb24a93d4faa2386c9ac8180";
      meta = with lib;
      {
        description = "Cette extension remplace le bookmarklet officiel et intègre un bouton « Shaarli » dans la barre des modules.";
        license = licenses.gpl3;
        mozPermissions = [ "tabs" "storage" ];
        platforms = platforms.all;
      };
    };
    "shinigami-eyes" = buildFirefoxXpiAddon {
      pname = "shinigami-eyes";
      version = "1.0.37";
      addonId = "shinigamieyes@shinigamieyes";
      url = "https://addons.mozilla.org/firefox/downloads/file/4362425/shinigami_eyes-1.0.37.xpi";
      sha256 = "e6a7f9833a1c3aa482ebad33388506aac953cff422cee27a46b1511e052f337c";
      meta = with lib;
      {
        homepage = "https://shinigami-eyes.github.io/";
        description = "Highlights transphobic/anti-LGBT and trans-friendly subreddits/facebook pages/groups with different colors.\n\nSupports Reddit, Twitter, Facebook, Tumblr, Medium, YouTube, Wikipedia, search engine results and all sites with Disqus comments.";
        license = licenses.mit;
        mozPermissions = [
          "contextMenus"
          "storage"
          "*://*/*"
          "*://*.facebook.com/*"
          "*://*.youtube.com/*"
          "*://*.reddit.com/*"
          "*://*.twitter.com/*"
          "*://*.x.com/*"
          "*://*.medium.com/*"
          "*://disqus.com/*"
          "*://tumblr.com/*"
          "*://www.tumblr.com/*"
          "*://*.wikipedia.org/*"
          "*://*.rationalwiki.org/*"
          "*://*.bsky.app/*"
          "*://anarchism.space/*"
          "*://aus.social/*"
          "*://c.im/*"
          "*://chaos.social/*"
          "*://eightpoint.app/*"
          "*://eldritch.cafe/*"
          "*://fosstodon.org/*"
          "*://hachyderm.io/*"
          "*://infosec.exchange/*"
          "*://kolektiva.social/*"
          "*://mas.to/*"
          "*://masto.ai/*"
          "*://chaosfem.tw/*"
          "*://mastodon.art/*"
          "*://mastodon.cloud/*"
          "*://mastodon.green/*"
          "*://mastodon.ie/*"
          "*://mastodon.nz/*"
          "*://mastodon.online/*"
          "*://mastodon.scot/*"
          "*://mastodon.social/*"
          "*://mastodon.world/*"
          "*://mastodon.xyz/*"
          "*://mastodonapp.uk/*"
          "*://meow.social/*"
          "*://mstdn.ca/*"
          "*://mstdn.jp/*"
          "*://mstdn.social/*"
          "*://octodon.social/*"
          "*://ohai.social/*"
          "*://pixelfed.social/*"
          "*://queer.party/*"
          "*://sfba.social/*"
          "*://social.transsafety.network/*"
          "*://tech.lgbt/*"
          "*://techhub.social/*"
          "*://toot.cat/*"
          "*://toot.community/*"
          "*://toot.wales/*"
          "*://vulpine.club/*"
          "*://wandering.shop/*"
          "*://lgbtqia.space/*"
          "*://*.threads.net/*"
          "*://duckduckgo.com/*"
          "*://*.bing.com/*"
          "*://*.google.ar/*"
          "*://*.google.at/*"
          "*://*.google.be/*"
          "*://*.google.ca/*"
          "*://*.google.ch/*"
          "*://*.google.co.uk/*"
          "*://*.google.com/*"
          "*://*.google.de/*"
          "*://*.google.dk/*"
          "*://*.google.es/*"
          "*://*.google.fi/*"
          "*://*.google.fr/*"
          "*://*.google.is/*"
          "*://*.google.it/*"
          "*://*.google.no/*"
          "*://*.google.pt/*"
          "*://*.google.se/*"
          "https://x.com/*"
          "https://twitter.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "shiori" = buildFirefoxXpiAddon {
      pname = "shiori";
      version = "1.8.0.1";
      addonId = "{c6e8bd66-ebb4-4b63-bd29-5ef59c795903}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4588202/shiori_ext-1.8.0.1.xpi";
      sha256 = "0ad6fc8d97ac2b587daf354f8c80e024f2f97e4a92b67c08ff40399416ef3de7";
      meta = with lib;
      {
        homepage = "https://github.com/go-shiori/shiori-web-ext";
        description = "Web extension for Shiori, a simple bookmark manager.\nSource code: https://github.com/go-shiori/shiori, https://github.com/go-shiori/shiori-web-ext";
        license = licenses.mit;
        mozPermissions = [
          "tabs"
          "storage"
          "bookmarks"
          "scripting"
          "activeTab"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "shortkeys" = buildFirefoxXpiAddon {
      pname = "shortkeys";
      version = "4.0.2";
      addonId = "Shortkeys@Shortkeys.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3673761/shortkeys-4.0.2.xpi";
      sha256 = "c6fe12efdd7a871787ac4526eea79ecc1acda8a99724aa2a2a55c88a9acf467c";
      meta = with lib;
      {
        homepage = "https://github.com/mikecrittenden/shortkeys";
        description = "Easily customizable custom keyboard shortcuts for Firefox. To configure this addon go to Addons (ctrl+shift+a) -&gt;Shortkeys -&gt;Options. Report issues here (please specify that the issue is found in Firefox): https://github.com/mikecrittenden/shortkeys";
        license = licenses.mit;
        mozPermissions = [
          "downloads"
          "tabs"
          "clipboardWrite"
          "browsingData"
          "storage"
          "bookmarks"
          "sessions"
          "management"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "side-view" = buildFirefoxXpiAddon {
      pname = "side-view";
      version = "0.6.6956";
      addonId = "side-view@mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4371246/side_view-0.6.6956.xpi";
      sha256 = "66ee4813570c1f98a661523f99426b1a36e9dcff9b395a7183e182cf1b4a4ef7";
      meta = with lib;
      {
        homepage = "https://github.com/mozilla/side-view/";
        description = "Open a mobile view of a page in the sidebar";
        license = licenses.mpl20;
        mozPermissions = [
          "activeTab"
          "tabs"
          "<all_urls>"
          "storage"
          "contextMenus"
          "webRequest"
          "webRequestBlocking"
          "bookmarks"
          "management"
        ];
        platforms = platforms.all;
      };
    };
    "sidebery" = buildFirefoxXpiAddon {
      pname = "sidebery";
      version = "5.3.3";
      addonId = "{3c078156-979c-498b-8990-85f7987dd929}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4442132/sidebery-5.3.3.xpi";
      sha256 = "a4f9a8305f93b7d6b95f27943ecd1b3d422773fae5b802beac3af4a3e3a7476b";
      meta = with lib;
      {
        homepage = "https://github.com/mbnuqw/sidebery";
        description = "Vertical tabs tree and bookmarks in sidebar with advanced containers configuration, grouping and many other features.";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "tabs"
          "contextualIdentities"
          "cookies"
          "storage"
          "unlimitedStorage"
          "sessions"
          "menus"
          "menus.overrideContext"
          "search"
          "theme"
          "identity"
        ];
        platforms = platforms.all;
      };
    };
    "simple-dark-vlasak" = buildFirefoxXpiAddon {
      pname = "simple-dark-vlasak";
      version = "3.0";
      addonId = "{02be1381-a3d9-460c-b209-5b39b42e2b30}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4041660/simple_dark_vlasak-3.0.xpi";
      sha256 = "050b392afd274003cb33d36eb625e98dc63e6a16fdfb9600d56e184d637af753";
      meta = with lib;
      {
        description = "A simple dark high contrast theme with a tone of cyan.";
        license = licenses.cc-by-30;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "simple-tab-groups" = buildFirefoxXpiAddon {
      pname = "simple-tab-groups";
      version = "5.3.2";
      addonId = "simple-tab-groups@drive4ik";
      url = "https://addons.mozilla.org/firefox/downloads/file/4469818/simple_tab_groups-5.3.2.xpi";
      sha256 = "efebf6a9f73a1747044624ddbad7a78fd90ffccdb34a426cf6bb555eda307c49";
      meta = with lib;
      {
        homepage = "https://github.com/drive4ik/simple-tab-groups";
        description = "Create, modify, and quickly change tab groups";
        license = licenses.mpl20;
        mozPermissions = [
          "tabs"
          "tabHide"
          "notifications"
          "menus"
          "contextualIdentities"
          "cookies"
          "sessions"
          "downloads"
          "management"
          "webRequest"
          "webRequestBlocking"
          "<all_urls>"
          "storage"
          "unlimitedStorage"
        ];
        platforms = platforms.all;
      };
    };
    "simple-translate" = buildFirefoxXpiAddon {
      pname = "simple-translate";
      version = "3.0.0";
      addonId = "simple-translate@sienori";
      url = "https://addons.mozilla.org/firefox/downloads/file/4286113/simple_translate-3.0.0.xpi";
      sha256 = "c9e36d1d8e32a223da367bdc83133f2436103eb5f16460c7cce2096376e78b68";
      meta = with lib;
      {
        homepage = "https://simple-translate.sienori.com";
        description = "Quickly translate selected or typed text on web pages. Supports Google Translate and DeepL API.";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "contextMenus"
          "http://*/*"
          "https://*/*"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "simplelogin" = buildFirefoxXpiAddon {
      pname = "simplelogin";
      version = "3.0.7";
      addonId = "addon@simplelogin";
      url = "https://addons.mozilla.org/firefox/downloads/file/4458602/simplelogin-3.0.7.xpi";
      sha256 = "8e91d0b7e2bc76746818dd8cc533ea525b9c3cfd433fba52da4766a83f579ded";
      meta = with lib;
      {
        homepage = "https://simplelogin.io";
        description = "Create a different email for each website to hide your real email. Guard your inbox against spams, phishing. Protect your privacy.";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "storage"
          "contextMenus"
          "scripting"
          "tabs"
          "http://*/*"
          "https://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "simplifygmail" = buildFirefoxXpiAddon {
      pname = "simplifygmail";
      version = "3.2.14";
      addonId = "{a4c1064c-95dd-47a7-9b02-bb30213b7b29}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4590257/simplifygmail-3.2.14.xpi";
      sha256 = "e9bd33b992eb4f4d71c2da7a999eb92fc01715bd095d0996054aea5ea58838e9";
      meta = with lib;
      {
        homepage = "https://simpl.fyi";
        description = "Your time and attention matter -- Simplify Gmail enhances Gmail to boost productivity, strengthen privacy, and reduce stress. From the co-founder of Google Inbox.";
        license = {
          shortName = "simplifygmail";
          fullName = "Terms of Service for Simplify Gmail";
          url = "https://simpl.fyi/terms";
          free = false;
        };
        mozPermissions = [
          "*://mail.google.com/*"
          "*://*.googleusercontent.com/proxy/*"
          "storage"
          "webRequest"
          "webRequestBlocking"
          "https://simpl.fyi/auth/*"
          "https://mail.google.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "single-file" = buildFirefoxXpiAddon {
      pname = "single-file";
      version = "1.22.81";
      addonId = "{531906d3-e22f-4a6c-a102-8057b88a1a63}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4465739/single_file-1.22.81.xpi";
      sha256 = "acc27ee2319e66192a8081cab771ecd1e99a0ea04c29262e595a43ddc92e05a7";
      meta = with lib;
      {
        homepage = "https://www.getsinglefile.com";
        description = "Save an entire web page—including images and styling—as a single HTML file.";
        license = licenses.agpl3Plus;
        mozPermissions = [
          "identity"
          "menus"
          "downloads"
          "storage"
          "tabs"
          "<all_urls>"
          "devtools"
        ];
        platforms = platforms.all;
      };
    };
    "skip-redirect" = buildFirefoxXpiAddon {
      pname = "skip-redirect";
      version = "2.3.6";
      addonId = "skipredirect@sblask";
      url = "https://addons.mozilla.org/firefox/downloads/file/3920533/skip_redirect-2.3.6.xpi";
      sha256 = "dbe8950245c1f475c5c1c6daab89c79b83ba4680621c91e80f15be7b09b618ae";
      meta = with lib;
      {
        description = "Some web pages use intermediary pages before redirecting to a final page. This add-on tries to extract the final url from the intermediary url and goes there straight away if successful.";
        license = licenses.mit;
        mozPermissions = [
          "<all_urls>"
          "clipboardWrite"
          "contextMenus"
          "notifications"
          "storage"
          "webRequest"
          "webRequestBlocking"
        ];
        platforms = platforms.all;
      };
    };
    "smart-referer" = buildFirefoxXpiAddon {
      pname = "smart-referer";
      version = "0.2.15";
      addonId = "smart-referer@meh.paranoid.pk";
      url = "https://addons.mozilla.org/firefox/downloads/file/3470999/smart_referer-0.2.15.xpi";
      sha256 = "4751ab905c4d9d13b1f21c9fc179efed7d248e3476effb5b393268b46855bf1a";
      meta = with lib;
      {
        homepage = "https://gitlab.com/smart-referer/smart-referer";
        description = "Improve your privacy by limiting Referer information leak!\n\nPlease note that this extension has been largely superseded by better browser defaults for websites using HTTPS (almost all) and is not maintained anymore.";
        license = licenses.wtfpl;
        mozPermissions = [
          "menus"
          "storage"
          "theme"
          "webRequest"
          "webRequestBlocking"
          "*://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "smartproxy" = buildFirefoxXpiAddon {
      pname = "smartproxy";
      version = "1.8";
      addonId = "smartproxy@salarcode.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4582982/smartproxy-1.8.xpi";
      sha256 = "cc8f2e6f3f6af1ecc67af8f6c2ae5f966862db118be962b823858a43e7a940d1";
      meta = with lib;
      {
        homepage = "https://github.com/salarcode/SmartProxy";
        description = "SmartProxy is a smart automatic proxy switcher that will automatically enable/disable proxy for the sites you visit, based on customizable rules.";
        license = licenses.gpl3;
        mozPermissions = [
          "<all_urls>"
          "activeTab"
          "tabs"
          "proxy"
          "webRequest"
          "webRequestBlocking"
          "storage"
          "unlimitedStorage"
          "notifications"
        ];
        platforms = platforms.all;
      };
    };
    "snoozetabs" = buildFirefoxXpiAddon {
      pname = "snoozetabs";
      version = "1.1.2resigned1";
      addonId = "snoozetabs@mozilla.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4271788/snoozetabs-1.1.2resigned1.xpi";
      sha256 = "1fe70147bb741f06c2ab9b2fbc5c1bff752703c4f9086b0edf83af673afa4b8c";
      meta = with lib;
      {
        homepage = "https://github.com/bwinton/SnoozeTabs#readme";
        description = "Snooze Tabs help you focus your attention online, whether you want to remove distractions for now or save something for later. Hit the snooze icon to dismiss tabs you don’t want now, and set an alarm to bring them back when you need them.";
        license = licenses.mpl20;
        mozPermissions = [
          "alarms"
          "bookmarks"
          "contextMenus"
          "notifications"
          "storage"
          "tabs"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "snowflake" = buildFirefoxXpiAddon {
      pname = "snowflake";
      version = "0.9.7";
      addonId = "{b11bea1f-a888-4332-8d8a-cec2be7d24b9}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4594619/torproject_snowflake-0.9.7.xpi";
      sha256 = "021fe23d13d4295aefbfa9c851ae0738568eef5f12dc796d0c31e7885c2ca9af";
      meta = with lib;
      {
        homepage = "https://snowflake.torproject.org/";
        description = "Help people in censored countries access the Internet without restrictions. Once you install and enable the extension, wait for the snowflake icon to turn green, this means a censored user is connecting through your extension to access the Internet!";
        license = licenses.bsd3;
        mozPermissions = [ "storage" ];
        platforms = platforms.all;
      };
    };
    "solarized-light" = buildFirefoxXpiAddon {
      pname = "solarized-light";
      version = "2.0";
      addonId = "{71864fba-a0ac-47f5-a514-e5f3378b9c12}";
      url = "https://addons.mozilla.org/firefox/downloads/file/2765354/solarized_light-2.0.xpi";
      sha256 = "3462da8a4a39ae1c93b9a0a5172f8690d2dd66baa856f240862d5943cad49c67";
      meta = with lib;
      {
        description = "Uh-oh!   Looks like somebody left Firefox out in the sun.\n\nCredit to Ethan Schoonover for the color scheme.\n\nhttp://ethanschoonover.com/solarized";
        license = {
          shortName = "all-rights-reserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/wiki/All_rights_reserved";
          free = false;
        };
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "solarized_fox" = buildFirefoxXpiAddon {
      pname = "solarized_fox";
      version = "3.0";
      addonId = "{059437b3-6db8-4703-a620-624be085a10c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3924784/solarized_fox-3.0.xpi";
      sha256 = "79ccb6f0d773fc3e10e249c16db0a20e03d96ae34913261d8aad2c4e40fa7f01";
      meta = with lib;
      {
        description = "Solarized Dark theme, using blue backgrounds with yellow highlights";
        license = licenses.cc-by-30;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "sonarr-radarr-lidarr-search" = buildFirefoxXpiAddon {
      pname = "sonarr-radarr-lidarr-search";
      version = "3.0.1.0";
      addonId = "sonarr-radarr-lidarr-autosearch@robgreen.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/4599655/sonarr_radarr_lidarr_search-3.0.1.0.xpi";
      sha256 = "e2bb1ff7a6a7863743731e8a33a14385d65ebb7d297535c11287b9df0044f9fd";
      meta = with lib;
      {
        homepage = "https://github.com/trossr32/sonarr-radarr-lidarr-autosearch-browser-extension";
        description = "Exposes a context menu that enables direct searching for tv shows, movies or artists in Sonarr, Radarr &amp; Lidarr.\n\nSee description for a list of integrated sites.";
        license = licenses.mpl20;
        mozPermissions = [
          "*://*.allocine.fr/*"
          "*://*.betaseries.com/*"
          "*://*.imdb.com/*"
          "*://*.iptorrents/*"
          "*://*.last.fm/*"
          "*://*.letterboxd.com/*"
          "*://*.metacritic.com/*"
          "*://*.musicbrainz.org/*"
          "*://*.myanimelist.net/*"
          "*://*.primevideo.com/*"
          "*://*.rateyourmusic.com/*"
          "*://*.rottentomatoes.com/*"
          "*://*.senscritique.com/*"
          "*://*.simkl.com/*"
          "*://*.themoviedb.org/*"
          "*://*.thetvdb.com/*"
          "*://*.trakt.tv/*"
          "*://*.pogdesign.co.uk/*"
          "*://*.tvmaze.com/*"
          "storage"
          "activeTab"
          "tabs"
          "contextMenus"
        ];
        platforms = platforms.all;
      };
    };
    "sourcegraph" = buildFirefoxXpiAddon {
      pname = "sourcegraph";
      version = "23.4.14.1343";
      addonId = "sourcegraph-for-firefox@sourcegraph.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4097469/sourcegraph_for_firefox-23.4.14.1343.xpi";
      sha256 = "fa02236d75a82a7c47dabd0272b77dd9a74e8069563415a7b8b2b9d37c36d20b";
      meta = with lib;
      {
        description = "Adds code intelligence to GitHub, GitLab, Bitbucket Server, and Phabricator: hovers, definitions, references. Supports 20+ languages.";
        mozPermissions = [
          "activeTab"
          "storage"
          "contextMenus"
          "https://github.com/*"
          "https://sourcegraph.com/*"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "sponsorblock" = buildFirefoxXpiAddon {
      pname = "sponsorblock";
      version = "6.0.3";
      addonId = "sponsorBlocker@ajay.app";
      url = "https://addons.mozilla.org/firefox/downloads/file/4598130/sponsorblock-6.0.3.xpi";
      sha256 = "accbfb3bb634834a16685cbc66c1a8e5e8ae51c075c7c86d4b7141c67ad4c88b";
      meta = with lib;
      {
        homepage = "https://sponsor.ajay.app";
        description = "Easily skip YouTube video sponsors. When you visit a YouTube video, the extension will check the database for reported sponsors and automatically skip known sponsors. You can also report sponsors in videos. Other browsers: https://sponsor.ajay.app";
        license = licenses.lgpl3;
        mozPermissions = [
          "storage"
          "scripting"
          "unlimitedStorage"
          "https://sponsor.ajay.app/*"
          "https://*.youtube.com/*"
          "https://www.youtube-nocookie.com/embed/*"
        ];
        platforms = platforms.all;
      };
    };
    "spoof-timezone" = buildFirefoxXpiAddon {
      pname = "spoof-timezone";
      version = "0.4.7";
      addonId = "{55f61747-c3d3-4425-97f9-dfc19a0be23c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4563054/spoof_timezone-0.4.7.xpi";
      sha256 = "adb82eb9692065945814044c7034ac9e75d1e158cbbdfb5ad3702a1c815b8bdd";
      meta = with lib;
      {
        homepage = "https://add0n.com/spoof-timezone.html";
        description = "This extension alters browser timezone to a random or user-defined value.";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "scripting"
          "webNavigation"
          "contextMenus"
          "notifications"
        ];
        platforms = platforms.all;
      };
    };
    "startpage-private-search" = buildFirefoxXpiAddon {
      pname = "startpage-private-search";
      version = "2.0.3";
      addonId = "{20fc2e06-e3e4-4b2b-812b-ab431220cada}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4416483/startpage_private_search-2.0.3.xpi";
      sha256 = "e22fdf5988a8134eef72d963891ab5c662f90a1fc061cd354f60529bd511ae40";
      meta = with lib;
      {
        description = "This extension protects users from being tracked while allowing them to search the web in complete private mode.";
        license = licenses.gpl3;
        mozPermissions = [
          "search"
          "storage"
          "webRequest"
          "webRequestBlocking"
          "https://*.startpage.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "startup-bookmarks" = buildFirefoxXpiAddon {
      pname = "startup-bookmarks";
      version = "1.7.18";
      addonId = "{d026fcc5-d071-4ddd-bbc0-66ccf814693d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4589645/startup_bookmarks-1.7.18.xpi";
      sha256 = "e2cb9941cc63b2c33ec06df519e1f6b5bbe97ebc5d77237748af21763fc9e4b2";
      meta = with lib;
      {
        homepage = "https://github.com/igorlogius/webextensions/tree/main/sources/startup-bookmarks";
        description = "Open a set of bookmarks on browser startup";
        mozPermissions = [ "bookmarks" "storage" ];
        platforms = platforms.all;
      };
    };
    "statshunters" = buildFirefoxXpiAddon {
      pname = "statshunters";
      version = "3.2.1";
      addonId = "browserextension@statshunters.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4603741/statshunters-3.2.1.xpi";
      sha256 = "1fbb1719c0757d837510d8ab2c72cd318c1c411639eaf667aaa7855adbaa90cd";
      meta = with lib;
      {
        homepage = "https://www.statshunters.com";
        description = "Show tiles on Strava, Komoot, Brouter, RWGPS, Garmin and Mapy.cz route builder";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "https://www.strava.com/maps/*"
          "https://www.strava.com/routes/*/edit*"
          "https://www.komoot.com/*"
          "https://www.komoot.nl/*"
          "https://www.komoot.es/*"
          "https://www.komoot.it/*"
          "https://www.komoot.fr/*"
          "https://www.komoot.de/*"
          "http://brouter.de/brouter-web/*"
          "http://www.brouter.de/brouter-web/*"
          "https://brouter.de/brouter-web/*"
          "https://www.brouter.de/brouter-web/*"
          "https://brouter.m11n.de/*"
          "https://bikerouter.de/*"
          "https://brouter.damsy.net/*"
          "https://ridewithgps.com/routes/new*"
          "https://ridewithgps.com/routes/*/edit*"
          "https://connect.garmin.com/modern/*"
          "https://connect.garmin.com/modern/course/create*"
          "https://connect.garmin.com/modern/course/*"
          "https://cycle.travel/map"
          "https://*.mapy.cz/*"
          "https://*.mapy.com/*"
          "https://web.locusmap.app/*"
          "https://dashboard.hammerhead.io/*"
          "https://dynamic.watch/*/plan*"
          "https://dynamic.watch/plan/*"
          "https://dynamic.watch/plan"
          "https://mapa-turystyczna.pl/*"
          "https://alltrails.com/explore/map/*"
          "https://www.alltrails.com/explore/map/*"
          "https://www.alltrails.com/*/explore/map/*"
          "https://www.alltrails.com/explore/*"
          "https://www.alltrails.com/members/*"
          "https://openrunner.com/*"
          "https://www.openrunner.com/*"
          "https://gpx.studio/*"
          "https://veloplanner.com/*"
          "https://gaiagps.com/map/*"
          "https://www.gaiagps.com/map/*"
        ];
        platforms = platforms.all;
      };
    };
    "steam-database" = buildFirefoxXpiAddon {
      pname = "steam-database";
      version = "4.27";
      addonId = "firefox-extension@steamdb.info";
      url = "https://addons.mozilla.org/firefox/downloads/file/4584596/steam_database-4.27.xpi";
      sha256 = "2d2a2c0347d096b7c75ee84cdf5b6a55fd1f94105d32bec8620039215d3f0e49";
      meta = with lib;
      {
        homepage = "https://steamdb.info/";
        description = "Adds SteamDB links and new features on the Steam store and community. View lowest game prices and stats.";
        license = licenses.bsd3;
        mozPermissions = [
          "storage"
          "https://steamdb.info/*"
          "https://store.steampowered.com/*"
          "https://steamcommunity.com/*"
          "https://store.steampowered.com/app/*"
          "https://store.steampowered.com/news/app/*"
          "https://store.steampowered.com/account/licenses*"
          "https://store.steampowered.com/account/registerkey*"
          "https://store.steampowered.com/sub/*"
          "https://store.steampowered.com/bundle/*"
          "https://store.steampowered.com/widget/*"
          "https://store.steampowered.com/app/*/agecheck"
          "https://store.steampowered.com/agecheck/*"
          "https://store.steampowered.com/explore*"
          "https://steamcommunity.com/app/*"
          "https://steamcommunity.com/sharedfiles/filedetails*"
          "https://steamcommunity.com/workshop/filedetails*"
          "https://steamcommunity.com/workshop/browse*"
          "https://steamcommunity.com/workshop/discussions*"
          "https://steamcommunity.com/id/*"
          "https://steamcommunity.com/profiles/*"
          "https://steamcommunity.com/id/*/inventory*"
          "https://steamcommunity.com/profiles/*/inventory*"
          "https://steamcommunity.com/id/*/stats*"
          "https://steamcommunity.com/profiles/*/stats*"
          "https://steamcommunity.com/id/*/stats/CSGO*"
          "https://steamcommunity.com/profiles/*/stats/CSGO*"
          "https://steamcommunity.com/stats/*/achievements*"
          "https://steamcommunity.com/tradeoffer/*"
          "https://steamcommunity.com/id/*/recommended/*"
          "https://steamcommunity.com/profiles/*/recommended/*"
          "https://steamcommunity.com/id/*/badges*"
          "https://steamcommunity.com/profiles/*/badges*"
          "https://steamcommunity.com/id/*/gamecards/*"
          "https://steamcommunity.com/profiles/*/gamecards/*"
          "https://steamcommunity.com/market/multibuy*"
          "https://steamcommunity.com/market/*"
          "https://steamcommunity.com/games/*"
          "https://steamcommunity.com/sharedfiles/*"
          "https://steamcommunity.com/workshop/*"
          "https://steamcommunity.com/linkfilter/*"
          "https://steamcommunity.com/tradingcards/boostercreator*"
        ];
        platforms = platforms.all;
      };
    };
    "streetpass-for-mastodon" = buildFirefoxXpiAddon {
      pname = "streetpass-for-mastodon";
      version = "2024.1";
      addonId = "streetpass@streetpass.social";
      url = "https://addons.mozilla.org/firefox/downloads/file/4239700/streetpass_for_mastodon-2024.1.xpi";
      sha256 = "9e711dbed82ef3e2444327007738c6474320347679683936539c4f2454116028";
      meta = with lib;
      {
        homepage = "https://streetpass.social/";
        description = "Find your people on Mastodon";
        license = licenses.mit;
        mozPermissions = [ "storage" "https://*/*" "http://*/*" ];
        platforms = platforms.all;
      };
    };
    "stylebot-web" = buildFirefoxXpiAddon {
      pname = "stylebot-web";
      version = "3.1.3";
      addonId = "{52bda3fd-dc48-4b3d-a7b9-58af57879f1e}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3979493/stylebot_web-3.1.3.xpi";
      sha256 = "f3f606dff3b77e1ad7ab0b516d6ce7196af119604af240a5881af4dfe0e27f4e";
      meta = with lib;
      {
        homepage = "https://stylebot.dev/";
        description = "Change the appearance of the web instantly";
        license = licenses.mit;
        mozPermissions = [
          "tabs"
          "storage"
          "identity"
          "contextMenus"
          "unlimitedStorage"
          "https://drive.google.com/*"
          "https://www.googleapis.com/*"
          "https://fonts.googleapis.com/*"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "stylus" = buildFirefoxXpiAddon {
      pname = "stylus";
      version = "2.3.16";
      addonId = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4554444/styl_us-2.3.16.xpi";
      sha256 = "2cda3445f1e5e5aa95b8b814cc395079185216e10ec42d20811b0350f4c378a8";
      meta = with lib;
      {
        homepage = "https://add0n.com/stylus.html";
        description = "Redesign your favorite websites with Stylus, an actively developed and community driven userstyles manager. Easily install custom themes from popular online repositories, or create, edit, and manage your own personalized CSS stylesheets.";
        license = licenses.gpl3;
        mozPermissions = [
          "alarms"
          "contextMenus"
          "storage"
          "tabs"
          "unlimitedStorage"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "<all_urls>"
          "https://userstyles.org/*"
        ];
        platforms = platforms.all;
      };
    };
    "substitoot" = buildFirefoxXpiAddon {
      pname = "substitoot";
      version = "0.7.2.0";
      addonId = "substitoot@kludge.guru";
      url = "https://addons.mozilla.org/firefox/downloads/file/4236602/substitoot-0.7.2.0.xpi";
      sha256 = "d5ab92a848e479bc1149b980554b18c32efb765ed34023a7aa0a33a68567aa02";
      meta = with lib;
      {
        homepage = "https://github.com/virtulis/substitoot";
        description = "A transparent toot fetcher for Mastodon. Loads missing replies to boosted toots in your feed directly from the source server.\n\nMake sure you set your home instance(s) in preferences to start using this!";
        license = licenses.mit;
        mozPermissions = [ "storage" "scripting" ];
        platforms = platforms.all;
      };
    };
    "surfingkeys" = buildFirefoxXpiAddon {
      pname = "surfingkeys";
      version = "1.17.11";
      addonId = "{a8332c60-5b6d-41ee-bfc8-e9bb331d34ad}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4573120/surfingkeys_ff-1.17.11.xpi";
      sha256 = "f044e5a5df1fcba1b617da078d5bfa3f0d6a321e8796d00b04e97f1efe7da8f8";
      meta = with lib;
      {
        homepage = "https://github.com/brookhong/Surfingkeys";
        description = "Rich shortcuts for you to click links / switch tabs / scroll pages or DIVs / capture full page or DIV etc, let you use the browser like vim, plus an embed vim editor.\n\nhttps://github.com/brookhong/Surfingkeys";
        license = licenses.mit;
        mozPermissions = [
          "nativeMessaging"
          "tabs"
          "history"
          "bookmarks"
          "scripting"
          "storage"
          "sessions"
          "downloads"
          "topSites"
          "clipboardRead"
          "clipboardWrite"
          "cookies"
          "contextualIdentities"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "swedish-dictionary" = buildFirefoxXpiAddon {
      pname = "swedish-dictionary";
      version = "1.21";
      addonId = "swedish@dictionaries.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3539390/gorans_hemmasnickrade_ordli-1.21.xpi";
      sha256 = "7d2ce7f7bfb65cfb5dd4138686acd977cf589c6ce91fc342ae5e2e26a09d1dbe";
      meta = with lib;
      {
        description = "Swedish spell-check dictionary.";
        license = licenses.lgpl3;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "swift-selection-search" = buildFirefoxXpiAddon {
      pname = "swift-selection-search";
      version = "3.49.0";
      addonId = "jid1-KdTtiCj6wxVAFA@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4473415/swift_selection_search-3.49.0.xpi";
      sha256 = "39c2073636f7d8c3e49002a930e0b569efc751e7beb46f7ed7f17c44b3c1680f";
      meta = with lib;
      {
        homepage = "https://github.com/CanisLupus/swift-selection-search";
        description = "Swiftly access your search engines in a popup panel when you select text in a webpage. Context menu also included!";
        license = licenses.mit;
        mozPermissions = [
          "<all_urls>"
          "clipboardWrite"
          "contextMenus"
          "search"
          "storage"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
        ];
        platforms = platforms.all;
      };
    };
    "switchyomega" = buildFirefoxXpiAddon {
      pname = "switchyomega";
      version = "2.5.10";
      addonId = "switchyomega@feliscatus.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/848109/switchyomega-2.5.10.xpi";
      sha256 = "dfefc2da59eeb2e92a32fc75fb05426feeea4c39ee01b7a797395ed29ed7cf77";
      meta = with lib;
      {
        homepage = "https://github.com/FelisCatus/SwitchyOmega";
        description = "Manage and switch between multiple proxies quickly &amp; easily.";
        license = licenses.gpl3;
        mozPermissions = [
          "proxy"
          "tabs"
          "alarms"
          "storage"
          "webRequest"
          "downloads"
          "webRequestBlocking"
          "contextMenus"
          "http://*/*"
          "https://*/*"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "tab-counter-plus" = buildFirefoxXpiAddon {
      pname = "tab-counter-plus";
      version = "3.4";
      addonId = "tab-counter-plus@Loirooriol";
      url = "https://addons.mozilla.org/firefox/downloads/file/3722375/tab_counter_plus-3.4.xpi";
      sha256 = "98e0d3b5c7f27c4811106a9564fd0fbd13c70856bb6f91bff25c6e9905fbdeb5";
      meta = with lib;
      {
        homepage = "https://github.com/Loirooriol/tab-counter-plus";
        description = "Shows the number of tabs in each window. Efficient and customizable.";
        license = licenses.asl20;
        mozPermissions = [ "storage" ];
        platforms = platforms.all;
      };
    };
    "tab-reloader" = buildFirefoxXpiAddon {
      pname = "tab-reloader";
      version = "0.6.6";
      addonId = "jid0-bnmfwWw2w2w4e4edvcdDbnMhdVg@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4538002/tab_reloader-0.6.6.xpi";
      sha256 = "70797fcd147ff4d1269621c151e3ecbb4157c4a25c1120c370b0bdd9b5b39553";
      meta = with lib;
      {
        homepage = "https://webextension.org/listing/tab-reloader.html";
        description = "An easy-to-use tab reloader with custom reloading time settings for individual tabs";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "tabs"
          "alarms"
          "webNavigation"
          "contextMenus"
          "idle"
          "scripting"
          "offscreen"
          "declarativeNetRequestWithHostAccess"
        ];
        platforms = platforms.all;
      };
    };
    "tab-retitle" = buildFirefoxXpiAddon {
      pname = "tab-retitle";
      version = "1.5.2";
      addonId = "{e855175b-f84a-429d-85d6-a61831c8291c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3468684/tab_retitle-1.5.2.xpi";
      sha256 = "3f4171f19bd37b5f6198f5db8beb49ca2c5c5cc426fae5435ca04c3533f4e22a";
      meta = with lib;
      {
        description = "Change tab titles easily!\n+ Persists through sessions\n+ Domain level re-titling\n+ Regex replacements\nand much more!";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "tabs"
          "storage"
          "<all_urls>"
          "contextMenus"
          "bookmarks"
        ];
        platforms = platforms.all;
      };
    };
    "tab-session-manager" = buildFirefoxXpiAddon {
      pname = "tab-session-manager";
      version = "7.1.1";
      addonId = "Tab-Session-Manager@sienori";
      url = "https://addons.mozilla.org/firefox/downloads/file/4464091/tab_session_manager-7.1.1.xpi";
      sha256 = "1cc20bfe2b38aa6c70101d296e6d57419713489cf0b4cde3480de40b2a7337e6";
      meta = with lib;
      {
        homepage = "https://tab-session-manager.sienori.com/";
        description = "Save and restore the state of windows and tabs. It also supports automatic saving and cloud sync.";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "unlimitedStorage"
          "tabs"
          "cookies"
          "downloads"
          "identity"
          "alarms"
        ];
        platforms = platforms.all;
      };
    };
    "tab-stash" = buildFirefoxXpiAddon {
      pname = "tab-stash";
      version = "3.3";
      addonId = "tab-stash@condordes.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4481624/tab_stash-3.3.xpi";
      sha256 = "57ffe879f571d28b9a5b22cbe0fc7587fe820b936c2bbd7990c5d5a4cd6d3730";
      meta = with lib;
      {
        homepage = "https://josh-berry.github.io/tab-stash/";
        description = "Easily save and organize batches of tabs as bookmarks. Clear your tabs, clear your mind. Only for Firefox.";
        license = licenses.mpl20;
        mozPermissions = [
          "sessions"
          "tabs"
          "tabHide"
          "bookmarks"
          "contextMenus"
          "browserSettings"
          "storage"
          "unlimitedStorage"
          "contextualIdentities"
          "cookies"
        ];
        platforms = platforms.all;
      };
    };
    "tab-unload-for-tree-style-tab" = buildFirefoxXpiAddon {
      pname = "tab-unload-for-tree-style-tab";
      version = "6.17";
      addonId = "{7aa0a466-58f8-427b-8cd2-e94645c4edc2}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4326243/tab_unload_for_tree_style_tab-6.17.xpi";
      sha256 = "243f48da0a7dd0834cb816bbdf0c16c503b3f5f273f9826478a70af11718bdca";
      meta = with lib;
      {
        homepage = "https://github.com/Lej77/tab-unloader-for-tree-style-tab";
        description = "Tab unload options for Tree Style Tab.";
        license = licenses.gpl3;
        mozPermissions = [ "storage" "menus" ];
        platforms = platforms.all;
      };
    };
    "tabcenter-reborn" = buildFirefoxXpiAddon {
      pname = "tabcenter-reborn";
      version = "3.0.1";
      addonId = "tabcenter-reborn@ariasuni";
      url = "https://addons.mozilla.org/firefox/downloads/file/4466811/tabcenter_reborn-3.0.1.xpi";
      sha256 = "a95d7c312a8a47647e93f34d43933ba065649b64083016fb3ab70600e015d812";
      meta = with lib;
      {
        homepage = "https://codeberg.org/ariasuni";
        description = "Simple and powerful vertical tab bar";
        license = licenses.mpl20;
        mozPermissions = [
          "<all_urls>"
          "bookmarks"
          "browserSettings"
          "contextualIdentities"
          "cookies"
          "menus"
          "menus.overrideContext"
          "search"
          "sessions"
          "storage"
          "tabs"
          "theme"
          "webNavigation"
        ];
        platforms = platforms.all;
      };
    };
    "tabliss" = buildFirefoxXpiAddon {
      pname = "tabliss";
      version = "2.6.0";
      addonId = "extension@tabliss.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/3940751/tabliss-2.6.0.xpi";
      sha256 = "de766810f234b1c13ffdb7047ae6cbf06ed79c3d08b51a07e4766fadff089c0f";
      meta = with lib;
      {
        homepage = "https://tabliss.io";
        description = "A beautiful New Tab page with many customisable backgrounds and widgets that does not require any permissions.";
        license = licenses.gpl3;
        mozPermissions = [ "storage" ];
        platforms = platforms.all;
      };
    };
    "tabwrangler" = buildFirefoxXpiAddon {
      pname = "tabwrangler";
      version = "7.8.0";
      addonId = "{81b74d53-9416-4fb3-afa2-ab46684b253b}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4438127/tabwrangler-7.8.0.xpi";
      sha256 = "1371955dc30d64c664ea8f644b95615dd5c44997bb7456457089c58941eecf69";
      meta = with lib;
      {
        homepage = "https://github.com/tabwrangler/tabwrangler/";
        description = "Automatically closes inactive tabs and makes it easy to get them back";
        license = licenses.mit;
        mozPermissions = [
          "alarms"
          "contextMenus"
          "sessions"
          "storage"
          "tabs"
        ];
        platforms = platforms.all;
      };
    };
    "tampermonkey" = buildFirefoxXpiAddon {
      pname = "tampermonkey";
      version = "5.4.0";
      addonId = "firefox@tampermonkey.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4578764/tampermonkey-5.4.0.xpi";
      sha256 = "20159d57c510cd0df9ad3992f818042b54d9b52e500fc384fc697314047fdf11";
      meta = with lib;
      {
        homepage = "https://tampermonkey.net";
        description = "Tampermonkey is the world's most popular userscript manager.";
        license = {
          shortName = "tampermonkey";
          fullName = "End-User License Agreement for Tampermonkey";
          url = "https://addons.mozilla.org/en-US/firefox/addon/tampermonkey/eula/";
          free = false;
        };
        mozPermissions = [
          "alarms"
          "notifications"
          "tabs"
          "idle"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "unlimitedStorage"
          "storage"
          "contextMenus"
          "clipboardWrite"
          "cookies"
          "downloads"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "tasks-for-canvas" = buildFirefoxXpiAddon {
      pname = "tasks-for-canvas";
      version = "1.3.2";
      addonId = "tasksforcanvas@jtchengdev.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4180681/tasks_for_canvas-1.3.2.xpi";
      sha256 = "37b29242329754a9c937c02a979e79ec995b9ecd44c41bdeb176e69bb023686e";
      meta = with lib;
      {
        homepage = "https://github.com/jtcheng26/canvas-task-extension";
        description = "A better to-do list sidebar for Canvas. The Tasks browser extension for Canvas™ updates the Canvas dashboard sidebar to show all of your weekly assignments and track your progress throughout the week.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "https://tasksforcanvas.onrender.com/*"
          "https://canvas-task-static.onrender.com/*"
          "https://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "temporary-containers" = buildFirefoxXpiAddon {
      pname = "temporary-containers";
      version = "1.9.2";
      addonId = "{c607c8df-14a7-4f28-894f-29e8722976af}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3723251/temporary_containers-1.9.2.xpi";
      sha256 = "3340a08c29be7c83bd0fea3fc27fde71e4608a4532d932114b439aa690e7edc0";
      meta = with lib;
      {
        homepage = "https://github.com/stoically/temporary-containers";
        description = "Open tabs, websites, and links in automatically managed disposable containers which isolate the data websites store (cookies, storage, and more) from each other, enhancing your privacy and security while you browse.";
        license = licenses.mit;
        mozPermissions = [
          "<all_urls>"
          "contextMenus"
          "contextualIdentities"
          "cookies"
          "management"
          "storage"
          "tabs"
          "webRequest"
          "webRequestBlocking"
        ];
        platforms = platforms.all;
      };
    };
    "temporary-containers-plus" = buildFirefoxXpiAddon {
      pname = "temporary-containers-plus";
      version = "2.0.2";
      addonId = "{1ea2fa75-677e-4702-b06a-50fc7d06fe7e}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4588498/temporary_containers_plus-2.0.2.xpi";
      sha256 = "11614dd91e8f1ed6b046b4f65345b9f39b2dd3fd2df5d79d63f8a6c8a2475b41";
      meta = with lib;
      {
        homepage = "https://github.com/GodKratos/temporary-containers";
        description = "Open tabs, websites, and links in automatically managed disposable containers. Containers isolate the data websites store (cookies, cache, and more) from each other, further enhancing your privacy while you browse.";
        license = licenses.mit;
        mozPermissions = [
          "<all_urls>"
          "contextMenus"
          "contextualIdentities"
          "cookies"
          "management"
          "storage"
          "tabs"
          "webRequest"
          "webRequestBlocking"
        ];
        platforms = platforms.all;
      };
    };
    "terms-of-service-didnt-read" = buildFirefoxXpiAddon {
      pname = "terms-of-service-didnt-read";
      version = "5.1.1";
      addonId = "jid0-3GUEt1r69sQNSrca5p8kx9Ezc3U@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4464742/terms_of_service_didnt_read-5.1.1.xpi";
      sha256 = "adeb00974e01177548bfc065be1d29c0c7e2992d6684ced2c555ca88dc45f243";
      meta = with lib;
      {
        homepage = "http://tosdr.org";
        description = "“I have read and agree to the Terms” is the biggest lie on the web. We aim to fix that. Get informed instantly about websites' terms &amp; privacy policies, with ratings and summaries from the www.tosdr.org initiative.";
        license = licenses.agpl3Plus;
        mozPermissions = [ "tabs" "storage" ];
        platforms = platforms.all;
      };
    };
    "tetrio-plus" = buildFirefoxXpiAddon {
      pname = "tetrio-plus";
      version = "0.27.7";
      addonId = "tetrio-plus@example.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4450796/tetrio_plus-0.27.7.xpi";
      sha256 = "acb2d9f3bd7f063e7a7df3fba936a9ffe003c7c4d9a7fc88ba130eddadd787f6";
      meta = with lib;
      {
        description = "Custom skins, background music, sound effects, (animated) backgrounds, input display, and touch control support for TETR.IO.";
        license = licenses.mit;
        mozPermissions = [
          "webRequest"
          "webRequestBlocking"
          "unlimitedStorage"
          "storage"
          "*://*.tetr.io/*"
          "https://tetr.io/*"
        ];
        platforms = platforms.all;
      };
    };
    "text-contrast-for-dark-themes" = buildFirefoxXpiAddon {
      pname = "text-contrast-for-dark-themes";
      version = "2.1.6";
      addonId = "jid1-nMVE2oP40qeQDQ@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3462082/text_contrast_for_dark_themes-2.1.6.xpi";
      sha256 = "e768c13a4fa10e4dc2ce54f0539dd5a115c76babe6c044ae1115966f6062244d";
      meta = with lib;
      {
        description = "Fixes low-contrast text when using a dark desktop theme.";
        license = licenses.mit;
        mozPermissions = [ "<all_urls>" "storage" "tabs" "webNavigation" ];
        platforms = platforms.all;
      };
    };
    "textern" = buildFirefoxXpiAddon {
      pname = "textern";
      version = "0.8";
      addonId = "textern@jlebon.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4123022/textern-0.8.xpi";
      sha256 = "e7c6dab734b44148ab10b1d3db016059d571bf7b0537c4f33c153e00327225ee";
      meta = with lib;
      {
        homepage = "https://github.com/jlebon/textern";
        description = "Edit text in your favourite external editor!";
        license = licenses.gpl3;
        mozPermissions = [
          "notifications"
          "nativeMessaging"
          "storage"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "the-camelizer-price-history-ch" = buildFirefoxXpiAddon {
      pname = "the-camelizer-price-history-ch";
      version = "3.0.15";
      addonId = "izer@camelcamelcamel.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4075638/the_camelizer_price_history_ch-3.0.15.xpi";
      sha256 = "6c799742bb52cba018b109022b23ff3d95bf32481037e42ed50dd31dc9dcf07a";
      meta = with lib;
      {
        homepage = "https://camelcamelcamel.com/camelizer";
        description = "Add price history charts and price watch features to Firefox when viewing product pages on Amazon.  Use it to make informed purchasing decisions and to receive price drop alerts via email, Twitter, or RSS feed.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "tabs"
          "activeTab"
          "storage"
          "https://*.camelcamelcamel.com/*"
          "https://camelcamelcamel.com/*"
          "https://*.amazon.com/*"
          "https://*.amazon.co.uk/*"
          "https://*.amazon.fr/*"
          "https://*.amazon.de/*"
          "https://*.amazon.es/*"
          "https://*.amazon.ca/*"
          "https://*.amazon.it/*"
          "https://*.amazon.com.au/*"
        ];
        platforms = platforms.all;
      };
    };
    "theater-mode-for-youtube" = buildFirefoxXpiAddon {
      pname = "theater-mode-for-youtube";
      version = "0.2.5";
      addonId = "{b8326f03-322f-4112-96bd-e7996548d99f}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4537602/theater_mode_for_youtube-0.2.5.xpi";
      sha256 = "d2524ae3b1ac9e149ccd477616e37c6f95067c0e2f3f45e2016e5179b6ad04fb";
      meta = with lib;
      {
        homepage = "https://webextension.org/listing/youtube-tools.html?theater";
        description = "Force YouTube to open in its player in the theater mode";
        license = licenses.mpl20;
        mozPermissions = [ "storage" "*://www.youtube.com/*" ];
        platforms = platforms.all;
      };
    };
    "theme-nord-polar-night" = buildFirefoxXpiAddon {
      pname = "theme-nord-polar-night";
      version = "1.18";
      addonId = "{758478b6-29f3-4d69-ab17-c49fe568ed80}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3786274/nord_polar_night_theme-1.18.xpi";
      sha256 = "3a871b7ad5f78fe929b14d12afca722155bf47382d94da53bc9db899b78ec34c";
      meta = with lib;
      {
        homepage = "https://github.com/ChristosBouronikos/Nord-Polar-Night-Theme";
        description = "https://paypal.me/christosbouronikos";
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "themesong-for-youtube-music" = buildFirefoxXpiAddon {
      pname = "themesong-for-youtube-music";
      version = "1.3.0";
      addonId = "{6458ac08-a9d7-4e42-a1b0-f0c43bf90f7d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4605253/themesong_for_youtube_music-1.3.0.xpi";
      sha256 = "edca74009cf6cedbab9c15dfda71e9a7a8ea215223a080fc8c7ae3bcba61b5e6";
      meta = with lib;
      {
        homepage = "https://www.themesong.app";
        description = "Enhancer for YouTube Music™. Dynamic Themes, Visualizers, Lyrics, Sleep Timer, and more!";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "https://music.youtube.com/*"
          "https://*.googleusercontent.com/*"
          "https://*.ytimg.com/*"
          "storage"
          "notifications"
          "scripting"
          "search"
        ];
        platforms = platforms.all;
      };
    };
    "time-zone-converter-savvy-time" = buildFirefoxXpiAddon {
      pname = "time-zone-converter-savvy-time";
      version = "1.10";
      addonId = "yuriy@savvytime.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4596710/time_zone_converter_savvy_time-1.10.xpi";
      sha256 = "ccf05c8bbecb184fa56cdcdd12f3456e7f69e1327427fa3ef1d837dad16d3f1b";
      meta = with lib;
      {
        homepage = "https://savvytime.com/converter";
        description = "Time zone and local time converter. Compare and convert time between many locations at a time.";
        license = licenses.mpl20;
        mozPermissions = [ "storage" ];
        platforms = platforms.all;
      };
    };
    "to-deepl" = buildFirefoxXpiAddon {
      pname = "to-deepl";
      version = "0.9.3";
      addonId = "{db420ff1-427a-4cda-b5e7-7d395b9f16e1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4441395/to_deepl-0.9.3.xpi";
      sha256 = "1596674c306b15daec916e25c19682d367d6729715347b8e1791e8ecbce8d4aa";
      meta = with lib;
      {
        homepage = "https://github.com/xpmn/firefox-to-deepl/";
        description = "Right-click on a section of text and click on \"To DeepL\" to translate it to your language. Default language is selected in extension preferences.";
        license = licenses.mit;
        mozPermissions = [ "activeTab" "contextMenus" "storage" ];
        platforms = platforms.all;
      };
    };
    "to-google-translate" = buildFirefoxXpiAddon {
      pname = "to-google-translate";
      version = "4.3.1";
      addonId = "jid1-93WyvpgvxzGATw@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4575673/to_google_translate-4.3.1.xpi";
      sha256 = "fa52fbf9cc36bd5c458ee5bdf0a3121c6291d2e0b06008944233e9e9a78348b8";
      meta = with lib;
      {
        homepage = "https://github.com/itsecurityco/to-google-translate";
        description = "Right-click a section of text and click the Translate icon next to it to text translate or listen to it in your language.";
        license = licenses.mpl20;
        mozPermissions = [
          "http://*/*"
          "https://*/*"
          "contextMenus"
          "storage"
          "webRequest"
          "webRequestBlocking"
          "tabs"
          "*://translate.google.com/*"
          "*://translate.google.cn/*"
          "*://translate.googleusercontent.com/*"
          "*://translate.googleusercontent.cn/*"
        ];
        platforms = platforms.all;
      };
    };
    "toggl-button-time-tracker" = buildFirefoxXpiAddon {
      pname = "toggl-button-time-tracker";
      version = "4.11.5";
      addonId = "toggl-button@toggl.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4604153/toggl_button_time_tracker-4.11.5.xpi";
      sha256 = "db66d448c78c0cad647c752a7facbb7e2d9495c002d71305ab1f26541becc7e1";
      meta = with lib;
      {
        homepage = "https://toggl.com/track/";
        description = "Puts a timer into any web tool and allows quick real time productivity tracking with all the data stored on your Toggl Track account. Time tracking has never been easier!";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "alarms"
          "contextMenus"
          "notifications"
          "scripting"
          "idle"
          "storage"
          "unlimitedStorage"
        ];
        platforms = platforms.all;
      };
    };
    "tokyo-night-v2" = buildFirefoxXpiAddon {
      pname = "tokyo-night-v2";
      version = "1.0";
      addonId = "{afda92c3-008d-4d08-8766-3f1571995071}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3872556/tokyo_night_v2-1.0.xpi";
      sha256 = "35e99f6584d450412916c95af3dc3cedf4c794657c54bbc1dde900a24880cdf9";
      meta = with lib;
      {
        description = "A Tokyo Night theme, based on enkia's VS Code theme. There are other Tokyo Night themes in the addons store, but none of them actually had the right colors, so I decided to make my own.";
        license = licenses.cc-by-nc-sa-30;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "tomato-clock" = buildFirefoxXpiAddon {
      pname = "tomato-clock";
      version = "6.0.2";
      addonId = "jid1-Kt2kYYgi32zPuw@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3835234/tomato_clock-6.0.2.xpi";
      sha256 = "a13ab0834740ad44ae569aa961b22ca86ce21989fffca50d5cb42061db4c78a7";
      meta = with lib;
      {
        homepage = "https://github.com/samueljun/tomato-clock";
        description = "Tomato Clock is a simple browser extension that helps with online time management.";
        license = licenses.gpl3;
        mozPermissions = [ "notifications" "storage" ];
        platforms = platforms.all;
      };
    };
    "toolkit-for-ynab" = buildFirefoxXpiAddon {
      pname = "toolkit-for-ynab";
      version = "3.19.0";
      addonId = "{4F1FB113-D7D8-40AE-A5BA-9300EAEA0F51}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4567104/toolkit_for_ynab-3.19.0.xpi";
      sha256 = "57115834bd79650cace95dfffc26ee9540dcccb1e81189b42f95a2655bfe4efd";
      meta = with lib;
      {
        homepage = "https://github.com/toolkit-for-ynab/toolkit-for-ynab";
        description = "UI customizations and tweaks for the web version of YNAB.";
        license = licenses.mit;
        mozPermissions = [
          "http://*.youneedabudget.com/*"
          "https://*.youneedabudget.com/*"
          "https://*.ynab.com/*"
          "http://*.ynab.com/*"
          "storage"
        ];
        platforms = platforms.all;
      };
    };
    "topcashback-cashback-coupons" = buildFirefoxXpiAddon {
      pname = "topcashback-cashback-coupons";
      version = "7.1.0.0";
      addonId = "{f89939f9-1978-4203-9802-835ce5844ce7}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4609058/topcashback_cashback_coupons-7.1.0.0.xpi";
      sha256 = "1e2ed1cfebcddf1c2cf423f14321331fcda3265204c8d157fbe8ad555d85067e";
      meta = with lib;
      {
        homepage = "https://www.topcashback.com";
        description = "Join over 25m members worldwide and earn cashback when you shop online at over 4,000 online stores with the highest cashback rates.";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "tabs"
          "storage"
          "unlimitedStorage"
          "cookies"
          "alarms"
          "nativeMessaging"
          "scripting"
          "webNavigation"
          "webRequest"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "torrent-control" = buildFirefoxXpiAddon {
      pname = "torrent-control";
      version = "0.2.44";
      addonId = "{e6e36c9a-8323-446c-b720-a176017e38ff}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4568486/torrent_control-0.2.44.xpi";
      sha256 = "411ffcc018d0d6158c5cb6f2ba782d95da04106d695c0c29cf20d14ed712f2d6";
      meta = with lib;
      {
        homepage = "https://github.com/Mika-/torrent-control";
        description = "Send torrent and magnet links to your Bittorrent client's web interface. Supports BiglyBT, Cloud Torrent, Deluge, Flood, ruTorrent, Synology Download Station, Tixati, Transmission, tTorrent, µTorrent, Vuze and qBittorrent.";
        license = licenses.mit;
        mozPermissions = [
          "contextMenus"
          "cookies"
          "notifications"
          "storage"
          "webRequest"
          "webRequestBlocking"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "tournesol" = buildFirefoxXpiAddon {
      pname = "tournesol";
      version = "3.10.0";
      addonId = "{e8e831e8-8a2b-4fd8-b9f0-cd11155b476d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4611011/tournesol_extension-3.10.0.xpi";
      sha256 = "1538c5550fd491931029de99df81ad233abcfac275b1c187bcc19700e6b97c73";
      meta = with lib;
      {
        homepage = "https://tournesol.app/";
        description = "See Tournesol recommendations on YouTube, and easily contribute to the project.";
        license = licenses.lgpl3;
        mozPermissions = [
          "https://tournesol.app/"
          "https://api.tournesol.app/"
          "https://www.youtube.com/"
          "activeTab"
          "contextMenus"
          "storage"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "https://*.youtube.com/*"
          "https://*.youtube.com/feed/history"
          "https://tournesol.app/*"
        ];
        platforms = platforms.all;
      };
    };
    "tranquility-1" = buildFirefoxXpiAddon {
      pname = "tranquility-1";
      version = "3.0.26";
      addonId = "tranquility@ushnisha.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4300302/tranquility_1-3.0.26.xpi";
      sha256 = "0effa816ae196eca8f2403c62738b182e6e7ce26477bafda8f27d3f958996330";
      meta = with lib;
      {
        homepage = "https://github.com/ushnisha/tranquility-reader-webextensions";
        description = "Tranquility Reader improves the readability of web articles by removing unnecessary elements like ads, images, social sharing widgets, and other distracting fluff.";
        license = licenses.gpl3;
        mozPermissions = [
          "<all_urls>"
          "activeTab"
          "storage"
          "alarms"
          "contextMenus"
        ];
        platforms = platforms.all;
      };
    };
    "translate-web-pages" = buildFirefoxXpiAddon {
      pname = "translate-web-pages";
      version = "10.1.1.1";
      addonId = "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4455681/traduzir_paginas_web-10.1.1.1.xpi";
      sha256 = "dc94a7efac63468f7d34a74bedf5c8b360a67c99d213bb5b1a1d55d911797782";
      meta = with lib;
      {
        description = "Translate your page in real time using Google, Bing or Yandex.\nIt is not necessary to open new tabs.";
        license = licenses.mpl20;
        mozPermissions = [
          "<all_urls>"
          "storage"
          "activeTab"
          "contextMenus"
          "webRequest"
          "https://www.deepl.com/*/translator*"
        ];
        platforms = platforms.all;
      };
    };
    "transparent-standalone-image" = buildFirefoxXpiAddon {
      pname = "transparent-standalone-image";
      version = "2.2resigned1";
      addonId = "jid0-ezUl0hF1SPM9hLO5BMBkNoblB8s@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4270447/transparent_standalone_image-2.2resigned1.xpi";
      sha256 = "bc7aeb16c9888c801300f818ff86737ca7e15315ab63c77acb309b42e2c0ba07";
      meta = with lib;
      {
        description = "This add-on renders standalone images on a transparent background, so you can see the image in all its glory!";
        license = licenses.mpl20;
        mozPermissions = [ "tabs" "file:///*" "*://*/*" ];
        platforms = platforms.all;
      };
    };
    "transparent-zen" = buildFirefoxXpiAddon {
      pname = "transparent-zen";
      version = "0.6.0";
      addonId = "{74186d10-f6f2-4f73-b33a-83bb72e50654}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4515420/transparent_zen-0.6.0.xpi";
      sha256 = "3863f54aedb8dc6358025b995a1f2d66d7e149ff8720559af4fa0b3397e48990";
      meta = with lib;
      {
        description = "Applies custom styles to make your favorite websites transparent.";
        license = licenses.mit;
        mozPermissions = [ "activeTab" "storage" "tabs" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "tree-style-tab" = buildFirefoxXpiAddon {
      pname = "tree-style-tab";
      version = "4.2.7";
      addonId = "treestyletab@piro.sakura.ne.jp";
      url = "https://addons.mozilla.org/firefox/downloads/file/4602712/tree_style_tab-4.2.7.xpi";
      sha256 = "098fa380635788ab25968ce25bd2911b3d03c41f99bcd3d3ca65572d9a37021b";
      meta = with lib;
      {
        homepage = "http://piro.sakura.ne.jp/xul/_treestyletab.html.en";
        description = "Show tabs like a tree.";
        license = {
          shortName = "tree-style-tab";
          fullName = "Tree Style Tab License, primarily MPL 2.0";
          url = "https://github.com/piroor/treestyletab/blob/trunk/COPYING.txt";
          free = true;
        };
        mozPermissions = [
          "activeTab"
          "contextualIdentities"
          "cookies"
          "menus"
          "menus.overrideContext"
          "notifications"
          "search"
          "sessions"
          "storage"
          "tabGroups"
          "tabs"
          "theme"
        ];
        platforms = platforms.all;
      };
    };
    "tridactyl" = buildFirefoxXpiAddon {
      pname = "tridactyl";
      version = "1.24.4";
      addonId = "tridactyl.vim@cmcaine.co.uk";
      url = "https://addons.mozilla.org/firefox/downloads/file/4549492/tridactyl_vim-1.24.4.xpi";
      sha256 = "9ba7d6bc3be555631c981c3acdd25cab6942c1f4a6f0cb511bbe8fa81d79dd9d";
      meta = with lib;
      {
        homepage = "https://tridactyl.xyz";
        description = "Vim, but in your browser. Replace Firefox's control mechanism with one modelled on Vim.\n\nThis addon is very usable, but is in an early stage of development. We intend to implement the majority of Vimperator's features.";
        license = licenses.asl20;
        mozPermissions = [
          "activeTab"
          "bookmarks"
          "browsingData"
          "contextMenus"
          "contextualIdentities"
          "cookies"
          "clipboardWrite"
          "clipboardRead"
          "downloads"
          "find"
          "history"
          "search"
          "sessions"
          "storage"
          "tabHide"
          "tabs"
          "topSites"
          "management"
          "nativeMessaging"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "proxy"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "tst-active-tab-on-scroll-bar" = buildFirefoxXpiAddon {
      pname = "tst-active-tab-on-scroll-bar";
      version = "1.3.2";
      addonId = "tst-active-tab-on-scrollbar@piro.sakura.ne.jp";
      url = "https://addons.mozilla.org/firefox/downloads/file/4255623/tst_active_tab_on_scroll_bar-1.3.2.xpi";
      sha256 = "48b1e34aff6f0432167d62f34c1a59015260cdf624e3860a75a4ed502bf88b6b";
      meta = with lib;
      {
        description = "Provides a marker to indicate active tab position in Tree Style Tab sidebar.";
        license = licenses.mpl20;
        mozPermissions = [ "tabs" "storage" ];
        platforms = platforms.all;
      };
    };
    "tst-bookmarks-subpanel" = buildFirefoxXpiAddon {
      pname = "tst-bookmarks-subpanel";
      version = "2.0";
      addonId = "tst-bookmarks-subpanel@piro.sakura.ne.jp";
      url = "https://addons.mozilla.org/firefox/downloads/file/4231489/tst_bookmarks_subpanel-2.0.xpi";
      sha256 = "a1d813e6aeff23d5d5b73496c99940815b03560556c22f975d6df4b7d781865d";
      meta = with lib;
      {
        description = "Provides a bookmarks subpanel for Tree Style Tab's sidebar.";
        license = licenses.mpl20;
        mozPermissions = [ "bookmarks" "browserSettings" "storage" ];
        platforms = platforms.all;
      };
    };
    "tst-fade-old-tabs" = buildFirefoxXpiAddon {
      pname = "tst-fade-old-tabs";
      version = "1.0.2";
      addonId = "tst_fade_old_tabs@emvaized.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4347144/tst_fade_old_tabs-1.0.2.xpi";
      sha256 = "93b8a7d572886d7e4d45728442d8c2442c558772b8402f91e30a1f17f37bf661";
      meta = with lib;
      {
        description = "This TST addon fades away tabs that hasn't been visited for a while";
        license = licenses.mpl20;
        mozPermissions = [ "tabs" "storage" ];
        platforms = platforms.all;
      };
    };
    "tst-indent-line" = buildFirefoxXpiAddon {
      pname = "tst-indent-line";
      version = "1.3.3";
      addonId = "tst-indent-line@piro.sakura.ne.jp";
      url = "https://addons.mozilla.org/firefox/downloads/file/4402044/tst_indent_line-1.3.3.xpi";
      sha256 = "8fb1c318460061d3729e12c230d2ed4419bcca24f5a4b25286c17689d9ba7396";
      meta = with lib;
      {
        description = "Provides indent line for Tree Style Tab sidebar.";
        license = licenses.mpl20;
        mozPermissions = [ "tabs" "storage" ];
        platforms = platforms.all;
      };
    };
    "tst-lock-tree-collapsed" = buildFirefoxXpiAddon {
      pname = "tst-lock-tree-collapsed";
      version = "1.4.3";
      addonId = "tst-lock-tree-collapsed@piro.sakura.ne.jp";
      url = "https://addons.mozilla.org/firefox/downloads/file/4259052/tst_lock_tree_collapsed-1.4.3.xpi";
      sha256 = "d7e25f5407ca1b9e57d3eca88fd9e7762805ed27c306377c5b8afc7f2570f796";
      meta = with lib;
      {
        homepage = "https://github.com/piroor/tst-lock-tree-collapsed";
        description = "Provides ability to lock trees in Tree Style Tab  as collapsed.";
        license = licenses.mpl20;
        mozPermissions = [ "menus" "tabs" "sessions" "storage" ];
        platforms = platforms.all;
      };
    };
    "tst-more-tree-commands" = buildFirefoxXpiAddon {
      pname = "tst-more-tree-commands";
      version = "1.5.1";
      addonId = "tst-more-tree-commands@piro.sakura.ne.jp";
      url = "https://addons.mozilla.org/firefox/downloads/file/4255633/tst_more_tree_commands-1.5.1.xpi";
      sha256 = "698bb52891454c18af3ebf4803546f18d990206d099f4f3721a1e65c91120fca";
      meta = with lib;
      {
        description = "Provides extra tree manipulation commands for Tree Style Tab.";
        license = licenses.mpl20;
        mozPermissions = [ "menus" "tabs" "storage" ];
        platforms = platforms.all;
      };
    };
    "tst-tab-search" = buildFirefoxXpiAddon {
      pname = "tst-tab-search";
      version = "0.0.7";
      addonId = "@tst-search";
      url = "https://addons.mozilla.org/firefox/downloads/file/4145356/tst_search-0.0.7.xpi";
      sha256 = "5979b6ebc694ed1e62d27fec8f750dcb7f09ca393a4ce8ca552d56b7e7241bef";
      meta = with lib;
      {
        homepage = "https://github.com/NiklasGollenstede/tst-search#readme";
        description = "Search for or filter the Tabs in TST's sidebar, and quickly find and activate them.";
        license = licenses.mpl20;
        mozPermissions = [ "storage" "notifications" "tabs" ];
        platforms = platforms.all;
      };
    };
    "tst-wheel-and-double" = buildFirefoxXpiAddon {
      pname = "tst-wheel-and-double";
      version = "1.5.10";
      addonId = "tst-wheel_and_double@dontpokebadgers.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4460647/tree_style_tab_mouse_wheel-1.5.10.xpi";
      sha256 = "4f5e656db4c493e1646ae622d01598b7cdc06b41f1b5facdbb3f007533440719";
      meta = with lib;
      {
        homepage = "https://github.com/joshuacant/";
        description = "This add-on requires Tree Style Tab. It extends Tree Style Tab to allow tab changing by mouse wheel scrolling and reloading a tab when double clicking it.";
        license = licenses.mpl20;
        mozPermissions = [ "storage" ];
        platforms = platforms.all;
      };
    };
    "tubearchivist-companion" = buildFirefoxXpiAddon {
      pname = "tubearchivist-companion";
      version = "0.4.2";
      addonId = "{08f0f80f-2b26-4809-9267-287a5bdda2da}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4575122/tubearchivist_companion-0.4.2.xpi";
      sha256 = "aee6d7f41bf0f9f4aad83b2675b7b568aa5ba5f6c1ca6ea09d770c867ae2b81c";
      meta = with lib;
      {
        homepage = "https://github.com/tubearchivist/browser-extension";
        description = "Interact with your selfhosted TA server.";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "cookies"
          "https://*.youtube.com/*"
          "https://www.youtube.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "tunnelbear-vpn-firefox" = buildFirefoxXpiAddon {
      pname = "tunnelbear-vpn-firefox";
      version = "3.6.1";
      addonId = "browser@tunnelbear.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4138239/tunnelbear_vpn_firefox-3.6.1.xpi";
      sha256 = "f237925eb375c8efc95185e41dbeac5eec4a0355b5d7b09e1c82cc6cd0270bf3";
      meta = with lib;
      {
        homepage = "https://tunnelbear.com";
        description = "TunnelBear is a simple app that helps you browse the Internet privately and securely. TunnelBear changes your IP and protects your browsing data from online threats, letting you access your favorite websites and apps worldwide.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "proxy"
          "tabs"
          "storage"
          "webRequest"
          "privacy"
          "webRequestBlocking"
          "https://*.tunnelbear.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "tweaks-for-youtube" = buildFirefoxXpiAddon {
      pname = "tweaks-for-youtube";
      version = "3.84.0";
      addonId = "{84c8edb0-65ca-43a5-bc53-0e80f41486e1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4603918/tweaks_for_youtube-3.84.0.xpi";
      sha256 = "9b4a955ba14accf6251c2a8a794751319b868ad50f6ecd3c5d4ae7d96682f1d9";
      meta = with lib;
      {
        description = "Seek, navigate chapters, control volume, speed, and more with mouse and keyboard shortcuts. Adjust player controls, progress bar, subtitles, process audio, show playlist duration, take video snapshot, set initial volume, speed, resolution, and more.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "contextMenus"
          "storage"
          "*://www.youtube.com/*"
          "*://www.youtube-nocookie.com/*"
          "*://youtube.googleapis.com/*"
          "*://music.youtube.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "twitch-auto-points" = buildFirefoxXpiAddon {
      pname = "twitch-auto-points";
      version = "1.2.5";
      addonId = "{076d8ebb-5df6-48e0-a619-99315c395644}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3783975/twitch_auto_points-1.2.5.xpi";
      sha256 = "7b11fd334267f61c6f4b2a3ff0450ae227776214790e056cdaf051532eaa8459";
      meta = with lib;
      {
        homepage = "https://github.com/Spring3/twitch-auto-points";
        description = "Automatic twitch channel points collection";
        license = licenses.gpl3;
        mozPermissions = [
          "activeTab"
          "storage"
          "tabs"
          "https://www.twitch.tv/*"
        ];
        platforms = platforms.all;
      };
    };
    "twiter-x-video-downloader" = buildFirefoxXpiAddon {
      pname = "twiter-x-video-downloader";
      version = "15.0";
      addonId = "{7536027f-96fb-4762-9e02-fdfaedd3bfb5}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4520123/twiter_x_video_downloader-15.0.xpi";
      sha256 = "4965a2bfa590a67ed0853443596e7a8ab1d51de77da3cdd4c05c1eae2388354a";
      meta = with lib;
      {
        description = "Download videos from X (Twitter)";
        license = licenses.mpl20;
        mozPermissions = [
          "*://*.x.com/*"
          "*://*.twitter.com/*"
          "webRequest"
          "webRequestBlocking"
          "storage"
        ];
        platforms = platforms.all;
      };
    };
    "ublacklist" = buildFirefoxXpiAddon {
      pname = "ublacklist";
      version = "9.3.0";
      addonId = "@ublacklist";
      url = "https://addons.mozilla.org/firefox/downloads/file/4602896/ublacklist-9.3.0.xpi";
      sha256 = "518047625c826aba2ababb480deb9e147c9f242c49a63415e050aeccb145f5c6";
      meta = with lib;
      {
        homepage = "https://ublacklist.github.io/";
        description = "Blocks sites you specify from appearing in Google search results";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "alarms"
          "declarativeNetRequestWithHostAccess"
          "identity"
          "scripting"
          "storage"
          "unlimitedStorage"
          "https://www.google.com/search?*"
          "https://www.google.ad/search?*"
          "https://www.google.ae/search?*"
          "https://www.google.com.af/search?*"
          "https://www.google.com.ag/search?*"
          "https://www.google.com.ai/search?*"
          "https://www.google.al/search?*"
          "https://www.google.am/search?*"
          "https://www.google.co.ao/search?*"
          "https://www.google.com.ar/search?*"
          "https://www.google.as/search?*"
          "https://www.google.at/search?*"
          "https://www.google.com.au/search?*"
          "https://www.google.az/search?*"
          "https://www.google.ba/search?*"
          "https://www.google.com.bd/search?*"
          "https://www.google.be/search?*"
          "https://www.google.bf/search?*"
          "https://www.google.bg/search?*"
          "https://www.google.com.bh/search?*"
          "https://www.google.bi/search?*"
          "https://www.google.bj/search?*"
          "https://www.google.com.bn/search?*"
          "https://www.google.com.bo/search?*"
          "https://www.google.com.br/search?*"
          "https://www.google.bs/search?*"
          "https://www.google.bt/search?*"
          "https://www.google.co.bw/search?*"
          "https://www.google.by/search?*"
          "https://www.google.com.bz/search?*"
          "https://www.google.ca/search?*"
          "https://www.google.cd/search?*"
          "https://www.google.cf/search?*"
          "https://www.google.cg/search?*"
          "https://www.google.ch/search?*"
          "https://www.google.ci/search?*"
          "https://www.google.co.ck/search?*"
          "https://www.google.cl/search?*"
          "https://www.google.cm/search?*"
          "https://www.google.cn/search?*"
          "https://www.google.com.co/search?*"
          "https://www.google.co.cr/search?*"
          "https://www.google.com.cu/search?*"
          "https://www.google.cv/search?*"
          "https://www.google.com.cy/search?*"
          "https://www.google.cz/search?*"
          "https://www.google.de/search?*"
          "https://www.google.dj/search?*"
          "https://www.google.dk/search?*"
          "https://www.google.dm/search?*"
          "https://www.google.com.do/search?*"
          "https://www.google.dz/search?*"
          "https://www.google.com.ec/search?*"
          "https://www.google.ee/search?*"
          "https://www.google.com.eg/search?*"
          "https://www.google.es/search?*"
          "https://www.google.com.et/search?*"
          "https://www.google.fi/search?*"
          "https://www.google.com.fj/search?*"
          "https://www.google.fm/search?*"
          "https://www.google.fr/search?*"
          "https://www.google.ga/search?*"
          "https://www.google.ge/search?*"
          "https://www.google.gg/search?*"
          "https://www.google.com.gh/search?*"
          "https://www.google.com.gi/search?*"
          "https://www.google.gl/search?*"
          "https://www.google.gm/search?*"
          "https://www.google.gp/search?*"
          "https://www.google.gr/search?*"
          "https://www.google.com.gt/search?*"
          "https://www.google.gy/search?*"
          "https://www.google.com.hk/search?*"
          "https://www.google.hn/search?*"
          "https://www.google.hr/search?*"
          "https://www.google.ht/search?*"
          "https://www.google.hu/search?*"
          "https://www.google.co.id/search?*"
          "https://www.google.ie/search?*"
          "https://www.google.co.il/search?*"
          "https://www.google.im/search?*"
          "https://www.google.co.in/search?*"
          "https://www.google.iq/search?*"
          "https://www.google.is/search?*"
          "https://www.google.it/search?*"
          "https://www.google.je/search?*"
          "https://www.google.com.jm/search?*"
          "https://www.google.jo/search?*"
          "https://www.google.co.jp/search?*"
          "https://www.google.co.ke/search?*"
          "https://www.google.com.kh/search?*"
          "https://www.google.ki/search?*"
          "https://www.google.kg/search?*"
          "https://www.google.co.kr/search?*"
          "https://www.google.com.kw/search?*"
          "https://www.google.kz/search?*"
          "https://www.google.la/search?*"
          "https://www.google.com.lb/search?*"
          "https://www.google.li/search?*"
          "https://www.google.lk/search?*"
          "https://www.google.co.ls/search?*"
          "https://www.google.lt/search?*"
          "https://www.google.lu/search?*"
          "https://www.google.lv/search?*"
          "https://www.google.com.ly/search?*"
          "https://www.google.co.ma/search?*"
          "https://www.google.md/search?*"
          "https://www.google.me/search?*"
          "https://www.google.mg/search?*"
          "https://www.google.mk/search?*"
          "https://www.google.ml/search?*"
          "https://www.google.com.mm/search?*"
          "https://www.google.mn/search?*"
          "https://www.google.ms/search?*"
          "https://www.google.com.mt/search?*"
          "https://www.google.mu/search?*"
          "https://www.google.mv/search?*"
          "https://www.google.mw/search?*"
          "https://www.google.com.mx/search?*"
          "https://www.google.com.my/search?*"
          "https://www.google.co.mz/search?*"
          "https://www.google.com.na/search?*"
          "https://www.google.com.nf/search?*"
          "https://www.google.com.ng/search?*"
          "https://www.google.com.ni/search?*"
          "https://www.google.ne/search?*"
          "https://www.google.nl/search?*"
          "https://www.google.no/search?*"
          "https://www.google.com.np/search?*"
          "https://www.google.nr/search?*"
          "https://www.google.nu/search?*"
          "https://www.google.co.nz/search?*"
          "https://www.google.com.om/search?*"
          "https://www.google.com.pa/search?*"
          "https://www.google.com.pe/search?*"
          "https://www.google.com.pg/search?*"
          "https://www.google.com.ph/search?*"
          "https://www.google.com.pk/search?*"
          "https://www.google.pl/search?*"
          "https://www.google.pn/search?*"
          "https://www.google.com.pr/search?*"
          "https://www.google.ps/search?*"
          "https://www.google.pt/search?*"
          "https://www.google.com.py/search?*"
          "https://www.google.com.qa/search?*"
          "https://www.google.ro/search?*"
          "https://www.google.ru/search?*"
          "https://www.google.rw/search?*"
          "https://www.google.com.sa/search?*"
          "https://www.google.com.sb/search?*"
          "https://www.google.sc/search?*"
          "https://www.google.se/search?*"
          "https://www.google.com.sg/search?*"
          "https://www.google.sh/search?*"
          "https://www.google.si/search?*"
          "https://www.google.sk/search?*"
          "https://www.google.com.sl/search?*"
          "https://www.google.sn/search?*"
          "https://www.google.so/search?*"
          "https://www.google.sm/search?*"
          "https://www.google.sr/search?*"
          "https://www.google.st/search?*"
          "https://www.google.com.sv/search?*"
          "https://www.google.td/search?*"
          "https://www.google.tg/search?*"
          "https://www.google.co.th/search?*"
          "https://www.google.com.tj/search?*"
          "https://www.google.tk/search?*"
          "https://www.google.tl/search?*"
          "https://www.google.tm/search?*"
          "https://www.google.tn/search?*"
          "https://www.google.to/search?*"
          "https://www.google.com.tr/search?*"
          "https://www.google.tt/search?*"
          "https://www.google.com.tw/search?*"
          "https://www.google.co.tz/search?*"
          "https://www.google.com.ua/search?*"
          "https://www.google.co.ug/search?*"
          "https://www.google.co.uk/search?*"
          "https://www.google.com.uy/search?*"
          "https://www.google.co.uz/search?*"
          "https://www.google.com.vc/search?*"
          "https://www.google.co.ve/search?*"
          "https://www.google.vg/search?*"
          "https://www.google.co.vi/search?*"
          "https://www.google.com.vn/search?*"
          "https://www.google.vu/search?*"
          "https://www.google.ws/search?*"
          "https://www.google.rs/search?*"
          "https://www.google.co.za/search?*"
          "https://www.google.co.zm/search?*"
          "https://www.google.co.zw/search?*"
          "https://www.google.cat/search?*"
        ];
        platforms = platforms.all;
      };
    };
    "ublock-origin" = buildFirefoxXpiAddon {
      pname = "ublock-origin";
      version = "1.67.0";
      addonId = "uBlock0@raymondhill.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4598854/ublock_origin-1.67.0.xpi";
      sha256 = "b83c6ec49f817a8d05d288b53dbc7005cceccf82e9490d8683b3120aab3c133a";
      meta = with lib;
      {
        homepage = "https://github.com/gorhill/uBlock#ublock-origin";
        description = "Finally, an efficient wide-spectrum content blocker. Easy on CPU and memory.";
        license = licenses.gpl3;
        mozPermissions = [
          "alarms"
          "dns"
          "menus"
          "privacy"
          "storage"
          "tabs"
          "unlimitedStorage"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "<all_urls>"
          "http://*/*"
          "https://*/*"
          "file://*/*"
          "https://easylist.to/*"
          "https://*.fanboy.co.nz/*"
          "https://filterlists.com/*"
          "https://forums.lanik.us/*"
          "https://github.com/*"
          "https://*.github.io/*"
          "https://github.com/uBlockOrigin/*"
          "https://ublockorigin.github.io/*"
          "https://*.reddit.com/r/uBlockOrigin/*"
        ];
        platforms = platforms.all;
      };
    };
    "ubo-scope" = buildFirefoxXpiAddon {
      pname = "ubo-scope";
      version = "1.1.0";
      addonId = "uBO-Scope@raymondhill.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4598871/ubo_scope-1.1.0.xpi";
      sha256 = "eb1dede45459c4f0446c245186fd275ea067c792c42cee99c99b75e0a7ce325a";
      meta = with lib;
      {
        homepage = "https://github.com/gorhill/uBO-Scope";
        description = "A tool to measure your 3rd-party exposure score for web sites you visit.";
        license = licenses.gpl3;
        mozPermissions = [ "activeTab" "storage" "webNavigation" "webRequest" ];
        platforms = platforms.all;
      };
    };
    "ukrainian-dictionary" = buildFirefoxXpiAddon {
      pname = "ukrainian-dictionary";
      version = "6.6.1";
      addonId = "uk-ua@dictionaries.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4481074/ukrainian_dictionary-6.6.1.xpi";
      sha256 = "02ef19a864f6c915908aad5f0a4ff8e8a989bbe3476fc91addda0754be2d7cdf";
      meta = with lib;
      {
        homepage = "https://github.com/brown-uk/dict_uk";
        description = "Ukrainian (uk-UA) spellchecking dictionary";
        license = licenses.mpl11;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "umatrix" = buildFirefoxXpiAddon {
      pname = "umatrix";
      version = "1.4.4";
      addonId = "uMatrix@raymondhill.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/3812704/umatrix-1.4.4.xpi";
      sha256 = "1de172b1d82de28c334834f7b0eaece0b503f59e62cfc0ccf23222b8f2cb88e5";
      meta = with lib;
      {
        homepage = "https://github.com/gorhill/uMatrix";
        description = "Point &amp; click to forbid/allow any class of requests made by your browser. Use it to block scripts, iframes, ads, facebook, etc.";
        license = licenses.gpl3;
        mozPermissions = [
          "browsingData"
          "cookies"
          "privacy"
          "storage"
          "tabs"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "<all_urls>"
          "http://*/*"
          "https://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "undoclosetabbutton" = buildFirefoxXpiAddon {
      pname = "undoclosetabbutton";
      version = "8.1.0";
      addonId = "{4853d046-c5a3-436b-bc36-220fd935ee1d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4513641/undoclosetabbutton-8.1.0.xpi";
      sha256 = "ff9a47b466fe29a860a1846a65502e327717945dc9f7ce627c9cd64a2859baab";
      meta = with lib;
      {
        homepage = "https://github.com/M-Reimer/undoclosetab";
        description = "Allows you to restore the tab you just closed with a single click—plus it can offer a list of recently closed tabs within a convenient context menu.";
        license = licenses.gpl3;
        mozPermissions = [ "menus" "tabs" "sessions" "storage" "theme" ];
        platforms = platforms.all;
      };
    };
    "unofficial-saladict-popup-dictionary" = buildFirefoxXpiAddon {
      pname = "unofficial-saladict-popup-dictionary";
      version = "7.20.0";
      addonId = "UNOFFICIAL_ext-saladict_whycantI_reusethisID@imayx.top";
      url = "https://addons.mozilla.org/firefox/downloads/file/4212328/2826049-7.20.0.xpi";
      sha256 = "e75280776ee8b2d126a1db4451d2075695b0babe932e63b622e40a80fbedaa66";
      meta = with lib;
      {
        homepage = "https://g.imayx.top/UNOFFICIAL_saladict/";
        description = "Saladict is an all-in-one professional pop-up dictionary and page translator which supports multiple search modes, page translations, new word notebook and PDF selection searching. This distribution is UNOFFICIAL. Remove it if you don't trust it.";
        license = licenses.mit;
        mozPermissions = [
          "<all_urls>"
          "alarms"
          "contextMenus"
          "cookies"
          "notifications"
          "storage"
          "tabs"
          "unlimitedStorage"
          "webRequest"
          "webRequestBlocking"
        ];
        platforms = platforms.all;
      };
    };
    "unpaywall" = buildFirefoxXpiAddon {
      pname = "unpaywall";
      version = "3.98";
      addonId = "{f209234a-76f0-4735-9920-eb62507a54cd}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3816853/unpaywall-3.98.xpi";
      sha256 = "6893bea86d3c4ed7f1100bf0e173591b526a062f4ddd7be13c30a54573c797fb";
      meta = with lib;
      {
        homepage = "https://unpaywall.org/products/extension";
        description = "Get free text of research papers as you browse, using Unpaywall's index of ten million legal, open-access articles.";
        license = licenses.mit;
        mozPermissions = [ "*://*.oadoi.org/*" "storage" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "untrap-for-youtube" = buildFirefoxXpiAddon {
      pname = "untrap-for-youtube";
      version = "8.3.1";
      addonId = "{2662ff67-b302-4363-95f3-b050218bd72c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4403100/untrap_for_youtube-8.3.1.xpi";
      sha256 = "9dab0042653747fb81cecf23c20e8b6f42d4d11a98181ac9c316e76e80c65575";
      meta = with lib;
      {
        homepage = "http://untrap.app";
        description = "Summarize YouTube videos with AI and Hide Distractions: shorts, ads, comments, related, suggestions, and more.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "storage"
          "activeTab"
          "*://*.youtube.com/*"
          "*://www.youtube.com/*"
          "*://m.youtube.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "unwanted-twitch" = buildFirefoxXpiAddon {
      pname = "unwanted-twitch";
      version = "25.3.16";
      addonId = "unwanted@twitch.tv";
      url = "https://addons.mozilla.org/firefox/downloads/file/4455580/unwanted_twitch-25.3.16.xpi";
      sha256 = "e724625fcdfdb06c8deb1de23a5cca2b3d5d1b64a84c67b83aa634c917f4c2e3";
      meta = with lib;
      {
        homepage = "https://github.com/kwaschny/unwanted-twitch";
        description = "Hide unwanted streams, games, categories, channels and tags on: twitch.tv";
        license = licenses.mit;
        mozPermissions = [ "storage" "https://www.twitch.tv/*" ];
        platforms = platforms.all;
      };
    };
    "uppity" = buildFirefoxXpiAddon {
      pname = "uppity";
      version = "2.2resigned1";
      addonId = "{16cbd87c-eb99-4f5c-9825-83cf13ab7ff8}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4270233/uppity-2.2resigned1.xpi";
      sha256 = "2696898c1bd077b81139f9639408c4966a47b234112a7eef0dfec8ddaca75b19";
      meta = with lib;
      {
        homepage = "https://github.com/arantius/uppity";
        description = "Navigate up one level (directory).  It will remove an in-page anchor, the querystring, the file, and the last directory in that order, whichever is first found...";
        license = licenses.mit;
        mozPermissions = [ "activeTab" "tabs" "webNavigation" ];
        platforms = platforms.all;
      };
    };
    "user-agent-string-switcher" = buildFirefoxXpiAddon {
      pname = "user-agent-string-switcher";
      version = "0.6.6";
      addonId = "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4593736/user_agent_string_switcher-0.6.6.xpi";
      sha256 = "9c1fee29bd89a721f7af8d76a997aacad027d4f2b141cdb043ee9027b8967599";
      meta = with lib;
      {
        homepage = "https://webextension.org/listing/useragent-switcher.html";
        description = "Spoof websites trying to gather information about your web navigation—like your browser type and operating system—to deliver distinct content you may not want.";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "contextMenus"
          "scripting"
          "declarativeNetRequestWithHostAccess"
        ];
        platforms = platforms.all;
      };
    };
    "userchrome-toggle" = buildFirefoxXpiAddon {
      pname = "userchrome-toggle";
      version = "1.2";
      addonId = "userchrome-toggle@joolee.nl";
      url = "https://addons.mozilla.org/firefox/downloads/file/3912447/userchrome_toggle-1.2.xpi";
      sha256 = "b8b87be8c67e0538536e9482a80a8536b081aed7a7c8bcb4387fdc4f97705c8d";
      meta = with lib;
      {
        description = "This extension allows you to toggle userchrome.css styles on-the-fly with buttons and hotkeys.";
        license = licenses.mit;
        mozPermissions = [ "notifications" "storage" ];
        platforms = platforms.all;
      };
    };
    "userchrome-toggle-extended" = buildFirefoxXpiAddon {
      pname = "userchrome-toggle-extended";
      version = "2.0.1";
      addonId = "userchrome-toggle-extended@n2ezr.ru";
      url = "https://addons.mozilla.org/firefox/downloads/file/4341014/userchrome_toggle_extended-2.0.1.xpi";
      sha256 = "3f5be2684284c0b79aaad0f70872a87f21a9a1329a5eaf8e60090e6f0e6a741d";
      meta = with lib;
      {
        description = "This extension allows you to toggle userchrome.css styles on-the-fly with buttons and hotkeys. You'll be able to switch up to six styles";
        license = licenses.mpl20;
        mozPermissions = [ "storage" ];
        platforms = platforms.all;
      };
    };
    "varia-integrator" = buildFirefoxXpiAddon {
      pname = "varia-integrator";
      version = "1.4";
      addonId = "giantpinkrobots@protonmail.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4556398/varia_integrator-1.4.xpi";
      sha256 = "58f6143ae499f19e931af43ea5403fd3397dcd9b823115ccec59e2c9d847fbd2";
      meta = with lib;
      {
        homepage = "https://giantpinkrobots.github.io/varia/";
        description = "Route all downloads to Varia if it's running.";
        license = licenses.mpl20;
        mozPermissions = [ "downloads" "storage" "<all_urls>" "tabs" ];
        platforms = platforms.all;
      };
    };
    "video-downloadhelper" = buildFirefoxXpiAddon {
      pname = "video-downloadhelper";
      version = "9.5.0.2";
      addonId = "{b9db16a4-6edc-47ec-a1f4-b86292ed211d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4502183/video_downloadhelper-9.5.0.2.xpi";
      sha256 = "c2dcc2fbb58c5a1c115d831ed26964433cffa4addf8c527b70b485d1fe8b7afb";
      meta = with lib;
      {
        homepage = "http://www.downloadhelper.net/";
        description = "Download videos from the web. Easy, smart, no tracking.";
        license = {
          shortName = "vdh";
          fullName = "Custom License for Video DownloadHelper";
          url = "https://addons.mozilla.org/en-US/firefox/addon/video-downloadhelper/license/";
          free = false;
        };
        mozPermissions = [
          "tabs"
          "webRequest"
          "downloads"
          "webNavigation"
          "notifications"
          "scripting"
          "storage"
          "<all_urls>"
          "webRequestBlocking"
          "menus"
          "contextMenus"
          "nativeMessaging"
          "*://*.downloadhelper.net/*"
          "*://*.downloadhelper.net/changelog/*"
          "*://*.downloadhelper.net/debugger"
        ];
        platforms = platforms.all;
      };
    };
    "video-resumer" = buildFirefoxXpiAddon {
      pname = "video-resumer";
      version = "1.2.4resigned1";
      addonId = "videoresumer@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4270451/video_resumer-1.2.4resigned1.xpi";
      sha256 = "e098a3acb92dcefa9d751676aad728082a6973fefc801ea47b239a88a828bea1";
      meta = with lib;
      {
        description = "Automatically resumes YouTube videos from where you played them last. Without this extension, for example, when you click through YouTube videos, back and forth, they always start from the beginning.";
        license = {
          shortName = "video-resumer";
          fullName = "Custom License for Video Resumer";
          url = "https://addons.mozilla.org/en-US/firefox/addon/video-resumer/license/";
          free = false;
        };
        mozPermissions = [
          "storage"
          "unlimitedStorage"
          "alarms"
          "*://*.youtube.com/*"
          "*://*.youtube.com/embed/*"
          "*://*.youtube-nocookie.com/embed/*"
        ];
        platforms = platforms.all;
      };
    };
    "videospeed" = buildFirefoxXpiAddon {
      pname = "videospeed";
      version = "0.6.3.3";
      addonId = "{7be2ba16-0f1e-4d93-9ebc-5164397477a9}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3756025/videospeed-0.6.3.3.xpi";
      sha256 = "dea225f3520dd92b5ab3ef30515f37fbd127aa191c7eb3fa2547d2deae52102a";
      meta = with lib;
      {
        homepage = "https://github.com/codebicycle/videospeed";
        description = "Speed up, slow down, advance and rewind any HTML5 video with quick shortcuts.";
        license = licenses.mit;
        mozPermissions = [ "storage" "http://*/*" "https://*/*" "file:///*" ];
        platforms = platforms.all;
      };
    };
    "view-image" = buildFirefoxXpiAddon {
      pname = "view-image";
      version = "5.2.0";
      addonId = "{287dcf75-bec6-4eec-b4f6-71948a2eea29}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4309509/view_image-5.2.0.xpi";
      sha256 = "32c74f49a4f54f90e768946d44ae569948fd7b9b155a91b6c1a0a3f1ab1cc7eb";
      meta = with lib;
      {
        homepage = "https://github.com/bijij/ViewImage";
        description = "Re-implements the google image, \"View Image\" button.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "*://*.google.com/*"
          "*://*.google.ad/*"
          "*://*.google.ae/*"
          "*://*.google.com.af/*"
          "*://*.google.com.ag/*"
          "*://*.google.al/*"
          "*://*.google.am/*"
          "*://*.google.co.ao/*"
          "*://*.google.com.ar/*"
          "*://*.google.as/*"
          "*://*.google.at/*"
          "*://*.google.com.au/*"
          "*://*.google.az/*"
          "*://*.google.ba/*"
          "*://*.google.com.bd/*"
          "*://*.google.be/*"
          "*://*.google.bf/*"
          "*://*.google.bg/*"
          "*://*.google.com.bh/*"
          "*://*.google.bi/*"
          "*://*.google.bj/*"
          "*://*.google.com.bn/*"
          "*://*.google.com.bo/*"
          "*://*.google.com.br/*"
          "*://*.google.bs/*"
          "*://*.google.bt/*"
          "*://*.google.co.bw/*"
          "*://*.google.by/*"
          "*://*.google.com.bz/*"
          "*://*.google.ca/*"
          "*://*.google.cd/*"
          "*://*.google.cf/*"
          "*://*.google.cg/*"
          "*://*.google.ch/*"
          "*://*.google.ci/*"
          "*://*.google.co.ck/*"
          "*://*.google.cl/*"
          "*://*.google.cm/*"
          "*://*.google.cn/*"
          "*://*.google.com.co/*"
          "*://*.google.co.cr/*"
          "*://*.google.com.cu/*"
          "*://*.google.cv/*"
          "*://*.google.com.cy/*"
          "*://*.google.cz/*"
          "*://*.google.de/*"
          "*://*.google.dj/*"
          "*://*.google.dk/*"
          "*://*.google.dm/*"
          "*://*.google.com.do/*"
          "*://*.google.dz/*"
          "*://*.google.com.ec/*"
          "*://*.google.ee/*"
          "*://*.google.com.eg/*"
          "*://*.google.es/*"
          "*://*.google.com.et/*"
          "*://*.google.fi/*"
          "*://*.google.com.fj/*"
          "*://*.google.fm/*"
          "*://*.google.fr/*"
          "*://*.google.ga/*"
          "*://*.google.ge/*"
          "*://*.google.gg/*"
          "*://*.google.com.gh/*"
          "*://*.google.com.gi/*"
          "*://*.google.gl/*"
          "*://*.google.gm/*"
          "*://*.google.gr/*"
          "*://*.google.com.gt/*"
          "*://*.google.gy/*"
          "*://*.google.com.hk/*"
          "*://*.google.hn/*"
          "*://*.google.hr/*"
          "*://*.google.ht/*"
          "*://*.google.hu/*"
          "*://*.google.co.id/*"
          "*://*.google.ie/*"
          "*://*.google.co.il/*"
          "*://*.google.im/*"
          "*://*.google.co.in/*"
          "*://*.google.iq/*"
          "*://*.google.is/*"
          "*://*.google.it/*"
          "*://*.google.je/*"
          "*://*.google.com.jm/*"
          "*://*.google.jo/*"
          "*://*.google.co.jp/*"
          "*://*.google.co.ke/*"
          "*://*.google.com.kh/*"
          "*://*.google.ki/*"
          "*://*.google.kg/*"
          "*://*.google.co.kr/*"
          "*://*.google.com.kw/*"
          "*://*.google.kz/*"
          "*://*.google.la/*"
          "*://*.google.com.lb/*"
          "*://*.google.li/*"
          "*://*.google.lk/*"
          "*://*.google.co.ls/*"
          "*://*.google.lt/*"
          "*://*.google.lu/*"
          "*://*.google.lv/*"
          "*://*.google.com.ly/*"
          "*://*.google.co.ma/*"
          "*://*.google.md/*"
          "*://*.google.me/*"
          "*://*.google.mg/*"
          "*://*.google.mk/*"
          "*://*.google.ml/*"
          "*://*.google.com.mm/*"
          "*://*.google.mn/*"
          "*://*.google.com.mt/*"
          "*://*.google.mu/*"
          "*://*.google.mv/*"
          "*://*.google.mw/*"
          "*://*.google.com.mx/*"
          "*://*.google.com.my/*"
          "*://*.google.co.mz/*"
          "*://*.google.com.na/*"
          "*://*.google.com.ng/*"
          "*://*.google.com.ni/*"
          "*://*.google.ne/*"
          "*://*.google.nl/*"
          "*://*.google.no/*"
          "*://*.google.com.np/*"
          "*://*.google.nr/*"
          "*://*.google.nu/*"
          "*://*.google.co.nz/*"
          "*://*.google.com.om/*"
          "*://*.google.com.pa/*"
          "*://*.google.com.pe/*"
          "*://*.google.com.pg/*"
          "*://*.google.com.ph/*"
          "*://*.google.com.pk/*"
          "*://*.google.pl/*"
          "*://*.google.pn/*"
          "*://*.google.com.pr/*"
          "*://*.google.ps/*"
          "*://*.google.pt/*"
          "*://*.google.com.py/*"
          "*://*.google.com.qa/*"
          "*://*.google.ro/*"
          "*://*.google.ru/*"
          "*://*.google.rw/*"
          "*://*.google.com.sa/*"
          "*://*.google.com.sb/*"
          "*://*.google.sc/*"
          "*://*.google.se/*"
          "*://*.google.com.sg/*"
          "*://*.google.sh/*"
          "*://*.google.si/*"
          "*://*.google.sk/*"
          "*://*.google.com.sl/*"
          "*://*.google.sn/*"
          "*://*.google.so/*"
          "*://*.google.sm/*"
          "*://*.google.sr/*"
          "*://*.google.st/*"
          "*://*.google.com.sv/*"
          "*://*.google.td/*"
          "*://*.google.tg/*"
          "*://*.google.co.th/*"
          "*://*.google.com.tj/*"
          "*://*.google.tl/*"
          "*://*.google.tm/*"
          "*://*.google.tn/*"
          "*://*.google.to/*"
          "*://*.google.com.tr/*"
          "*://*.google.tt/*"
          "*://*.google.com.tw/*"
          "*://*.google.co.tz/*"
          "*://*.google.com.ua/*"
          "*://*.google.co.ug/*"
          "*://*.google.co.uk/*"
          "*://*.google.com.uy/*"
          "*://*.google.co.uz/*"
          "*://*.google.com.vc/*"
          "*://*.google.co.ve/*"
          "*://*.google.co.vi/*"
          "*://*.google.com.vn/*"
          "*://*.google.vu/*"
          "*://*.google.ws/*"
          "*://*.google.rs/*"
          "*://*.google.co.za/*"
          "*://*.google.co.zm/*"
          "*://*.google.co.zw/*"
          "*://*.google.cat/*"
        ];
        platforms = platforms.all;
      };
    };
    "vim-vixen" = buildFirefoxXpiAddon {
      pname = "vim-vixen";
      version = "1.2.3";
      addonId = "vim-vixen@i-beam.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3845233/vim_vixen-1.2.3.xpi";
      sha256 = "8f86c77ac8e65dfd3f1a32690b56ce9231ac7686d5a86bf85e3d5cc5a3a9e9b5";
      meta = with lib;
      {
        homepage = "https://github.com/ueokande/vim-vixen";
        description = "Accelerates your web browsing with Vim power!!";
        license = licenses.mit;
        mozPermissions = [
          "history"
          "sessions"
          "storage"
          "tabs"
          "clipboardRead"
          "notifications"
          "bookmarks"
          "browserSettings"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "vimium" = buildFirefoxXpiAddon {
      pname = "vimium";
      version = "2.3";
      addonId = "{d7742d87-e61d-4b78-b8a1-b469842139fa}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4524018/vimium_ff-2.3.xpi";
      sha256 = "3da9c02f6ba1c7ae00ba85c87a7f47355904137467547e96199a455553608e9b";
      meta = with lib;
      {
        homepage = "https://github.com/philc/vimium";
        description = "The Hacker's Browser. Vimium provides keyboard shortcuts for navigation and control in the spirit of Vim.";
        license = licenses.mit;
        mozPermissions = [
          "tabs"
          "bookmarks"
          "history"
          "storage"
          "sessions"
          "notifications"
          "scripting"
          "webNavigation"
          "search"
          "clipboardRead"
          "clipboardWrite"
          "<all_urls>"
          "file:///"
          "file:///*/"
        ];
        platforms = platforms.all;
      };
    };
    "vimium-c" = buildFirefoxXpiAddon {
      pname = "vimium-c";
      version = "2.12.3";
      addonId = "vimium-c@gdh1995.cn";
      url = "https://addons.mozilla.org/firefox/downloads/file/4474326/vimium_c-2.12.3.xpi";
      sha256 = "e1a4f8cc13791dfb985c2a78d33df1e8a40f23bd6eca9217165cb748009df540";
      meta = with lib;
      {
        homepage = "https://github.com/gdh1995/vimium-c";
        description = "A keyboard shortcut tool for keyboard-based page navigation and browser tab operations with an advanced omnibar and global shortcuts";
        license = licenses.mit;
        mozPermissions = [
          "clipboardRead"
          "clipboardWrite"
          "history"
          "notifications"
          "search"
          "sessions"
          "storage"
          "tabs"
          "webNavigation"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "violentmonkey" = buildFirefoxXpiAddon {
      pname = "violentmonkey";
      version = "2.31.0";
      addonId = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4455138/violentmonkey-2.31.0.xpi";
      sha256 = "8880114a3ac30a5f3aebc71443f86a1f7fdd1ec9298def22dc2e250502ecccee";
      meta = with lib;
      {
        homepage = "https://violentmonkey.github.io/";
        description = "Userscript support for browsers, open source.";
        license = licenses.mit;
        mozPermissions = [
          "tabs"
          "<all_urls>"
          "webRequest"
          "webRequestBlocking"
          "notifications"
          "storage"
          "unlimitedStorage"
          "clipboardWrite"
          "contextMenus"
          "cookies"
        ];
        platforms = platforms.all;
      };
    };
    "visbug" = buildFirefoxXpiAddon {
      pname = "visbug";
      version = "0.4.6";
      addonId = "{50864413-c4c8-43b0-80b8-982c4a368ac9}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4310221/visbug-0.4.6.xpi";
      sha256 = "cf337509cdc613b51e124b8db4989a5d1bf55c108d38ec57c3d1af82cc9ce3dc";
      meta = with lib;
      {
        homepage = "https://visbug.web.app";
        description = "Open source browser design tools";
        license = licenses.asl20;
        mozPermissions = [ "activeTab" "contextMenus" "scripting" "storage" ];
        platforms = platforms.all;
      };
    };
    "vue-js-devtools" = buildFirefoxXpiAddon {
      pname = "vue-js-devtools";
      version = "7.7.7";
      addonId = "{5caff8cc-3d2e-4110-a88a-003cc85b3858}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4508409/vue_js_devtools-7.7.7.xpi";
      sha256 = "5672cd0d3298fa57f2f51e4644011e4152e6e291f6f338601495dd8037331169";
      meta = with lib;
      {
        homepage = "https://devtools.vuejs.org";
        description = "DevTools extension for debugging Vue.js applications.";
        license = licenses.mit;
        mozPermissions = [ "<all_urls>" "devtools" ];
        platforms = platforms.all;
      };
    };
    "w2g" = buildFirefoxXpiAddon {
      pname = "w2g";
      version = "10.8";
      addonId = "{6ea0a676-b3ef-48aa-b23d-24c8876945fb}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4491885/w2g-10.8.xpi";
      sha256 = "212592ce269cbee52793a99be55b56415f5844b4e73692a3e8805ac97f27f87a";
      meta = with lib;
      {
        homepage = "https://w2g.tv";
        description = "With Watch2Gether you can watch videos together with your friends. Enhance your Watch2Gether experience with our official browser extension.";
        license = {
          shortName = "w2g.tv";
          fullName = "Watch2Gether Terms of Use";
          url = "https://community.w2g.tv/t/terms-of-use-english/597/1";
          free = false;
        };
        mozPermissions = [
          "activeTab"
          "webNavigation"
          "scripting"
          "storage"
          "https://stage.watch2gether.com/rooms/*"
          "https://w2g.tv/*"
          "https://rooms.w2g.tv/*"
          "https://stage-rooms.w2g.tv/*"
          "https://stage.w2g.tv/*"
          "https://staging.w2g.tv/*"
        ];
        platforms = platforms.all;
      };
    };
    "wakatimes" = buildFirefoxXpiAddon {
      pname = "wakatimes";
      version = "4.1.0";
      addonId = "addons@wakatime.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4491651/wakatimes-4.1.0.xpi";
      sha256 = "8bcbe94e36612a1cd2cfcce25e941aa20f4ea75382f8663474d1efc9f75a18e9";
      meta = with lib;
      {
        homepage = "https://wakatime.com";
        description = "Automatic time tracking for Firefox.";
        license = licenses.mpl20;
        mozPermissions = [
          "alarms"
          "tabs"
          "storage"
          "activeTab"
          "https://api.wakatime.com/*"
          "https://wakatime.com/*"
          "devtools"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "wallabagger" = buildFirefoxXpiAddon {
      pname = "wallabagger";
      version = "1.19.2";
      addonId = "{7a7b1d36-d7a4-481b-92c6-9f5427cb9eb1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4595455/wallabagger-1.19.2.xpi";
      sha256 = "ff0d5799bec2c95fe5ec0584e1ecef1d1c031b429fc36cd48a906b8ac5b932bd";
      meta = with lib;
      {
        homepage = "https://github.com/wallabag/wallabagger";
        description = "This wallabag v2 extension has the ability to edit title and tags and set starred, archived, or delete states.\r\nYou can add a page from the icon or through the right click menu on a link or on a blank page spot.";
        license = licenses.mit;
        mozPermissions = [ "tabs" "storage" "contextMenus" "activeTab" ];
        platforms = platforms.all;
      };
    };
    "wappalyzer" = buildFirefoxXpiAddon {
      pname = "wappalyzer";
      version = "6.10.86";
      addonId = "wappalyzer@crunchlabz.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4579833/wappalyzer-6.10.86.xpi";
      sha256 = "5dbbc6b20928f76014e64bdf17538a0fe7056cf3b62934df291cb9e6092174ec";
      meta = with lib;
      {
        homepage = "https://www.wappalyzer.com";
        description = "Identify technologies on websites";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "cookies"
          "storage"
          "tabs"
          "webRequest"
          "http://*/*"
          "https://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "watchmarker-for-youtube" = buildFirefoxXpiAddon {
      pname = "watchmarker-for-youtube";
      version = "5.0.3";
      addonId = "yourect@coderect.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4591615/watchmarker_for_youtube-5.0.3.xpi";
      sha256 = "c3a1f0fe9731542bf79957350cf9cb61fd6b73c3356c516cd593ad1498c152a1";
      meta = with lib;
      {
        homepage = "http://sniklaus.com/";
        description = "Automatically mark videos on Youtube that you have already watched.";
        license = licenses.gpl3;
        mozPermissions = [
          "alarms"
          "cookies"
          "declarativeNetRequest"
          "declarativeNetRequestWithHostAccess"
          "history"
          "scripting"
          "storage"
          "tabs"
          "*://www.youtube.com/*"
          "*://m.youtube.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "wave-accessibility-tool" = buildFirefoxXpiAddon {
      pname = "wave-accessibility-tool";
      version = "3.2.7.1";
      addonId = "{9bbf6724-d709-492e-a313-bfed0415a224}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4347627/wave_accessibility_tool-3.2.7.1.xpi";
      sha256 = "26dbf601d4cce121040116ede4edbd983428a8fdece49dc5663db40bdbe9c11e";
      meta = with lib;
      {
        description = "Evaluate web accessibility within the Firefox browser. When activated, the WAVE extension injects icons and indicators into your page to give feedback about accessibility and to facilitate manual evaluation.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "http://*/*"
          "https://*/*"
          "file:///*"
          "<all_urls>"
          "tabs"
          "contextMenus"
        ];
        platforms = platforms.all;
      };
    };
    "wayback-machine" = buildFirefoxXpiAddon {
      pname = "wayback-machine";
      version = "3.2";
      addonId = "wayback_machine@mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4047136/wayback_machine_new-3.2.xpi";
      sha256 = "75da413fee7c28e22ed61380f959888ec80c14e2a38f7b6f9d622f8a4ea853e4";
      meta = with lib;
      {
        homepage = "https://archive.org";
        description = "Welcome to the Official Internet Archive Wayback Machine Browser Extension! Go back in time to see how a website has changed through the history of the Web. Save websites, view missing 404 Not Found pages, or read archived books &amp; papers.";
        license = licenses.gpl3;
        mozPermissions = [
          "activeTab"
          "cookies"
          "contextMenus"
          "notifications"
          "storage"
          "webRequest"
          "webRequestBlocking"
          "https://archive.org/*"
          "https://*.archive.org/*"
          "https://hypothes.is/*"
          "<all_urls>"
          "http://*.wikipedia.org/*"
          "https://*.wikipedia.org/*"
        ];
        platforms = platforms.all;
      };
    };
    "web-archives" = buildFirefoxXpiAddon {
      pname = "web-archives";
      version = "7.1.0";
      addonId = "{d07ccf11-c0cd-4938-a265-2a4d6ad01189}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4596314/view_page_archive-7.1.0.xpi";
      sha256 = "063e259e6d86278b2d9ee7c7af6244195bc115a589492aa0e8402fea53167e5d";
      meta = with lib;
      {
        homepage = "https://github.com/dessant/web-archives#readme";
        description = "View archived and cached versions of web pages on various search engines, such as the Wayback Machine and Archive․is.";
        license = licenses.gpl3Only;
        mozPermissions = [
          "alarms"
          "contextMenus"
          "storage"
          "unlimitedStorage"
          "tabs"
          "activeTab"
          "notifications"
          "webRequest"
          "webRequestBlocking"
          "<all_urls>"
          "http://*/*"
          "https://*/*"
          "file:///*"
        ];
        platforms = platforms.all;
      };
    };
    "web-clipper-obsidian" = buildFirefoxXpiAddon {
      pname = "web-clipper-obsidian";
      version = "0.12.0";
      addonId = "clipper@obsidian.md";
      url = "https://addons.mozilla.org/firefox/downloads/file/4585733/web_clipper_obsidian-0.12.0.xpi";
      sha256 = "9db0c8c9609a4b8489d2e179e0c709a1bd4c91b0c42dfbe7f5f5d102a1eab5b7";
      meta = with lib;
      {
        homepage = "https://obsidian.md/clipper";
        description = "Save and highlight web pages in a private and durable format that you can access offline. The official browser extension for Obsidian.";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "clipboardWrite"
          "contextMenus"
          "storage"
          "scripting"
          "http://*/*"
          "https://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "web-developer" = buildFirefoxXpiAddon {
      pname = "web-developer";
      version = "3.0.1";
      addonId = "{c45c406e-ab73-11d8-be73-000a95be3b12}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4306323/web_developer-3.0.1.xpi";
      sha256 = "4d2ce2773186faa385bd95cfff10e244e37a288800497b750bab665d7be21a3d";
      meta = with lib;
      {
        homepage = "http://chrispederick.com/work/web-developer/firefox/";
        description = "The Web Developer extension adds various web developer tools to the browser.";
        license = licenses.lgpl3;
        mozPermissions = [
          "browsingData"
          "cookies"
          "history"
          "scripting"
          "storage"
          "tabs"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "web-eid" = buildFirefoxXpiAddon {
      pname = "web-eid";
      version = "2.2.1";
      addonId = "{e68418bc-f2b0-4459-a9ea-3e72b6751b07}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4079746/web_eid_webextension-2.2.1.xpi";
      sha256 = "392666581a3e71130307eb94f9010b4ca843829f592db9a093ad68fc00ca59ba";
      meta = with lib;
      {
        description = "Use your electronic identification card for secure authentication and digital signing.";
        license = licenses.mit;
        mozPermissions = [ "*://*/*" "nativeMessaging" ];
        platforms = platforms.all;
      };
    };
    "web-scrobbler" = buildFirefoxXpiAddon {
      pname = "web-scrobbler";
      version = "3.18.0";
      addonId = "{799c0914-748b-41df-a25c-22d008f9e83f}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4602485/web_scrobbler-3.18.0.xpi";
      sha256 = "cca7a8015a4f2463dbab63102575b02acd922730b64a3167fce693efd1b7fa9b";
      meta = with lib;
      {
        homepage = "https://web-scrobbler.com";
        description = "Scrobble music all around the web!";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "contextMenus"
          "notifications"
          "scripting"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "web-search-navigator" = buildFirefoxXpiAddon {
      pname = "web-search-navigator";
      version = "0.5.2";
      addonId = "{ffadac89-63bb-4b04-be90-8cb2aa323171}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4117463/web_search_navigator-0.5.2.xpi";
      sha256 = "838c5e6e1520232716275c1a284fbeaeb3d5ef2ae16a67ee55fdbe208f4e439b";
      meta = with lib;
      {
        homepage = "https://github.com/infokiller/web-search-navigator";
        description = "Boost your searching productivity with Web Search Navigator! Adds keyboard shortcuts to navigate within Google Search results.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "*://www.google.com/search*"
          "*://www.google.ad/search*"
          "*://www.google.ae/search*"
          "*://www.google.com.af/search*"
          "*://www.google.com.ag/search*"
          "*://www.google.com.ai/search*"
          "*://www.google.al/search*"
          "*://www.google.am/search*"
          "*://www.google.co.ao/search*"
          "*://www.google.com.ar/search*"
          "*://www.google.as/search*"
          "*://www.google.at/search*"
          "*://www.google.com.au/search*"
          "*://www.google.az/search*"
          "*://www.google.ba/search*"
          "*://www.google.com.bd/search*"
          "*://www.google.be/search*"
          "*://www.google.bf/search*"
          "*://www.google.bg/search*"
          "*://www.google.com.bh/search*"
          "*://www.google.bi/search*"
          "*://www.google.bj/search*"
          "*://www.google.com.bn/search*"
          "*://www.google.com.bo/search*"
          "*://www.google.com.br/search*"
          "*://www.google.bs/search*"
          "*://www.google.bt/search*"
          "*://www.google.co.bw/search*"
          "*://www.google.by/search*"
          "*://www.google.com.bz/search*"
          "*://www.google.ca/search*"
          "*://www.google.cd/search*"
          "*://www.google.cf/search*"
          "*://www.google.cg/search*"
          "*://www.google.ch/search*"
          "*://www.google.ci/search*"
          "*://www.google.co.ck/search*"
          "*://www.google.cl/search*"
          "*://www.google.cm/search*"
          "*://www.google.cn/search*"
          "*://www.google.com.co/search*"
          "*://www.google.co.cr/search*"
          "*://www.google.com.cu/search*"
          "*://www.google.cv/search*"
          "*://www.google.com.cy/search*"
          "*://www.google.cz/search*"
          "*://www.google.de/search*"
          "*://www.google.dj/search*"
          "*://www.google.dk/search*"
          "*://www.google.dm/search*"
          "*://www.google.com.do/search*"
          "*://www.google.dz/search*"
          "*://www.google.com.ec/search*"
          "*://www.google.ee/search*"
          "*://www.google.com.eg/search*"
          "*://www.google.es/search*"
          "*://www.google.com.et/search*"
          "*://www.google.fi/search*"
          "*://www.google.com.fj/search*"
          "*://www.google.fm/search*"
          "*://www.google.fr/search*"
          "*://www.google.ga/search*"
          "*://www.google.ge/search*"
          "*://www.google.gg/search*"
          "*://www.google.com.gh/search*"
          "*://www.google.com.gi/search*"
          "*://www.google.gl/search*"
          "*://www.google.gm/search*"
          "*://www.google.gp/search*"
          "*://www.google.gr/search*"
          "*://www.google.com.gt/search*"
          "*://www.google.gy/search*"
          "*://www.google.com.hk/search*"
          "*://www.google.hn/search*"
          "*://www.google.hr/search*"
          "*://www.google.ht/search*"
          "*://www.google.hu/search*"
          "*://www.google.co.id/search*"
          "*://www.google.ie/search*"
          "*://www.google.co.il/search*"
          "*://www.google.im/search*"
          "*://www.google.co.in/search*"
          "*://www.google.iq/search*"
          "*://www.google.is/search*"
          "*://www.google.it/search*"
          "*://www.google.je/search*"
          "*://www.google.com.jm/search*"
          "*://www.google.jo/search*"
          "*://www.google.co.jp/search*"
          "*://www.google.co.ke/search*"
          "*://www.google.com.kh/search*"
          "*://www.google.ki/search*"
          "*://www.google.kg/search*"
          "*://www.google.co.kr/search*"
          "*://www.google.com.kw/search*"
          "*://www.google.kz/search*"
          "*://www.google.la/search*"
          "*://www.google.com.lb/search*"
          "*://www.google.li/search*"
          "*://www.google.lk/search*"
          "*://www.google.co.ls/search*"
          "*://www.google.lt/search*"
          "*://www.google.lu/search*"
          "*://www.google.lv/search*"
          "*://www.google.com.ly/search*"
          "*://www.google.co.ma/search*"
          "*://www.google.md/search*"
          "*://www.google.me/search*"
          "*://www.google.mg/search*"
          "*://www.google.mk/search*"
          "*://www.google.ml/search*"
          "*://www.google.com.mm/search*"
          "*://www.google.mn/search*"
          "*://www.google.ms/search*"
          "*://www.google.com.mt/search*"
          "*://www.google.mu/search*"
          "*://www.google.mv/search*"
          "*://www.google.mw/search*"
          "*://www.google.com.mx/search*"
          "*://www.google.com.my/search*"
          "*://www.google.co.mz/search*"
          "*://www.google.com.na/search*"
          "*://www.google.com.nf/search*"
          "*://www.google.com.ng/search*"
          "*://www.google.com.ni/search*"
          "*://www.google.ne/search*"
          "*://www.google.nl/search*"
          "*://www.google.no/search*"
          "*://www.google.com.np/search*"
          "*://www.google.nr/search*"
          "*://www.google.nu/search*"
          "*://www.google.co.nz/search*"
          "*://www.google.com.om/search*"
          "*://www.google.com.pa/search*"
          "*://www.google.com.pe/search*"
          "*://www.google.com.pg/search*"
          "*://www.google.com.ph/search*"
          "*://www.google.com.pk/search*"
          "*://www.google.pl/search*"
          "*://www.google.pn/search*"
          "*://www.google.com.pr/search*"
          "*://www.google.ps/search*"
          "*://www.google.pt/search*"
          "*://www.google.com.py/search*"
          "*://www.google.com.qa/search*"
          "*://www.google.ro/search*"
          "*://www.google.ru/search*"
          "*://www.google.rw/search*"
          "*://www.google.com.sa/search*"
          "*://www.google.com.sb/search*"
          "*://www.google.sc/search*"
          "*://www.google.se/search*"
          "*://www.google.com.sg/search*"
          "*://www.google.sh/search*"
          "*://www.google.si/search*"
          "*://www.google.sk/search*"
          "*://www.google.com.sl/search*"
          "*://www.google.sn/search*"
          "*://www.google.so/search*"
          "*://www.google.sm/search*"
          "*://www.google.sr/search*"
          "*://www.google.st/search*"
          "*://www.google.com.sv/search*"
          "*://www.google.td/search*"
          "*://www.google.tg/search*"
          "*://www.google.co.th/search*"
          "*://www.google.com.tj/search*"
          "*://www.google.tk/search*"
          "*://www.google.tl/search*"
          "*://www.google.tm/search*"
          "*://www.google.tn/search*"
          "*://www.google.to/search*"
          "*://www.google.com.tr/search*"
          "*://www.google.tt/search*"
          "*://www.google.com.tw/search*"
          "*://www.google.co.tz/search*"
          "*://www.google.com.ua/search*"
          "*://www.google.co.ug/search*"
          "*://www.google.co.uk/search*"
          "*://www.google.com.uy/search*"
          "*://www.google.co.uz/search*"
          "*://www.google.com.vc/search*"
          "*://www.google.co.ve/search*"
          "*://www.google.vg/search*"
          "*://www.google.co.vi/search*"
          "*://www.google.com.vn/search*"
          "*://www.google.vu/search*"
          "*://www.google.ws/search*"
          "*://www.google.rs/search*"
          "*://www.google.co.za/search*"
          "*://www.google.co.zm/search*"
          "*://www.google.co.zw/search*"
          "*://www.google.cat/search*"
        ];
        platforms = platforms.all;
      };
    };
    "webhint" = buildFirefoxXpiAddon {
      pname = "webhint";
      version = "2.4.17";
      addonId = "{e748cb59-4901-4bea-b74a-1d8dab98e3c7}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4344764/webhint-2.4.17.xpi";
      sha256 = "38e3b8244dc05dc3128daf7ed0a35f068afb76e839561eb93bfc3e509bd4752a";
      meta = with lib;
      {
        homepage = "https://webhint.io";
        description = "Check for best practices and common errors with your site's accessibility, speed, security and more.";
        mozPermissions = [ "<all_urls>" "webNavigation" "devtools" ];
        platforms = platforms.all;
      };
    };
    "webxr-api-emulator" = buildFirefoxXpiAddon {
      pname = "webxr-api-emulator";
      version = "0.3.3";
      addonId = "{c9bd631a-fdc3-488d-b083-0fed11cefb84}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3717226/webxr_api_emulator-0.3.3.xpi";
      sha256 = "d12b3d35d6a27ddc50a65ebf26ffb83e6fde40546ed277f88e45c1be40da4cca";
      meta = with lib;
      {
        homepage = "https://github.com/MozillaReality/WebXR-emulator-extension";
        description = "Emulate WebXR devices on your browser";
        license = licenses.mpl20;
        mozPermissions = [
          "file://*/*"
          "http://*/*"
          "https://*/*"
          "storage"
          "devtools"
        ];
        platforms = platforms.all;
      };
    };
    "whowrotethat" = buildFirefoxXpiAddon {
      pname = "whowrotethat";
      version = "0.22.3.0";
      addonId = "{7c53a467-2542-497a-86fb-59c2904a56d1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4494744/whowrotethat-0.22.3.0.xpi";
      sha256 = "1bc5be641e6226c0585e1727f406455b0898c0b5a3c0fb927cafb9238bc464dc";
      meta = with lib;
      {
        homepage = "https://www.mediawiki.org/wiki/WWT";
        description = "Explore authorship and revision information visually and directly in Wikipedia articles. Powered by WikiWho.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "*://ar.wikipedia.org/*"
          "*://de.wikipedia.org/*"
          "*://en.wikipedia.org/*"
          "*://es.wikipedia.org/*"
          "*://eu.wikipedia.org/*"
          "*://fr.wikipedia.org/*"
          "*://hu.wikipedia.org/*"
          "*://id.wikipedia.org/*"
          "*://it.wikipedia.org/*"
          "*://ja.wikipedia.org/*"
          "*://nl.wikipedia.org/*"
          "*://pl.wikipedia.org/*"
          "*://pt.wikipedia.org/*"
          "*://tr.wikipedia.org/*"
        ];
        platforms = platforms.all;
      };
    };
    "widegithub" = buildFirefoxXpiAddon {
      pname = "widegithub";
      version = "3.3.1";
      addonId = "{72742915-c83b-4485-9023-b55dc5a1e730}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4545356/widegithub-3.3.1.xpi";
      sha256 = "733a480e054786518ad64406f67b291df50207d252bbf0d3c65d94bdbe0d0540";
      meta = with lib;
      {
        homepage = "https://github.com/fabiocchetti/wide-github/";
        description = "Makes GitHub wide on Mozilla Firefox.\n\nSupports GitHub, private Gists, GitHub Enterprise, and custom domains (TLDs).";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "activeTab"
          "https://github.com/*"
          "https://gist.github.com/*"
          "https://*.github.com/*"
          "https://*.github.io/*"
          "*://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "wikipedia-vector-skin" = buildFirefoxXpiAddon {
      pname = "wikipedia-vector-skin";
      version = "1.3";
      addonId = "{ebe73c0d-b0fd-4f1c-ac90-64ccc950bb0d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4061959/wikipedia_vector_skin-1.3.xpi";
      sha256 = "d81defbe5810d3c3b1ae0d7427d7ec2ff148fe846d19864bab41675db49c789b";
      meta = with lib;
      {
        description = "This extension restores the old Wikipedia Layout and Design by appending \"?useskin=vector\" to Wikipedia URLs.";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "webRequest"
          "webRequestBlocking"
          "*://*.mediawiki.org/*"
          "*://*.wikipedia.org/*"
          "*://*.wiktionary.org/*"
          "*://*.wikiquote.org/*"
          "*://*.wikiversity.org/*"
          "*://*.wikivoyage.org/*"
          "*://*.wikimedia.org/*"
          "*://*.wikidata.org/*"
          "*://*.wikinews.org/*"
          "*://*.wikisource.org/*"
          "*://*.wikibooks.org/*"
        ];
        platforms = platforms.all;
      };
    };
    "wikiwand-wikipedia-modernized" = buildFirefoxXpiAddon {
      pname = "wikiwand-wikipedia-modernized";
      version = "10.0.1";
      addonId = "jid1-D7momAzRw417Ag@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4341711/wikiwand_wikipedia_modernized-10.0.1.xpi";
      sha256 = "ccd5e25bc14a7ce1ba9ada666e7bdb120b60beaf40c6c8ed77120e549171542a";
      meta = with lib;
      {
        homepage = "http://www.wikiwand.com";
        description = "AI-driven wiki aggregator created to enhance user experience on Wikipedia by streamlining knowledge consumption";
        license = {
          shortName = "wikiwand";
          fullName = "Terms of Service - Wikiwand";
          url = "https://www.wikiwand.com/terms";
          free = false;
        };
        mozPermissions = [ "webNavigation" "menus" ];
        platforms = platforms.all;
      };
    };
    "windscribe" = buildFirefoxXpiAddon {
      pname = "windscribe";
      version = "3.4.14.1";
      addonId = "@windscribeff";
      url = "https://addons.mozilla.org/firefox/downloads/file/4585722/windscribe-3.4.14.1.xpi";
      sha256 = "ca09e250631e63c259b89934c5b337daefba6206d2ea3714df8bb20ca523ff78";
      meta = with lib;
      {
        homepage = "https://windscribe.com";
        description = "Windscribe helps you circumvent censorship, block ads, beacons and trackers on websites you use every day.";
        license = licenses.gpl3;
        mozPermissions = [
          "<all_urls>"
          "proxy"
          "management"
          "tabs"
          "webRequest"
          "webRequestBlocking"
          "activeTab"
          "storage"
          "unlimitedStorage"
          "contextMenus"
          "privacy"
          "webNavigation"
          "notifications"
          "cookies"
          "browserSettings"
          "http://*/*"
          "https://*/*"
          "file://*/*"
          "https://windscribe.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "xbrowsersync" = buildFirefoxXpiAddon {
      pname = "xbrowsersync";
      version = "1.5.2";
      addonId = "{019b606a-6f61-4d01-af2a-cea528f606da}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3546070/xbs-1.5.2.xpi";
      sha256 = "8b58ad5498273e121b1ba5abaf108d2bc9f4fb4795bd5c7e6a3778196f7a0221";
      meta = with lib;
      {
        homepage = "https://www.xbrowsersync.org/";
        description = "Browser syncing as it should be: secure, anonymous and free! Sync bookmarks across your browsers and devices, no sign up required.";
        license = licenses.gpl3;
        mozPermissions = [
          "activeTab"
          "alarms"
          "bookmarks"
          "http://*/"
          "https://*/"
          "notifications"
          "storage"
          "tabs"
          "unlimitedStorage"
        ];
        platforms = platforms.all;
      };
    };
    "xdebug-helper-for-firefox" = buildFirefoxXpiAddon {
      pname = "xdebug-helper-for-firefox";
      version = "1.0.10";
      addonId = "{806cbba4-1bd3-4916-9ddc-e719e9ca0cbf}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4141260/xdebug_helper_for_firefox-1.0.10.xpi";
      sha256 = "03190a79c37d7517003349e8aa651a576c28ab4855a5bb004e25785f9b5dea26";
      meta = with lib;
      {
        homepage = "https://github.com/BrianGilbert/xdebug-helper-for-firefox";
        description = "This extension is very useful for PHP developers that are using PHP tools with Xdebug support like PHPStorm, Eclipse with PDT, Netbeans and MacGDBp or any other Xdebug compatible profiling tool like KCacheGrind, WinCacheGrind or Webgrind.";
        license = licenses.mit;
        mozPermissions = [ "tabs" "*://*/*" ];
        platforms = platforms.all;
      };
    };
    "xkit-rewritten" = buildFirefoxXpiAddon {
      pname = "xkit-rewritten";
      version = "1.1.1";
      addonId = "{6e710c58-36cc-49d6-b772-bfc3030fa56e}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4604823/xkit_rewritten-1.1.1.xpi";
      sha256 = "89b934a4e4598b106ad825f030871721854bcbfabb66f2923c1445d845860df0";
      meta = with lib;
      {
        homepage = "https://github.com/AprilSylph/XKit-Rewritten/wiki";
        description = "The enhancement suite for Tumblr's new web interface";
        license = licenses.gpl3;
        mozPermissions = [ "storage" "*://www.tumblr.com/*" ];
        platforms = platforms.all;
      };
    };
    "yang" = buildFirefoxXpiAddon {
      pname = "yang";
      version = "1.0.11";
      addonId = "{0a3250b1-58e0-48cb-9383-428f5adc3dc1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4609186/yang_addon-1.0.11.xpi";
      sha256 = "6658d0671df0c9cf63926ae3e0cd0c0e54587d1be0ff93bf7bf26d39609e3b73";
      meta = with lib;
      {
        homepage = "https://github.com/dmlls/yang";
        description = "An open-source, lightweight extension that allows using DuckDuckGo-like bangs anywhere.";
        license = licenses.gpl3;
        mozPermissions = [ "webRequest" "activeTab" "storage" ];
        platforms = platforms.all;
      };
    };
    "yank" = buildFirefoxXpiAddon {
      pname = "yank";
      version = "2.1.1";
      addonId = "yank@roosta.sh";
      url = "https://addons.mozilla.org/firefox/downloads/file/4538698/yank-2.1.1.xpi";
      sha256 = "1b0f70cc71fc63a2b5eb112dc6923812220e83febce53a04dc1bea17c69f0035";
      meta = with lib;
      {
        homepage = "https://github.com/roosta/yank#readme";
        description = "Yank URL and title of current tab, format to a chosen markup language, and copy to clipboard";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "clipboardWrite"
          "contextMenus"
          "storage"
        ];
        platforms = platforms.all;
      };
    };
    "yomitan" = buildFirefoxXpiAddon {
      pname = "yomitan";
      version = "25.10.13.0";
      addonId = "{6b733b82-9261-47ee-a595-2dda294a4d08}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4602541/yomitan-25.10.13.0.xpi";
      sha256 = "35e5b0f74b4c067306eb3cda014f41e548a082d8f9892a5c6b39c06c73742799";
      meta = with lib;
      {
        homepage = "https://github.com/themoeway/yomitan";
        description = "Powerful and versatile pop-up dictionary for language learning used by 100,000+ language learners.";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "clipboardWrite"
          "unlimitedStorage"
          "declarativeNetRequest"
          "scripting"
          "contextMenus"
          "http://*/*"
          "https://*/*"
          "file://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "youronlinechoices" = buildFirefoxXpiAddon {
      pname = "youronlinechoices";
      version = "0.1.2resigned1";
      addonId = "yoc@edaa.eu";
      url = "https://addons.mozilla.org/firefox/downloads/file/4270703/youronlinechoices_plugin-0.1.2resigned1.xpi";
      sha256 = "b878b3dfd1f3fa2a648f715a089532c936bb4c30ea0eea0f65956d147b9e53ee";
      meta = with lib;
      {
        description = "Helps preserve your choices for online behavioural advertising from companies participating in the European OBA Self-Regulatory Programme.";
        license = licenses.mpl20;
        mozPermissions = [
          "cookies"
          "http://*/*"
          "unlimitedStorage"
          "storage"
        ];
        platforms = platforms.all;
      };
    };
    "youtube-alternative-switch" = buildFirefoxXpiAddon {
      pname = "youtube-alternative-switch";
      version = "2.1.1";
      addonId = "{0290a66b-cebd-47e3-9475-9da502aab1ff}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4256674/youtube_alternative_switch-2.1.1.xpi";
      sha256 = "b084a37c2f9fa125ed088a88796af3101462399f03968df0678c72fbdf803498";
      meta = with lib;
      {
        homepage = "https://codeberg.org/willswats/youtube-alternative-switch";
        description = "Quickly switch videos between YouTube, Piped, Invidious and Chat Replay.";
        license = licenses.mit;
        mozPermissions = [ "tabs" "contextMenus" "storage" ];
        platforms = platforms.all;
      };
    };
    "youtube-auto-hd-fps" = buildFirefoxXpiAddon {
      pname = "youtube-auto-hd-fps";
      version = "1.11.4";
      addonId = "avi6106@gmail.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4453306/youtube_auto_hd_fps-1.11.4.xpi";
      sha256 = "0326c8ccfd38d21e6363dc9786ea15e0ec4244ea77f99aa7e5c30e49a428bdf6";
      meta = with lib;
      {
        homepage = "https://avi12.com/youtube-auto-hd";
        description = "Automatically set the videos' quality on YouTube according to their FPS!";
        license = licenses.gpl3;
        mozPermissions = [
          "cookies"
          "storage"
          "https://www.youtube-nocookie.com/*"
          "https://www.youtube.com/*"
          "https://youtube.googleapis.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "youtube-cards" = buildFirefoxXpiAddon {
      pname = "youtube-cards";
      version = "1.0.4";
      addonId = "{fef652df-dd80-450e-b64a-567abeb3aa4b}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4050818/youtube_cards-1.0.4.xpi";
      sha256 = "e6e983fe3495d9106a6d27efc56acaeff91474af407be3c45236da0df7f142d7";
      meta = with lib;
      {
        homepage = "https://unhook.app";
        description = "Remove YouTube end cards and end screen recommendation videowall.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
        };
        mozPermissions = [
          "storage"
          "https://*.youtube.com/*"
          "https://*.youtube-nocookie.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "youtube-high-definition" = buildFirefoxXpiAddon {
      pname = "youtube-high-definition";
      version = "118.0.9";
      addonId = "{7b1bf0b6-a1b9-42b0-b75d-252036438bdc}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4344731/youtube_high_definition-118.0.9.xpi";
      sha256 = "99195aac88a26aa194ace2f0075d9b4e7710ac3f0c700d18ad3db57b656ee517";
      meta = with lib;
      {
        homepage = "http://barisderin.com/";
        description = "YouTube High Definition is a powerful tool that automatically plays all YouTube videos in HD, changes video player size, offers auto-stop and mute, and much more.";
        license = licenses.lgpl3;
        mozPermissions = [
          "storage"
          "*://*.youtube.com/*"
          "*://*.youtube-nocookie.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "youtube-no-translation" = buildFirefoxXpiAddon {
      pname = "youtube-no-translation";
      version = "2.17.1";
      addonId = "{9a3104a2-02c2-464c-b069-82344e5ed4ec}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4601783/youtube_no_translation-2.17.1.xpi";
      sha256 = "5cb74598b95d2d3a2d74ebb6d6c0b5072f4c699880c70fd0d361347963323699";
      meta = with lib;
      {
        description = "Keeps titles, descriptions and audio tracks in their original language on YouTube.";
        mozPermissions = [
          "storage"
          "*://*.youtube.com/*"
          "*://*.youtube-nocookie.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "youtube-nonstop" = buildFirefoxXpiAddon {
      pname = "youtube-nonstop";
      version = "0.9.2";
      addonId = "{0d7cafdd-501c-49ca-8ebb-e3341caaa55e}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4187690/youtube_nonstop-0.9.2.xpi";
      sha256 = "7659d180f76ea908ea81b84ed9bdd188624eaaa62b88accbe6d8ad4e8caeff38";
      meta = with lib;
      {
        homepage = "https://github.com/lawfx/YoutubeNonStop";
        description = "Tired of getting that \"Video paused. Continue watching?\" confirmation dialog?\nThis extension autoclicks it, so you can listen to your favorite music uninterrupted.\n\nWorking on YouTube and YouTube Music!";
        license = licenses.mit;
        mozPermissions = [
          "https://www.youtube.com/*"
          "https://music.youtube.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "youtube-recommended-videos" = buildFirefoxXpiAddon {
      pname = "youtube-recommended-videos";
      version = "1.6.7";
      addonId = "myallychou@gmail.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4263531/youtube_recommended_videos-1.6.7.xpi";
      sha256 = "bb6d68b8df48c8ece44e4152783cfe401a7da6c275176366b2faa9ea78740d15";
      meta = with lib;
      {
        homepage = "https://unhook.app";
        description = "Hide YouTube related videos, comments, video suggestions wall, homepage recommendations, trending tab, and other distractions.";
        license = {
          shortName = "unhook-eula";
          fullName = "End-User License Agreement for Unhook: Remove YouTube Recommended Videos Comments";
          url = "https://addons.mozilla.org/en-US/firefox/addon/youtube-recommended-videos/eula/},";
          free = false;
        };
        mozPermissions = [
          "storage"
          "webRequest"
          "https://www.youtube.com/*"
          "https://m.youtube.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "youtube-redux" = buildFirefoxXpiAddon {
      pname = "youtube-redux";
      version = "3.10.0";
      addonId = "{2d4c0962-e9ff-4cad-8039-9a8b80d9b8b6}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4606400/youtube_redux-3.10.0.xpi";
      sha256 = "fc90e5b9792e49e1a5796ec2039ee83e7773ea94d5a95b89c6383b973aef1879";
      meta = with lib;
      {
        description = "Replicate old YouTube look and features within the modern layout!";
        license = licenses.mit;
        mozPermissions = [ "activeTab" "storage" "*://*.youtube.com/*" ];
        platforms = platforms.all;
      };
    };
    "youtube-screenshot-button" = buildFirefoxXpiAddon {
      pname = "youtube-screenshot-button";
      version = "4.4.0";
      addonId = "{d8b32864-153d-47fb-93ea-c273c4d1ef17}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4531502/youtube_screenshot_button-4.4.0.xpi";
      sha256 = "9bd3b3bb6a38c2f90c144b6a399dc602d3415cded4ecb124f72168e11deedc5b";
      meta = with lib;
      {
        homepage = "https://github.com/gurumukhi/youtube-screenshot";
        description = "Take screenshots from YouTube Videos &amp; YouTube Shorts. The addon adds screenshot button &amp; also enables Shift+A shortcut.";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "clipboardWrite"
          "notifications"
          "*://*.youtube.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "youtube-shorts-block" = buildFirefoxXpiAddon {
      pname = "youtube-shorts-block";
      version = "1.5.3";
      addonId = "{34daeb50-c2d2-4f14-886a-7160b24d66a4}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4487339/youtube_shorts_block-1.5.3.xpi";
      sha256 = "774896393bc782db2d79992a337d782963766365723c4bbab73d53a63feb2043";
      meta = with lib;
      {
        description = "Play the Youtube shorts video as if it were a normal video.\nand hide \"shorts\"tab and videos (optional).";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "*://*.youtube.com/*"
          "*://m.youtube.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "youtube-subscription-groups" = buildFirefoxXpiAddon {
      pname = "youtube-subscription-groups";
      version = "17.8.10";
      addonId = "danabok16@gmail.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4604905/youtube_subscription_groups-17.8.10.xpi";
      sha256 = "c438eec4e08f64e3db48fcc061f9d38f307bdf1da734c3426e11b83087db4fdd";
      meta = with lib;
      {
        homepage = "https://pockettube.io";
        description = "The best way to group your subscriptions\r\nUsing this simple extension you can create collections that seamlessly fit into YouTube's layout.";
        license = licenses.mpl20;
        mozPermissions = [
          "alarms"
          "storage"
          "unlimitedStorage"
          "identity"
          "contextMenus"
          "https://*.youtube.com/*"
          "webRequest"
        ];
        platforms = platforms.all;
      };
    };
    "ytcfilter" = buildFirefoxXpiAddon {
      pname = "ytcfilter";
      version = "3.0.5";
      addonId = "{20f2dcdf-6f8d-4aeb-862b-b13174475d9c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4365656/ytcfilter-3.0.5.xpi";
      sha256 = "6afdf8869da1e3b08a6d84c55cc71c74b80ab82713dab69080e7dbeadc2dd92a";
      meta = with lib;
      {
        description = "The most powerful and intuitive YouTube chat filter extension.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "unlimitedStorage"
          "https://www.youtube.com/live_chat*"
          "https://www.youtube.com/live_chat_replay*"
          "https://studio.youtube.com/live_chat*"
          "https://studio.youtube.com/live_chat_replay*"
          "https://www.youtube.com/embed/ytcfilter_embed?*"
        ];
        platforms = platforms.all;
      };
    };
    "zeroomega" = buildFirefoxXpiAddon {
      pname = "zeroomega";
      version = "3.4.5";
      addonId = "suziwen1@gmail.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4593637/zeroomega-3.4.5.xpi";
      sha256 = "c053548a8b5dbf135f573af8ef8e63a6833607ce476c1dfdfe8495ad6edc4009";
      meta = with lib;
      {
        description = "Manage and switch between multiple proxies quickly &amp; easily.";
        license = licenses.gpl3;
        mozPermissions = [
          "proxy"
          "tabs"
          "alarms"
          "storage"
          "unlimitedStorage"
          "webRequest"
          "webRequestBlocking"
          "contextMenus"
        ];
        platforms = platforms.all;
      };
    };
    "zhihu-undirect" = buildFirefoxXpiAddon {
      pname = "zhihu-undirect";
      version = "1.1.2resigned1";
      addonId = "{e1896037-b13b-4fe4-9aaf-3fc14d0f5c54}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4272066/zhihu_undirect-1.1.2resigned1.xpi";
      sha256 = "d1d756aa992b3ec2af66e7fc72eb37ced230669fe9c3f54d4574db9813478b65";
      meta = with lib;
      {
        homepage = "https://github.com/paicha/zhihu-undirect";
        description = "移除知乎外部链接重定向，加速上网、避免访问追踪。";
        license = licenses.mit;
        mozPermissions = [ "*://*.zhihu.com/*" ];
        platforms = platforms.all;
      };
    };
    "zhongwen" = buildFirefoxXpiAddon {
      pname = "zhongwen";
      version = "5.16.0";
      addonId = "{dedb3663-6f13-4c6c-bf0f-5bd111cb2c79}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4482184/zhongwen-5.16.0.xpi";
      sha256 = "98645c53837a419fecfbaf335df80b366e6b6d274bb2a41711c8e3d760756574";
      meta = with lib;
      {
        homepage = "https://github.com/cschiller/zhongwen";
        description = "Official Firefox port of the Zhongwen Chrome extension (http://github.com/cschiller/zhongwen). Translate Chinese characters by hovering over them with the mouse. Includes internal word list, links to Chinese Grammar Wiki, tone colors, and more.";
        license = licenses.gpl2;
        mozPermissions = [ "contextMenus" "tabs" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "zoom-image" = buildFirefoxXpiAddon {
      pname = "zoom-image";
      version = "2.7.1";
      addonId = "{b14f4076-e80d-4baa-8c7d-8c65dfd2519c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3717935/zoom_image-2.7.1.xpi";
      sha256 = "a4dd818b5a8a99b945de31797715c7d8d7350fcdfb2450ea6aff200d631c8941";
      meta = with lib;
      {
        homepage = "http://crossblade.her.jp/addon/ff_zoomimage/index.php";
        description = "As though the mouse wheel rotate by the right click on the images, you can do the images extenting / reducing / rotating and so on.\nIt can be expanded regardless of design. Also you can drag zoomed images.";
        license = licenses.mpl20;
        mozPermissions = [
          "contextMenus"
          "activeTab"
          "storage"
          "http://*/*"
          "https://*/*"
          "file://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "zoom-page-we" = buildFirefoxXpiAddon {
      pname = "zoom-page-we";
      version = "19.13";
      addonId = "zoompage-we@DW-dev";
      url = "https://addons.mozilla.org/firefox/downloads/file/4098225/zoom_page_we-19.13.xpi";
      sha256 = "00ef2331283fdfe337fa26d65fee16b1c0409b240401aabf8cae6f56ef08d601";
      meta = with lib;
      {
        description = "Zoom web pages (either per-site or per-tab) using full-page zoom, text-only zoom and minimum font size. Fit-to-width zooming can be applied to pages automatically. Fit-to-window scaling  can be applied to small images.";
        license = licenses.gpl2;
        mozPermissions = [
          "tabs"
          "webNavigation"
          "contextMenus"
          "notifications"
          "storage"
          "browserSettings"
          "http://*/*"
          "https://*/*"
          "file:///*"
        ];
        platforms = platforms.all;
      };
    };
    "zoom-redirector" = buildFirefoxXpiAddon {
      pname = "zoom-redirector";
      version = "1.0.2";
      addonId = "{2d0a18e8-6b0a-4c8c-9256-6e00c01f07fe}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3620533/zoom_redirector-1.0.2.xpi";
      sha256 = "fa505a34cabd8ba22625892cfb48103a4c06118b8f95d9fe2e49e57ef350a3a7";
      meta = with lib;
      {
        homepage = "https://github.com/arkadiyt/zoom-redirector";
        description = "Zoom Redirector transparently redirects any meeting links to use Zoom's browser based web client.";
        license = licenses.mit;
        mozPermissions = [
          "webRequest"
          "webRequestBlocking"
          "*://*.zoom.us/*"
          "*://*.zoomgov.com/*"
        ];
        platforms = platforms.all;
      };
    };
  }
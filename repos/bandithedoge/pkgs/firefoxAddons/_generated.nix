{
  buildFirefoxXpiAddon,
  fetchurl,
  lib,
  stdenv,
}: {
  "augmented-steam" = buildFirefoxXpiAddon {
    pname = "augmented-steam";
    version = "2.6.0";
    addonId = "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4167723/augmented_steam-2.6.0.xpi";
    sha256 = "949f9f8c8a932cbaee3fea6ccbb25a34fa1d260c61df78e5c384bdf7d4118c59";
    meta = with lib; {
      homepage = "https://augmentedsteam.com/";
      description = "Augments your Steam Experience";
      license = licenses.gpl3;
      mozPermissions = [
        "storage"
        "*://*.steampowered.com/*"
        "*://steamcommunity.com/*"
        "*://*.isthereanydeal.com/"
        "webRequest"
        "webRequestBlocking"
        "contextMenus"
        "*://store.steampowered.com/?*"
        "*://store.steampowered.com/"
        "*://*.steampowered.com/wishlist/id/*"
        "*://*.steampowered.com/wishlist/profiles/*"
        "*://*.steampowered.com/charts/*"
        "*://*.steampowered.com/charts"
        "*://*.steampowered.com/charts?*"
        "*://*.steampowered.com/search/*"
        "*://*.steampowered.com/search"
        "*://*.steampowered.com/search?*"
        "*://*.steampowered.com/steamaccount/addfunds"
        "*://*.steampowered.com/steamaccount/addfunds?*"
        "*://*.steampowered.com/steamaccount/addfunds/"
        "*://*.steampowered.com/steamaccount/addfunds/?*"
        "*://*.steampowered.com/digitalgiftcards/selectgiftcard"
        "*://*.steampowered.com/digitalgiftcards/selectgiftcard?*"
        "*://*.steampowered.com/digitalgiftcards/selectgiftcard/"
        "*://*.steampowered.com/digitalgiftcards/selectgiftcard/?*"
        "*://*.steampowered.com/account"
        "*://*.steampowered.com/account?*"
        "*://*.steampowered.com/account/"
        "*://*.steampowered.com/account/?*"
        "*://store.steampowered.com/account/licenses"
        "*://store.steampowered.com/account/licenses?*"
        "*://store.steampowered.com/account/licenses/"
        "*://store.steampowered.com/account/licenses/?*"
        "*://*.steampowered.com/account/registerkey"
        "*://*.steampowered.com/account/registerkey?*"
        "*://*.steampowered.com/account/registerkey/"
        "*://*.steampowered.com/account/registerkey/?*"
        "*://*.steampowered.com/bundle/*"
        "*://*.steampowered.com/sub/*"
        "*://*.steampowered.com/app/*"
        "*://*.steampowered.com/agecheck/*"
        "*://*.steampowered.com/points/*"
        "*://*.steampowered.com/points"
        "*://*.steampowered.com/points?*"
        "*://*.steampowered.com/cart/*"
        "*://*.steampowered.com/cart"
        "*://*.steampowered.com/cart?*"
        "*://steamcommunity.com/sharedfiles"
        "*://steamcommunity.com/sharedfiles?*"
        "*://steamcommunity.com/sharedfiles/"
        "*://steamcommunity.com/sharedfiles/?*"
        "*://steamcommunity.com/workshop"
        "*://steamcommunity.com/workshop?*"
        "*://steamcommunity.com/workshop/"
        "*://steamcommunity.com/workshop/?*"
        "*://steamcommunity.com/sharedfiles/browse"
        "*://steamcommunity.com/sharedfiles/browse?*"
        "*://steamcommunity.com/sharedfiles/browse/"
        "*://steamcommunity.com/sharedfiles/browse/?*"
        "*://steamcommunity.com/workshop/browse"
        "*://steamcommunity.com/workshop/browse?*"
        "*://steamcommunity.com/workshop/browse/"
        "*://steamcommunity.com/workshop/browse/?*"
        "*://steamcommunity.com/id/*/home"
        "*://steamcommunity.com/id/*/home?*"
        "*://steamcommunity.com/id/*/home/"
        "*://steamcommunity.com/id/*/home/?*"
        "*://steamcommunity.com/profiles/*/home"
        "*://steamcommunity.com/profiles/*/home?*"
        "*://steamcommunity.com/profiles/*/home/"
        "*://steamcommunity.com/profiles/*/home/?*"
        "*://steamcommunity.com/id/*/myactivity"
        "*://steamcommunity.com/id/*/myactivity?*"
        "*://steamcommunity.com/id/*/myactivity/"
        "*://steamcommunity.com/id/*/myactivity/?*"
        "*://steamcommunity.com/profiles/*/myactivity"
        "*://steamcommunity.com/profiles/*/myactivity?*"
        "*://steamcommunity.com/profiles/*/myactivity/"
        "*://steamcommunity.com/profiles/*/myactivity/?*"
        "*://steamcommunity.com/id/*/friendactivitydetail/*"
        "*://steamcommunity.com/profiles/*/friendactivitydetail/*"
        "*://steamcommunity.com/id/*/status/*"
        "*://steamcommunity.com/profiles/*/status/*"
        "*://steamcommunity.com/id/*/games"
        "*://steamcommunity.com/id/*/games?*"
        "*://steamcommunity.com/id/*/games/"
        "*://steamcommunity.com/id/*/games/?*"
        "*://steamcommunity.com/profiles/*/games"
        "*://steamcommunity.com/profiles/*/games?*"
        "*://steamcommunity.com/profiles/*/games/"
        "*://steamcommunity.com/profiles/*/games/?*"
        "*://steamcommunity.com/id/*/followedgames"
        "*://steamcommunity.com/id/*/followedgames?*"
        "*://steamcommunity.com/id/*/followedgames/"
        "*://steamcommunity.com/id/*/followedgames/?*"
        "*://steamcommunity.com/profiles/*/followedgames"
        "*://steamcommunity.com/profiles/*/followedgames?*"
        "*://steamcommunity.com/profiles/*/followedgames/"
        "*://steamcommunity.com/profiles/*/followedgames/?*"
        "*://steamcommunity.com/id/*/edit/*"
        "*://steamcommunity.com/profiles/*/edit/*"
        "*://steamcommunity.com/id/*/badges"
        "*://steamcommunity.com/id/*/badges?*"
        "*://steamcommunity.com/id/*/badges/"
        "*://steamcommunity.com/id/*/badges/?*"
        "*://steamcommunity.com/profiles/*/badges"
        "*://steamcommunity.com/profiles/*/badges?*"
        "*://steamcommunity.com/profiles/*/badges/"
        "*://steamcommunity.com/profiles/*/badges/?*"
        "*://steamcommunity.com/id/*/gamecards/*"
        "*://steamcommunity.com/profiles/*/gamecards/*"
        "*://steamcommunity.com/id/*/friendsthatplay/*"
        "*://steamcommunity.com/profiles/*/friendsthatplay/*"
        "*://steamcommunity.com/id/*/friends/*"
        "*://steamcommunity.com/id/*/friends"
        "*://steamcommunity.com/id/*/friends?*"
        "*://steamcommunity.com/profiles/*/friends/*"
        "*://steamcommunity.com/profiles/*/friends"
        "*://steamcommunity.com/profiles/*/friends?*"
        "*://steamcommunity.com/id/*/groups/*"
        "*://steamcommunity.com/id/*/groups"
        "*://steamcommunity.com/id/*/groups?*"
        "*://steamcommunity.com/profiles/*/groups/*"
        "*://steamcommunity.com/profiles/*/groups"
        "*://steamcommunity.com/profiles/*/groups?*"
        "*://steamcommunity.com/id/*/following/*"
        "*://steamcommunity.com/id/*/following"
        "*://steamcommunity.com/id/*/following?*"
        "*://steamcommunity.com/profiles/*/following/*"
        "*://steamcommunity.com/profiles/*/following"
        "*://steamcommunity.com/profiles/*/following?*"
        "*://steamcommunity.com/id/*/inventory"
        "*://steamcommunity.com/id/*/inventory?*"
        "*://steamcommunity.com/id/*/inventory/"
        "*://steamcommunity.com/id/*/inventory/?*"
        "*://steamcommunity.com/profiles/*/inventory"
        "*://steamcommunity.com/profiles/*/inventory?*"
        "*://steamcommunity.com/profiles/*/inventory/"
        "*://steamcommunity.com/profiles/*/inventory/?*"
        "*://steamcommunity.com/market/listings/*"
        "*://steamcommunity.com/market/search/*"
        "*://steamcommunity.com/market/search"
        "*://steamcommunity.com/market/search?*"
        "*://steamcommunity.com/market"
        "*://steamcommunity.com/market?*"
        "*://steamcommunity.com/market/"
        "*://steamcommunity.com/market/?*"
        "*://steamcommunity.com/id/*/stats/*"
        "*://steamcommunity.com/profiles/*/stats/*"
        "*://steamcommunity.com/id/*/myworkshopfiles/?*browsefilter=mysubscriptions*"
        "*://steamcommunity.com/id/*/myworkshopfiles?*browsefilter=mysubscriptions*"
        "*://steamcommunity.com/profiles/*/myworkshopfiles/?*browsefilter=mysubscriptions*"
        "*://steamcommunity.com/profiles/*/myworkshopfiles?*browsefilter=mysubscriptions*"
        "*://steamcommunity.com/id/*/recommended"
        "*://steamcommunity.com/id/*/recommended?*"
        "*://steamcommunity.com/id/*/recommended/"
        "*://steamcommunity.com/id/*/recommended/?*"
        "*://steamcommunity.com/profiles/*/recommended"
        "*://steamcommunity.com/profiles/*/recommended?*"
        "*://steamcommunity.com/profiles/*/recommended/"
        "*://steamcommunity.com/profiles/*/recommended/?*"
        "*://steamcommunity.com/id/*/reviews"
        "*://steamcommunity.com/id/*/reviews?*"
        "*://steamcommunity.com/id/*/reviews/"
        "*://steamcommunity.com/id/*/reviews/?*"
        "*://steamcommunity.com/profiles/*/reviews"
        "*://steamcommunity.com/profiles/*/reviews?*"
        "*://steamcommunity.com/profiles/*/reviews/"
        "*://steamcommunity.com/profiles/*/reviews/?*"
        "*://steamcommunity.com/id/*"
        "*://steamcommunity.com/profiles/*"
        "*://steamcommunity.com/groups/*"
        "*://steamcommunity.com/app/*/guides"
        "*://steamcommunity.com/app/*/guides?*"
        "*://steamcommunity.com/app/*/guides/"
        "*://steamcommunity.com/app/*/guides/?*"
        "*://steamcommunity.com/app/*"
        "*://steamcommunity.com/sharedfiles/filedetails/*"
        "*://steamcommunity.com/sharedfiles/filedetails"
        "*://steamcommunity.com/sharedfiles/filedetails?*"
        "*://steamcommunity.com/workshop/filedetails/*"
        "*://steamcommunity.com/workshop/filedetails"
        "*://steamcommunity.com/workshop/filedetails?*"
        "*://steamcommunity.com/sharedfiles/editguide/?*"
        "*://steamcommunity.com/sharedfiles/editguide?*"
        "*://steamcommunity.com/workshop/editguide/?*"
        "*://steamcommunity.com/workshop/editguide?*"
        "*://steamcommunity.com/tradingcards/boostercreator"
        "*://steamcommunity.com/tradingcards/boostercreator?*"
        "*://steamcommunity.com/tradingcards/boostercreator/"
        "*://steamcommunity.com/tradingcards/boostercreator/?*"
        "*://steamcommunity.com/stats/*/achievements"
        "*://steamcommunity.com/stats/*/achievements?*"
        "*://steamcommunity.com/stats/*/achievements/"
        "*://steamcommunity.com/stats/*/achievements/?*"
        "*://steamcommunity.com/tradeoffer/*"
      ];
      platforms = platforms.all;
    };
  };
  "auto-tab-discard" = buildFirefoxXpiAddon {
    pname = "auto-tab-discard";
    version = "0.6.7";
    addonId = "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4045009/auto_tab_discard-0.6.7.xpi";
    sha256 = "89e59b8603c444258c89a507d7126be52ad7a35e4f7b8cfbca039b746f70b5d5";
    meta = with lib; {
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
  "base64-decoder" = buildFirefoxXpiAddon {
    pname = "base64-decoder";
    version = "1.0";
    addonId = "{b20e4f00-ab03-4a88-90e7-4f6b6232c5a9}";
    url = "https://addons.mozilla.org/firefox/downloads/file/806183/base64_decoder-1.0.xpi";
    sha256 = "77703d2f99b04279486ffc67daf4db8700e46799ffd68ee5d168b540e02307bf";
    meta = with lib; {
      description = "select some text, and base64 decode it.";
      license = licenses.mpl20;
      mozPermissions = [
        "activeTab"
        "tabs"
        "contextMenus"
        "storage"
        "<all_urls>"
      ];
      platforms = platforms.all;
    };
  };
  "betterviewer" = buildFirefoxXpiAddon {
    pname = "betterviewer";
    version = "1.0.5";
    addonId = "ademking@betterviewer";
    url = "https://addons.mozilla.org/firefox/downloads/file/4002455/betterviewer-1.0.5.xpi";
    sha256 = "01b90d2afc4dc5de93dbb2eff2cc1cbd8eac181ddefb9d9506ff36788db901a7";
    meta = with lib; {
      homepage = "https://github.com/Ademking/BetterViewer";
      description = "BetterViewer was designed as a replacement for the image viewing mode built into Firefox and Chrome-based web browsers. With BetterViewer you can use various keyboard shortcuts to quickly pan, zoom images, edit and a lot more!";
      license = licenses.mit;
      mozPermissions = [
        "webRequest"
        "webRequestBlocking"
        "activeTab"
        "storage"
        "*://*/*"
      ];
      platforms = platforms.all;
    };
  };
  "canvasblocker" = buildFirefoxXpiAddon {
    pname = "canvasblocker";
    version = "1.9";
    addonId = "CanvasBlocker@kkapsner.de";
    url = "https://addons.mozilla.org/firefox/downloads/file/4097901/canvasblocker-1.9.xpi";
    sha256 = "5248c2c2dedd14b8aa2cd73f9484285d9453e93339f64fcf04a3d63c859cf3d7";
    meta = with lib; {
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
  "csgofloat" = buildFirefoxXpiAddon {
    pname = "csgofloat";
    version = "3.2.0";
    addonId = "{194d0dc6-7ada-41c6-88b8-95d7636fe43c}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4147246/csgofloat-3.2.0.xpi";
    sha256 = "2c1d46959a9c8c49625889ca2f6c4ebfaeeb299a95e13f51f478bc0b5e20befd";
    meta = with lib; {
      homepage = "https://csgofloat.com";
      description = "Shows the float value, paint seed, and screenshots of Counter-Strike (CS:GO &amp; CS2) items on the Steam Market or Inventories";
      license = licenses.mit;
      mozPermissions = [
        "storage"
        "scripting"
        "*://*.steamcommunity.com/market/listings/730/*"
        "*://*.steamcommunity.com/id/*/tradehistory*"
        "*://*.steamcommunity.com/profiles/*/tradehistory*"
        "*://*.steamcommunity.com/id/*/inventory*"
        "*://*.steamcommunity.com/profiles/*/inventory*"
        "*://*.steamcommunity.com/tradeoffer/*"
      ];
      platforms = platforms.all;
    };
  };
  "dont-fuck-with-paste" = buildFirefoxXpiAddon {
    pname = "dont-fuck-with-paste";
    version = "2.7";
    addonId = "DontFuckWithPaste@raim.ist";
    url = "https://addons.mozilla.org/firefox/downloads/file/3630212/don_t_fuck_with_paste-2.7.xpi";
    sha256 = "ef17dcef7e2034a25982a106e54d19e24c9f226434a396a808195ef0de021a40";
    meta = with lib; {
      homepage = "https://github.com/aaronraimist/DontFuckWithPaste";
      description = "This add-on stops websites from blocking copy and paste for password fields and other input fields.";
      license = licenses.mit;
      mozPermissions = ["storage" "tabs" "<all_urls>"];
      platforms = platforms.all;
    };
  };
  "downthemall" = buildFirefoxXpiAddon {
    pname = "downthemall";
    version = "4.11.1";
    addonId = "{DDC359D1-844A-42a7-9AA1-88A850A938A8}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4157731/downthemall-4.11.1.xpi";
    sha256 = "8f4d25c179e8324d4f8ad785a5dc92d547003974fd3609a06e250f826270291b";
    meta = with lib; {
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
  "enhanced-github" = buildFirefoxXpiAddon {
    pname = "enhanced-github";
    version = "5.0.11";
    addonId = "{72bd91c9-3dc5-40a8-9b10-dec633c0873f}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3764141/enhanced_github-5.0.11.xpi";
    sha256 = "a75d7844b261289d099cf99b1c8915210919b371069f066af139d5a7892967b6";
    meta = with lib; {
      homepage = "https://github.com/softvar/enhanced-github";
      description = "Display repo size, size of each file, download link and option to copy file contents";
      license = licenses.mit;
      mozPermissions = [
        "*://*.github.com/*"
        "storage"
        "webRequest"
        "webNavigation"
      ];
      platforms = platforms.all;
    };
  };
  "gesturefy" = buildFirefoxXpiAddon {
    pname = "gesturefy";
    version = "3.2.9";
    addonId = "{506e023c-7f2b-40a3-8066-bc5deb40aebe}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4177077/gesturefy-3.2.9.xpi";
    sha256 = "e639eb9666c7658db403e9408d33e01fd6b47db65362d246808087e329e78a57";
    meta = with lib; {
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
  "gitako" = buildFirefoxXpiAddon {
    pname = "gitako";
    version = "3.11.6";
    addonId = "{983bd86b-9d6f-4394-92b8-63d844c4ce4c}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4152377/gitako_github_file_tree-3.11.6.xpi";
    sha256 = "1988cc8cbe3cd035daec0bc039e9ccf97093912093366cebc5c0d992065de561";
    meta = with lib; {
      homepage = "https://github.com/EnixCoda/Gitako";
      description = "Gitako is a file tree extension for GitHub, available on Firefox, Chrome, and Edge.\n\nVideo intro: <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/1c1a0c23e84b9c3e43af4c047563692e835dfa55acf38822fa3ca2bd4cb9ad0e/https%3A//youtu.be/r4Ein-s2pN0\" rel=\"nofollow\">https://youtu.be/r4Ein-s2pN0</a>\nHomepage: <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/414db85f00575463826dd366beac0a912bf5a9dc43e679f39ddb998d218d376c/https%3A//github.com/EnixCoda/Gitako\" rel=\"nofollow\">https://github.com/EnixCoda/Gitako</a>";
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
  "github-code-folding" = buildFirefoxXpiAddon {
    pname = "github-code-folding";
    version = "0.1.1";
    addonId = "{b588f8ac-dbdf-4397-bcd7-3d29be2f17d7}";
    url = "https://addons.mozilla.org/firefox/downloads/file/569290/github_code_folding-0.1.1.xpi";
    sha256 = "62f9e4fad039a2fa29223c267d9ddd497bbc9f8481140f80e333b0fb2f2c29a8";
    meta = with lib; {
      homepage = "https://github.com/noam3127/github-code-folding";
      description = "Enable code folding when viewing files in GitHub.";
      license = licenses.mpl20;
      mozPermissions = ["tabs" "*://github.com/*"];
      platforms = platforms.all;
    };
  };
  "github-isometric-contributions" = buildFirefoxXpiAddon {
    pname = "github-isometric-contributions";
    version = "1.1.28";
    addonId = "isometric-contributions@jasonlong.me";
    url = "https://addons.mozilla.org/firefox/downloads/file/4196768/github_isometric_contributions-1.1.28.xpi";
    sha256 = "fff29a12f3b4dbdd0ab67969af582d321ff2f14f50f8283ce55d7330f0da1a59";
    meta = with lib; {
      description = "Renders an isometric pixel view of GitHub contribution graphs.";
      license = licenses.mit;
      mozPermissions = ["storage" "https://github.com/*"];
      platforms = platforms.all;
    };
  };
  "github-repo-size" = buildFirefoxXpiAddon {
    pname = "github-repo-size";
    version = "1.7.0";
    addonId = "github-repo-size@mattelrah.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/3854469/github_repo_size-1.7.0.xpi";
    sha256 = "db3198d767ac62eb1ac362335ccfb590fd01ff452bc6ed328fbc5794396eb6da";
    meta = with lib; {
      homepage = "https://github.com/Shywim/github-repo-size";
      description = "Add repositories size to their GitHub summary band using the GitHub public API.";
      license = licenses.mit;
      mozPermissions = [
        "*://api.github.com/repos/*"
        "storage"
        "*://github.com/*"
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
    meta = with lib; {
      homepage = "https://tiny.cc/Imagus";
      description = "With a simple mouse-over you can enlarge images and display images/videos from links.";
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
  "lovely-forks" = buildFirefoxXpiAddon {
    pname = "lovely-forks";
    version = "3.7.2";
    addonId = "github-forks-addon@musicallyut.in";
    url = "https://addons.mozilla.org/firefox/downloads/file/3805375/lovely_forks-3.7.2.xpi";
    sha256 = "a96c0da726fd46ce6a14ea39ceaaf571e7cf9a2d467b2e2e72543a7c57312b78";
    meta = with lib; {
      homepage = "https://github.com/musically-ut/lovely-forks";
      description = "Show notable forks of Github projects.";
      license = licenses.mpl20;
      mozPermissions = [
        "*://github.com/*"
        "*://api.github.com/*"
        "storage"
      ];
      platforms = platforms.all;
    };
  };
  "material-icons-for-github" = buildFirefoxXpiAddon {
    pname = "material-icons-for-github";
    version = "1.8.8";
    addonId = "{eac6e624-97fa-4f28-9d24-c06c9b8aa713}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4197942/material_icons_for_github-1.8.8.xpi";
    sha256 = "10eef864eb50f70d99b5b823120a5b10a71e4bba38e91cf4f5cd15d5a6a8959c";
    meta = with lib; {
      homepage = "https://github.com/Claudiohbsantos/github-material-icons-extension";
      description = "Replace the file/folder icons on github file browsers with icons representing the file's type and which tool it is used by.";
      license = licenses.mit;
      mozPermissions = [
        "storage"
        "activeTab"
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
  "npm-hub" = buildFirefoxXpiAddon {
    pname = "npm-hub";
    version = "2023.5.29";
    addonId = "npm-hub@sikelianos.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/4117658/npm_hub-2023.5.29.xpi";
    sha256 = "3c59f51145e2fd42f0b56fdf42cfb6a8e882d04149756466a512d3ab2435bbfb";
    meta = with lib; {
      homepage = "https://github.com/npmhub/npmhub";
      description = "Explore npm dependencies on GitHub repos";
      license = licenses.mit;
      mozPermissions = [
        "https://registry.npmjs.org/"
        "contextMenus"
        "activeTab"
        "https://github.com/*"
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
    meta = with lib; {
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
  "privacy-badger" = buildFirefoxXpiAddon {
    pname = "privacy-badger";
    version = "2023.10.31";
    addonId = "jid1-MnnxcxisBPnSXQ@jetpack";
    url = "https://addons.mozilla.org/firefox/downloads/file/4188670/privacy_badger17-2023.10.31.xpi";
    sha256 = "37e96cbd257b73d7350605ed20494a82b578f25a2cefc3de2dab019e5ff6ced1";
    meta = with lib; {
      homepage = "https://privacybadger.org/";
      description = "Automatically learns to block invisible trackers.";
      license = licenses.gpl3;
      mozPermissions = [
        "alarms"
        "tabs"
        "http://*/*"
        "https://*/*"
        "webNavigation"
        "webRequest"
        "webRequestBlocking"
        "storage"
        "privacy"
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
        "<all_urls>"
      ];
      platforms = platforms.all;
    };
  };
  "privacy-pass" = buildFirefoxXpiAddon {
    pname = "privacy-pass";
    version = "3.0.6";
    addonId = "{48748554-4c01-49e8-94af-79662bf34d50}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4160723/privacy_pass-3.0.6.xpi";
    sha256 = "5966bfb190a575b54bd657f6e1b8735a9fd6b9a3ee008520468da37d7838122f";
    meta = with lib; {
      homepage = "https://privacypass.github.io";
      description = "Client-side of the Privacy Pass protocol providing unlinkable cryptographic tokens.";
      license = licenses.bsd2;
      mozPermissions = [
        "<all_urls>"
        "cookies"
        "webRequest"
        "webRequestBlocking"
      ];
      platforms = platforms.all;
    };
  };
  "pronoundb" = buildFirefoxXpiAddon {
    pname = "pronoundb";
    version = "0.14.1";
    addonId = "firefox-addon@pronoundb.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/4119845/pronoundb-0.14.1.xpi";
    sha256 = "aad93ea20e8ec347c1db489754f3d4a3d1e0a6d226af12430dc3e9902d261b61";
    meta = with lib; {
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
      ];
      platforms = platforms.all;
    };
  };
  "reddit-enhancement-suite" = buildFirefoxXpiAddon {
    pname = "reddit-enhancement-suite";
    version = "5.22.17";
    addonId = "jid1-xUfzOsOFlzSOXg@jetpack";
    url = "https://addons.mozilla.org/firefox/downloads/file/4092764/reddit_enhancement_suite-5.22.17.xpi";
    sha256 = "f49827c7684076dbf6890741dbbc31e82c180f87cb3fd745216ba2432398b1d9";
    meta = with lib; {
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
        "unlimitedStorage"
      ];
      platforms = platforms.all;
    };
  };
  "refined-github" = buildFirefoxXpiAddon {
    pname = "refined-github";
    version = "23.11.23";
    addonId = "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4199107/refined_github-23.11.23.xpi";
    sha256 = "c9263d5768f07c9de20cc9e0ccca78b01f82a5c9695a69f601dc9bcd95dff2bd";
    meta = with lib; {
      homepage = "https://github.com/sindresorhus/refined-github";
      description = "Simplifies the GitHub interface and adds many useful features.";
      license = licenses.mit;
      mozPermissions = [
        "storage"
        "contextMenus"
        "activeTab"
        "alarms"
        "https://github.com/*"
        "https://api.github.com/*"
        "https://gist.github.com/*"
      ];
      platforms = platforms.all;
    };
  };
  "sidebery" = buildFirefoxXpiAddon {
    pname = "sidebery";
    version = "5.0.0";
    addonId = "{3c078156-979c-498b-8990-85f7987dd929}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4170134/sidebery-5.0.0.xpi";
    sha256 = "f592427a1c68d3e51aee208d05588f39702496957771fd84b76a93e364138bf5";
    meta = with lib; {
      homepage = "https://github.com/mbnuqw/sidebery";
      description = "Tabs tree and bookmarks in sidebar with advanced containers configuration.";
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
    meta = with lib; {
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
    version = "5.4.27";
    addonId = "sponsorBlocker@ajay.app";
    url = "https://addons.mozilla.org/firefox/downloads/file/4192543/sponsorblock-5.4.27.xpi";
    sha256 = "f5b99a12e5635ab7ae8a8829c62bab363f62b83ef42ff3b146521c59c801559a";
    meta = with lib; {
      homepage = "https://sponsor.ajay.app";
      description = "Easily skip YouTube video sponsors. When you visit a YouTube video, the extension will check the database for reported sponsors and automatically skip known sponsors. You can also report sponsors in videos.\n\nOther browsers: https://sponsor.ajay.app";
      license = licenses.lgpl3;
      mozPermissions = [
        "storage"
        "https://sponsor.ajay.app/*"
        "scripting"
        "https://*.youtube.com/*"
        "https://www.youtube-nocookie.com/embed/*"
      ];
      platforms = platforms.all;
    };
  };
  "steam-database" = buildFirefoxXpiAddon {
    pname = "steam-database";
    version = "3.7.8";
    addonId = "firefox-extension@steamdb.info";
    url = "https://addons.mozilla.org/firefox/downloads/file/4197171/steam_database-3.7.8.xpi";
    sha256 = "99eba9f082bfc9d7a74d0d40ec5188af7c3b38490565e41b15e5319c849b840a";
    meta = with lib; {
      homepage = "https://steamdb.info/";
      description = "Adds SteamDB links and new features on the Steam store and community. View lowest game prices and stats.";
      license = licenses.bsd2;
      mozPermissions = [
        "storage"
        "https://steamdb.info/*"
        "https://store.steampowered.com/*"
        "https://store.steampowered.com/checkout/*"
        "https://store.steampowered.com/cart/*"
        "https://store.steampowered.com/app/*"
        "https://store.steampowered.com/news/app/*"
        "https://store.steampowered.com/account/licenses*"
        "https://store.steampowered.com/account/registerkey*"
        "https://store.steampowered.com/sub/*"
        "https://store.steampowered.com/bundle/*"
        "https://store.steampowered.com/widget/*"
        "https://store.steampowered.com/video/*"
        "https://store.steampowered.com/app/*/agecheck"
        "https://store.steampowered.com/agecheck/*"
        "https://store.steampowered.com/explore*"
        "https://store.steampowered.com/checkout/sendgift/*"
        "https://steamcommunity.com/app/*"
        "https://steamcommunity.com/sharedfiles/filedetails*"
        "https://steamcommunity.com/workshop/filedetails*"
        "https://steamcommunity.com/workshop/browse*"
        "https://steamcommunity.com/workshop/discussions*"
        "https://steamcommunity.com/*"
        "https://steamcommunity.com/id/*"
        "https://steamcommunity.com/profiles/*"
        "https://steamcommunity.com/id/*/inventory*"
        "https://steamcommunity.com/profiles/*/inventory*"
        "https://steamcommunity.com/id/*/stats*"
        "https://steamcommunity.com/profiles/*/stats*"
        "https://steamcommunity.com/stats/*/achievements*"
        "https://steamcommunity.com/tradeoffer/*"
        "https://steamcommunity.com/id/*/recommended/*"
        "https://steamcommunity.com/profiles/*/recommended/*"
        "https://steamcommunity.com/id/*/badges*"
        "https://steamcommunity.com/profiles/*/badges*"
        "https://steamcommunity.com/id/*/gamecards/*"
        "https://steamcommunity.com/profiles/*/gamecards/*"
        "https://steamcommunity.com/games/*"
        "https://steamcommunity.com/sharedfiles/*"
        "https://steamcommunity.com/workshop/*"
        "https://steamcommunity.com/market/*"
      ];
      platforms = platforms.all;
    };
  };
  "stylus" = buildFirefoxXpiAddon {
    pname = "stylus";
    version = "1.5.35";
    addonId = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4160414/styl_us-1.5.35.xpi";
    sha256 = "d415ee11fa4a4313096a268e54fd80fa93143345be16f417eb1300a6ebe26ba1";
    meta = with lib; {
      homepage = "https://add0n.com/stylus.html";
      description = "Redesign your favorite websites with Stylus, an actively developed and community driven userstyles manager. Easily install custom themes from popular online repositories, or create, edit, and manage your own personalized CSS stylesheets.";
      license = licenses.gpl3;
      mozPermissions = [
        "tabs"
        "webNavigation"
        "webRequest"
        "webRequestBlocking"
        "contextMenus"
        "storage"
        "unlimitedStorage"
        "alarms"
        "<all_urls>"
        "http://userstyles.org/*"
        "https://userstyles.org/*"
      ];
      platforms = platforms.all;
    };
  };
  "tabcenter-reborn" = buildFirefoxXpiAddon {
    pname = "tabcenter-reborn";
    version = "2.3.1";
    addonId = "tabcenter-reborn@ariasuni";
    url = "https://addons.mozilla.org/firefox/downloads/file/3829515/tabcenter_reborn-2.3.1.xpi";
    sha256 = "d31c693c896045d4326c7e9e0152830820009bd60f62b36043bb322cab713f34";
    meta = with lib; {
      homepage = "https://framagit.org/ariasuni/tabcenter-reborn";
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
        "notifications"
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
  "tree-style-tab" = buildFirefoxXpiAddon {
    pname = "tree-style-tab";
    version = "3.9.19";
    addonId = "treestyletab@piro.sakura.ne.jp";
    url = "https://addons.mozilla.org/firefox/downloads/file/4197314/tree_style_tab-3.9.19.xpi";
    sha256 = "bb67f47a554f8f937f4176bee6144945eb0f240630b93f73d2cff49f0985b55a";
    meta = with lib; {
      homepage = "http://piro.sakura.ne.jp/xul/_treestyletab.html.en";
      description = "Show tabs like a tree.";
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
        "tabs"
        "theme"
      ];
      platforms = platforms.all;
    };
  };
  "tridactyl" = buildFirefoxXpiAddon {
    pname = "tridactyl";
    version = "1.23.0";
    addonId = "tridactyl.vim@cmcaine.co.uk";
    url = "https://addons.mozilla.org/firefox/downloads/file/4036604/tridactyl_vim-1.23.0.xpi";
    sha256 = "08b7af97bef05300ab3ac3ad721322ff00505631233482568fc4489c16d51b71";
    meta = with lib; {
      homepage = "https://tridactyl.xyz";
      description = "Vim, but in your browser. Replace Firefox's control mechanism with one modelled on Vim.\n\nThis addon is very usable, but is in an early stage of development. We intend to implement the majority of Vimperator's features.";
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
  "ublock-origin" = buildFirefoxXpiAddon {
    pname = "ublock-origin";
    version = "1.53.0";
    addonId = "uBlock0@raymondhill.net";
    url = "https://addons.mozilla.org/firefox/downloads/file/4188488/ublock_origin-1.53.0.xpi";
    sha256 = "5403474101f753b5d38c09135e40d82a115afcd01310d78133a4af363462194b";
    meta = with lib; {
      homepage = "https://github.com/gorhill/uBlock#ublock-origin";
      description = "Finally, an efficient wide-spectrum content blocker. Easy on CPU and memory.";
      license = licenses.gpl3;
      mozPermissions = [
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
        "https://*.letsblock.it/*"
        "https://github.com/uBlockOrigin/*"
        "https://ublockorigin.github.io/*"
        "https://*.reddit.com/r/uBlockOrigin/*"
      ];
      platforms = platforms.all;
    };
  };
  "violentmonkey" = buildFirefoxXpiAddon {
    pname = "violentmonkey";
    version = "2.16.0";
    addonId = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4185752/violentmonkey-2.16.0.xpi";
    sha256 = "cd1529f42c4ee591e86d55ea382c8be523236b866ad2c06088152450f682da9c";
    meta = with lib; {
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
}

{
  buildMozillaXpiAddon,
  fetchurl,
  lib,
  stdenv,
}:
{
  "augmented-steam" = buildMozillaXpiAddon {
    pname = "augmented-steam";
    version = "4.8.3";
    addonId = "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4966854/augmented_steam-4.8.3.xpi";
    sha256 = "230b9fbda8501992e7f660837c59ae601ef0a0f5ed1e21c171bfdeecfae0a9ce";
    meta = with lib; {
      homepage = "https://augmentedsteam.com/";
      description = "Augments your Steam Experience";
      license = licenses.gpl3;
      mozPermissions = [
        "storage"
        "contextMenus"
        "webRequest"
        "*://store.steampowered.com/*"
        "*://steamcommunity.com/*"
        "*://steamcommunity.com/id/*/friendsthatplay/*"
        "*://steamcommunity.com/profiles/*/friendsthatplay/*"
        "*://steamcommunity.com/id/*/gamecards/*"
        "*://steamcommunity.com/profiles/*/gamecards/*"
        "*://steamcommunity.com/id/*/badges"
        "*://steamcommunity.com/id/*/badges/"
        "*://steamcommunity.com/id/*/badges/?*"
        "*://steamcommunity.com/id/*/badges?*"
        "*://steamcommunity.com/profiles/*/badges"
        "*://steamcommunity.com/profiles/*/badges/"
        "*://steamcommunity.com/profiles/*/badges/?*"
        "*://steamcommunity.com/profiles/*/badges?*"
        "*://steamcommunity.com/sharedfiles/editguide/?*"
        "*://steamcommunity.com/sharedfiles/editguide?*"
        "*://steamcommunity.com/workshop/editguide/?*"
        "*://steamcommunity.com/workshop/editguide?*"
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
        "*://steamcommunity.com/groups/*"
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
        "*://steamcommunity.com/app/*/guides"
        "*://steamcommunity.com/app/*/guides/"
        "*://steamcommunity.com/app/*/guides/?*"
        "*://steamcommunity.com/app/*/guides?*"
        "*://steamcommunity.com/tradingcards/boostercreator"
        "*://steamcommunity.com/tradingcards/boostercreator/"
        "*://steamcommunity.com/tradingcards/boostercreator/?*"
        "*://steamcommunity.com/tradingcards/boostercreator?*"
        "*://steamcommunity.com/market/search"
        "*://steamcommunity.com/market/search/*"
        "*://steamcommunity.com/market/search?*"
        "*://steamcommunity.com/id/*/inventory"
        "*://steamcommunity.com/id/*/inventory/"
        "*://steamcommunity.com/id/*/inventory/?*"
        "*://steamcommunity.com/id/*/inventory?*"
        "*://steamcommunity.com/profiles/*/inventory"
        "*://steamcommunity.com/profiles/*/inventory/"
        "*://steamcommunity.com/profiles/*/inventory/?*"
        "*://steamcommunity.com/profiles/*/inventory?*"
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
        "*://steamcommunity.com/id/*/myworkshopfiles/?*browsefilter=mysubscriptions*"
        "*://steamcommunity.com/id/*/myworkshopfiles?*browsefilter=mysubscriptions*"
        "*://steamcommunity.com/profiles/*/myworkshopfiles/?*browsefilter=mysubscriptions*"
        "*://steamcommunity.com/profiles/*/myworkshopfiles?*browsefilter=mysubscriptions*"
        "*://steamcommunity.com/market"
        "*://steamcommunity.com/market/"
        "*://steamcommunity.com/market/?*"
        "*://steamcommunity.com/market?*"
        "*://steamcommunity.com/app/*"
        "*://steamcommunity.com/id/*"
        "*://steamcommunity.com/profiles/*"
        "*://steamcommunity.com/market/listings/*"
        "*://steamcommunity.com/id/*/edit/*"
        "*://steamcommunity.com/profiles/*/edit/*"
        "*://steamcommunity.com/id/*/stats/*"
        "*://steamcommunity.com/profiles/*/stats/*"
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
        "*://steamcommunity.com/tradeoffer/*"
        "*://steamcommunity.com/sharedfiles/browse"
        "*://steamcommunity.com/sharedfiles/browse/"
        "*://steamcommunity.com/sharedfiles/browse/?*"
        "*://steamcommunity.com/sharedfiles/browse?*"
        "*://steamcommunity.com/workshop/browse"
        "*://steamcommunity.com/workshop/browse/"
        "*://steamcommunity.com/workshop/browse/?*"
        "*://steamcommunity.com/workshop/browse?*"
        "*://steamcommunity.com/sharedfiles"
        "*://steamcommunity.com/sharedfiles/"
        "*://steamcommunity.com/sharedfiles/?*"
        "*://steamcommunity.com/sharedfiles?*"
        "*://steamcommunity.com/workshop"
        "*://steamcommunity.com/workshop/"
        "*://steamcommunity.com/workshop/?*"
        "*://steamcommunity.com/workshop?*"
        "*://steamcommunity.com/sharedfiles/filedetails"
        "*://steamcommunity.com/sharedfiles/filedetails/*"
        "*://steamcommunity.com/sharedfiles/filedetails?*"
        "*://steamcommunity.com/workshop/filedetails"
        "*://steamcommunity.com/workshop/filedetails/*"
        "*://steamcommunity.com/workshop/filedetails?*"
        "*://*.steampowered.com/agecheck/*"
        "*://*.steampowered.com/app/*"
        "*://store.steampowered.com/account/licenses"
        "*://store.steampowered.com/account/licenses/"
        "*://store.steampowered.com/account/licenses/?*"
        "*://store.steampowered.com/account/licenses?*"
        "*://*.steampowered.com/*"
        "*://*.steampowered.com/bundle/*"
        "*://*.steampowered.com/cart"
        "*://*.steampowered.com/cart/*"
        "*://*.steampowered.com/cart?*"
        "*://*.steampowered.com/points"
        "*://*.steampowered.com/points/*"
        "*://*.steampowered.com/points?*"
        "*://*.steampowered.com/steamaccount/addfunds"
        "*://*.steampowered.com/steamaccount/addfunds/"
        "*://*.steampowered.com/steamaccount/addfunds/?*"
        "*://*.steampowered.com/steamaccount/addfunds?*"
        "*://*.steampowered.com/digitalgiftcards/selectgiftcard"
        "*://*.steampowered.com/digitalgiftcards/selectgiftcard/"
        "*://*.steampowered.com/digitalgiftcards/selectgiftcard/?*"
        "*://*.steampowered.com/digitalgiftcards/selectgiftcard?*"
        "*://*.steampowered.com/account/registerkey"
        "*://*.steampowered.com/account/registerkey/"
        "*://*.steampowered.com/account/registerkey/?*"
        "*://*.steampowered.com/account/registerkey?*"
        "*://store.steampowered.com/"
        "*://store.steampowered.com/?*"
        "*://*.steampowered.com/wishlist"
        "*://*.steampowered.com/wishlist/"
        "*://*.steampowered.com/wishlist/?*"
        "*://*.steampowered.com/wishlist?*"
        "*://*.steampowered.com/wishlist/id/*"
        "*://*.steampowered.com/wishlist/profiles/*"
        "*://*.steampowered.com//wishlist"
        "*://*.steampowered.com//wishlist/"
        "*://*.steampowered.com//wishlist/?*"
        "*://*.steampowered.com//wishlist?*"
        "*://*.steampowered.com//wishlist/id/*"
        "*://*.steampowered.com//wishlist/profiles/*"
        "*://*.steampowered.com/search"
        "*://*.steampowered.com/search/*"
        "*://*.steampowered.com/search?*"
        "*://*.steampowered.com/account"
        "*://*.steampowered.com/account/"
        "*://*.steampowered.com/account/?*"
        "*://*.steampowered.com/account?*"
        "*://*.steampowered.com/sub/*"
      ];
      platforms = platforms.all;
    };
  };
  "auto-tab-discard" = buildMozillaXpiAddon {
    pname = "auto-tab-discard";
    version = "0.7.3";
    addonId = "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4978053/auto_tab_discard-0.7.3.xpi";
    sha256 = "66a98738e69df9ad7c7aeb12a495c5880d1f56fb93610f51cd3207a9b73ee702";
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
        "scripting"
        "<all_urls>"
      ];
      platforms = platforms.all;
    };
  };
  "base64-decoder" = buildMozillaXpiAddon {
    pname = "base64-decoder";
    version = "1.1resigned1";
    addonId = "{b20e4f00-ab03-4a88-90e7-4f6b6232c5a9}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4273906/base64_decoder-1.1resigned1.xpi";
    sha256 = "0456e008a8c7e1acf03f48b7be05d75c92a00a4ebdc201e06fd9b85b02e6298d";
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
  "betterviewer" = buildMozillaXpiAddon {
    pname = "betterviewer";
    version = "2.0.2";
    addonId = "ademking@betterviewer";
    url = "https://addons.mozilla.org/firefox/downloads/file/4548184/betterviewer-2.0.2.xpi";
    sha256 = "692e983dbbdeba2655f7a0cc446fea56ad3aafa831d626b58b414df87ceb1b97";
    meta = with lib; {
      homepage = "https://github.com/Ademking/BetterViewer";
      description = "BetterViewer was designed as a replacement for the image viewing mode built into Firefox and Chrome-based web browsers. With BetterViewer you can use various keyboard shortcuts to quickly pan, zoom images, edit and a lot more!";
      license = licenses.mit;
      mozPermissions = [
        "storage"
        "contextMenus"
        "<all_urls>"
      ];
      platforms = platforms.all;
    };
  };
  "canvasblocker" = buildMozillaXpiAddon {
    pname = "canvasblocker";
    version = "1.12";
    addonId = "CanvasBlocker@kkapsner.de";
    url = "https://addons.mozilla.org/firefox/downloads/file/4691016/canvasblocker-1.12.xpi";
    sha256 = "0698d92c4bd2d190b2f4025613bf4bd3dba40910d58ab4cf1b32f36637a244c9";
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
  "csgofloat" = buildMozillaXpiAddon {
    pname = "csgofloat";
    version = "5.17.0";
    addonId = "{194d0dc6-7ada-41c6-88b8-95d7636fe43c}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4957680/csgofloat-5.17.0.xpi";
    sha256 = "70c540b8b1df125596ef615fe37028542de4d92b3816ad81eb6ad5ce3d11798d";
    meta = with lib; {
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
  "dont-fuck-with-paste" = buildMozillaXpiAddon {
    pname = "dont-fuck-with-paste";
    version = "2.7";
    addonId = "DontFuckWithPaste@raim.ist";
    url = "https://addons.mozilla.org/firefox/downloads/file/3630212/don_t_fuck_with_paste-2.7.xpi";
    sha256 = "ef17dcef7e2034a25982a106e54d19e24c9f226434a396a808195ef0de021a40";
    meta = with lib; {
      homepage = "https://github.com/aaronraimist/DontFuckWithPaste";
      description = "This add-on stops websites from blocking copy and paste for password fields and other input fields.";
      license = licenses.mit;
      mozPermissions = [
        "storage"
        "tabs"
        "<all_urls>"
      ];
      platforms = platforms.all;
    };
  };
  "downthemall" = buildMozillaXpiAddon {
    pname = "downthemall";
    version = "4.15.1";
    addonId = "{DDC359D1-844A-42a7-9AA1-88A850A938A8}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4825019/downthemall-4.15.1.xpi";
    sha256 = "a6f53822b708b4cb595195f25818fb0eeb690e1244ca2d7fc0d0b645c4dc5de9";
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
  "enhanced-github" = buildMozillaXpiAddon {
    pname = "enhanced-github";
    version = "6.1.0";
    addonId = "{72bd91c9-3dc5-40a8-9b10-dec633c0873f}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4297236/enhanced_github-6.1.0.xpi";
    sha256 = "8ebf2ff7602e1747f3cc329e7c99acf7348d019ec456e5639d9d90af0b7afec3";
    meta = with lib; {
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
  "ff2mpv" = buildMozillaXpiAddon {
    pname = "ff2mpv";
    version = "6.0.0";
    addonId = "ff2mpv@yossarian.net";
    url = "https://addons.mozilla.org/firefox/downloads/file/4394631/ff2mpv-6.0.0.xpi";
    sha256 = "f5edb75698ebd73d7a6d4034a37636022019adde712379b7a43e741b2a179b9d";
    meta = with lib; {
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
  "gesturefy" = buildMozillaXpiAddon {
    pname = "gesturefy";
    version = "3.2.18";
    addonId = "{506e023c-7f2b-40a3-8066-bc5deb40aebe}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4712754/gesturefy-3.2.18.xpi";
    sha256 = "fbe25c2272ca45efd328eb1c8c7a1887fa4c4003dc953149d3246704c93ec838";
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
  "gitako" = buildMozillaXpiAddon {
    pname = "gitako";
    version = "3.15.4";
    addonId = "{983bd86b-9d6f-4394-92b8-63d844c4ce4c}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4668841/gitako_github_file_tree-3.15.4.xpi";
    sha256 = "851734bd764796dd0fdd4573b7e148a1e77f74e3eef5fd194ddd0dec5f4ef6d8";
    meta = with lib; {
      homepage = "https://github.com/EnixCoda/Gitako";
      description = "Gitako is a file tree extension for GitHub, available on Firefox, Chrome, and Edge.\n\nVideo intro: https://youtu.be/r4Ein-s2pN0\nHomepage: https://github.com/EnixCoda/Gitako";
      license = licenses.mit;
      mozPermissions = [
        "scripting"
        "storage"
        "contextMenus"
        "activeTab"
        "https://github.com/*"
      ];
      platforms = platforms.all;
    };
  };
  "github-code-folding" = buildMozillaXpiAddon {
    pname = "github-code-folding";
    version = "0.1.2resigned1";
    addonId = "{b588f8ac-dbdf-4397-bcd7-3d29be2f17d7}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4271738/github_code_folding-0.1.2resigned1.xpi";
    sha256 = "50d2fa82c8411e220cdc856f24042143f212b9d892018835d02271781f4eec3d";
    meta = with lib; {
      homepage = "https://github.com/noam3127/github-code-folding";
      description = "Enable code folding when viewing files in GitHub.";
      license = licenses.mpl20;
      mozPermissions = [
        "tabs"
        "*://github.com/*"
      ];
      platforms = platforms.all;
    };
  };
  "github-isometric-contributions" = buildMozillaXpiAddon {
    pname = "github-isometric-contributions";
    version = "1.2.6";
    addonId = "isometric-contributions@jasonlong.me";
    url = "https://addons.mozilla.org/firefox/downloads/file/4759677/github_isometric_contributions-1.2.6.xpi";
    sha256 = "8f4bdf96d914df81b22be95e96426c48e2efeb5601b4393065216e45b11d8f4e";
    meta = with lib; {
      description = "Renders an isometric pixel view of GitHub contribution graphs.";
      license = licenses.mit;
      mozPermissions = [
        "storage"
        "https://github.com/"
        "https://github.com/*"
      ];
      platforms = platforms.all;
    };
  };
  "github-repo-size" = buildMozillaXpiAddon {
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
  "harper" = buildMozillaXpiAddon {
    pname = "harper";
    version = "2.8.0";
    addonId = "harper@writewithharper.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/4957307/private_grammar_checker_harper-2.8.0.xpi";
    sha256 = "89b924ea7a260eb98f2ab69aa50ff77ac3750b3c1f8aaca7b674b829ff1a71ea";
    meta = with lib; {
      homepage = "https://writewithharper.com";
      description = "A private grammar checker for 21st Century English";
      mozPermissions = [
        "storage"
        "tabs"
        "https://docs.google.com/document/*"
        "<all_urls>"
      ];
      platforms = platforms.all;
    };
  };
  "imagus" = buildMozillaXpiAddon {
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
  "indie-wiki-buddy" = buildMozillaXpiAddon {
    pname = "indie-wiki-buddy";
    version = "4.0.0";
    addonId = "{cb31ec5d-c49a-4e5a-b240-16c767444f62}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4982796/indie_wiki_buddy-4.0.0.xpi";
    sha256 = "2769ffe55ff3462eef9029f00d90bb2df7d3f2fa6521b90de47aa81152e25df8";
    meta = with lib; {
      homepage = "https://getindie.wiki/";
      description = "Helping you discover quality, independent wikis!\n\nWhen visiting a Fandom wiki, Indie Wiki Buddy redirects or alerts you of independent alternatives. It also filters search engine results. BreezeWiki is also supported, to reduce clutter on Fandom.";
      license = licenses.mit;
      mozPermissions = [
        "alarms"
        "storage"
        "webRequest"
        "notifications"
        "scripting"
        "https://*.fandom.com/*"
        "https://*.fextralife.com/*"
        "https://*.neoseeker.com/*"
        "https://breezewiki.com/*"
        "https://www.google.com/search*"
      ];
      platforms = platforms.all;
    };
  };
  "lovely-forks" = buildMozillaXpiAddon {
    pname = "lovely-forks";
    version = "3.7.4";
    addonId = "github-forks-addon@musicallyut.in";
    url = "https://addons.mozilla.org/firefox/downloads/file/4863232/lovely_forks-3.7.4.xpi";
    sha256 = "16e8139fc8429c8ce30660f94ed573d9c0fd94763dc4953f6144468602d29fca";
    meta = with lib; {
      homepage = "https://github.com/musically-ut/lovely-forks";
      description = "Show notable forks of Github projects.";
      license = licenses.mpl20;
      mozPermissions = [
        "storage"
        "*://github.com/*"
      ];
      platforms = platforms.all;
    };
  };
  "material-icons-for-github" = buildMozillaXpiAddon {
    pname = "material-icons-for-github";
    version = "1.16.4";
    addonId = "{eac6e624-97fa-4f28-9d24-c06c9b8aa713}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4978028/material_icons_for_github-1.16.4.xpi";
    sha256 = "88246df1f6b54f8376ece3c9ed95724b9fb33550f44ef15f359879e4799b7740";
    meta = with lib; {
      homepage = "https://github.com/material-extensions/material-icons-browser-extension";
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
        "*://codeberg.org/*"
        "*://tangled.org/*"
      ];
      platforms = platforms.all;
    };
  };
  "nexusmods-advance" = buildMozillaXpiAddon {
    pname = "nexusmods-advance";
    version = "0.26.86";
    addonId = "NexusModsAdvance@Caiota";
    url = "https://addons.mozilla.org/firefox/downloads/file/4934055/nexusmods_advance-0.26.86.xpi";
    sha256 = "b81e189af76a2b6c2869dd3fc938a63bb97cfc8c2ccc57fd82cafd276e4cf1fa";
    meta = with lib; {
      description = "Enhance your browsing experience on the NexusMods site and manage your mods directly through the browser!";
      license = licenses.mpl20;
      mozPermissions = [
        "activeTab"
        "tabs"
        "storage"
        "notifications"
        "webNavigation"
        "declarativeNetRequest"
        "declarativeNetRequestWithHostAccess"
        "https://*.nexusmods.com/*"
      ];
      platforms = platforms.all;
    };
  };
  "npm-hub" = buildMozillaXpiAddon {
    pname = "npm-hub";
    version = "2024.7.26";
    addonId = "npm-hub@sikelianos.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/4326828/npm_hub-2024.7.26.xpi";
    sha256 = "cf15185521b7580f80fbcf179ad368c006a2d678b85d08bb688f0db937735a39";
    meta = with lib; {
      homepage = "https://github.com/npmhub/npmhub";
      description = "Explore npm dependencies on GitHub repos";
      license = licenses.mit;
      mozPermissions = [
        "contextMenus"
        "storage"
        "activeTab"
        "https://github.com/*"
      ];
      platforms = platforms.all;
    };
  };
  "octolinker" = buildMozillaXpiAddon {
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
  "privacy-badger" = buildMozillaXpiAddon {
    pname = "privacy-badger";
    version = "2026.8.7";
    addonId = "jid1-MnnxcxisBPnSXQ@jetpack";
    url = "https://addons.mozilla.org/firefox/downloads/file/4944345/privacy_badger17-2026.8.7.xpi";
    sha256 = "27885c1a80a00f8a293817feefb390addeb40ac4fa24a4ef3b56c9333c93d053";
    meta = with lib; {
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
  "privacy-pass" = buildMozillaXpiAddon {
    pname = "privacy-pass";
    version = "4.0.2";
    addonId = "{48748554-4c01-49e8-94af-79662bf34d50}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4258867/privacy_pass-4.0.2.xpi";
    sha256 = "48e832600bdd47639d17ed2a99ea74d2eb1e12728e8b743a7057420b7f72102f";
    meta = with lib; {
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
  "pronoundb" = buildMozillaXpiAddon {
    pname = "pronoundb";
    version = "0.14.6";
    addonId = "firefox-addon@pronoundb.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/4376744/pronoundb-0.14.6.xpi";
    sha256 = "5fb1f32c2584e90a1fc8ae5c5471584fa0d4ec0e6af80c6a2d1be8fe64c4ad00";
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
        "https://*.x.com/*"
      ];
      platforms = platforms.all;
    };
  };
  "reddit-enhancement-suite" = buildMozillaXpiAddon {
    pname = "reddit-enhancement-suite";
    version = "5.24.10";
    addonId = "jid1-xUfzOsOFlzSOXg@jetpack";
    url = "https://addons.mozilla.org/firefox/downloads/file/4899821/reddit_enhancement_suite-5.24.10.xpi";
    sha256 = "4573cfdb10193467e99e1dd5a792f23ae69764540c2e06d0444f12a81cdc4f0a";
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
        "scripting"
        "unlimitedStorage"
      ];
      platforms = platforms.all;
    };
  };
  "refined-github" = buildMozillaXpiAddon {
    pname = "refined-github";
    version = "26.8.8";
    addonId = "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4945591/refined_github-26.8.8.xpi";
    sha256 = "cfa6508a75193560a2623220a4e59c6bad7099fed16d65e04c28f0372775e4c6";
    meta = with lib; {
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
  "search_by_image" = buildMozillaXpiAddon {
    pname = "search_by_image";
    version = "8.5.3";
    addonId = "{2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4840197/search_by_image-8.5.3.xpi";
    sha256 = "ba604478b50f5c46e13011ea7e3e2906abc7b1b72cb7e87b02c4fbdefa64ae37";
    meta = with lib; {
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
  "sidebery" = buildMozillaXpiAddon {
    pname = "sidebery";
    version = "5.6.1";
    addonId = "{3c078156-979c-498b-8990-85f7987dd929}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4903712/sidebery-5.6.1.xpi";
    sha256 = "e8a0a4b556ab7dd536897c1816af9d0918030223068ea6683a04376103a6caf2";
    meta = with lib; {
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
  "skip-redirect" = buildMozillaXpiAddon {
    pname = "skip-redirect";
    version = "3.0.2";
    addonId = "skipredirect@sblask";
    url = "https://addons.mozilla.org/firefox/downloads/file/4968151/skip_redirect-3.0.2.xpi";
    sha256 = "1ed9c4ca15fced2963dc001d95c4745eed9a1c5bb9d76d70a3140dbd5715b9d7";
    meta = with lib; {
      description = "Some web pages use intermediary pages before redirecting to a final page. This add-on tries to extract the final url from the intermediary url and goes there straight away if successful.";
      license = licenses.mit;
      mozPermissions = [
        "alarms"
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
  "sourcegraph" = buildMozillaXpiAddon {
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
  "sponsorblock" = buildMozillaXpiAddon {
    pname = "sponsorblock";
    version = "6.1.7";
    addonId = "sponsorBlocker@ajay.app";
    url = "https://addons.mozilla.org/firefox/downloads/file/4897574/sponsorblock-6.1.7.xpi";
    sha256 = "0d50e1632c6f15ee15a543e670e1c572974605a5c02622916e08e026803df83f";
    meta = with lib; {
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
  "steam-database" = buildMozillaXpiAddon {
    pname = "steam-database";
    version = "4.37";
    addonId = "firefox-extension@steamdb.info";
    url = "https://addons.mozilla.org/firefox/downloads/file/4967437/steam_database-4.37.xpi";
    sha256 = "d280d9a8be7fe8bcdffd60697daf5903cb4da67912569510fb7a8bd68562d6cc";
    meta = with lib; {
      homepage = "https://steamdb.info/";
      description = "Adds SteamDB links and new features on the Steam store and community. View lowest game prices and stats.";
      license = licenses.bsd2;
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
        "https://steamcommunity.com/games/*"
        "https://steamcommunity.com/sharedfiles/*"
        "https://steamcommunity.com/workshop/*"
        "https://steamcommunity.com/linkfilter/*"
        "https://steamcommunity.com/market/*"
        "https://steamcommunity.com/tradingcards/boostercreator*"
      ];
      platforms = platforms.all;
    };
  };
  "stylus" = buildMozillaXpiAddon {
    pname = "stylus";
    version = "2.4.11";
    addonId = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4970801/styl_us-2.4.11.xpi";
    sha256 = "a1fb8025132ad77f3f81dcdf6ac6a31798048a95ea65b975d12b335116df0224";
    meta = with lib; {
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
  "tabcenter-reborn" = buildMozillaXpiAddon {
    pname = "tabcenter-reborn";
    version = "3.0.2";
    addonId = "tabcenter-reborn@ariasuni";
    url = "https://addons.mozilla.org/firefox/downloads/file/4631653/tabcenter_reborn-3.0.2.xpi";
    sha256 = "47dc2967afd4bc1774807e52ebc1ccdef909864f873fbbc03e382d47054c24c5";
    meta = with lib; {
      homepage = "https://codeberg.org/ariasuni/tabcenter-reborn";
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
  "tree-style-tab" = buildMozillaXpiAddon {
    pname = "tree-style-tab";
    version = "4.4.3";
    addonId = "treestyletab@piro.sakura.ne.jp";
    url = "https://addons.mozilla.org/firefox/downloads/file/4985978/tree_style_tab-4.4.3.xpi";
    sha256 = "5d4d2a7ec7e3027d8e8e4e0b3d8a0355070267fbda8c927dfaeb0fd3b7cb09c8";
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
        "tabGroups"
        "tabs"
        "theme"
      ];
      platforms = platforms.all;
    };
  };
  "tridactyl" = buildMozillaXpiAddon {
    pname = "tridactyl";
    version = "1.25.0";
    addonId = "tridactyl.vim@cmcaine.co.uk";
    url = "https://addons.mozilla.org/firefox/downloads/file/4988638/tridactyl_vim-1.25.0.xpi";
    sha256 = "46f4dec5b81c08a688c704a1b2ea7b45f44b3a4a1c4295f991cabffb670f1816";
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
  "ublock-origin" = buildMozillaXpiAddon {
    pname = "ublock-origin";
    version = "1.74.0";
    addonId = "uBlock0@raymondhill.net";
    url = "https://addons.mozilla.org/firefox/downloads/file/4981431/ublock_origin-1.74.0.xpi";
    sha256 = "175756d74468c9ba45863f7fc333d3be670f82d5b066314e915814dd547d1652";
    meta = with lib; {
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
  "violentmonkey" = buildMozillaXpiAddon {
    pname = "violentmonkey";
    version = "2.48.0";
    addonId = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4963965/violentmonkey-2.48.0.xpi";
    sha256 = "e73e3103697cbeee3335020c31c7e3c587946929740cd78f9bff1b50bf62be34";
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

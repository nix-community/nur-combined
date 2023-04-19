{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
  {
    "10ten-ja-reader" = buildFirefoxXpiAddon {
      pname = "10ten-ja-reader";
      version = "1.13.6";
      addonId = "{59812185-ea92-4cca-8ab7-cfcacee81281}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4074768/10ten_ja_reader-1.13.6.xpi";
      sha256 = "335802205e0ad14155a9a34b689b499e5d717d4881202f7498b797beb14caec5";
      meta = with lib;
      {
        homepage = "https://github.com/birchill/10ten-ja-reader/";
        description = "Quickly translate Japanese by hovering over words. Formerly released as Rikaichamp.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "a11ycss" = buildFirefoxXpiAddon {
      pname = "a11ycss";
      version = "1.3.0";
      addonId = "a11y.css@ffoodd";
      url = "https://addons.mozilla.org/firefox/downloads/file/3997242/a11ycss-1.3.0.xpi";
      sha256 = "33ed6c73adcd6a3501b3b9320a4e3adcd7ea50820a0e16e97b57efe22fcb4132";
      meta = with lib;
      {
        homepage = "https://ffoodd.github.io/a11y.css/";
        description = "a11y.css provides warnings about possible risks and mistakes that exist in HTML code through a style sheet. This extension also provides several accessibility-related utilities.\n\nsee <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/4c643171ccddfcfa3712d45a2b7b615f54195eb4507868ab6ef3fbf6694dc4c2/https%3A//github.com/ffoodd/a11y.css/tree/webextension\" rel=\"nofollow\">https://github.com/ffoodd/a11y.css/tree/webextension</a> for  details";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "add-custom-search-engine" = buildFirefoxXpiAddon {
      pname = "add-custom-search-engine";
      version = "4.2";
      addonId = "{af37054b-3ace-46a2-ac59-709e4412bec6}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3812756/add_custom_search_engine-4.2.xpi";
      sha256 = "86aaf173514ec2da55556eb339a9d7c115c6e070c5433ebff8db31baa8e165d5";
      meta = with lib;
      {
        description = "Add a custom search engine to the list of available search engines in the search bar and URL bar.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "adnauseam" = buildFirefoxXpiAddon {
      pname = "adnauseam";
      version = "3.16.2.0";
      addonId = "adnauseam@rednoise.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4075872/adnauseam-3.16.2.0.xpi";
      sha256 = "9342eb0fa05890b094639b305856461ecf6622387dc5ab9b7cfc12ba97cbfb4e";
      meta = with lib;
      {
        homepage = "https://adnauseam.io";
        description = "Blocking ads and fighting back against advertising surveillance.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "adsum-notabs" = buildFirefoxXpiAddon {
      pname = "adsum-notabs";
      version = "1.1";
      addonId = "{c9f848fb-3fb6-4390-9fc1-e4dd4d1c5122}";
      url = "https://addons.mozilla.org/firefox/downloads/file/883289/adsum_notabs-1.1.xpi";
      sha256 = "48e846a60b217c13ee693ac8bfe23a8bdef2ec073f5f713cce0e08814f280354";
      meta = with lib;
      {
        homepage = "https://gitlab.com/adsum/firefox-notabs";
        description = "Disable tabs completely, by always opening a new window instead.";
        license = licenses.gpl3;
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
        platforms = platforms.all;
        };
      };
    "anchors-reveal" = buildFirefoxXpiAddon {
      pname = "anchors-reveal";
      version = "1.1";
      addonId = "jid1-XX0TcCGBa7GVGw@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/1690998/anchors_reveal-1.1.xpi";
      sha256 = "0412acabe742f7e78ff77aa95c4196150c240592a1bbbad75012b39a05352c36";
      meta = with lib;
      {
        homepage = "http://dascritch.net/post/2014/06/24/Sniffeur-d-ancre";
        description = "Reveal the anchors in a webpage";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "angular-devtools" = buildFirefoxXpiAddon {
      pname = "angular-devtools";
      version = "1.0.7";
      addonId = "{20a9bb38-ed7c-4faf-9aaf-7c5d241fd747}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4072031/angular_devtools-1.0.7.xpi";
      sha256 = "85359059376fd3ecbddce5cfd0ff6f811c72ad097944e6274fe2906990f4f6cc";
      meta = with lib;
      {
        homepage = "https://angular.io/devtools";
        description = "Angular DevTools extends Firefox DevTools adding Angular specific debugging and profiling capabilities.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "anonaddy" = buildFirefoxXpiAddon {
      pname = "anonaddy";
      version = "2.1.6";
      addonId = "browser-extension@anonaddy";
      url = "https://addons.mozilla.org/firefox/downloads/file/4052970/anonaddy-2.1.6.xpi";
      sha256 = "ea1ac148788c3f3dd1756371e2ff1ca01d1b0fdd50a0bbb3454dfbc70fa0e42e";
      meta = with lib;
      {
        homepage = "https://anonaddy.com";
        description = "Open-source Anonymous Email Forwarding. \n\nQuickly and easily view, search, manage and create new aliases in just a few clicks using the AnonAddy browser extension.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "augmented-steam" = buildFirefoxXpiAddon {
      pname = "augmented-steam";
      version = "2.4.1";
      addonId = "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4054613/augmented_steam-2.4.1.xpi";
      sha256 = "962412b40471bc0dfafe72cd29c7e80ef789c33dc322086bbc03d3a89a5d08db";
      meta = with lib;
      {
        homepage = "https://augmentedsteam.com/";
        description = "Augments your Steam Experience";
        license = licenses.gpl3;
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
        platforms = platforms.all;
        };
      };
    "better-tweetdeck" = buildFirefoxXpiAddon {
      pname = "better-tweetdeck";
      version = "4.10.1";
      addonId = "BetterTweetDeck@erambert.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/4067593/better_tweetdeck_17-4.10.1.xpi";
      sha256 = "d565bed529334e0a2efa95a2a768a372a3901c06a3661a0afb5f161a2e2c9f5f";
      meta = with lib;
      {
        homepage = "https://better.tw/";
        description = "Improve your experience on TweetDeck web with emojis, thumbnails, and a lot of customization options to make TweetDeck even better for you";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "betterttv" = buildFirefoxXpiAddon {
      pname = "betterttv";
      version = "7.5.3";
      addonId = "firefox@betterttv.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4078007/betterttv-7.5.3.xpi";
      sha256 = "1fd75b392c963bd952912e13a6e847563da70209f2e1297b9fd5cf418367b34a";
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
        platforms = platforms.all;
        };
      };
    "beyond-20" = buildFirefoxXpiAddon {
      pname = "beyond-20";
      version = "2.8.0";
      addonId = "beyond20@kakaroto.homelinux.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4029811/beyond_20-2.8.0.xpi";
      sha256 = "d7b1a3a5551f6150d93715fcb8f86ed25464909ae6dfc3c91a0a3bd8308dd2b4";
      meta = with lib;
      {
        homepage = "https://beyond20.here-for-more.info";
        description = "Integrates the D&amp;D Beyond Character Sheet into Roll20 and Foundry VTT.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "bitwarden" = buildFirefoxXpiAddon {
      pname = "bitwarden";
      version = "2023.3.1";
      addonId = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4093799/bitwarden_password_manager-2023.3.1.xpi";
      sha256 = "d4ea270874c013daf0aa8b46686766481464db0b3eaa271dc1a2e579751f36f7";
      meta = with lib;
      {
        homepage = "https://bitwarden.com";
        description = "A secure and free password manager for all of your devices.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "blocktube" = buildFirefoxXpiAddon {
      pname = "blocktube";
      version = "0.3.36";
      addonId = "{58204f8b-01c2-4bbc-98f8-9a90458fd9ef}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4077014/blocktube-0.3.36.xpi";
      sha256 = "839017a75d1c7e63116b6f801b833a21b7ff544f9fe9542294811b20b6ff3c0d";
      meta = with lib;
      {
        homepage = "https://github.com/amitbl/blocktube";
        description = "YouTube™ Video blocker.\nBlock and hide annoying videos from YouTube™.\nFast and easy.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "browserpass" = buildFirefoxXpiAddon {
      pname = "browserpass";
      version = "3.7.2";
      addonId = "browserpass@maximbaz.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3711209/browserpass_ce-3.7.2.xpi";
      sha256 = "b1781405b46f3274697885b53139264dca2ab56ffc4435c093102ad5ebc59297";
      meta = with lib;
      {
        homepage = "https://github.com/browserpass/browserpass-extension";
        description = "Browserpass is a browser extension for Firefox and Chrome to retrieve login details from zx2c4's pass (<a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/fcd8dcb23434c51a78197a1c25d3e2277aa1bc764c827b4b4726ec5a5657eb64/http%3A//passwordstore.org\" rel=\"nofollow\">passwordstore.org</a>) straight from your browser. Tags: passwordstore, password store, password manager, passwordmanager, gpg";
        license = licenses.isc;
        platforms = platforms.all;
        };
      };
    "bukubrow" = buildFirefoxXpiAddon {
      pname = "bukubrow";
      version = "5.0.3.0";
      addonId = "bukubrow@samhh.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3769984/bukubrow-5.0.3.0.xpi";
      sha256 = "4c9424d0f13df8f1f6ac605302c42bb30f3c138eb76c8d4ced5d45a637942913";
      meta = with lib;
      {
        homepage = "https://github.com/samhh/bukubrow";
        description = "Synchronise your browser bookmarks with Buku";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "buster-captcha-solver" = buildFirefoxXpiAddon {
      pname = "buster-captcha-solver";
      version = "2.0.1";
      addonId = "{e58d3966-3d76-4cd9-8552-1582fbc800c1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4044701/buster_captcha_solver-2.0.1.xpi";
      sha256 = "9910d2d0add8ba10d7053fd90818e17e6d844050c125f07cb4e4f5759810efcf";
      meta = with lib;
      {
        homepage = "https://github.com/dessant/buster#readme";
        description = "Save time by asking Buster to solve captchas for you.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "c-c-search-extension" = buildFirefoxXpiAddon {
      pname = "c-c-search-extension";
      version = "0.3.0";
      addonId = "{e737d9cb-82de-4f23-83c6-76f70a82229c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3957223/c_c_search_extension-0.3.0.xpi";
      sha256 = "7cc6d2b11d4b5d1689feed6c4f9a45f467e2764f5a9fc12339172d0b348c7b1f";
      meta = with lib;
      {
        homepage = "https://cpp.extension.sh";
        description = "The ultimate search extension for C/C++";
        platforms = platforms.all;
        };
      };
    "canvasblocker" = buildFirefoxXpiAddon {
      pname = "canvasblocker";
      version = "1.8";
      addonId = "CanvasBlocker@kkapsner.de";
      url = "https://addons.mozilla.org/firefox/downloads/file/3910598/canvasblocker-1.8.xpi";
      sha256 = "817a6181be877668eca1d0fef9ecf789c898e6d7d93dca7e29479d40f986c844";
      meta = with lib;
      {
        homepage = "https://github.com/kkapsner/CanvasBlocker/";
        description = "Alters some JS APIs to prevent fingerprinting.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "censor-tracker" = buildFirefoxXpiAddon {
      pname = "censor-tracker";
      version = "11.0.0";
      addonId = "{5d0d1f87-5991-42d3-98c3-54878ead1ed1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4043935/censor_tracker-11.0.0.xpi";
      sha256 = "2f240b6e227a1a226a49c5aaa5931423a5954f76a400e2f46a6a6ad8f5a7d8bf";
      meta = with lib;
      {
        homepage = "https://censortracker.org/en.html";
        description = "Censor Tracker is an extension that allows you to bypass Internet censorship, warns you about sites that transmit your data with government agencies, and detect new acts of censorship.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "clearurls" = buildFirefoxXpiAddon {
      pname = "clearurls";
      version = "1.26.1";
      addonId = "{74145f27-f039-47ce-a470-a662b129930a}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4064884/clearurls-1.26.1.xpi";
      sha256 = "e20168d63cb1b8ba3ad0de4cdb42c540d99fe00aa9679b59f49bccc36f106291";
      meta = with lib;
      {
        homepage = "https://clearurls.xyz/";
        description = "Removes tracking elements from URLs";
        license = licenses.lgpl3;
        platforms = platforms.all;
        };
      };
    "close-other-windows" = buildFirefoxXpiAddon {
      pname = "close-other-windows";
      version = "0.1";
      addonId = "{fab4ea0f-e0d3-4bb4-9515-aea14d709f69}";
      url = "https://addons.mozilla.org/firefox/downloads/file/589832/close_other_windows-0.1.xpi";
      sha256 = "6c189fb4d396f835bf8f0f09c9f1e9ae5dc7cde471b776d8c7d12592a373d3d3";
      meta = with lib;
      {
        description = "Adds a button to close all tabs in other windows which are not pinned";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "conex" = buildFirefoxXpiAddon {
      pname = "conex";
      version = "0.9.7";
      addonId = "{ec9d70ea-0229-49c0-bbf7-0df9bbccde35}";
      url = "https://addons.mozilla.org/firefox/downloads/file/1667278/conex-0.9.7.xpi";
      sha256 = "f6aa6c18b278b5ceb977e06409afe6572f3fe8fe94494512e91087321f6ca7e6";
      meta = with lib;
      {
        homepage = "https://github.com/kesselborn/conex#conex";
        description = "TabGroups married with Tab Containers and bookmark  &amp; history search";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "consent-o-matic" = buildFirefoxXpiAddon {
      pname = "consent-o-matic";
      version = "1.0.12";
      addonId = "gdpr@cavi.au.dk";
      url = "https://addons.mozilla.org/firefox/downloads/file/4074847/consent_o_matic-1.0.12.xpi";
      sha256 = "013ea48757b8a4d84a2a0d944bc49b5612d62bae1d337f9569f425f2b8310e0f";
      meta = with lib;
      {
        homepage = "https://consentomatic.au.dk/";
        description = "Automatic handling of GDPR consent forms";
        license = licenses.mit;
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
        platforms = platforms.all;
        };
      };
    "container-tabs-sidebar" = buildFirefoxXpiAddon {
      pname = "container-tabs-sidebar";
      version = "1.0.0";
      addonId = "containertabssidebar@maciekmm.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/3958291/container_tabs_sidebar-1.0.0.xpi";
      sha256 = "8cd29eb55b0a8ecfb92815047414f2ee136b51bba916f07c761653d3467e8181";
      meta = with lib;
      {
        homepage = "https://github.com/maciekmm/container-tabs-sidebar";
        description = "Show tabs in a sidebar grouped by privacy containers.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "control-panel-for-twitter" = buildFirefoxXpiAddon {
      pname = "control-panel-for-twitter";
      version = "3.4.1";
      addonId = "{5cce4ab5-3d47-41b9-af5e-8203eea05245}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4095007/control_panel_for_twitter-3.4.1.xpi";
      sha256 = "81963876b07fead57e001669932c81768f81e6faa842dea71f4312ca446e680d";
      meta = with lib;
      {
        homepage = "https://github.com/insin/control-panel-for-twitter";
        description = "Gives you more control over Twitter and adds missing features and UI improvements";
        license = licenses.mit;
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
        platforms = platforms.all;
        };
      };
    "cookies-txt" = buildFirefoxXpiAddon {
      pname = "cookies-txt";
      version = "0.4";
      addonId = "{12cf650b-1822-40aa-bff0-996df6948878}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4037589/cookies_txt-0.4.xpi";
      sha256 = "6b07b6e478cae96c6eb5e669d90a233439458a00f866d88cb7c8275b054153e2";
      meta = with lib;
      {
        description = "Exports all cookies to a Netscape HTTP Cookie File, as used by curl, wget, and youtube-dl, among others.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "copy-selection-as-markdown" = buildFirefoxXpiAddon {
      pname = "copy-selection-as-markdown";
      version = "0.21.0";
      addonId = "{db9a72da-7bc5-4805-bcea-da3cb1a15316}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3802383/copy_selection_as_markdown-0.21.0.xpi";
      sha256 = "ead9406f8e9afbe409a55c5b5b3d9d4eb9f0b8fb0f3f42c985b86bcfe2173ed4";
      meta = with lib;
      {
        homepage = "https://github.com/0x6b/copy-selection-as-markdown";
        description = "Copy title, URL, and selection as Markdown.";
        license = licenses.mit;
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
        description = "Makes the scrollbars on TweetDeck and other sites dark in Firefox. This should be done by the site itself, not by an addon :(\n\nImage based on Scroll by Juan Pablo Bravo, CL <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/f9c83bffbd0bf3bfa6ea46deecfa4fa4e9d5a69f49f323c020877e0bf283efac/https%3A//thenounproject.com/term/scroll/18607/\" rel=\"nofollow\">https://thenounproject.com/term/scroll/18607/</a>";
        license = licenses.lgpl3;
        platforms = platforms.all;
        };
      };
    "darkreader" = buildFirefoxXpiAddon {
      pname = "darkreader";
      version = "4.9.63";
      addonId = "addon@darkreader.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4095037/darkreader-4.9.63.xpi";
      sha256 = "16ba6337fcff7ad85e08ad51b384ba26ff751b2b2ded12309f75e8337ace925a";
      meta = with lib;
      {
        homepage = "https://darkreader.org/";
        description = "Dark mode for every website. Take care of your eyes, use dark theme for night and daily browsing.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "decentraleyes" = buildFirefoxXpiAddon {
      pname = "decentraleyes";
      version = "2.0.17";
      addonId = "jid1-BoFifL9Vbdl2zQ@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3902154/decentraleyes-2.0.17.xpi";
      sha256 = "e7f16ddc458eb2bc5bea75832305895553fca53c2565b6f1d07d5d9620edaff1";
      meta = with lib;
      {
        homepage = "https://decentraleyes.org";
        description = "Protects you against tracking through \"free\", centralized, content delivery. It prevents a lot of requests from reaching networks like Google Hosted Libraries, and serves local files to keep sites from breaking. Complements regular content blockers.";
        license = licenses.mpl20;
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
        platforms = platforms.all;
        };
      };
    "disable-javascript" = buildFirefoxXpiAddon {
      pname = "disable-javascript";
      version = "2.3.1";
      addonId = "{41f9e51d-35e4-4b29-af66-422ff81c8b41}";
      url = "https://addons.mozilla.org/firefox/downloads/file/1090623/disable_javascript-2.3.1.xpi";
      sha256 = "d3578dca38de54ae3f8f1e381b371f63176bedcd753e53cd7f5af0209493dc7c";
      meta = with lib;
      {
        homepage = "https://github.com/dpacassi/disable-javascript";
        description = "Adds the ability to disable JavaScript for specific sites or specific tabs.\nYou can customize the default JS state (on or off), the disable behavior (by domain or by tab) and much more.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "disconnect" = buildFirefoxXpiAddon {
      pname = "disconnect";
      version = "20.3.1.1";
      addonId = "2.0@disconnect.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/3655554/disconnect-20.3.1.1.xpi";
      sha256 = "f1e98b4b1189975753c5c806234de70cbd7f09ae3925ab65ef834da5915ac64d";
      meta = with lib;
      {
        homepage = "https://disconnect.me/";
        description = "Make the web faster, more private, and more secure.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "display-_anchors" = buildFirefoxXpiAddon {
      pname = "display-_anchors";
      version = "1.3";
      addonId = "display-anchors@robwu.nl";
      url = "https://addons.mozilla.org/firefox/downloads/file/584272/display__anchors-1.3.xpi";
      sha256 = "3cd2143e39d195225b8cf3432d0cf87b366ac6f31f3a7242c35cd0ce980ee6b8";
      meta = with lib;
      {
        homepage = "https://github.com/Rob--W/display-anchors";
        description = "Displays anchors for all content in the current web page without breaking the layout.";
        license = licenses.mit;
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
        platforms = platforms.all;
        };
      };
    "dracula-dark-colorscheme" = buildFirefoxXpiAddon {
      pname = "dracula-dark-colorscheme";
      version = "1.9.4";
      addonId = "{b743f56d-1cc1-4048-8ba6-f9c2ab7aa54d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4091018/dracula_dark_colorscheme-1.9.4.xpi";
      sha256 = "c4c3b5dbf758f140dc3f60a7819b80af04b3b72a84e742c6731b33532c39c083";
      meta = with lib;
      {
        homepage = "https://draculatheme.com/firefox";
        description = "Official Dracula theme for firefox.";
        license = licenses.cc-by-nc-sa-30;
        platforms = platforms.all;
        };
      };
    "duckduckgo-privacy-essentials" = buildFirefoxXpiAddon {
      pname = "duckduckgo-privacy-essentials";
      version = "2023.3.28.1";
      addonId = "jid1-ZAdIEUB7XOzOJw@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4090115/duckduckgo_for_firefox-2023.3.28.1.xpi";
      sha256 = "ea43172afcf4e4c7c9b78a8e35e70c874fcad64f94f51bd58db18e74309c53b8";
      meta = with lib;
      {
        homepage = "https://duckduckgo.com/app";
        description = "Simple and seamless privacy protection for your browser: tracker blocking, cookie protection, DuckDuckGo private search, email protection, HTTPS upgrading, and much more.";
        license = licenses.asl20;
        platforms = platforms.all;
        };
      };
    "ecosia" = buildFirefoxXpiAddon {
      pname = "ecosia";
      version = "4.1.0";
      addonId = "{d04b0b40-3dab-4f0b-97a6-04ec3eddbfb0}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3960424/ecosia_the_green_search-4.1.0.xpi";
      sha256 = "cf5f9987e13a716ddd6c9d0f1ec2435997cdeebaa5083cb3dc437dbba07bc66c";
      meta = with lib;
      {
        homepage = "http://www.ecosia.org";
        description = "This extension adds <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/c7a1fe7e1838aaf8fcdb3e88c6700a42c275a31c5fdea179157c9751846df4bf/http%3A//Ecosia.org\" rel=\"nofollow\">Ecosia.org</a> as the default search engine to your browser — it’s completely free!";
        license = licenses.mpl20;
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
        platforms = platforms.all;
        };
      };
    "elasticvue" = buildFirefoxXpiAddon {
      pname = "elasticvue";
      version = "0.44.0";
      addonId = "{2879bc11-6e9e-4d73-82c9-1ed8b78df296}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4036001/elasticvue-0.44.0.xpi";
      sha256 = "2805fb9b89669f30a644aa555fd6090300792668df38cd33540e65ccc5249c6d";
      meta = with lib;
      {
        homepage = "https://elasticvue.com/";
        description = "Elasticvue is a free and simple elasticsearch gui for your browser";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "enhanced-github" = buildFirefoxXpiAddon {
      pname = "enhanced-github";
      version = "5.0.11";
      addonId = "{72bd91c9-3dc5-40a8-9b10-dec633c0873f}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3764141/enhanced_github-5.0.11.xpi";
      sha256 = "a75d7844b261289d099cf99b1c8915210919b371069f066af139d5a7892967b6";
      meta = with lib;
      {
        homepage = "https://github.com/softvar/enhanced-github";
        description = "Display repo size, size of each file, download link and option to copy file contents";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "enhancer-for-youtube" = buildFirefoxXpiAddon {
      pname = "enhancer-for-youtube";
      version = "2.0.117.10";
      addonId = "enhancerforyoutube@maximerf.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4040535/enhancer_for_youtube-2.0.117.10.xpi";
      sha256 = "a15758d3c42416575c188cf756dd1f5ce7e0194ebf1055979eff2f21a1bed736";
      meta = with lib;
      {
        homepage = "https://www.mrfdev.com/enhancer-for-youtube";
        description = "Take control of YouTube and boost your user experience!";
        license = {
          shortName = "enhancer-for-youtube";
          fullName = "Custom License for Enhancer for YouTube™";
          url = "https://addons.mozilla.org/en-US/firefox/addon/enhancer-for-youtube/license/";
          free = false;
          };
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
        platforms = platforms.all;
        };
      };
    "facebook-container" = buildFirefoxXpiAddon {
      pname = "facebook-container";
      version = "2.3.9";
      addonId = "@contain-facebook";
      url = "https://addons.mozilla.org/firefox/downloads/file/4024031/facebook_container-2.3.9.xpi";
      sha256 = "f4cdd84471e2f6d3195a3f90aa511b0aba7f138f888bd239d8cb71684611ef78";
      meta = with lib;
      {
        homepage = "https://github.com/mozilla/contain-facebook";
        description = "Prevent Facebook from tracking you around the web. The Facebook Container extension for Firefox helps you take control and isolate your web activity from Facebook.";
        license = licenses.mpl20;
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
        description = "Simplifies interactions on other Mastodon instances than your own. Visit <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/789a581b17c520493af8e5da2391e5958c7c2b17da669e418888a11bbb423d5a/https%3A//github.com/lartsch/FediAct\" rel=\"nofollow\">https://github.com/lartsch/FediAct</a> for more.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "ff2mpv" = buildFirefoxXpiAddon {
      pname = "ff2mpv";
      version = "4.0.0";
      addonId = "ff2mpv@yossarian.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/3898765/ff2mpv-4.0.0.xpi";
      sha256 = "88312a84fc0a5d8e32100664af900a252a86875ee51869c30fd68054e990c992";
      meta = with lib;
      {
        homepage = "https://github.com/woodruffw/ff2mpv";
        description = "Tries to play links in mpv.\n\nPress the toolbar button to play the current URL in mpv. Otherwise, right click on a URL and use the context  item to play an arbitrary URL.\n\nYou'll need the native client here: <a rel=\"nofollow\" href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/aadcd34348f892e0805a94f141a1124d9c4aa75199eb4cb7c4ff530417617f77/http%3A//github.com/woodruffw/ff2mpv\">github.com/woodruffw/ff2mpv</a>";
        license = licenses.mit;
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
        platforms = platforms.all;
        };
      };
    "firefox-translations" = buildFirefoxXpiAddon {
      pname = "firefox-translations";
      version = "1.3.2buildid20230220.141944";
      addonId = "firefox-translations-addon@mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4074062/firefox_translations-1.3.2buildid20230220.141944.xpi";
      sha256 = "2fc03ecd608b7e1fa78866cd786354e6344e260dd8af8cf6468f80d1e14531e2";
      meta = with lib;
      {
        homepage = "https://blog.mozilla.org/en/mozilla/local-translation-add-on-project-bergamot/";
        description = "Translate websites in your browser, privately, without using the cloud.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "firemonkey" = buildFirefoxXpiAddon {
      pname = "firemonkey";
      version = "2.67";
      addonId = "firemonkey@eros.man";
      url = "https://addons.mozilla.org/firefox/downloads/file/4073785/firemonkey-2.67.xpi";
      sha256 = "2332636d0e64fac8d0d9e06d5623734d5c374ade1d75f129df8e5c78b0a60091";
      meta = with lib;
      {
        homepage = "https://github.com/erosman/support/issues";
        description = "Super Lightweight User Script and Style Manager";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "firenvim" = buildFirefoxXpiAddon {
      pname = "firenvim";
      version = "0.2.14";
      addonId = "firenvim@lacamb.re";
      url = "https://addons.mozilla.org/firefox/downloads/file/4026386/firenvim-0.2.14.xpi";
      sha256 = "a8c495a59e30eaabbb3fcd188db9b5e28b40bffefe41a3f0fa22ecc58c80c2b6";
      meta = with lib;
      {
        description = "Turn Firefox into a Neovim client.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "flagfox" = buildFirefoxXpiAddon {
      pname = "flagfox";
      version = "6.1.61";
      addonId = "{1018e4d6-728f-4b20-ad56-37578a4de76b}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4091245/flagfox-6.1.61.xpi";
      sha256 = "e2e243e82b971b02e20ede3ce1c514f9955a4392b11c0c70cb4d4cf2750e48e6";
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
        platforms = platforms.all;
        };
      };
    "floccus" = buildFirefoxXpiAddon {
      pname = "floccus";
      version = "4.19.1";
      addonId = "floccus@handmadeideas.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4090997/floccus-4.19.1.xpi";
      sha256 = "a806d218c2e8eb11d115f3cd85d877ee8b0ec4f043a3c3edf1e41f78738ca314";
      meta = with lib;
      {
        homepage = "https://floccus.org";
        description = "Sync your bookmarks across browsers via Nextcloud, WebDAV or Google Drive";
        license = licenses.mpl20;
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
        platforms = platforms.all;
        };
      };
    "form-history-control" = buildFirefoxXpiAddon {
      pname = "form-history-control";
      version = "2.5.6.1";
      addonId = "formhistory@yahoo.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3758560/form_history_control-2.5.6.1.xpi";
      sha256 = "3ce088e3d569363312f55ca945cacbdcb7f2c4268aae1b3dea45307e2c47e18b";
      meta = with lib;
      {
        homepage = "https://stephanmahieu.github.io/fhc-home/";
        description = "Manage form history entries (search, edit, cleanup, export/import) and easy text formfiller.\n\nAuto-save text entered in any form while typing to allow fast recovery when disaster strikes.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "foxyproxy-standard" = buildFirefoxXpiAddon {
      pname = "foxyproxy-standard";
      version = "7.5.1";
      addonId = "foxyproxy@eric.h.jung";
      url = "https://addons.mozilla.org/firefox/downloads/file/3616824/foxyproxy_standard-7.5.1.xpi";
      sha256 = "42109bc250e20aafd841183d09c7336008ab49574b5e8aa9206991bb306c3a65";
      meta = with lib;
      {
        homepage = "https://getfoxyproxy.org";
        description = "FoxyProxy is an advanced proxy management tool that completely replaces Firefox's limited proxying capabilities. For a simpler tool and less advanced configuration options, please use FoxyProxy Basic.";
        license = licenses.gpl2;
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
        platforms = platforms.all;
        };
      };
    "french-language-pack" = buildFirefoxXpiAddon {
      pname = "french-language-pack";
      version = "113.0.20230418.175842";
      addonId = "langpack-fr@firefox.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4099313/francais_language_pack-113.0.20230418.175842.xpi";
      sha256 = "35b12eb0aede4667572a7730864a59aa1f004fffddc043fc97ccc1082f677d28";
      meta = with lib;
      {
        description = "Firefox Language Pack for Français (fr) – French";
        license = licenses.mpl20;
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
        platforms = platforms.all;
        };
      };
    "gesturefy" = buildFirefoxXpiAddon {
      pname = "gesturefy";
      version = "3.2.7";
      addonId = "{506e023c-7f2b-40a3-8066-bc5deb40aebe}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4016417/gesturefy-3.2.7.xpi";
      sha256 = "24eeac920b89d6760e6134471ecf14916a1d2fb470aea6ab9ba52cb2330db83b";
      meta = with lib;
      {
        homepage = "https://github.com/Robbendebiene/Gesturefy";
        description = "Navigate, operate, and browse faster with mouse gestures! A customizable mouse gesture add-on with a variety of different commands.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "ghostery" = buildFirefoxXpiAddon {
      pname = "ghostery";
      version = "8.9.14";
      addonId = "firefox@ghostery.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4088491/ghostery-8.9.14.xpi";
      sha256 = "13c7eca0efb73cf4d3071470aa7b2ef173ddf28ac13ca15f7e0d85f44e2f553c";
      meta = with lib;
      {
        homepage = "http://www.ghostery.com/";
        description = "Ghostery is a powerful privacy extension. Block ads, stop trackers and speed up websites.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "ghosttext" = buildFirefoxXpiAddon {
      pname = "ghosttext";
      version = "23.3.27";
      addonId = "ghosttext@bfred.it";
      url = "https://addons.mozilla.org/firefox/downloads/file/4089624/ghosttext-23.3.27.xpi";
      sha256 = "1173595022cee7bc84eda8110218c46af85b924c0166188d2d51e06aefc9eaf6";
      meta = with lib;
      {
        homepage = "https://github.com/fregante/GhostText";
        description = "Use your text editor to write in your browser. Everything you type in the editor will be instantly updated in the browser (and vice versa).";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "gitpod" = buildFirefoxXpiAddon {
      pname = "gitpod";
      version = "1.18";
      addonId = "{dbcc42f9-c979-4f53-8a95-a102fbff3bbe}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4075459/gitpod-1.18.xpi";
      sha256 = "c574a0c595bea36735a7206d4bbbe1d699255dcafec228b3143e3d47838be0f8";
      meta = with lib;
      {
        homepage = "http://www.gitpod.io";
        description = "Gitpod streamlines developer workflows by providing ready-to-code development environments in your browser - powered by VS Code.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/w/index.php?title=All_rights_reserved&oldid=1101263186";
          free = false;
          };
        platforms = platforms.all;
        };
      };
    "gloc" = buildFirefoxXpiAddon {
      pname = "gloc";
      version = "8.2.67";
      addonId = "{bc2166c4-e7a2-46d5-ad9e-342cef57f1f7}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4066555/gloc-8.2.67.xpi";
      sha256 = "8be408c7afc05ea67935e854b0128cb1505106ff9fc487adf1040389b38fce11";
      meta = with lib;
      {
        homepage = "https://github.com/kas-elvirov/gloc";
        description = "Сounts lines of code on GitHub\nWorks for public and private repositories.\nCounts lines of code from:\n- project detail page,\n- user's repositories,\n- organization page,\n- search results page, \n- trending page.";
        license = licenses.gpl2;
        platforms = platforms.all;
        };
      };
    "gnome-shell-integration" = buildFirefoxXpiAddon {
      pname = "gnome-shell-integration";
      version = "11.1";
      addonId = "chrome-gnome-shell@gnome.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3974897/gnome_shell_integration-11.1.xpi";
      sha256 = "dff05cff4e53254c03a91d047e776f77aeb1d069540aecd5e48209fae2a44c3b";
      meta = with lib;
      {
        homepage = "https://wiki.gnome.org/Projects/GnomeShellIntegrationForChrome";
        description = "This extension provides integration with GNOME Shell and the corresponding extensions repository <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/b16ff805576d83628b80265636b483e6f56c58d6e812e04045626ff602eff739/https%3A//extensions.gnome.org\" rel=\"nofollow\">https://extensions.gnome.org</a>";
        license = licenses.gpl3;
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
        description = "Chrome extension that visually merges the same event on multiple Google Calendars into one event.\n\nSource: <a rel=\"nofollow\" href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/342b7a3d66f39d16cdbc5cd1d4cc26f85aeb1f94cae54867035888d93d484554/https%3A//github.com/imightbeamy/gcal-multical-event-merge\">https://github.com/imightbeamy/gcal-multical-event-merge</a>";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "gopass-bridge" = buildFirefoxXpiAddon {
      pname = "gopass-bridge";
      version = "0.9.0";
      addonId = "{eec37db0-22ad-4bf1-9068-5ae08df8c7e9}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3933988/gopass_bridge-0.9.0.xpi";
      sha256 = "3ef72f32eabc9092591076a2093b3341cb1a9e6c57631655a97c7bcecab80420";
      meta = with lib;
      {
        homepage = "https://github.com/gopasspw/gopassbridge";
        description = "Gopass Bridge allows searching and inserting login credentials from the gopass password manager ( <a rel=\"nofollow\" href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/fa484fa7cde64c1be04f689a80902fdf34bfe274b8675213f619c3a13e6606ab/https%3A//www.gopass.pw/\">https://www.gopass.pw/</a> ).";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "grammarly" = buildFirefoxXpiAddon {
      pname = "grammarly";
      version = "8.905.0";
      addonId = "87677a2c52b84ad3a151a4a72f5bd3c4@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4084257/grammarly_1-8.905.0.xpi";
      sha256 = "59f7c824c2de095b5bb97c98e2339232fe9167471132d08963e5a043195b5cd6";
      meta = with lib;
      {
        homepage = "http://grammarly.com";
        description = "Improve your writing with Grammarly's communication assistance. Spell check, grammar check, and punctuation check in one tool. Real-time suggestions for improving tone and clarity help ensure your writing makes the impression you want.";
        license = {
          shortName = "grammarly";
          fullName = "Grammarly Terms of Service and License Agreement";
          url = "https://www.grammarly.com/terms";
          free = false;
          };
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
        platforms = platforms.all;
        };
      };
    "greasemonkey" = buildFirefoxXpiAddon {
      pname = "greasemonkey";
      version = "4.11";
      addonId = "{e4a8a97b-f2ed-450b-b12d-ee082ba24781}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3716451/greasemonkey-4.11.xpi";
      sha256 = "5eb85a96f76a9b16a47cf207991d4237bf597c7b767574559204e2e0ff1173f0";
      meta = with lib;
      {
        homepage = "http://www.greasespot.net/";
        description = "Customize the way a web page displays or behaves, by using small bits of JavaScript.";
        license = licenses.mit;
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
        homepage = "https://gitlab.com/calvinchd/gruvbox-dark-firefox-theme";
        description = "Gruvbox dark theme for Firefox. Using <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/51b32595b55bba030aad1f22730eb7a787bb37c8a04d43f4a473d4b094b65ccb/https%3A//github.com/morhetz/gruvbox\" rel=\"nofollow\">https://github.com/morhetz/gruvbox</a> color palette";
        license = licenses.cc-by-30;
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
        platforms = platforms.all;
        };
      };
    "header-editor" = buildFirefoxXpiAddon {
      pname = "header-editor";
      version = "4.1.1";
      addonId = "headereditor-amo@addon.firefoxcn.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/3472456/header_editor-4.1.1.xpi";
      sha256 = "389fba1a1a08b97f8b4bf0ed9c21ac2e966093ec43cecb80fc574997a0a99766";
      meta = with lib;
      {
        homepage = "https://he.firefoxcn.net/en/";
        description = "Manage browser's requests, include modify the request headers and response headers, redirect requests, cancel requests";
        license = licenses.gpl2;
        platforms = platforms.all;
        };
      };
    "history-cleaner" = buildFirefoxXpiAddon {
      pname = "history-cleaner";
      version = "1.4.0";
      addonId = "{a138007c-5ff6-4d10-83d9-0afaf0efbe5e}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3853325/history_cleaner-1.4.0.xpi";
      sha256 = "9aa09f68d29c499180c37a4cc6e7b93eae9d6a96e13a525417eeeb68afb85a6d";
      meta = with lib;
      {
        homepage = "https://github.com/Rayquaza01/HistoryCleaner";
        description = "Deletes browsing history older than a specified number of days.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "honey" = buildFirefoxXpiAddon {
      pname = "honey";
      version = "12.8.4";
      addonId = "jid1-93CWPmRbVPjRQA@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3731265/honey-12.8.4.xpi";
      sha256 = "1abc41b3d81879e8687696bb084ecceb40edec95ffa5b4516ad86185e13114cb";
      meta = with lib;
      {
        homepage = "https://www.joinhoney.com";
        description = "Automatically find and try coupon codes with 1-click. Works at thousands of stores in the US, Canada, Australia, India and the UK.";
        license = {
          shortName = "honeyl";
          fullName = "Custom License for Honey";
          url = "https://addons.mozilla.org/en-US/firefox/addon/honey/license/";
          free = false;
          };
        platforms = platforms.all;
        };
      };
    "hoppscotch" = buildFirefoxXpiAddon {
      pname = "hoppscotch";
      version = "0.25";
      addonId = "postwoman-firefox@postwoman.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/3991522/hoppscotch-0.25.xpi";
      sha256 = "bf8b07191f73a0785f726b6def710f14ad9d4c97750fa1188984b53367711b66";
      meta = with lib;
      {
        homepage = "https://github.com/hoppscotch/hoppscotch-extension";
        description = "Provides better experience for using the Hoppscotch web app.\n\nHaven't used Hoppscotch ? It's an amazing quick API Request Builder.\nTry it at <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/b9072bc5e1ee582514460d66641043506a2be371c097d77e1eb00a6b5b9dfa97/https%3A//hoppscotch.io/\" rel=\"nofollow\">https://hoppscotch.io/</a> !!!";
        license = licenses.mit;
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
        platforms = platforms.all;
        };
      };
    "i-dont-care-about-cookies" = buildFirefoxXpiAddon {
      pname = "i-dont-care-about-cookies";
      version = "3.4.6";
      addonId = "jid1-KKzOGWgsW3Ao4Q@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4071150/i_dont_care_about_cookies-3.4.6.xpi";
      sha256 = "17a9c529762978e28f7f68140359f9ccba2d5e811878ea2963908f0c2294fe05";
      meta = with lib;
      {
        homepage = "https://www.i-dont-care-about-cookies.eu/";
        description = "Get rid of cookie warnings from almost all websites!";
        license = licenses.gpl3;
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
        platforms = platforms.all;
        };
      };
    "ipfs-companion" = buildFirefoxXpiAddon {
      pname = "ipfs-companion";
      version = "2.22.1";
      addonId = "ipfs-firefox-addon@lidel.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4074701/ipfs_companion-2.22.1.xpi";
      sha256 = "7f0f191bc7525cd487e2c58476574a2ff4231795c9d1ea3388ff068ec6d871f1";
      meta = with lib;
      {
        homepage = "https://github.com/ipfs-shipyard/ipfs-companion";
        description = "Harness the power of IPFS in your browser";
        license = licenses.cc0;
        platforms = platforms.all;
        };
      };
    "ipvfoo" = buildFirefoxXpiAddon {
      pname = "ipvfoo";
      version = "1.42";
      addonId = "ipvfoo@pmarks.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/730512/ipvfoo_pmarks-1.42.xpi";
      sha256 = "3429c60ea4d73725842e4ed729c05f8eae414c3d9337cf70443da13b3ddcdbe0";
      meta = with lib;
      {
        homepage = "https://github.com/pmarks-net/ipvfoo";
        description = "Display the server IP address, with a realtime summary of IPv4, IPv6, and HTTPS information across all page elements.\n\n(This is primarily a Chrome extension, so it's a bit glitchy due to Firefox's inexact implementation of the APIs.)";
        license = licenses.asl20;
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
        platforms = platforms.all;
        };
      };
    "keepass-helper" = buildFirefoxXpiAddon {
      pname = "keepass-helper";
      version = "1.3";
      addonId = "{e56fa932-ad2c-4cfa-b0d7-a35db1d9b0f6}";
      url = "https://addons.mozilla.org/firefox/downloads/file/839803/keepass_helper_url_in_title-1.3.xpi";
      sha256 = "0ff5e82dd4526db8c7b8cddd7778f46d282de9f6fc4c1d11ac7aa7b0bbefe7e4";
      meta = with lib;
      {
        description = "Puts a hostname or a URL in the window title.\nIt does not modify the title of a tab, just the window title.\nIt does not inject any JavaScript code to a website, so it can't corrupt, nor can it be corrupted by it.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "keepassxc-browser" = buildFirefoxXpiAddon {
      pname = "keepassxc-browser";
      version = "1.8.6.1";
      addonId = "keepassxc-browser@keepassxc.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4094964/keepassxc_browser-1.8.6.1.xpi";
      sha256 = "ce2275eb1f0a4b0ce2342204d00d62033f81f6dcb9e021cff38f51273e614f20";
      meta = with lib;
      {
        homepage = "https://keepassxc.org/";
        description = "Official browser plugin for the KeePassXC password manager (<a rel=\"nofollow\" href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/aebde84f385b73661158862b419dd43b46ac4c22bea71d8f812030e93d0e52d5/https%3A//keepassxc.org\">https://keepassxc.org</a>).";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "keybase" = buildFirefoxXpiAddon {
      pname = "keybase";
      version = "1.10.16";
      addonId = "keybase@keybase.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/1102153/keybase_for_firefox-1.10.16.xpi";
      sha256 = "6f4a171d534b6e7159094e7eb5fd8e696c1caee5116d78453db3827ba501c5fc";
      meta = with lib;
      {
        homepage = "https://keybase.io/docs/extension";
        description = "A secure chat button for every profile.";
        license = licenses.bsd2;
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
        description = "Firefox theme inspired by <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/276dc50c9e2710aa17b441df1ee87a9f5f023f5ded676ddd689d8f998d92713a/https%3A//www.nordtheme.com/\" rel=\"nofollow\">https://www.nordtheme.com/</a>";
        license = licenses.cc-by-30;
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
        platforms = platforms.all;
        };
      };
    "languagetool" = buildFirefoxXpiAddon {
      pname = "languagetool";
      version = "6.2.5";
      addonId = "languagetool-webextension@languagetool.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4086343/languagetool-6.2.5.xpi";
      sha256 = "d17977befe90e9c15b86407668a985587e8fb25aee353c7d47d34b917dec7cd9";
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
        platforms = platforms.all;
        };
      };
    "lastpass-password-manager" = buildFirefoxXpiAddon {
      pname = "lastpass-password-manager";
      version = "4.112.0.2";
      addonId = "support@lastpass.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4088441/lastpass_password_manager-4.112.0.2.xpi";
      sha256 = "20d665587a4aec3eeaf87126fe677c9fe21f0bf326ddd4019c2eee61cc989030";
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
        platforms = platforms.all;
        };
      };
    "leechblock-ng" = buildFirefoxXpiAddon {
      pname = "leechblock-ng";
      version = "1.5.4.1";
      addonId = "leechblockng@proginosko.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4081038/leechblock_ng-1.5.4.1.xpi";
      sha256 = "62b748ee4bb6ff81f6f6212cfe55373039b45580986593725ea54036c8f1d6a8";
      meta = with lib;
      {
        homepage = "https://www.proginosko.com/leechblock/";
        description = "LeechBlock NG is a simple productivity tool designed to block those time-wasting sites that can suck the life out of your working day. All you need to do is specify which sites to block and when to block them.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "lesspass" = buildFirefoxXpiAddon {
      pname = "lesspass";
      version = "9.6.9";
      addonId = "contact@lesspass.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4051050/lesspass-9.6.9.xpi";
      sha256 = "8efda879b3a7d6d2ec7777da20520c1427bced622ae0ea74a4562672f2f47d73";
      meta = with lib;
      {
        homepage = "https://github.com/lesspass/lesspass";
        description = "Use LessPass add-on to generate complex passwords and log in  automatically to all your sites";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "libredirect" = buildFirefoxXpiAddon {
      pname = "libredirect";
      version = "2.5.4";
      addonId = "7esoorv3@alefvanoon.anonaddy.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/4079849/libredirect-2.5.4.xpi";
      sha256 = "57d6adbaabf74f386be88d63906992be46cf77c485c1c00afa27161ef3bbb8d4";
      meta = with lib;
      {
        homepage = "https://libredirect.github.io";
        description = "Redirects YouTube, Twitter, TikTok... requests to alternative privacy friendly frontends.";
        license = licenses.gpl3;
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
        platforms = platforms.all;
        };
      };
    "link-cleaner" = buildFirefoxXpiAddon {
      pname = "link-cleaner";
      version = "1.5";
      addonId = "{6d85dea2-0fb4-4de3-9f8c-264bce9a2296}";
      url = "https://addons.mozilla.org/firefox/downloads/file/671858/link_cleaner-1.5.xpi";
      sha256 = "1ecec8cbe78b4166fc50da83213219f30575a8c183f7a13aabbff466c71ce560";
      meta = with lib;
      {
        homepage = "https://github.com/idlewan/link_cleaner";
        description = "Clean URLs that are about to be visited:\n- removes utm_* parameters\n- on item pages of aliexpress and amazon, removes tracking parameters\n- skip redirect pages of facebook, steam and reddit";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "linkhints" = buildFirefoxXpiAddon {
      pname = "linkhints";
      version = "1.3.1";
      addonId = "linkhints@lydell.github.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/3985677/linkhints-1.3.1.xpi";
      sha256 = "ca0d9ed8d52e3ab62a9d3d7c2be29ae30d22f2ecd37eff5b38e34c130d96711b";
      meta = with lib;
      {
        homepage = "https://lydell.github.io/LinkHints";
        description = "Click with your keyboard.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "localcdn" = buildFirefoxXpiAddon {
      pname = "localcdn";
      version = "2.6.49";
      addonId = "{b86e4813-687a-43e6-ab65-0bde4ab75758}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4094744/localcdn_fork_of_decentraleyes-2.6.49.xpi";
      sha256 = "09a230844d6e63383e4a28514afd1738dfcc25a0652d10700cce32d96e55b3d0";
      meta = with lib;
      {
        homepage = "https://www.localcdn.org";
        description = "Emulates remote frameworks (e.g. jQuery, Bootstrap, AngularJS) and delivers them as local resource. Prevents unnecessary 3rd party requests to Google, StackPath, MaxCDN and more. Prepared rules for uBlock Origin/uMatrix.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "lovely-forks" = buildFirefoxXpiAddon {
      pname = "lovely-forks";
      version = "3.7.2";
      addonId = "github-forks-addon@musicallyut.in";
      url = "https://addons.mozilla.org/firefox/downloads/file/3805375/lovely_forks-3.7.2.xpi";
      sha256 = "a96c0da726fd46ce6a14ea39ceaaf571e7cf9a2d467b2e2e72543a7c57312b78";
      meta = with lib;
      {
        homepage = "https://github.com/musically-ut/lovely-forks";
        description = "Show notable forks of Github projects.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "mailvelope" = buildFirefoxXpiAddon {
      pname = "mailvelope";
      version = "4.2.3";
      addonId = "jid1-AQqSMBYb0a8ADg@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3520187/mailvelope-4.2.3.xpi";
      sha256 = "e3e9a09354f03b35426bf48f134553b13199170fa2583eef4a6098da616e8f4e";
      meta = with lib;
      {
        homepage = "https://www.mailvelope.com/";
        description = "Enhance your webmail provider with end-to-end encryption. Secure email communication based on the OpenPGP standard.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "markdownload" = buildFirefoxXpiAddon {
      pname = "markdownload";
      version = "3.2.1";
      addonId = "{1c5e4c6f-5530-49a3-b216-31ce7d744db0}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4007848/markdownload-3.2.1.xpi";
      sha256 = "9cb65bf5c48a38d43ca3b2c47b5f424c2d27eaca66f1d7d2473eddd9ea73f63f";
      meta = with lib;
      {
        homepage = "https://github.com/deathau/markdown-clipper";
        description = "This extension works like a web clipper, but it downloads articles in a markdown format. Turndown and Readability.js are used as core libraries. It is not guaranteed to work with all websites.";
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
        platforms = platforms.all;
        };
      };
    "metamask" = buildFirefoxXpiAddon {
      pname = "metamask";
      version = "10.28.3";
      addonId = "webextension@metamask.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/4096869/ether_metamask-10.28.3.xpi";
      sha256 = "bf034e8296bc4a6aafc5152a240c0c3a40641e1687a95c0ec7f964118a3e3e97";
      meta = with lib;
      {
        description = "Ethereum Browser Extension";
        platforms = platforms.all;
        };
      };
    "modheader" = buildFirefoxXpiAddon {
      pname = "modheader";
      version = "4.3.2";
      addonId = "{ed630365-1261-4ba9-a676-99963d2b4f54}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4095128/modheader_firefox-4.3.2.xpi";
      sha256 = "0fda7510f5e024bdf4ecd64d2355c03b4405ed57d4af14b1a1727dcd65e7ffa7";
      meta = with lib;
      {
        homepage = "https://modheader.com/";
        description = "Add and modify the HTTP request headers and response headers.\n\nUse ModHeader to:\n- Add / modify request and response headers\n- Add / modify cookies\n- Multi-profile support\n- Filtering based on URL, tab, or window\n- Export and share profiles";
        license = {
          shortName = "modheader";
          fullName = "Terms of Use for ModHeader";
          url = "https://modheader.com/terms#license-terms";
          free = false;
          };
        platforms = platforms.all;
        };
      };
    "modrinthify" = buildFirefoxXpiAddon {
      pname = "modrinthify";
      version = "1.6.1";
      addonId = "{5183707f-8a46-4092-8c1f-e4515bcebbad}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4081301/modrinthify-1.6.1.xpi";
      sha256 = "b5c40e5e9ade210e1a6089bd0b97cd694214df0a97b811270d7e41cbbd577773";
      meta = with lib;
      {
        homepage = "https://github.com/devBoi76/modrinthify";
        description = "Automatically searches Modrinth for Curseforge mods and displays Modrinth notifications in the toolbar!";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "momentumdash" = buildFirefoxXpiAddon {
      pname = "momentumdash";
      version = "2.7.65";
      addonId = "momentum@momentumdash.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4097762/momentumdash-2.7.65.xpi";
      sha256 = "e83f96427b62b090b984ed85495c9c7c8b057287d464b6a8cafc3e5279232305";
      meta = with lib;
      {
        homepage = "https://momentumdash.com";
        description = "Replace your new tab page with an all-in-one productivity dashboard. Featuring daily inspiration, focus reminders, to-do lists, local weather info, and more!";
        license = {
          shortName = "momentum";
          fullName = "Momentum Terms of Use";
          url = "https://momentumdash.com/legal";
          free = false;
          };
        platforms = platforms.all;
        };
      };
    "multi-account-containers" = buildFirefoxXpiAddon {
      pname = "multi-account-containers";
      version = "8.1.2";
      addonId = "@testpilot-containers";
      url = "https://addons.mozilla.org/firefox/downloads/file/4058426/multi_account_containers-8.1.2.xpi";
      sha256 = "0ab8f0222853fb68bc05fcf96401110910dfeb507aaea2cf88c5cd7084d167fc";
      meta = with lib;
      {
        homepage = "https://github.com/mozilla/multi-account-containers/#readme";
        description = "Firefox Multi-Account Containers lets you keep parts of your online life separated into color-coded tabs. Cookies are separated by container, allowing you to use the web with multiple accounts and integrate Mozilla VPN for an extra layer of privacy.";
        license = licenses.mpl20;
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
        description = "download sheet music from <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/c0273e141ab141ea0a7256437045917b687d145c317a25868e70a5d8ccb864ea/http%3A//musescore.com\" rel=\"nofollow\">musescore.com</a> for free, no login or Musescore Pro required | 免登录、免 Musescore Pro，免费下载 <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/c0273e141ab141ea0a7256437045917b687d145c317a25868e70a5d8ccb864ea/http%3A//musescore.com\" rel=\"nofollow\">musescore.com</a> 上的曲谱";
        license = licenses.mit;
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
        platforms = platforms.all;
        };
      };
    "new-tab-override" = buildFirefoxXpiAddon {
      pname = "new-tab-override";
      version = "15.1.1";
      addonId = "newtaboverride@agenedia.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3782413/new_tab_override-15.1.1.xpi";
      sha256 = "74d97de74c1d4d5cc146182dbbf9cdc3f383ba4c5d1492edbdb14351549a9d64";
      meta = with lib;
      {
        homepage = "https://www.soeren-hentzschel.at/firefox-webextensions/new-tab-override/";
        description = "New Tab Override allows you to set the page that shows whenever you open a new tab.";
        license = licenses.mpl20;
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
        platforms = platforms.all;
        };
      };
    "new-zealand-english-dict" = buildFirefoxXpiAddon {
      pname = "new-zealand-english-dict";
      version = "1.0.1.2webext";
      addonId = "en-NZ@dictionaries.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/1163918/new_zealand_english_dict-1.0.1.2webext.xpi";
      sha256 = "d5c1a77b2f38073c0c0500a0c2ad449759da01c4697c58ebb2f7032f2ea04f33";
      meta = with lib;
      {
        description = "New Zealand English Dictionary 1.0.1 for Firefox.";
        license = licenses.lgpl21;
        platforms = platforms.all;
        };
      };
    "news-feed-eradicator" = buildFirefoxXpiAddon {
      pname = "news-feed-eradicator";
      version = "2.2.4";
      addonId = "@news-feed-eradicator";
      url = "https://addons.mozilla.org/firefox/downloads/file/4030420/news_feed_eradicator-2.2.4.xpi";
      sha256 = "fe31c99ee6befbe9fbcbebf4e74391e3dd68802ce8c9c5ebe17466045e3ef88e";
      meta = with lib;
      {
        homepage = "https://west.io/news-feed-eradicator";
        description = "Find yourself spending too much time on Facebook? Eradicate distractions by replacing your entire news feed with an inspiring quote";
        license = licenses.mit;
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
        platforms = platforms.all;
        };
      };
    "ninja-cookie" = buildFirefoxXpiAddon {
      pname = "ninja-cookie";
      version = "0.2.7";
      addonId = "debug@ninja-cookie.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3625855/ninja_cookie-0.2.7.xpi";
      sha256 = "b48f03a79fec4dc47065088c11115de0159857e6f77f7ffcb7da89b010ad3e61";
      meta = with lib;
      {
        homepage = "https://ninja-cookie.com/";
        description = "Ninja Cookie removes cookie banners by rejecting the use of non-essential cookies.";
        license = {
          shortName = "ninja-cookie";
          fullName = "End-User License Agreement (EULA) of Ninja Cookie";
          url = "https://ninja-cookie.com/eula/";
          free = false;
          };
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
        platforms = platforms.all;
        };
      };
    "noscript" = buildFirefoxXpiAddon {
      pname = "noscript";
      version = "11.4.21";
      addonId = "{73a6fe31-595d-460b-a920-fcc0f8843232}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4090970/noscript-11.4.21.xpi";
      sha256 = "0fd3b66a2780d03a5b3cd460216105f3df2b27c6d3a552c1769c5de48c9e2338";
      meta = with lib;
      {
        homepage = "https://noscript.net";
        description = "The best security you can get in a web browser! Allow potentially malicious web content to run only from sites you trust. Protect yourself against XSS other web security exploits.";
        license = licenses.gpl2;
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
        platforms = platforms.all;
        };
      };
    "octotree" = buildFirefoxXpiAddon {
      pname = "octotree";
      version = "7.8.3";
      addonId = "jid1-Om7eJGwA1U8Akg@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4082360/octotree-7.8.3.xpi";
      sha256 = "ee6c09046648e30da6a2cc942e5b41771975e9ea28f9b252d43d1b20ad4ac711";
      meta = with lib;
      {
        homepage = "https://github.com/buunguyen/octotree/";
        description = "GitHub on steroids";
        platforms = platforms.all;
        };
      };
    "offline-qr-code-generator" = buildFirefoxXpiAddon {
      pname = "offline-qr-code-generator";
      version = "1.8";
      addonId = "offline-qr-code@rugk.github.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/3870992/offline_qr_code_generator-1.8.xpi";
      sha256 = "449c236b88cf3fea2da31bdc004fdf6379face841b77ccc5096cba3afbd983de";
      meta = with lib;
      {
        homepage = "https://github.com/rugk/offline-qr-code";
        description = "This add-on allows you to quickly generate a QR code offline with the URL of the open tab or any (selected) other text! 👍\n\nIt works completely offline protecting your privacy and has a big range of features like colored QR codes!";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "okta-browser-plugin" = buildFirefoxXpiAddon {
      pname = "okta-browser-plugin";
      version = "6.19.0";
      addonId = "plugin@okta.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4086303/okta_browser_plugin-6.19.0.xpi";
      sha256 = "9d62d4f59083d0c14f536228cc969d9d4a8e6175fabf9a27f1346a3fc68129b1";
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
        platforms = platforms.all;
        };
      };
    "old-reddit-redirect" = buildFirefoxXpiAddon {
      pname = "old-reddit-redirect";
      version = "1.6.1";
      addonId = "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4051311/old_reddit_redirect-1.6.1.xpi";
      sha256 = "17f18ce82f060d7847cce9b6052631a9f2ec207d4500944ebc60b9d06a348aad";
      meta = with lib;
      {
        homepage = "https://github.com/tom-james-watson/old-reddit-redirect";
        description = "Ensure Reddit always loads the old design";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "onepassword-password-manager" = buildFirefoxXpiAddon {
      pname = "onepassword-password-manager";
      version = "2.9.0";
      addonId = "{d634138d-c276-4fc8-924b-40a0ea21d284}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4091893/1password_x_password_manager-2.9.0.xpi";
      sha256 = "f26bf329836d2947d98e62b33ddd0d52ded8dd13f2bb56e89e887babd587f212";
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
        platforms = platforms.all;
        };
      };
    "onetab" = buildFirefoxXpiAddon {
      pname = "onetab";
      version = "1.59";
      addonId = "extension@one-tab.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3946687/onetab-1.59.xpi";
      sha256 = "8976b6841f3f729d349a23333e6544c4e973ada7486a8a20f85e151d65ca6191";
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
        platforms = platforms.all;
        };
      };
    "org-capture" = buildFirefoxXpiAddon {
      pname = "org-capture";
      version = "0.2.1";
      addonId = "{ddefd400-12ea-4264-8166-481f23abaa87}";
      url = "https://addons.mozilla.org/firefox/downloads/file/1127481/org_capture-0.2.1.xpi";
      sha256 = "5683ee1ebfafc24abc2d759c7180c4e839c24fa90764d8cf3285c5d72fc81f0a";
      meta = with lib;
      {
        homepage = "https://github.com/sprig/org-capture-extension";
        description = "A helper for capturing things via org-protocol in emacs: First, set up: <a rel=\"nofollow\" href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/04ad17418f8d35ee0f3edf4599aed951b2a5ef88d4bc7e0e3237f6d86135e4fb/http%3A//orgmode.org/worg/org-contrib/org-protocol.html\">http://orgmode.org/worg/org-contrib/org-protocol.html</a> or <a rel=\"nofollow\" href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/fb401af8127ccf82bc948b0a7af0543eec48d58100c0c46404f81aabeda442e6/https%3A//github.com/sprig/org-capture-extension\">https://github.com/sprig/org-capture-extension</a>\n\nSee <a rel=\"nofollow\" href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/6aad51cc4e2f9476f9fff344e6554eade08347181aed05f8b61cda05073daecb/https%3A//youtu.be/zKDHto-4wsU\">https://youtu.be/zKDHto-4wsU</a> for example usage";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "pay-by-privacy-com" = buildFirefoxXpiAddon {
      pname = "pay-by-privacy-com";
      version = "1.6.3";
      addonId = "privacy@privacy.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3596835/pay_by_privacy_com-1.6.3.xpi";
      sha256 = "d04c7bf29b7905534687ccf4ca1050b6daa2a7aef65a138987380252e7ef714d";
      meta = with lib;
      {
        homepage = "https://privacy.com";
        description = "<a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/adc81a532e2c6239668fcd0691327d16fe545090b6e7073ccfdbaa2a69eda0c2/http%3A//Privacy.com\" rel=\"nofollow\">Privacy.com</a>'s Firefox add-on allows you to generate a new virtual card number with 1-click on any checkout page. Keep your payment info safe from data breaches, shady merchants, and sneaky subscription billing.";
        license = {
          shortName = "pay-by-privacy.com";
          fullName = "Custom License for Pay by Privacy.com";
          url = "https://addons.mozilla.org/en-US/firefox/addon/pay-by-privacy-com/license/";
          free = false;
          };
        platforms = platforms.all;
        };
      };
    "peertubeify" = buildFirefoxXpiAddon {
      pname = "peertubeify";
      version = "0.6.0";
      addonId = "{01175c8e-4506-4263-bad9-d3ddfd4f5a5f}";
      url = "https://addons.mozilla.org/firefox/downloads/file/1687641/peertubeify-0.6.0.xpi";
      sha256 = "9ccd1eec053a1131629c60983d6fc5ff8ac96205bbcf5a1ed22c7bb46ad07d3b";
      meta = with lib;
      {
        homepage = "https://gitlab.com/Ealhad/peertubeify";
        description = "PeerTubeify allows to redirect between YouTube and PeerTube and across PeerTube instances, automatically or by displaying a link.\n\nDon't forget to set your preferences :)\n\nPeerTubeify is not affiliated with PeerTube.";
        license = licenses.gpl3;
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
        description = "Unofficial Firefox add-on for <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/9195797232dc4f996eff7bc68a67ac5b906f828efd0d0ebded52b3b4ef47556d/http%3A//Pinboard.in\" rel=\"nofollow\">Pinboard.in</a>. Bookmark web pages &amp; add notes easily. Keyboard command: Alt + p";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "plasma-integration" = buildFirefoxXpiAddon {
      pname = "plasma-integration";
      version = "1.8.1";
      addonId = "plasma-browser-integration@kde.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3859385/plasma_integration-1.8.1.xpi";
      sha256 = "e156e82091bbff44cb9d852e16aedacdcc0819c5a3b8cb34cedd77acf566c5c4";
      meta = with lib;
      {
        homepage = "http://kde.org";
        description = "Multitask efficiently by controlling browser functions from the Plasma desktop.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "pocket-select-all" = buildFirefoxXpiAddon {
      pname = "pocket-select-all";
      version = "1.0";
      addonId = "{68a267e1-f384-4356-9f1e-511ec5807858}";
      url = "https://addons.mozilla.org/firefox/downloads/file/1052566/pocket_select_all-1.0.xpi";
      sha256 = "5cdf8426127fdc376bad81aa3035f3993cfa7621b2899353881333302c0df507";
      meta = with lib;
      {
        description = "Adds a Select All button to <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/00c9d03cfa8d351fa7e6b5809ce9940b861a97f394a8cedefcee710f58cfb0c5/https%3A//getpocket.com\" rel=\"nofollow\">https://getpocket.com</a>.\n\n**WARNING**: Some people have complained about this extension being automatically installed or similar. If this happens, or you installed it from anywhere but <a href=\"http://addons.mozilla.org\" rel=\"nofollow\">addons.mozilla.org</a>, please remove it.";
        license = {
          shortName = "unfree";
          fullName = "Unfree";
          url = "https://addons.mozilla.org/en-US/firefox/addon/pocket-select-all/";
          free = false;
          };
        platforms = platforms.all;
        };
      };
    "polish-dictionary" = buildFirefoxXpiAddon {
      pname = "polish-dictionary";
      version = "1.0.20160228.1webext";
      addonId = "pl@dictionaries.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/1163872/polish_spellchecker_dictionary-1.0.20160228.1webext.xpi";
      sha256 = "b11906da9d9c1f3de7661b990fc1a670dc1615eda0ce0e96efae26b0627474c7";
      meta = with lib;
      {
        homepage = "http://www.aviary.pl/";
        description = "Polish spell-check dictionary for Firefox, Thunderbird and SeaMonkey.";
        platforms = platforms.all;
        };
      };
    "polkadot-js" = buildFirefoxXpiAddon {
      pname = "polkadot-js";
      version = "0.41.1";
      addonId = "{7e3ce1f0-15fb-4fb1-99c6-25774749ec6d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3865101/polkadot_js_extension-0.41.1.xpi";
      sha256 = "8ddbe656dbbc11806b70fdf5b9faa4441524ddf5fb5a5b960cdbf377becf2256";
      meta = with lib;
      {
        homepage = "https://github.com/polkadot-js/extension";
        description = "Manage your Polkadot accounts outside of dapps. Injects the accounts and allows signs transactions for a specific account.";
        platforms = platforms.all;
        };
      };
    "privacy-badger" = buildFirefoxXpiAddon {
      pname = "privacy-badger";
      version = "2023.1.31";
      addonId = "jid1-MnnxcxisBPnSXQ@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4064595/privacy_badger17-2023.1.31.xpi";
      sha256 = "0082d8ffe7b25f370a313d9b899b0c1ba1669b21b3a11791fe5ecf031aeb6a6c";
      meta = with lib;
      {
        homepage = "https://privacybadger.org/";
        description = "Automatically learns to block invisible trackers.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "privacy-pass" = buildFirefoxXpiAddon {
      pname = "privacy-pass";
      version = "3.0.5";
      addonId = "{48748554-4c01-49e8-94af-79662bf34d50}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4068311/privacy_pass-3.0.5.xpi";
      sha256 = "a8f1d496986af78fd91b9e44c782b80afc45d0cb39013d5cfb54da1611e21273";
      meta = with lib;
      {
        homepage = "https://privacypass.github.io";
        description = "Client-side of the Privacy Pass protocol providing unlinkable cryptographic tokens.";
        license = licenses.bsd2;
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
        platforms = platforms.all;
        };
      };
    "privacy-settings" = buildFirefoxXpiAddon {
      pname = "privacy-settings";
      version = "0.3.7";
      addonId = "jid1-CKHySAadH4nL6Q@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/1182089/privacy_settings-0.3.7.xpi";
      sha256 = "692ef4eea9b192c470be28f6fb7e9eb3f5a92946aad65d384be9ea0b4d01e40c";
      meta = with lib;
      {
        homepage = "http://add0n.com/privacy-settings.html";
        description = "Alter Firefox's built-in privacy settings easily with a toolbar panel.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "private-relay" = buildFirefoxXpiAddon {
      pname = "private-relay";
      version = "2.7.0";
      addonId = "private-relay@firefox.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4095147/private_relay-2.7.0.xpi";
      sha256 = "1913cd25517dd9af78f5d8f30494f13f8c8dd5db362191432cb5668df0f7982d";
      meta = with lib;
      {
        homepage = "https://relay.firefox.com/";
        description = "Firefox Relay lets you generate email aliases that forward to your real inbox. Use it to hide your real email address and protect yourself from hackers and unwanted mail.";
        license = licenses.mpl20;
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
        platforms = platforms.all;
        };
      };
    "promnesia" = buildFirefoxXpiAddon {
      pname = "promnesia";
      version = "1.1.1";
      addonId = "{07c6b8e1-94f7-4bbf-8e91-26c0a8992ab5}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3947740/promnesia-1.1.1.xpi";
      sha256 = "512d2aa1a5715c0fd0d93456f83e877a749d219a75ff2ad83b385b31560cc94a";
      meta = with lib;
      {
        homepage = "https://github.com/karlicoss/promnesia";
        description = "Enhancement of your browsing history";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "protondb-for-steam" = buildFirefoxXpiAddon {
      pname = "protondb-for-steam";
      version = "1.8.1";
      addonId = "{30280527-c46c-4e03-bb16-2e3ed94fa57c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3736312/protondb_for_steam-1.8.1.xpi";
      sha256 = "879a5d1a2b757d54089d07a325340656ba2968f57408fe53259dc31d72a687a9";
      meta = with lib;
      {
        homepage = "https://github.com/tryton-vanmeer/ProtonDB-for-Steam#protondb-for-steam";
        description = "Shows ratings from <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/f8db0358d96c1a46b9a77aa02190de811e40819051b1d42dd013c17276046ffd/http%3A//protondb.com\" rel=\"nofollow\">protondb.com</a> on Steam";
        license = licenses.lgpl3;
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
        platforms = platforms.all;
        };
      };
    "rabattcorner" = buildFirefoxXpiAddon {
      pname = "rabattcorner";
      version = "2.1.5.5";
      addonId = "jid1-7eplFgLu6atoog@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4096853/rabattcorner-2.1.5.5.xpi";
      sha256 = "2cdb01ad33c59fef9ca15d3d358f732867a8937332bea728b4287fc388edb54f";
      meta = with lib;
      {
        homepage = "https://www.rabattcorner.ch";
        description = "Jetzt bei jedem Online Einkauf bis zu 25% Cashback erhalten. <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/be8bb3eaeaba31de0d5f89ccc266fa9cf18fda0fabad24266491f7c9342df151/http%3A//Rabattcorner.ch\" rel=\"nofollow\">Rabattcorner.ch</a> zahlt dir nach jedem Einkauf in einem der über 350 angeschlossenen Online Shops einen Teil deines Einkaufsbetrags zurück.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "react-devtools" = buildFirefoxXpiAddon {
      pname = "react-devtools";
      version = "4.27.1";
      addonId = "@react-devtools";
      url = "https://addons.mozilla.org/firefox/downloads/file/4040280/react_devtools-4.27.1.xpi";
      sha256 = "c0cf290a4dab2d18f840d7267da68033779bb3a001986aed2a78ed5e92432a1e";
      meta = with lib;
      {
        homepage = "https://github.com/facebook/react";
        description = "React Developer Tools is a tool that allows you to inspect a React tree, including the component hierarchy, props, state, and more. To get started, just open the Firefox devtools and switch to the \"⚛️ Components\" or \"⚛️ Profiler\" tab.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "reddit-comment-collapser" = buildFirefoxXpiAddon {
      pname = "reddit-comment-collapser";
      version = "5.1.1";
      addonId = "{a5b2e636-07e5-4331-93c1-6cf4074356c8}";
      url = "https://addons.mozilla.org/firefox/downloads/file/687469/reddit_comment_collapser-5.1.1.xpi";
      sha256 = "32c55ccfc082715f648d04bd92c9985730a6cce768f6e0ee9e9eb28cb72d6c44";
      meta = with lib;
      {
        homepage = "https://github.com/tom-james-watson/reddit-comment-collapser";
        description = "A more elegant solution for collapsing reddit comment trees.\n\nReddit Comment Collapser is free and open source. Contributions welcome - <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/782747fdec02dc86f6a710b2169056074fd7d1c2e56583eddf9168d2be14e7a0/https%3A//github.com/tom-james-watson/reddit-comment-collapser\" rel=\"nofollow\">https://github.com/tom-james-watson/reddit-comment-collapser</a>";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "reddit-enhancement-suite" = buildFirefoxXpiAddon {
      pname = "reddit-enhancement-suite";
      version = "5.22.17";
      addonId = "jid1-xUfzOsOFlzSOXg@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4092764/reddit_enhancement_suite-5.22.17.xpi";
      sha256 = "f49827c7684076dbf6890741dbbc31e82c180f87cb3fd745216ba2432398b1d9";
      meta = with lib;
      {
        homepage = "https://redditenhancementsuite.com/";
        description = "Reddit Enhancement Suite (RES) is a suite of tools to enhance your Reddit browsing experience.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "reddit-moderator-toolbox" = buildFirefoxXpiAddon {
      pname = "reddit-moderator-toolbox";
      version = "6.1.2";
      addonId = "yes@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4041487/reddit_moderator_toolbox-6.1.2.xpi";
      sha256 = "21477ebd83ab9d17102ce61e431c2567ac88e3e7a63e4c4ff4a7ceec2e329323";
      meta = with lib;
      {
        homepage = "https://www.reddit.com/r/toolbox";
        description = "This is bundled extension of the /r/toolbox moderator tools for <a rel=\"nofollow\" href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/42268797a19a16a2ebeeda77cca1eda5a48db14e0cff56de4fab35eaef484216/http%3A//reddit.com\">reddit.com</a>\n\nContaining:\n\nMod Tools Enhanced\nMod Button\nMod Mail Pro\nMod Domain Tagger\nToolbox Notifier\nMod User Notes\nToolbox Config";
        license = licenses.asl20;
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
        platforms = platforms.all;
        };
      };
    "reduxdevtools" = buildFirefoxXpiAddon {
      pname = "reduxdevtools";
      version = "3.0.19";
      addonId = "extension@redux.devtools";
      url = "https://addons.mozilla.org/firefox/downloads/file/4079806/reduxdevtools-3.0.19.xpi";
      sha256 = "f4da621d3d226cd3dcd817230e4214ddbc2423221dc3ef4428341fd393d1f66f";
      meta = with lib;
      {
        homepage = "https://github.com/reduxjs/redux-devtools";
        description = "DevTools for Redux with actions history, undo and replay.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "refined-github" = buildFirefoxXpiAddon {
      pname = "refined-github";
      version = "23.4.15";
      addonId = "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4097949/refined_github-23.4.15.xpi";
      sha256 = "022592b8a7c31858c90334d4decfb22ce61dd80ee9b4daafe54d2750210b2ab4";
      meta = with lib;
      {
        homepage = "https://github.com/sindresorhus/refined-github";
        description = "Simplifies the GitHub interface and adds many useful features.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "return-youtube-dislikes" = buildFirefoxXpiAddon {
      pname = "return-youtube-dislikes";
      version = "3.0.0.8";
      addonId = "{762f9885-5a13-4abd-9c77-433dcd38b8fd}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4072734/return_youtube_dislikes-3.0.0.8.xpi";
      sha256 = "e44a7a84bb552d4d3885b2e6d31cb653ed9dd65634e32d5af9a8930f6cae1fb8";
      meta = with lib;
      {
        description = "Returns ability to see dislike statistics on youtube";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "rust-search-extension" = buildFirefoxXpiAddon {
      pname = "rust-search-extension";
      version = "1.10.0";
      addonId = "{04188724-64d3-497b-a4fd-7caffe6eab29}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4089019/rust_search_extension-1.10.0.xpi";
      sha256 = "6f7f9cd46e981b565f9ef453eb8204676d3df17bef5b862ac3ddbef9f4f2ffb1";
      meta = with lib;
      {
        homepage = "https://rust.extension.sh";
        description = "The ultimate search extension for Rust\n\nSearch std docs, crates, builtin attributes, official books, and error codes, etc in your address bar instantly.\n<a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/4af48e3229ba03b454fb9b352a7e5a4c038e1bcc6721bf744b781a5e96b9e798/https%3A//rust.extension.sh\" rel=\"nofollow\">https://rust.extension.sh</a>";
        license = licenses.mpl20;
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
        platforms = platforms.all;
        };
      };
    "search-by-image" = buildFirefoxXpiAddon {
      pname = "search-by-image";
      version = "5.4.2";
      addonId = "{2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4034617/search_by_image-5.4.2.xpi";
      sha256 = "327549ce86f8dc27794ece4a065cf673e007eefe716fb188b8c6d28102fca22f";
      meta = with lib;
      {
        homepage = "https://github.com/dessant/search-by-image#readme";
        description = "A powerful reverse image search tool, with support for various search engines, such as Google, Bing, Yandex, Baidu and TinEye.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "search-engines-helper" = buildFirefoxXpiAddon {
      pname = "search-engines-helper";
      version = "3.3.0";
      addonId = "{65a2d764-7358-455b-930d-5afa86fb5ed0}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4041949/search_engines_helper-3.3.0.xpi";
      sha256 = "0e6f49394b7798d27dd507b0de2b27ad4cc888949a0ec9ac02294eb27f1a6382";
      meta = with lib;
      {
        homepage = "https://github.com/soufianesakhi/firefox-search-engines-helper";
        description = "Add a custom search engine and export/import all the search urls and icon urls for all search engines added to Firefox.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "sidebery" = buildFirefoxXpiAddon {
      pname = "sidebery";
      version = "4.10.2";
      addonId = "{3c078156-979c-498b-8990-85f7987dd929}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3994928/sidebery-4.10.2.xpi";
      sha256 = "60e35f2bfac88e5b2b4e044722dde49b4ed0eca9e9216f3d67dafdd9948273ac";
      meta = with lib;
      {
        homepage = "https://github.com/mbnuqw/sidebery";
        description = "Tabs tree and bookmarks in sidebar with advanced containers configuration.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "simple-tab-groups" = buildFirefoxXpiAddon {
      pname = "simple-tab-groups";
      version = "5.0.1";
      addonId = "simple-tab-groups@drive4ik";
      url = "https://addons.mozilla.org/firefox/downloads/file/4093909/simple_tab_groups-5.0.1.xpi";
      sha256 = "3201c4a0bb3fe7285227faf804cfa8584fbe41958f5dbcf47e4576adb6ca20b7";
      meta = with lib;
      {
        homepage = "https://github.com/drive4ik/simple-tab-groups";
        description = "Create, modify, and quickly change tab groups";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "simplelogin" = buildFirefoxXpiAddon {
      pname = "simplelogin";
      version = "2.9.2";
      addonId = "addon@simplelogin";
      url = "https://addons.mozilla.org/firefox/downloads/file/4028552/simplelogin-2.9.2.xpi";
      sha256 = "1cda6f6cab1ef3783fdf34d128fea3913f8cc7d9bd9d2c28eb98fc0c297c32e3";
      meta = with lib;
      {
        homepage = "https://simplelogin.io";
        description = "Create a different email for each website to hide your real email. Guard your inbox against spams, phishing. Protect your privacy.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "single-file" = buildFirefoxXpiAddon {
      pname = "single-file";
      version = "1.21.40";
      addonId = "{531906d3-e22f-4a6c-a102-8057b88a1a63}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4093783/single_file-1.21.40.xpi";
      sha256 = "5c8dea4521e82dce41d04d82e5a5f95bd07ab09b344e1c10edbab6bbb5ad9d21";
      meta = with lib;
      {
        homepage = "https://github.com/gildas-lormeau/SingleFile";
        description = "Save an entire web page—including images and styling—as a single HTML file.";
        license = licenses.agpl3Plus;
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
        description = "Improve your privacy by limiting Referer information leak!";
        license = licenses.wtfpl;
        platforms = platforms.all;
        };
      };
    "snowflake" = buildFirefoxXpiAddon {
      pname = "snowflake";
      version = "0.7.2";
      addonId = "{b11bea1f-a888-4332-8d8a-cec2be7d24b9}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4095470/torproject_snowflake-0.7.2.xpi";
      sha256 = "101b5c6f8f968645bd95d23ecd5c1f245b45d37c692153bf6e73c866997101dd";
      meta = with lib;
      {
        homepage = "https://snowflake.torproject.org/";
        description = "Help people in censored countries access the Internet without restrictions. Once you install and enable the extension, wait for the snowflake icon to turn green, this means a censored user is connecting through your extension to access the Internet!";
        license = licenses.bsd3;
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
        description = "Uh-oh!   Looks like somebody left Firefox out in the sun.\n\nCredit to Ethan Schoonover for the color scheme.\n\n<a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/84fc2a9889cf35b10644adef8f36c2af5f4beaf19955759761bceb2d20cfd051/http%3A//ethanschoonover.com/solarized\" rel=\"nofollow\">http://ethanschoonover.com/solarized</a>";
        license = {
          shortName = "all-rights-reserved";
          fullName = "All Rights Reserved";
          url = "https://en.wikipedia.org/wiki/All_rights_reserved";
          free = false;
          };
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
        platforms = platforms.all;
        };
      };
    "sponsorblock" = buildFirefoxXpiAddon {
      pname = "sponsorblock";
      version = "5.3.1";
      addonId = "sponsorBlocker@ajay.app";
      url = "https://addons.mozilla.org/firefox/downloads/file/4085308/sponsorblock-5.3.1.xpi";
      sha256 = "02385a0765aa88fbff553953a202fcca31012b1fb0ed9b82320c0572929a3849";
      meta = with lib;
      {
        homepage = "https://sponsor.ajay.app";
        description = "Easily skip YouTube video sponsors. When you visit a YouTube video, the extension will check the database for reported sponsors and automatically skip known sponsors. You can also report sponsors in videos.\n\nOther browsers: https://sponsor.ajay.app";
        license = licenses.lgpl3;
        platforms = platforms.all;
        };
      };
    "startpage-private-search" = buildFirefoxXpiAddon {
      pname = "startpage-private-search";
      version = "1.3.0";
      addonId = "{20fc2e06-e3e4-4b2b-812b-ab431220cada}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3421533/startpage_private_search-1.3.0.xpi";
      sha256 = "e7b5500da81cd360336780bbc7c8e92c6044ede40b4bfbcbdb401ecf38e9b439";
      meta = with lib;
      {
        description = "This extension protects users from being tracked while allowing them to search the web in complete private mode.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "statshunters" = buildFirefoxXpiAddon {
      pname = "statshunters";
      version = "1.0.17";
      addonId = "browserextension@statshunters.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4038642/statshunters-1.0.17.xpi";
      sha256 = "41e3ff4dc438f2c6aec5b6ab57918a27b1b3bd01bed865dc4b6bfbc31d5ae979";
      meta = with lib;
      {
        homepage = "https://www.statshunters.com";
        description = "Show tiles on Strava, Komoot, Brouter, RWGPS, Garmin and <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/a56490334fb034ba5435e2c86dcc1b7178abea1af61a6939f8af580c0b188354/http%3A//Mapy.cz\" rel=\"nofollow\">Mapy.cz</a> route builder";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "steam-database" = buildFirefoxXpiAddon {
      pname = "steam-database";
      version = "3.6.4";
      addonId = "firefox-extension@steamdb.info";
      url = "https://addons.mozilla.org/firefox/downloads/file/4056899/steam_database-3.6.4.xpi";
      sha256 = "074d3abfb652c18113a82fe603f46db44b0c4f12012fb2d8fe336688abe82d88";
      meta = with lib;
      {
        homepage = "https://steamdb.info/";
        description = "Adds SteamDB links and new features on the Steam store and community. View lowest game prices and stats.";
        license = licenses.bsd3;
        platforms = platforms.all;
        };
      };
    "streetpass-for-mastodon" = buildFirefoxXpiAddon {
      pname = "streetpass-for-mastodon";
      version = "2023.9";
      addonId = "streetpass@streetpass.social";
      url = "https://addons.mozilla.org/firefox/downloads/file/4092171/streetpass_for_mastodon-2023.9.xpi";
      sha256 = "3a707d9a75c77f29c4bc69a345552d9626fc62ecab5b5afff6b40523bb9fbf27";
      meta = with lib;
      {
        homepage = "https://streetpass.social/";
        description = "Find your people on Mastodon";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "stylus" = buildFirefoxXpiAddon {
      pname = "stylus";
      version = "1.5.30";
      addonId = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4075896/styl_us-1.5.30.xpi";
      sha256 = "9a8b40ecfb4e19252ab5435c3cb5976d9c86a7c295e4eda8a64820838b56b9ea";
      meta = with lib;
      {
        homepage = "https://add0n.com/stylus.html";
        description = "Redesign your favorite websites with Stylus, an actively developed and community driven userstyles manager. Easily install custom themes from popular online repositories, or create, edit, and manage your own personalized CSS stylesheets.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "surfingkeys" = buildFirefoxXpiAddon {
      pname = "surfingkeys";
      version = "1.13.0";
      addonId = "{a8332c60-5b6d-41ee-bfc8-e9bb331d34ad}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4085556/surfingkeys_ff-1.13.0.xpi";
      sha256 = "66ceeb45d2522825daad8b7be0a30ca42f91264d5c32ba5b897845f25e78f40c";
      meta = with lib;
      {
        homepage = "https://github.com/brookhong/Surfingkeys";
        description = "Rich shortcuts for you to click links / switch tabs / scroll pages or DIVs / capture full page or DIV etc, let you use the browser like vim, plus an embed vim editor.\n\n<a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/353ad9268cb5cdeb3fa107ea4d154273229fe2ffe8a28e3fda510de7f6ddd75f/https%3A//github.com/brookhong/Surfingkeys\" rel=\"nofollow\">https://github.com/brookhong/Surfingkeys</a>";
        license = licenses.mit;
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
        platforms = platforms.all;
        };
      };
    "switchyomega" = buildFirefoxXpiAddon {
      pname = "switchyomega";
      version = "2.5.19";
      addonId = "switchyomega@feliscatus.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/1051594/switchyomega-2.5.19.xpi";
      sha256 = "93f4d8abc4264be562a497ed6a88018780161a7fef680abd811579b1b6c0fa1b";
      meta = with lib;
      {
        homepage = "https://github.com/FelisCatus/SwitchyOmega";
        description = "Manage and switch between multiple proxies quickly &amp; easily.";
        license = licenses.gpl3;
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
        platforms = platforms.all;
        };
      };
    "tab-reloader" = buildFirefoxXpiAddon {
      pname = "tab-reloader";
      version = "0.6.1";
      addonId = "jid0-bnmfwWw2w2w4e4edvcdDbnMhdVg@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4069787/tab_reloader-0.6.1.xpi";
      sha256 = "775a96538999ec88868d68ad8909b2bbbfe8fd49f0d7ced2339139e0c88b11b7";
      meta = with lib;
      {
        homepage = "https://webextension.org/listing/tab-reloader.html";
        description = "An easy-to-use tab reloader with custom reloading time settings for individual tabs";
        license = licenses.mpl20;
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
        platforms = platforms.all;
        };
      };
    "tab-session-manager" = buildFirefoxXpiAddon {
      pname = "tab-session-manager";
      version = "6.12.1";
      addonId = "Tab-Session-Manager@sienori";
      url = "https://addons.mozilla.org/firefox/downloads/file/4002882/tab_session_manager-6.12.1.xpi";
      sha256 = "a3128a187fa42d45f7beca2480ebd3117a40bc591e6df726336932e081860747";
      meta = with lib;
      {
        homepage = "https://tab-session-manager.sienori.com/";
        description = "Save and restore the state of windows and tabs. It also supports automatic saving and cloud sync.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "tab-stash" = buildFirefoxXpiAddon {
      pname = "tab-stash";
      version = "2.12.0.1";
      addonId = "tab-stash@condordes.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4039316/tab_stash-2.12.0.1.xpi";
      sha256 = "03c26b1a067137cd03d538289c9ec502c93735550b2debfba0b301f4f89eb7d8";
      meta = with lib;
      {
        homepage = "https://josh-berry.github.io/tab-stash/";
        description = "A no-fuss way to save and organize batches of tabs as bookmarks. Clear your tabs, clear your mind.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "tab-unload-for-tree-style-tab" = buildFirefoxXpiAddon {
      pname = "tab-unload-for-tree-style-tab";
      version = "6.15";
      addonId = "{7aa0a466-58f8-427b-8cd2-e94645c4edc2}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3940033/tab_unload_for_tree_style_tab-6.15.xpi";
      sha256 = "fbe4ec3cff0a29fe9d730f689d323ba98ad159cb04800e59b7f91f694256473b";
      meta = with lib;
      {
        homepage = "https://github.com/Lej77/tab-unloader-for-tree-style-tab";
        description = "Tab unload options for Tree Style Tab.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "tabcenter-reborn" = buildFirefoxXpiAddon {
      pname = "tabcenter-reborn";
      version = "2.3.1";
      addonId = "tabcenter-reborn@ariasuni";
      url = "https://addons.mozilla.org/firefox/downloads/file/3829515/tabcenter_reborn-2.3.1.xpi";
      sha256 = "d31c693c896045d4326c7e9e0152830820009bd60f62b36043bb322cab713f34";
      meta = with lib;
      {
        homepage = "https://framagit.org/ariasuni/tabcenter-reborn";
        description = "Simple and powerful vertical tab bar";
        license = licenses.mpl20;
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
        platforms = platforms.all;
        };
      };
    "tampermonkey" = buildFirefoxXpiAddon {
      pname = "tampermonkey";
      version = "4.18.1";
      addonId = "firefox@tampermonkey.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4030629/tampermonkey-4.18.1.xpi";
      sha256 = "edb43812730e5b8d866589de7ab8d80e7932cab49a2fa10d2bc2b8be374ebcde";
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
        platforms = platforms.all;
        };
      };
    "terms-of-service-didnt-read" = buildFirefoxXpiAddon {
      pname = "terms-of-service-didnt-read";
      version = "4.1.2";
      addonId = "jid0-3GUEt1r69sQNSrca5p8kx9Ezc3U@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3827536/terms_of_service_didnt_read-4.1.2.xpi";
      sha256 = "886263dd428e08cc857275b771f7d28ec0e89a7663c1512607d61dd233f83fa8";
      meta = with lib;
      {
        homepage = "http://tosdr.org";
        description = "“I have read and agree to the Terms” is the biggest lie on the web. We aim to fix that. Get informed instantly about websites' terms &amp; privacy policies, with ratings and summaries from the <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/782d4bf373fdb0bc94e6bd037af1bf988ce2274e2210205e7e5b8bbd291b0997/http%3A//www.tosdr.org\" rel=\"nofollow\">www.tosdr.org</a> initiative.";
        license = licenses.agpl3Plus;
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
        platforms = platforms.all;
        };
      };
    "textern" = buildFirefoxXpiAddon {
      pname = "textern";
      version = "0.7";
      addonId = "textern@jlebon.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3594392/textern-0.7.xpi";
      sha256 = "cf15dba57b32b24c2dbc79ea169fb53286c40a5c500a066ba81e67439021bb5a";
      meta = with lib;
      {
        homepage = "https://github.com/jlebon/textern";
        description = "Edit text in your favourite external editor!";
        license = licenses.gpl3;
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
        description = "<a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/ba1182cc6e56316a3cb1a60385b04ef4843dca5caf9bb4a82a5ba5b0556aeee8/https%3A//paypal.me/christosbouronikos\" rel=\"nofollow\">https://paypal.me/christosbouronikos</a>";
        platforms = platforms.all;
        };
      };
    "to-deepl" = buildFirefoxXpiAddon {
      pname = "to-deepl";
      version = "0.9.0";
      addonId = "{db420ff1-427a-4cda-b5e7-7d395b9f16e1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4065186/to_deepl-0.9.0.xpi";
      sha256 = "98dde9b41f4971b0795a7c884b34b578701752deafe9febcd870fc4b056afdf4";
      meta = with lib;
      {
        homepage = "https://github.com/xpmn/firefox-to-deepl/";
        description = "Right-click on a section of text and click on \"To DeepL\" to translate it to your language. Default language is selected in extension preferences.";
        license = licenses.mit;
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
        platforms = platforms.all;
        };
      };
    "tournesol" = buildFirefoxXpiAddon {
      pname = "tournesol";
      version = "2.6.5";
      addonId = "{e8e831e8-8a2b-4fd8-b9f0-cd11155b476d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4099172/tournesol_extension-2.6.5.xpi";
      sha256 = "e33411e709f9a44074a10ccd757e044ab077464cb650e51da3826f3c808573f7";
      meta = with lib;
      {
        homepage = "https://tournesol.app/";
        description = "The extension facilitates using and contributing to the Tournesol project (https://tournesol.app).";
        license = licenses.lgpl3;
        platforms = platforms.all;
        };
      };
    "translate-web-pages" = buildFirefoxXpiAddon {
      pname = "translate-web-pages";
      version = "9.6.1";
      addonId = "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4011167/traduzir_paginas_web-9.6.1.xpi";
      sha256 = "3cc0c107f68b3c483c7f2cf1a9d6b734fcbee2762911e0531c3ee9afd64359c1";
      meta = with lib;
      {
        description = "Translate your page in real time using Google or Yandex.\nIt is not necessary to open new tabs.\nNow works with the NoScript Extension.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "transparent-standalone-image" = buildFirefoxXpiAddon {
      pname = "transparent-standalone-image";
      version = "2.1";
      addonId = "jid0-ezUl0hF1SPM9hLO5BMBkNoblB8s@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/738931/transparent_standalone_image-2.1.xpi";
      sha256 = "f56bc840d5ac96d1697feed57e7ab0928ff2c47232e236d00560efc2f3bf57b5";
      meta = with lib;
      {
        description = "This add-on renders standalone images on a transparent background, so you can see the image in all its glory!";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "tree-style-tab" = buildFirefoxXpiAddon {
      pname = "tree-style-tab";
      version = "3.9.15";
      addonId = "treestyletab@piro.sakura.ne.jp";
      url = "https://addons.mozilla.org/firefox/downloads/file/4088468/tree_style_tab-3.9.15.xpi";
      sha256 = "7c993bae2d43488615f1a3b7459a2c35730a486b3855049709c636a84751d252";
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
        platforms = platforms.all;
        };
      };
    "tridactyl" = buildFirefoxXpiAddon {
      pname = "tridactyl";
      version = "1.23.0";
      addonId = "tridactyl.vim@cmcaine.co.uk";
      url = "https://addons.mozilla.org/firefox/downloads/file/4036604/tridactyl_vim-1.23.0.xpi";
      sha256 = "08b7af97bef05300ab3ac3ad721322ff00505631233482568fc4489c16d51b71";
      meta = with lib;
      {
        homepage = "https://tridactyl.xyz";
        description = "Vim, but in your browser. Replace Firefox's control mechanism with one modelled on Vim.\n\nThis addon is very usable, but is in an early stage of development. We intend to implement the majority of Vimperator's features.";
        license = licenses.asl20;
        platforms = platforms.all;
        };
      };
    "tst-tab-search" = buildFirefoxXpiAddon {
      pname = "tst-tab-search";
      version = "0.0.6";
      addonId = "@tst-search";
      url = "https://addons.mozilla.org/firefox/downloads/file/4009035/tst_search-0.0.6.xpi";
      sha256 = "1c4ebfaadb2af712684acc96d12da69e86d4bcff9db84c97c20d3576722a4981";
      meta = with lib;
      {
        homepage = "https://github.com/NiklasGollenstede/tst-search#readme";
        description = "Search for or filter the Tabs in TST's sidebar, and quickly find and activate them.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "ublacklist" = buildFirefoxXpiAddon {
      pname = "ublacklist";
      version = "8.3.0";
      addonId = "@ublacklist";
      url = "https://addons.mozilla.org/firefox/downloads/file/4095141/ublacklist-8.3.0.xpi";
      sha256 = "98413c704d08334ba196a7f085e6a666b60865f6897c7fc41c308097d1f12a5f";
      meta = with lib;
      {
        homepage = "https://iorate.github.io/ublacklist/";
        description = "Blocks sites you specify from appearing in Google search results";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "ublock-origin" = buildFirefoxXpiAddon {
      pname = "ublock-origin";
      version = "1.48.4";
      addonId = "uBlock0@raymondhill.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4092158/ublock_origin-1.48.4.xpi";
      sha256 = "d7666b963c2969b0014937aae55472eea5098ff21ed3bea8a2e1f595f62856c1";
      meta = with lib;
      {
        homepage = "https://github.com/gorhill/uBlock#ublock-origin";
        description = "Finally, an efficient wide-spectrum content blocker. Easy on CPU and memory.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "ubo-scope" = buildFirefoxXpiAddon {
      pname = "ubo-scope";
      version = "0.1.12";
      addonId = "uBO-Scope@raymondhill.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/982889/ubo_scope-0.1.12.xpi";
      sha256 = "00946c772704fc10e2bdd5ebbf5b91fd51bac19c40fbb4e43d751648fa171ef5";
      meta = with lib;
      {
        homepage = "https://github.com/gorhill/uBO-Scope";
        description = "A tool to measure your 3rd-party exposure score for web sites you visit.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "ukrainian-dictionary" = buildFirefoxXpiAddon {
      pname = "ukrainian-dictionary";
      version = "6.1.0";
      addonId = "uk-ua@dictionaries.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4088837/ukrainian_dictionary-6.1.0.xpi";
      sha256 = "90a57caef9f656812c03d6fd365c251cbcab722405d51313f931f12976e18a1b";
      meta = with lib;
      {
        homepage = "https://github.com/brown-uk/dict_uk";
        description = "Ukrainian (uk-UA) spellchecking dictionary";
        license = licenses.mpl11;
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
        platforms = platforms.all;
        };
      };
    "user-agent-string-switcher" = buildFirefoxXpiAddon {
      pname = "user-agent-string-switcher";
      version = "0.4.9";
      addonId = "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4047133/user_agent_string_switcher-0.4.9.xpi";
      sha256 = "617ab726419f6c1addedc727ad41dca18f52fbde34af59ed7d42425f139129d1";
      meta = with lib;
      {
        homepage = "http://add0n.com/useragent-switcher.html";
        description = "Spoof websites trying to gather information about your web navigation—like your browser type and operating system—to deliver distinct content you may not want.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "video-downloadhelper" = buildFirefoxXpiAddon {
      pname = "video-downloadhelper";
      version = "7.6.6";
      addonId = "{b9db16a4-6edc-47ec-a1f4-b86292ed211d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4040817/video_downloadhelper-7.6.6.xpi";
      sha256 = "460b64348a6616c87bdead85f6226a6f22decfc5b33458d9577777b762438c8a";
      meta = with lib;
      {
        homepage = "http://www.downloadhelper.net/";
        description = "The easy way to download and convert Web videos from hundreds of YouTube-like sites.";
        license = {
          shortName = "vdh";
          fullName = "Custom License for Video DownloadHelper";
          url = "https://addons.mozilla.org/en-US/firefox/addon/video-downloadhelper/license/";
          free = false;
          };
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
        platforms = platforms.all;
        };
      };
    "view-image" = buildFirefoxXpiAddon {
      pname = "view-image";
      version = "3.6.5";
      addonId = "{287dcf75-bec6-4eec-b4f6-71948a2eea29}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3962917/view_image-3.6.5.xpi";
      sha256 = "45c8c7b12b53756dfb2a8579e72bd0ba4e22f0e9defe13fd4dfe7832255650e5";
      meta = with lib;
      {
        homepage = "https://github.com/bijij/ViewImage";
        description = "Re-implements the google image, \"View Image\" and \"Search by Image\" buttons.";
        license = licenses.mit;
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
        platforms = platforms.all;
        };
      };
    "vimium" = buildFirefoxXpiAddon {
      pname = "vimium";
      version = "1.67.6";
      addonId = "{d7742d87-e61d-4b78-b8a1-b469842139fa}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4046008/vimium_ff-1.67.6.xpi";
      sha256 = "e8d6c98842bd7221d62d1079e4153e3e0d20c5ca5412316dd71cb5c3bdb7d457";
      meta = with lib;
      {
        homepage = "https://github.com/philc/vimium";
        description = "The Hacker's Browser. Vimium provides keyboard shortcuts for navigation and control in the spirit of Vim.This is a port of the popular Chrome extension to Firefox.Most stuff works, but the port to Firefox remains a work in progress.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "vimium-c" = buildFirefoxXpiAddon {
      pname = "vimium-c";
      version = "1.99.99";
      addonId = "vimium-c@gdh1995.cn";
      url = "https://addons.mozilla.org/firefox/downloads/file/4098265/vimium_c-1.99.99.xpi";
      sha256 = "d133091be65e0854a60e8c997852657dc23a68c3288e21f4b10e75c82c021d37";
      meta = with lib;
      {
        homepage = "https://github.com/gdh1995/vimium-c";
        description = "A keyboard shortcut tool for keyboard-based page navigation and browser tab operations with an advanced omnibar and global shortcuts";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "violentmonkey" = buildFirefoxXpiAddon {
      pname = "violentmonkey";
      version = "2.14.0";
      addonId = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4076005/violentmonkey-2.14.0.xpi";
      sha256 = "6c25cfb7d464c22ea4c560e5271a0cacd49b8fe0c404420fb5b4fd2c78880b2d";
      meta = with lib;
      {
        homepage = "https://violentmonkey.github.io/";
        description = "Violentmonkey provides userscripts support for browsers.\nIt's open source! <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/c8bcebd9a0e76f20c888274e94578ab5957439e46d59a046ff9e1a9ef55c282c/https%3A//github.com/violentmonkey/violentmonkey\" rel=\"nofollow\">https://github.com/violentmonkey/violentmonkey</a>";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "vue-js-devtools" = buildFirefoxXpiAddon {
      pname = "vue-js-devtools";
      version = "6.5.0";
      addonId = "{5caff8cc-3d2e-4110-a88a-003cc85b3858}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4059290/vue_js_devtools-6.5.0.xpi";
      sha256 = "eb45cf5cf3044de7d9da45c7827547146c6ffc7a48f771bf1c413419f4de6ee8";
      meta = with lib;
      {
        homepage = "https://devtools.vuejs.org";
        description = "DevTools extension for debugging Vue.js applications.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "w2g" = buildFirefoxXpiAddon {
      pname = "w2g";
      version = "8.6";
      addonId = "{6ea0a676-b3ef-48aa-b23d-24c8876945fb}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4012364/w2g-8.6.xpi";
      sha256 = "166b67e6e742ee1982b9cf5a740821869f7808314b09dde82ae76d0d9b395112";
      meta = with lib;
      {
        homepage = "https://w2g.tv";
        description = "The official Watch2Gether Firefox extension allows you to share content from a supported site (Youtube, Vimeo, ...) directly into a Watch2Gether room. The new W2gSync feature allows you to sync-watch videos from any website on Watch2Gether.";
        license = {
          shortName = "w2g.tv";
          fullName = "Watch2Gether Terms of Use";
          url = "https://community.w2g.tv/t/terms-of-use-english/597/1";
          free = false;
          };
        platforms = platforms.all;
        };
      };
    "wallabagger" = buildFirefoxXpiAddon {
      pname = "wallabagger";
      version = "1.15.0";
      addonId = "{7a7b1d36-d7a4-481b-92c6-9f5427cb9eb1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4055568/wallabagger-1.15.0.xpi";
      sha256 = "d6980b65daa5ca746a7b6a9b7ef5f5c228ae99ca2d9e3c1c06041fd43489fc6f";
      meta = with lib;
      {
        homepage = "https://github.com/wallabag/wallabagger";
        description = "This wallabag v2 extension has the ability to edit title and tags and set starred, archived, or delete states.\nYou can add a page from the icon or through the right click menu on a link or on a blank page spot.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "wappalyzer" = buildFirefoxXpiAddon {
      pname = "wappalyzer";
      version = "6.10.62";
      addonId = "wappalyzer@crunchlabz.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4095500/wappalyzer-6.10.62.xpi";
      sha256 = "1434950437497dbcd91d7bd781e15a3eb3336bf956217dae4fd5a438b04a67fc";
      meta = with lib;
      {
        homepage = "https://www.wappalyzer.com";
        description = "Identify technologies on websites";
        license = licenses.gpl3;
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
        platforms = platforms.all;
        };
      };
    "web-scrobbler" = buildFirefoxXpiAddon {
      pname = "web-scrobbler";
      version = "2.89.0";
      addonId = "{799c0914-748b-41df-a25c-22d008f9e83f}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4089909/web_scrobbler-2.89.0.xpi";
      sha256 = "298a96681644686b40c118a2a5c579e3860f47c9690ded1fe059b75e28e4b65e";
      meta = with lib;
      {
        homepage = "https://web-scrobbler.com";
        description = "Scrobble music all around the web!";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "windscribe" = buildFirefoxXpiAddon {
      pname = "windscribe";
      version = "3.4.8";
      addonId = "@windscribeff";
      url = "https://addons.mozilla.org/firefox/downloads/file/4046960/windscribe-3.4.8.xpi";
      sha256 = "6f06485cb24257afe532df29c268bc08c68bf466f105049eeb0902e2e0a7741e";
      meta = with lib;
      {
        homepage = "https://windscribe.com";
        description = "Windscribe helps you circumvent censorship, block ads, beacons and trackers on websites you use every day.";
        license = licenses.gpl3;
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
        platforms = platforms.all;
        };
      };
    "youchoose-ai" = buildFirefoxXpiAddon {
      pname = "youchoose-ai";
      version = "2.7.0";
      addonId = "{bc9bb30a-c6a3-4404-b116-574f1208e70b}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4030054/youchoose_ai-2.7.0.xpi";
      sha256 = "39d425686f271c25b6746daed89fc2cbd7c0c7e292504d663feae34a95212c68";
      meta = with lib;
      {
        homepage = "https://youchoose.ai";
        description = "Gain control back on your content recommendations on YouTube. See recommendations provided by content creators. Analyze YouTube's algorithm, and help us expose shadow-banning.\nA free-software, built by a non-profit defending your digital rights!";
        license = licenses.lgpl3;
        platforms = platforms.all;
        };
      };
    "youtube-recommended-videos" = buildFirefoxXpiAddon {
      pname = "youtube-recommended-videos";
      version = "1.6.2";
      addonId = "myallychou@gmail.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4050795/youtube_recommended_videos-1.6.2.xpi";
      sha256 = "c4cba094d6acb196fd5aa8df10683a59eba1300091b98a90a2bfa25f574476c1";
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
        platforms = platforms.all;
        };
      };
    "youtube-shorts-block" = buildFirefoxXpiAddon {
      pname = "youtube-shorts-block";
      version = "1.3.4";
      addonId = "{34daeb50-c2d2-4f14-886a-7160b24d66a4}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4027038/youtube_shorts_block-1.3.4.xpi";
      sha256 = "8c2500bffd27d13c066afb705f795b2c6fbf54ae49fa5efa64ccdeb7455c3052";
      meta = with lib;
      {
        description = "Play the Youtube shorts video as if it were a normal video.\nand hide \"shorts\"tab and videos (optional).";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "zoom-page-we" = buildFirefoxXpiAddon {
      pname = "zoom-page-we";
      version = "19.12";
      addonId = "zoompage-we@DW-dev";
      url = "https://addons.mozilla.org/firefox/downloads/file/4079247/zoom_page_we-19.12.xpi";
      sha256 = "4938a3117c5d150d23a79458d26c42cf89183ce9219b2b7721b2554337609690";
      meta = with lib;
      {
        description = "Zoom web pages (either per-site or per-tab) using full-page zoom, text-only zoom and minimum font size. Fit-to-width zooming can be applied to pages automatically. Fit-to-window scaling  can be applied to small images.";
        license = licenses.gpl2;
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
        description = "Zoom Redirector transparently redirects any meeting links to use Zoom's browser based web client.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    }
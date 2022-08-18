{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
  {
    "a11ycss" = buildFirefoxXpiAddon {
      pname = "a11ycss";
      version = "1.2.1";
      addonId = "a11y.css@ffoodd";
      url = "https://addons.mozilla.org/firefox/downloads/file/3889115/a11ycss-1.2.1.xpi";
      sha256 = "db0dbda6eaffac5a3df7e72c6062981bf5107f8e2ec5fbbf26f868659991d8a4";
      meta = with lib;
      {
        homepage = "https://ffoodd.github.io/a11y.css/";
        description = "a11y.css provides warnings about possible risks and mistakes that exist in HTML code through a style sheet. This extension also provides several accessibility-related utilities.\n\nsee <a href=\"https://outgoing.prod.mozaws.net/v1/4c643171ccddfcfa3712d45a2b7b615f54195eb4507868ab6ef3fbf6694dc4c2/https%3A//github.com/ffoodd/a11y.css/tree/webextension\" rel=\"nofollow\">https://github.com/ffoodd/a11y.css/tree/webextension</a> for  details";
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
      version = "3.13.1";
      addonId = "adnauseam@rednoise.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3953369/adnauseam-3.13.1.xpi";
      sha256 = "bdf16fa70f1217c7611c0458024cb5a380c07ac4053be3a03f4bda723d991ebb";
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
    "anonaddy" = buildFirefoxXpiAddon {
      pname = "anonaddy";
      version = "2.1.3";
      addonId = "browser-extension@anonaddy";
      url = "https://addons.mozilla.org/firefox/downloads/file/3990409/anonaddy-2.1.3.xpi";
      sha256 = "6a311098d968a964289e9c4e27882d2fe141a90fa745469f95d82d9f364e1dfe";
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
      version = "2.3.2";
      addonId = "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3943117/augmented_steam-2.3.2.xpi";
      sha256 = "400a0935f9b5ea58cc0f596eeaf396e9aeb12e6764c534649eb1635ccfaf988f";
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
      version = "0.5.0";
      addonId = "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3889015/auto_tab_discard-0.5.0.xpi";
      sha256 = "c67145babb671dadccfb983b781f4c4dbf1f2f51ae80e4efeafed6aaa02bc72d";
      meta = with lib;
      {
        homepage = "http://add0n.com/tab-discard.html";
        description = "Increase browser speed and reduce memory load and when you have numerous open tabs.";
        license = licenses.mpl20;
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
      version = "4.8.6";
      addonId = "BetterTweetDeck@erambert.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/3933944/better_tweetdeck_17-4.8.6.xpi";
      sha256 = "661a9a84041f15a1ab91c794118a269f398e3df1c8db854b15ef7fb84961b3df";
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
      version = "7.4.35";
      addonId = "firefox@betterttv.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/3984942/betterttv-7.4.35.xpi";
      sha256 = "c3475bf8ac2f6e5d799dad6b49c097fd04eace87a82471ee9224b4a194d64fe3";
      meta = with lib;
      {
        homepage = "https://betterttv.com";
        description = "Enhances Twitch with new features, emotes, and more.";
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
      version = "2.7.0";
      addonId = "beyond20@kakaroto.homelinux.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/3964482/beyond_20-2.7.0.xpi";
      sha256 = "87b0e02a010a734b4491230019612dd6950233048a34abd0fcd47a519ab5b20f";
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
      version = "2022.8.0";
      addonId = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3986147/bitwarden_password_manager-2022.8.0.xpi";
      sha256 = "208fba348f86fde8bd6663e0ed0540a993d74c4a35d71bf899c106bbcd555400";
      meta = with lib;
      {
        homepage = "https://bitwarden.com";
        description = "A secure and free password manager for all of your devices.";
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
        description = "Browserpass is a browser extension for Firefox and Chrome to retrieve login details from zx2c4's pass (<a href=\"https://outgoing.prod.mozaws.net/v1/fcd8dcb23434c51a78197a1c25d3e2277aa1bc764c827b4b4726ec5a5657eb64/http%3A//passwordstore.org\" rel=\"nofollow\">passwordstore.org</a>) straight from your browser. Tags: passwordstore, password store, password manager, passwordmanager, gpg";
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
      version = "1.3.1";
      addonId = "{e58d3966-3d76-4cd9-8552-1582fbc800c1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3861819/buster_captcha_solver-1.3.1.xpi";
      sha256 = "e64f8c043c34325e60b7050b616ebef2df4dc35d15602961ccfabd0a9a0e637a";
      meta = with lib;
      {
        homepage = "https://github.com/dessant/buster";
        description = "Save time by asking Buster to solve captchas for you.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "bypass-paywalls-clean" = buildFirefoxXpiAddon {
      pname = "bypass-paywalls-clean";
      version = "2.8.0.0";
      addonId = "{d133e097-46d9-4ecc-9903-fa6a722a6e0e}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3988821/bypass_paywalls_clean-2.8.0.0.xpi";
      sha256 = "7cc23898d449db059655c1fe3c65b873904a67cea236f14fcd1ef9c7ca963d36";
      meta = with lib;
      {
        homepage = "https://gitlab.com/magnolia1234/bypass-paywalls-firefox-clean";
        description = "Bypass Paywalls of (custom) news sites";
        license = licenses.mit;
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
    "clearurls" = buildFirefoxXpiAddon {
      pname = "clearurls";
      version = "1.25.0";
      addonId = "{74145f27-f039-47ce-a470-a662b129930a}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3980848/clearurls-1.25.0.xpi";
      sha256 = "96bf83092830a34427ae4f105dce0422c306d9d95669c0c93f4e55804993435c";
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
      version = "1.0.8";
      addonId = "gdpr@cavi.au.dk";
      url = "https://addons.mozilla.org/firefox/downloads/file/3970126/consent_o_matic-1.0.8.xpi";
      sha256 = "0a75ccf41f2cb22b3897fb9170efe1b1886fef3a77f84b6c2ed6f172f819edbe";
      meta = with lib;
      {
        homepage = "https://consentomatic.au.dk/";
        description = "Automatic handling of GDPR consent forms";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "cookie-autodelete" = buildFirefoxXpiAddon {
      pname = "cookie-autodelete";
      version = "3.8.1";
      addonId = "CookieAutoDelete@kennydo.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3971429/cookie_autodelete-3.8.1.xpi";
      sha256 = "443d4b0749b69202809597dfbb5580c046dd739c6666c4c6a5c1dc6efe1a4294";
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
      version = "0.3";
      addonId = "{12cf650b-1822-40aa-bff0-996df6948878}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3847514/cookies_txt-0.3.xpi";
      sha256 = "4929e9162b925366f3630a149f5d879f9eb41b6587708fa3957390f327743135";
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
        description = "Makes the scrollbars on TweetDeck and other sites dark in Firefox. This should be done by the site itself, not by an addon :(\n\nImage based on Scroll by Juan Pablo Bravo, CL <a href=\"https://outgoing.prod.mozaws.net/v1/f9c83bffbd0bf3bfa6ea46deecfa4fa4e9d5a69f49f323c020877e0bf283efac/https%3A//thenounproject.com/term/scroll/18607/\" rel=\"nofollow\">https://thenounproject.com/term/scroll/18607/</a>";
        license = licenses.lgpl3;
        platforms = platforms.all;
        };
      };
    "darkreader" = buildFirefoxXpiAddon {
      pname = "darkreader";
      version = "4.9.56";
      addonId = "addon@darkreader.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3990001/darkreader-4.9.56.xpi";
      sha256 = "3610535118e039d463a4e215682ef011befd6e1d30891d28904533cab00b6ae6";
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
    "duckduckgo-privacy-essentials" = buildFirefoxXpiAddon {
      pname = "duckduckgo-privacy-essentials";
      version = "2022.8.9";
      addonId = "jid1-ZAdIEUB7XOzOJw@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3987636/duckduckgo_for_firefox-2022.8.9.xpi";
      sha256 = "313b8afb43b8f5444453252c8ea334c85b6d2f0bc2270bde5506c88ef818a64b";
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
        description = "This extension adds <a href=\"https://outgoing.prod.mozaws.net/v1/c7a1fe7e1838aaf8fcdb3e88c6700a42c275a31c5fdea179157c9751846df4bf/http%3A//Ecosia.org\" rel=\"nofollow\">Ecosia.org</a> as the default search engine to your browser — it’s completely free!";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "enhancer-for-youtube" = buildFirefoxXpiAddon {
      pname = "enhancer-for-youtube";
      version = "2.0.115";
      addonId = "enhancerforyoutube@maximerf.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3964540/enhancer_for_youtube-2.0.115.xpi";
      sha256 = "a0728584ad2b36b10aec9e857fec477cbcd84f90e52a60771eb77f8f98e3b1d7";
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
      version = "2.3.2";
      addonId = "@contain-facebook";
      url = "https://addons.mozilla.org/firefox/downloads/file/3923300/facebook_container-2.3.2.xpi";
      sha256 = "a1851f15ae4ec790c40f9a751ad6d64a44a6bf47f70ee497ef4ee17115bb7e06";
      meta = with lib;
      {
        homepage = "https://github.com/mozilla/contain-facebook";
        description = "Prevent Facebook from tracking you around the web. The Facebook Container extension for Firefox helps you take control and isolate your web activity from Facebook.";
        license = licenses.mpl20;
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
        description = "Tries to play links in mpv.\n\nPress the toolbar button to play the current URL in mpv. Otherwise, right click on a URL and use the context  item to play an arbitrary URL.\n\nYou'll need the native client here: <a rel=\"nofollow\" href=\"https://outgoing.prod.mozaws.net/v1/aadcd34348f892e0805a94f141a1124d9c4aa75199eb4cb7c4ff530417617f77/http%3A//github.com/woodruffw/ff2mpv\">github.com/woodruffw/ff2mpv</a>";
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
      version = "1.1.4buildid20220803.111909";
      addonId = "firefox-translations-addon@mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3984258/firefox_translations-1.1.4buildid20220803.111909.xpi";
      sha256 = "cd2cec8c83eaa60cd5bea490bd66de9393a0ea1c8a38cfbc82594b6161dcc00a";
      meta = with lib;
      {
        homepage = "https://browser.mt";
        description = "Translate websites in your browser without using the cloud.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "firenvim" = buildFirefoxXpiAddon {
      pname = "firenvim";
      version = "0.2.13";
      addonId = "firenvim@lacamb.re";
      url = "https://addons.mozilla.org/firefox/downloads/file/3976212/firenvim-0.2.13.xpi";
      sha256 = "572b08118340bcb3788221a9c4e7b299b88c74d702921f4d775c65ab61dd7e10";
      meta = with lib;
      {
        description = "Turn Firefox into a Neovim client.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "flagfox" = buildFirefoxXpiAddon {
      pname = "flagfox";
      version = "6.1.53";
      addonId = "{1018e4d6-728f-4b20-ad56-37578a4de76b}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3982666/flagfox-6.1.53.xpi";
      sha256 = "57d4eaadb4648100d777949b32a8a16bb7f7816b9e5112d8766a14bbcb0672e0";
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
      version = "4.17.0";
      addonId = "floccus@handmadeideas.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3985748/floccus-4.17.0.xpi";
      sha256 = "f343343fcd4a5e00351ce2221bd1af581d7a3e2243e4404e2ad34651b5df482b";
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
      version = "104.0buildid20220816.115024";
      addonId = "langpack-fr@firefox.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3989850/francais_language_pack-104.0buildid20220816.115024.xpi";
      sha256 = "402b6860204b4bc9b4c352beebc7dc12b32844e128ac46dbca7bed9d1246937b";
      meta = with lib;
      {
        description = "Français Language Pack";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "gesturefy" = buildFirefoxXpiAddon {
      pname = "gesturefy";
      version = "3.2.5";
      addonId = "{506e023c-7f2b-40a3-8066-bc5deb40aebe}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3934429/gesturefy-3.2.5.xpi";
      sha256 = "3a15d627e12dd735b0a76c42247613cadf915bd3b7c3fec39239c64a1652e0db";
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
      version = "8.7.6";
      addonId = "firefox@ghostery.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3974763/ghostery-8.7.6.xpi";
      sha256 = "aae4aa7251bbb0464927324f8d09bce9f5a60a5f5be0ad593295e5f027067db1";
      meta = with lib;
      {
        homepage = "http://www.ghostery.com/";
        description = "Ghostery is a powerful privacy extension. \n\nBlock ads, stop trackers and speed up websites.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "ghosttext" = buildFirefoxXpiAddon {
      pname = "ghosttext";
      version = "22.7.22";
      addonId = "ghosttext@bfred.it";
      url = "https://addons.mozilla.org/firefox/downloads/file/3986563/ghosttext-22.7.22.xpi";
      sha256 = "cd2062a9e2076519288398ebad601a3e41cf15e947636861d6ddfbe72033a620";
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
      version = "1.15";
      addonId = "{dbcc42f9-c979-4f53-8a95-a102fbff3bbe}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3950347/gitpod-1.15.xpi";
      sha256 = "19b3fe5ccdd6a692a7fe5ca7c7270d3b10c5d51db5349203d291f06e1f5daf6c";
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
    "gnome-shell-integration" = buildFirefoxXpiAddon {
      pname = "gnome-shell-integration";
      version = "11.1";
      addonId = "chrome-gnome-shell@gnome.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3974897/gnome_shell_integration-11.1.xpi";
      sha256 = "dff05cff4e53254c03a91d047e776f77aeb1d069540aecd5e48209fae2a44c3b";
      meta = with lib;
      {
        homepage = "https://wiki.gnome.org/Projects/GnomeShellIntegrationForChrome";
        description = "This extension provides integration with GNOME Shell and the corresponding extensions repository <a href=\"https://outgoing.prod.mozaws.net/v1/b16ff805576d83628b80265636b483e6f56c58d6e812e04045626ff602eff739/https%3A//extensions.gnome.org\" rel=\"nofollow\">https://extensions.gnome.org</a>";
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
        description = "Chrome extension that visually merges the same event on multiple Google Calendars into one event.\n\nSource: <a rel=\"nofollow\" href=\"https://outgoing.prod.mozaws.net/v1/342b7a3d66f39d16cdbc5cd1d4cc26f85aeb1f94cae54867035888d93d484554/https%3A//github.com/imightbeamy/gcal-multical-event-merge\">https://github.com/imightbeamy/gcal-multical-event-merge</a>";
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
        description = "Gopass Bridge allows searching and inserting login credentials from the gopass password manager ( <a rel=\"nofollow\" href=\"https://outgoing.prod.mozaws.net/v1/fa484fa7cde64c1be04f689a80902fdf34bfe274b8675213f619c3a13e6606ab/https%3A//www.gopass.pw/\">https://www.gopass.pw/</a> ).";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "grammarly" = buildFirefoxXpiAddon {
      pname = "grammarly";
      version = "8.901.0";
      addonId = "87677a2c52b84ad3a151a4a72f5bd3c4@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3978044/grammarly_1-8.901.0.xpi";
      sha256 = "439ab1f52f2f1709ccf73fb504c4d6bcb3e3cf9a4b4463c2c7d147fd753a94cd";
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
        homepage = "http://team.firefoxcn.net";
        description = "Manage browser's requests, include modify the request headers and response headers, redirect requests, cancel requests";
        license = licenses.gpl2;
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
    "https-everywhere" = buildFirefoxXpiAddon {
      pname = "https-everywhere";
      version = "2021.7.13";
      addonId = "https-everywhere@eff.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3809748/https_everywhere-2021.7.13.xpi";
      sha256 = "e261461b5d4d3621285fce70773558184d691c614b330744dab672f032db731c";
      meta = with lib;
      {
        homepage = "https://www.eff.org/https-everywhere";
        description = "Encrypt the web! HTTPS Everywhere is a Firefox extension to protect your communications by enabling HTTPS encryption automatically on sites that are known to support it, even when you type URLs or follow links that omit the https: prefix.";
        license = {
          shortName = "https-everywhere-license";
          fullName = "Multiple";
          url = "https://addons.mozilla.org/en-US/firefox/addon/https-everywhere/license/";
          free = true;
          };
        platforms = platforms.all;
        };
      };
    "i-dont-care-about-cookies" = buildFirefoxXpiAddon {
      pname = "i-dont-care-about-cookies";
      version = "3.4.2";
      addonId = "jid1-KKzOGWgsW3Ao4Q@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3988152/i_dont_care_about_cookies-3.4.2.xpi";
      sha256 = "bee737e7ecdac55be8d7ee49ba75ce475054c8e5c370d51671ade960363d3039";
      meta = with lib;
      {
        homepage = "https://www.i-dont-care-about-cookies.eu/";
        description = "Get rid of cookie warnings from almost all websites!";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "ipfs-companion" = buildFirefoxXpiAddon {
      pname = "ipfs-companion";
      version = "2.19.1";
      addonId = "ipfs-firefox-addon@lidel.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3804013/ipfs_companion-2.19.1.xpi";
      sha256 = "6abe23deb1fdf9e0634aa8bd0c8115b03631affc67e2a88b47590b389dca2017";
      meta = with lib;
      {
        homepage = "https://github.com/ipfs-shipyard/ipfs-companion";
        description = "Harness the power of IPFS in your browser";
        license = licenses.cc0;
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
      version = "1.8.1";
      addonId = "keepassxc-browser@keepassxc.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3974246/keepassxc_browser-1.8.1.xpi";
      sha256 = "5c1459e29b86b5f8e0a379d3b969e1e6e188ebb4d52071f368588ae97b797568";
      meta = with lib;
      {
        homepage = "https://keepassxc.org/";
        description = "Official browser plugin for the KeePassXC password manager (<a rel=\"nofollow\" href=\"https://outgoing.prod.mozaws.net/v1/aebde84f385b73661158862b419dd43b46ac4c22bea71d8f812030e93d0e52d5/https%3A//keepassxc.org\">https://keepassxc.org</a>).";
        license = licenses.gpl3;
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
        description = "Firefox theme inspired by <a href=\"https://outgoing.prod.mozaws.net/v1/276dc50c9e2710aa17b441df1ee87a9f5f023f5ded676ddd689d8f998d92713a/https%3A//www.nordtheme.com/\" rel=\"nofollow\">https://www.nordtheme.com/</a>";
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
      version = "5.4.3";
      addonId = "languagetool-webextension@languagetool.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3985810/languagetool-5.4.3.xpi";
      sha256 = "0a5fd00fd7a6fdd0e18479783596b553b18fc06507ff54ebba425d6d0f25f76e";
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
      version = "4.101.0.2";
      addonId = "support@lastpass.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3984651/lastpass_password_manager-4.101.0.2.xpi";
      sha256 = "44294c1cb711a5d566a17de6087e4825755e81944735e6f182de4cf9d63e8cfc";
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
      version = "1.5.1";
      addonId = "leechblockng@proginosko.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3988385/leechblock_ng-1.5.1.xpi";
      sha256 = "6b733e6b9cd42c994e7e12a90b013d9a8376aa823b8914d78c656cb682141f06";
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
      version = "9.6.6";
      addonId = "contact@lesspass.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3899836/lesspass-9.6.6.xpi";
      sha256 = "5f419c4a2aa20f9e30a7111e90537c99aba3683b715ebfe5b09743ad373cd52f";
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
      version = "2.2.1";
      addonId = "7esoorv3@alefvanoon.anonaddy.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/3965151/libredirect-2.2.1.xpi";
      sha256 = "568591d3f7e48fd986815c5bc4a43ba40ca8788b68301686368a6f0918a14cb7";
      meta = with lib;
      {
        homepage = "https://libredirect.github.io/";
        description = "Redirects YouTube, Twitter, Instagram... requests to alternative privacy friendly frontends and backends.";
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
      version = "2.6.32";
      addonId = "{b86e4813-687a-43e6-ab65-0bde4ab75758}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3985626/localcdn_fork_of_decentraleyes-2.6.32.xpi";
      sha256 = "20f260078ecdf6148a927bd2d22de651a324dca8b7e6019b4b268476db067b10";
      meta = with lib;
      {
        homepage = "https://www.localcdn.org";
        description = "Emulates remote frameworks (e.g. jQuery, Bootstrap, AngularJS) and delivers them as local resource. Prevents unnecessary 3rd party requests to Google, StackPath, MaxCDN and more. Prepared rules for uBlock Origin/uMatrix.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "mailvelope" = buildFirefoxXpiAddon {
      pname = "mailvelope";
      version = "4.6.0";
      addonId = "jid1-AQqSMBYb0a8ADg@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3965080/mailvelope-4.6.0.xpi";
      sha256 = "f332e8a407f342f6144c7689e8f192fc94171ae2b896cec8bd0654f147ad4287";
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
      version = "3.1.0";
      addonId = "{1c5e4c6f-5530-49a3-b216-31ce7d744db0}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3911043/markdownload-3.1.0.xpi";
      sha256 = "90162919e1517eb7b4fd75eade3573011550a9c6d081e23a606ec0bdfeadb2ab";
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
    "metamask" = buildFirefoxXpiAddon {
      pname = "metamask";
      version = "10.18.3";
      addonId = "webextension@metamask.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/3987382/ether_metamask-10.18.3.xpi";
      sha256 = "4d2e3bd8a4cc35b6368965791be500e460a133112c882a22a5a6fa9c6ce68782";
      meta = with lib;
      {
        description = "Ethereum Browser Extension";
        platforms = platforms.all;
        };
      };
    "momentumdash" = buildFirefoxXpiAddon {
      pname = "momentumdash";
      version = "2.6.25";
      addonId = "momentum@momentumdash.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3986826/momentumdash-2.6.25.xpi";
      sha256 = "433dd7acd10ce1732328223dbc377700bcc0fea09b5b2476f34f65e741780090";
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
      version = "8.0.7";
      addonId = "@testpilot-containers";
      url = "https://addons.mozilla.org/firefox/downloads/file/3932862/multi_account_containers-8.0.7.xpi";
      sha256 = "0e60e00c13dcc372b43ddb2e5428c2e3c1e79d2b23d7166df82d45245edc4f10";
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
        description = "download sheet music from <a href=\"https://outgoing.prod.mozaws.net/v1/c0273e141ab141ea0a7256437045917b687d145c317a25868e70a5d8ccb864ea/http%3A//musescore.com\" rel=\"nofollow\">musescore.com</a> for free, no login or Musescore Pro required | 免登录、免 Musescore Pro，免费下载 <a href=\"https://outgoing.prod.mozaws.net/v1/c0273e141ab141ea0a7256437045917b687d145c317a25868e70a5d8ccb864ea/http%3A//musescore.com\" rel=\"nofollow\">musescore.com</a> 上的曲谱";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "netflix-1080p" = buildFirefoxXpiAddon {
      pname = "netflix-1080p";
      version = "1.17.0";
      addonId = "{f18f0257-10ad-4ff7-b51e-6895edeccfc8}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3939434/netflix_1080p_firefox-1.17.0.xpi";
      sha256 = "bd3fdc7516f096ddf0fb4abf59cc5ab3a6c89630975b67a5f49b203dcc07c4d2";
      meta = with lib;
      {
        homepage = "https://github.com/TheGoddessInari/netflix-1080p-firefox";
        description = "Forces 1080p playback for Netflix in Firefox. Originated with truedread/netflix-1080p-firefox, basic functionality has been rewritten.";
        license = licenses.mit;
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
      version = "2.2.2";
      addonId = "@news-feed-eradicator";
      url = "https://addons.mozilla.org/firefox/downloads/file/3981935/news_feed_eradicator-2.2.2.xpi";
      sha256 = "72066af596767ce4087e0f6afc7ca370f28f5d7a3bb3f3a46bef5ae3f02a8d6a";
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
      version = "11.4.9";
      addonId = "{73a6fe31-595d-460b-a920-fcc0f8843232}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3988352/noscript-11.4.9.xpi";
      sha256 = "47a740f90258de755b709168c4985d9fc6721ff7f32f9cfc4c7094316cc5f960";
      meta = with lib;
      {
        homepage = "https://noscript.net";
        description = "The best security you can get in a web browser! Allow potentially malicious web content to run only from sites you trust. Protect yourself against XSS other web security exploits.";
        license = licenses.gpl2;
        platforms = platforms.all;
        };
      };
    "octolinker" = buildFirefoxXpiAddon {
      pname = "octolinker";
      version = "6.10.4";
      addonId = "octolinker@stefanbuck.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3976430/octolinker-6.10.4.xpi";
      sha256 = "140327b54f7a7afef4de8ffe2a741c1a48eb2b8413deabb99d14497b3e594227";
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
      version = "7.6.0";
      addonId = "jid1-Om7eJGwA1U8Akg@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3986528/octotree-7.6.0.xpi";
      sha256 = "e93da6d90d93c4a1500f78703ce40fdf1e705a50577c00cd450f4b07bb502d1c";
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
      version = "6.10.0";
      addonId = "plugin@okta.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3956279/okta_browser_plugin-6.10.0.xpi";
      sha256 = "7b76c0f1117e97f018d202715e5892bf41d94b51c610031450af2cd37c508638";
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
      version = "1.6.0";
      addonId = "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3864522/old_reddit_redirect-1.6.0.xpi";
      sha256 = "591420f13d2fed7802d71ab95a645ba0813741ee963428c4a548472a2efe48c2";
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
      version = "2.3.7";
      addonId = "{d634138d-c276-4fc8-924b-40a0ea21d284}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3972472/1password_x_password_manager-2.3.7.xpi";
      sha256 = "9aaee3215d05faa802d83c5a355405d1ba8659f502aacd32aa44c036d2d6d354";
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
        description = "A helper for capturing things via org-protocol in emacs: First, set up: <a rel=\"nofollow\" href=\"https://outgoing.prod.mozaws.net/v1/04ad17418f8d35ee0f3edf4599aed951b2a5ef88d4bc7e0e3237f6d86135e4fb/http%3A//orgmode.org/worg/org-contrib/org-protocol.html\">http://orgmode.org/worg/org-contrib/org-protocol.html</a> or <a rel=\"nofollow\" href=\"https://outgoing.prod.mozaws.net/v1/fb401af8127ccf82bc948b0a7af0543eec48d58100c0c46404f81aabeda442e6/https%3A//github.com/sprig/org-capture-extension\">https://github.com/sprig/org-capture-extension</a>\n\nSee <a rel=\"nofollow\" href=\"https://outgoing.prod.mozaws.net/v1/6aad51cc4e2f9476f9fff344e6554eade08347181aed05f8b61cda05073daecb/https%3A//youtu.be/zKDHto-4wsU\">https://youtu.be/zKDHto-4wsU</a> for example usage";
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
        description = "<a href=\"https://outgoing.prod.mozaws.net/v1/adc81a532e2c6239668fcd0691327d16fe545090b6e7073ccfdbaa2a69eda0c2/http%3A//Privacy.com\" rel=\"nofollow\">Privacy.com</a>'s Firefox add-on allows you to generate a new virtual card number with 1-click on any checkout page. Keep your payment info safe from data breaches, shady merchants, and sneaky subscription billing.";
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
        description = "Unofficial Firefox add-on for <a href=\"https://outgoing.prod.mozaws.net/v1/9195797232dc4f996eff7bc68a67ac5b906f828efd0d0ebded52b3b4ef47556d/http%3A//Pinboard.in\" rel=\"nofollow\">Pinboard.in</a>. Bookmark web pages &amp; add notes easily. Keyboard command: Alt + p";
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
        description = "Adds a Select All button to <a href=\"https://outgoing.prod.mozaws.net/v1/00c9d03cfa8d351fa7e6b5809ce9940b861a97f394a8cedefcee710f58cfb0c5/https%3A//getpocket.com\" rel=\"nofollow\">https://getpocket.com</a>.\n\n**WARNING**: Some people have complained about this extension being automatically installed or similar. If this happens, or you installed it from anywhere but <a href=\"http://addons.mozilla.org\" rel=\"nofollow\">addons.mozilla.org</a>, please remove it.";
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
      version = "0.44.1";
      addonId = "{7e3ce1f0-15fb-4fb1-99c6-25774749ec6d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3958783/polkadot_js_extension-0.44.1.xpi";
      sha256 = "3ddaa83ab2b91f9bd7f35f52b7ae8163c2748ce6bd8e71714991e4eb1ef353b4";
      meta = with lib;
      {
        homepage = "https://github.com/polkadot-js/extension";
        description = "Manage your Polkadot accounts outside of dapps. Injects the accounts and allows signs transactions for a specific account.";
        platforms = platforms.all;
        };
      };
    "privacy-badger" = buildFirefoxXpiAddon {
      pname = "privacy-badger";
      version = "2021.11.23.1";
      addonId = "jid1-MnnxcxisBPnSXQ@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3872283/privacy_badger17-2021.11.23.1.xpi";
      sha256 = "50274cd280413bd0e7c4b53d2ef3d019f6a3ce14a7396fed6d248f295ae7f63e";
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
      version = "3.0.3";
      addonId = "{48748554-4c01-49e8-94af-79662bf34d50}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3962152/privacy_pass-3.0.3.xpi";
      sha256 = "41fbbd038b3fb9b18edf41f8b10c9726ea3108753e3906112ab222afdccb9884";
      meta = with lib;
      {
        homepage = "https://privacypass.github.io";
        description = "Client support for Privacy Pass anonymous authorization protocol.";
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
      version = "2.4.5";
      addonId = "private-relay@firefox.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3978299/private_relay-2.4.5.xpi";
      sha256 = "fd21090f5ea7d5642b65d9c1feba5176a7bc74bb0ed5b7153062c7e6460a155c";
      meta = with lib;
      {
        homepage = "https://relay.firefox.com/";
        description = "Firefox Relay lets you generate email aliases that forward to your real inbox. Use it to hide your real email address and protect yourself from hackers and unwanted mail.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "promnesia" = buildFirefoxXpiAddon {
      pname = "promnesia";
      version = "1.1.2";
      addonId = "{07c6b8e1-94f7-4bbf-8e91-26c0a8992ab5}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3953419/promnesia-1.1.2.xpi";
      sha256 = "342a1025aa3a282c9dc088fe2b5225d316208d996f2164c81831f7efaed7058d";
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
        description = "Shows ratings from <a href=\"https://outgoing.prod.mozaws.net/v1/f8db0358d96c1a46b9a77aa02190de811e40819051b1d42dd013c17276046ffd/http%3A//protondb.com\" rel=\"nofollow\">protondb.com</a> on Steam";
        license = licenses.lgpl3;
        platforms = platforms.all;
        };
      };
    "pywalfox" = buildFirefoxXpiAddon {
      pname = "pywalfox";
      version = "2.0.8";
      addonId = "pywalfox@frewacom.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3942967/pywalfox-2.0.8.xpi";
      sha256 = "9527552b0a80b4ca02d0622ab9e4364fbd880d843958eed04cfd0bad814516c0";
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
      version = "2.1.1";
      addonId = "jid1-7eplFgLu6atoog@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/976325/rabattcorner-2.1.1.xpi";
      sha256 = "c6d51f11f0dfea6e4253eb161f8f769ee25e1e47d2ea2ce88f0b464805e7c5ed";
      meta = with lib;
      {
        homepage = "https://www.rabattcorner.ch";
        description = "Jetzt bei jedem Online Einkauf bis zu 25% Cashback erhalten. <a href=\"https://outgoing.prod.mozaws.net/v1/be8bb3eaeaba31de0d5f89ccc266fa9cf18fda0fabad24266491f7c9342df151/http%3A//Rabattcorner.ch\" rel=\"nofollow\">Rabattcorner.ch</a> zahlt dir nach jedem Einkauf in einem der über 350 angeschlossenen Online Shops einen Teil deines Einkaufsbetrags zurück.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "react-devtools" = buildFirefoxXpiAddon {
      pname = "react-devtools";
      version = "4.25.0";
      addonId = "@react-devtools";
      url = "https://addons.mozilla.org/firefox/downloads/file/3975827/react_devtools-4.25.0.xpi";
      sha256 = "8547cb5044edc99c6408722913649102ec48e56a18eec73848325e02992155a3";
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
        description = "A more elegant solution for collapsing reddit comment trees.\n\nReddit Comment Collapser is free and open source. Contributions welcome - <a href=\"https://outgoing.prod.mozaws.net/v1/782747fdec02dc86f6a710b2169056074fd7d1c2e56583eddf9168d2be14e7a0/https%3A//github.com/tom-james-watson/reddit-comment-collapser\" rel=\"nofollow\">https://github.com/tom-james-watson/reddit-comment-collapser</a>";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "reddit-enhancement-suite" = buildFirefoxXpiAddon {
      pname = "reddit-enhancement-suite";
      version = "5.22.10";
      addonId = "jid1-xUfzOsOFlzSOXg@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3902655/reddit_enhancement_suite-5.22.10.xpi";
      sha256 = "749ecad7db8a9411ab72ea7f5f40b468a084128f2e6ba9446fc1745a2b734045";
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
      version = "5.6.5";
      addonId = "yes@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3934998/reddit_moderator_toolbox-5.6.5.xpi";
      sha256 = "51e83fb1f426d2363545ab71e2a21d71a0316fa8e1b004da5e3a16df6b1d64ac";
      meta = with lib;
      {
        homepage = "https://www.reddit.com/r/toolbox";
        description = "This is bundled extension of the /r/toolbox moderator tools for <a rel=\"nofollow\" href=\"https://outgoing.prod.mozaws.net/v1/42268797a19a16a2ebeeda77cca1eda5a48db14e0cff56de4fab35eaef484216/http%3A//reddit.com\">reddit.com</a>\n\nContaining:\n\nMod Tools Enhanced\nMod Button\nMod Mail Pro\nMod Domain Tagger\nToolbox Notifier\nMod User Notes\nToolbox Config";
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
      version = "3.0.11";
      addonId = "extension@redux.devtools";
      url = "https://addons.mozilla.org/firefox/downloads/file/3932897/reduxdevtools-3.0.11.xpi";
      sha256 = "97b2d14543a2f42c02948c05eef8d6dda24eba6eca559fd967e2638adc2da352";
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
      version = "22.8.8";
      addonId = "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3986172/refined_github-22.8.8.xpi";
      sha256 = "1936a380d825565baa5f99717706a31c159919bbc57c8506fafce9d8261cd793";
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
      version = "3.0.0.5";
      addonId = "{762f9885-5a13-4abd-9c77-433dcd38b8fd}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3985341/return_youtube_dislikes-3.0.0.5.xpi";
      sha256 = "92119081c594065e7d55c4cb3f5f7a2a35738e02cd012d44c0bc9cb9406f6503";
      meta = with lib;
      {
        description = "Returns ability to see dislike statistics on youtube";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "rust-search-extension" = buildFirefoxXpiAddon {
      pname = "rust-search-extension";
      version = "1.8.1";
      addonId = "{04188724-64d3-497b-a4fd-7caffe6eab29}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3990385/rust_search_extension-1.8.1.xpi";
      sha256 = "a09895131b0e1fde06dbcc6f5596160b1511f070152022ca1ada36fd64c1e8d9";
      meta = with lib;
      {
        homepage = "https://rust.extension.sh";
        description = "The ultimate search extension for Rust\n\nSearch std docs, crates, builtin attributes, official books, and error codes, etc in your address bar instantly.\n<a href=\"https://outgoing.prod.mozaws.net/v1/4af48e3229ba03b454fb9b352a7e5a4c038e1bcc6721bf744b781a5e96b9e798/https%3A//rust.extension.sh\" rel=\"nofollow\">https://rust.extension.sh</a>";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "save-page-we" = buildFirefoxXpiAddon {
      pname = "save-page-we";
      version = "27.5";
      addonId = "savepage-we@DW-dev";
      url = "https://addons.mozilla.org/firefox/downloads/file/3956141/save_page_we-27.5.xpi";
      sha256 = "0dd8b93fb05e4676d5cfd83fd9d7bd456c42d9e4b20f6732203aa9aa83cd2392";
      meta = with lib;
      {
        description = "Save a complete web page (as currently displayed) as a single HTML file that can be opened in any browser. Save a single page, multiple selected pages or a list of page URLs. Automate saving from command line.";
        license = licenses.gpl2;
        platforms = platforms.all;
        };
      };
    "search-by-image" = buildFirefoxXpiAddon {
      pname = "search-by-image";
      version = "5.2.0";
      addonId = "{2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3988785/search_by_image-5.2.0.xpi";
      sha256 = "340cb228a9ef2f9506e314f3b372c4041b8fd459d5c6534019e1d546d3ed582f";
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
      version = "3.2.2";
      addonId = "{65a2d764-7358-455b-930d-5afa86fb5ed0}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3827755/search_engines_helper-3.2.2.xpi";
      sha256 = "2ed0dd789cd2b6530e5ba7a6eb095f7fdb3e9518e1df2ae6d855699c60bff9ac";
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
      version = "4.10.1";
      addonId = "{3c078156-979c-498b-8990-85f7987dd929}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3939103/sidebery-4.10.1.xpi";
      sha256 = "ee2c96dff631b4d4dd110f826bfb2c0edde8ea3272a56ace491e9b9f651de42d";
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
      version = "4.7.2.1";
      addonId = "simple-tab-groups@drive4ik";
      url = "https://addons.mozilla.org/firefox/downloads/file/3873608/simple_tab_groups-4.7.2.1.xpi";
      sha256 = "75077589098ca62c00b86cf9554c6120bf8dc04c5f916fe26f84915f5147b2a4";
      meta = with lib;
      {
        homepage = "https://github.com/drive4ik/simple-tab-groups";
        description = "Create, modify, and quickly change tab groups";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "single-file" = buildFirefoxXpiAddon {
      pname = "single-file";
      version = "1.21.20";
      addonId = "{531906d3-e22f-4a6c-a102-8057b88a1a63}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3981860/single_file-1.21.20.xpi";
      sha256 = "4bfd7d02527a2175ca3007fa0df812327d413d68f6ae3ce4f30806e5447b1792";
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
      version = "0.6.1";
      addonId = "{b11bea1f-a888-4332-8d8a-cec2be7d24b9}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3979765/torproject_snowflake-0.6.1.xpi";
      sha256 = "b54630c7a124821cfe24f80110b23b294ef0b92bf18799623a991b47e65e210f";
      meta = with lib;
      {
        homepage = "https://snowflake.torproject.org/";
        description = "Snowflake is a WebRTC pluggable transport for Tor.\n\nEnabling this extension turns your browser into a proxy that connects Tor users in censored regions to the Tor network.";
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
        description = "Uh-oh!   Looks like somebody left Firefox out in the sun.\n\nCredit to Ethan Schoonover for the color scheme.\n\n<a href=\"https://outgoing.prod.mozaws.net/v1/84fc2a9889cf35b10644adef8f36c2af5f4beaf19955759761bceb2d20cfd051/http%3A//ethanschoonover.com/solarized\" rel=\"nofollow\">http://ethanschoonover.com/solarized</a>";
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
      version = "22.7.29.851";
      addonId = "sourcegraph-for-firefox@sourcegraph.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3981990/sourcegraph_for_firefox-22.7.29.851.xpi";
      sha256 = "83141fd1b755b57c76de7bc2ec3ee16080abe5aa66671c1add13909118aa5942";
      meta = with lib;
      {
        description = "Adds code intelligence to GitHub, GitLab, Bitbucket Server, and Phabricator: hovers, definitions, references. Supports 20+ languages.";
        platforms = platforms.all;
        };
      };
    "sponsorblock" = buildFirefoxXpiAddon {
      pname = "sponsorblock";
      version = "4.7.1";
      addonId = "sponsorBlocker@ajay.app";
      url = "https://addons.mozilla.org/firefox/downloads/file/3978884/sponsorblock-4.7.1.xpi";
      sha256 = "00f5cbb335d6f40e019f28a8bc00499dc5f1bb9ac6ceb64c128af3a6a0aa0015";
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
    "steam-database" = buildFirefoxXpiAddon {
      pname = "steam-database";
      version = "3.3.0";
      addonId = "firefox-extension@steamdb.info";
      url = "https://addons.mozilla.org/firefox/downloads/file/3954188/steam_database-3.3.0.xpi";
      sha256 = "3c4b0d14d6696791f0dd9c39c55d70b320f6e24eb97c3ef3150b16e225c94cba";
      meta = with lib;
      {
        homepage = "https://steamdb.info/";
        description = "Adds SteamDB links and new features on the Steam store and community. View lowest game prices and stats.";
        license = licenses.bsd3;
        platforms = platforms.all;
        };
      };
    "stylus" = buildFirefoxXpiAddon {
      pname = "stylus";
      version = "1.5.25";
      addonId = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3956290/styl_us-1.5.25.xpi";
      sha256 = "64a872e97eb7ab4b571c4408ea3f2b69c09b5a2bf7a4c54387d31bd360a31277";
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
      version = "1.0.6";
      addonId = "{a8332c60-5b6d-41ee-bfc8-e9bb331d34ad}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3943498/surfingkeys_ff-1.0.6.xpi";
      sha256 = "73085800f37ec23bd03ab7df4daba9fc4a69476f6a5f6b8c993969b58a3090a4";
      meta = with lib;
      {
        homepage = "https://github.com/brookhong/Surfingkeys";
        description = "Rich shortcuts for you to click links / switch tabs / scroll pages or DIVs / capture full page or DIV etc, let you use the browser like vim, plus an embed vim editor.\n\n<a href=\"https://outgoing.prod.mozaws.net/v1/353ad9268cb5cdeb3fa107ea4d154273229fe2ffe8a28e3fda510de7f6ddd75f/https%3A//github.com/brookhong/Surfingkeys\" rel=\"nofollow\">https://github.com/brookhong/Surfingkeys</a>";
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
    "tab-session-manager" = buildFirefoxXpiAddon {
      pname = "tab-session-manager";
      version = "6.12.0";
      addonId = "Tab-Session-Manager@sienori";
      url = "https://addons.mozilla.org/firefox/downloads/file/3944769/tab_session_manager-6.12.0.xpi";
      sha256 = "91daf01ed2f58117ef03b09e24bae388563c329fe87006a2a9bd3d2382b043bf";
      meta = with lib;
      {
        homepage = "https://tab-session-manager.sienori.com/";
        description = "Save and restore the state of windows and tabs. It also supports automatic saving and cloud sync.";
        license = licenses.mpl20;
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
      version = "4.17.6161";
      addonId = "firefox@tampermonkey.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/3947043/tampermonkey-4.17.6161.xpi";
      sha256 = "2f4c3e7a7f9709fef78969b9c0519e426b70725078406bd089312b81d834c58c";
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
        description = "“I have read and agree to the Terms” is the biggest lie on the web. We aim to fix that. Get informed instantly about websites' terms &amp; privacy policies, with ratings and summaries from the <a href=\"https://outgoing.prod.mozaws.net/v1/782d4bf373fdb0bc94e6bd037af1bf988ce2274e2210205e7e5b8bbd291b0997/http%3A//www.tosdr.org\" rel=\"nofollow\">www.tosdr.org</a> initiative.";
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
        description = "<a href=\"https://outgoing.prod.mozaws.net/v1/ba1182cc6e56316a3cb1a60385b04ef4843dca5caf9bb4a82a5ba5b0556aeee8/https%3A//paypal.me/christosbouronikos\" rel=\"nofollow\">https://paypal.me/christosbouronikos</a>";
        platforms = platforms.all;
        };
      };
    "to-deepl" = buildFirefoxXpiAddon {
      pname = "to-deepl";
      version = "0.6.0";
      addonId = "{db420ff1-427a-4cda-b5e7-7d395b9f16e1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3988276/to_deepl-0.6.0.xpi";
      sha256 = "79cfce1b7da7607bd1e93d4f7d75dc34d269589fee18101db6005d8fd52e6cf3";
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
    "translate-web-pages" = buildFirefoxXpiAddon {
      pname = "translate-web-pages";
      version = "9.5.4";
      addonId = "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3984229/traduzir_paginas_web-9.5.4.xpi";
      sha256 = "bcdf8c18338da42910b672f9c6889c1f967e25ef74cbee60064051878d568e2d";
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
      version = "3.8.26";
      addonId = "treestyletab@piro.sakura.ne.jp";
      url = "https://addons.mozilla.org/firefox/downloads/file/3975864/tree_style_tab-3.8.26.xpi";
      sha256 = "fad45a87897df26613c89403f8dc0eb22eea55faeb98119810e8c1856114e4c1";
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
      version = "1.22.1";
      addonId = "tridactyl.vim@cmcaine.co.uk";
      url = "https://addons.mozilla.org/firefox/downloads/file/3926466/tridactyl_vim-1.22.1.xpi";
      sha256 = "ed0337dd67516142d1f02a77cab910c7cb95ca575ec1ee4b1f5cf8971918b0f6";
      meta = with lib;
      {
        homepage = "https://github.com/cmcaine/tridactyl";
        description = "Vim, but in your browser. Replace Firefox's control mechanism with one modelled on Vim.\n\nThis addon is very usable, but is in an early stage of development. We intend to implement the majority of Vimperator's features.";
        license = licenses.asl20;
        platforms = platforms.all;
        };
      };
    "tst-tab-search" = buildFirefoxXpiAddon {
      pname = "tst-tab-search";
      version = "0.0.5";
      addonId = "@tst-search";
      url = "https://addons.mozilla.org/firefox/downloads/file/3982203/tst_search-0.0.5.xpi";
      sha256 = "767614427624c41a63946c7e0eb10d8e0237f65a3e5cd8a5e28f03f9ed3acebd";
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
      version = "8.0.1";
      addonId = "@ublacklist";
      url = "https://addons.mozilla.org/firefox/downloads/file/3989794/ublacklist-8.0.1.xpi";
      sha256 = "05c143b14f02ec64aef7dfadd2ef2224efaf3f080cc0787a96d59dda9bef238b";
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
      version = "1.44.0";
      addonId = "uBlock0@raymondhill.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/3989793/ublock_origin-1.44.0.xpi";
      sha256 = "ae761fe4014e328fdef838b81d43c30c84422cb8140cceedf0ed7a7c1f8e70aa";
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
      version = "5.8.0";
      addonId = "uk-ua@dictionaries.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3964213/ukrainian_dictionary-5.8.0.xpi";
      sha256 = "ce91785c8aaff4efb0dc66eccaed66e1fd6786b8d5139e07c8ea6b71e8a1536c";
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
      version = "0.4.8";
      addonId = "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3952467/user_agent_string_switcher-0.4.8.xpi";
      sha256 = "723a1846f165544b82a97e69000f25ffbe9de312f0a932c1f6c35e54240a03ee";
      meta = with lib;
      {
        homepage = "http://add0n.com/useragent-switcher.html";
        description = "Spoof websites trying to gather information about your web navigation—like your browser type and operating system—to deliver distinct content you may not want.";
        license = licenses.mpl20;
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
      version = "1.67.1";
      addonId = "{d7742d87-e61d-4b78-b8a1-b469842139fa}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3898202/vimium_ff-1.67.1.xpi";
      sha256 = "12740802748e7abff8f13014c845db182b5266f280e2f9e22fae0af82789fe6d";
      meta = with lib;
      {
        homepage = "https://github.com/philc/vimium";
        description = "The Hacker's Browser. Vimium provides keyboard shortcuts for navigation and control in the spirit of Vim.\n\nThis is a port of the popular Chrome extension to Firefox.\n\nMost stuff works, but the port to Firefox remains a work in progress.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "violentmonkey" = buildFirefoxXpiAddon {
      pname = "violentmonkey";
      version = "2.13.0";
      addonId = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3770708/violentmonkey-2.13.0.xpi";
      sha256 = "c2b17f2fbad676304f8b3791602edd388a9df68c585168d04221c2851ff6346a";
      meta = with lib;
      {
        homepage = "https://violentmonkey.github.io/";
        description = "Violentmonkey provides userscripts support for browsers.\nIt's open source! <a rel=\"nofollow\" href=\"https://outgoing.prod.mozaws.net/v1/c8bcebd9a0e76f20c888274e94578ab5957439e46d59a046ff9e1a9ef55c282c/https%3A//github.com/violentmonkey/violentmonkey\">https://github.com/violentmonkey/violentmonkey</a>";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "vue-js-devtools" = buildFirefoxXpiAddon {
      pname = "vue-js-devtools";
      version = "6.2.1";
      addonId = "{5caff8cc-3d2e-4110-a88a-003cc85b3858}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3975216/vue_js_devtools-6.2.1.xpi";
      sha256 = "bd8f661ea22e9a26f59ce4f1373fb5885ab702bcc4279c72fc8ce55f4b07a391";
      meta = with lib;
      {
        homepage = "https://devtools.vuejs.org";
        description = "DevTools extension for debugging Vue.js applications.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "wallabagger" = buildFirefoxXpiAddon {
      pname = "wallabagger";
      version = "1.14.0";
      addonId = "{7a7b1d36-d7a4-481b-92c6-9f5427cb9eb1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3923281/wallabagger-1.14.0.xpi";
      sha256 = "0cf005740093b42fd1a129fc3430e21ddcce9699e611c18aab641547a02d0b90";
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
      version = "6.10.38";
      addonId = "wappalyzer@crunchlabz.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3978438/wappalyzer-6.10.38.xpi";
      sha256 = "10b118eda1d8863d8cb979b80b7979545281bc2fbd67247f9b70879a8838cb57";
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
      version = "3.1";
      addonId = "wayback_machine@mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3936135/wayback_machine_new-3.1.xpi";
      sha256 = "69df7d023f7afb477f6ac9b5572a31adacf6b6f6c9148ce272911cfd69189cdb";
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
      version = "2.67.1";
      addonId = "{799c0914-748b-41df-a25c-22d008f9e83f}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3988579/web_scrobbler-2.67.1.xpi";
      sha256 = "89b53dcf08e9fa4d14c866f7cf192c9089258e127041ec3cbebbc0eeaeff3232";
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
      version = "3.4.4";
      addonId = "@windscribeff";
      url = "https://addons.mozilla.org/firefox/downloads/file/3969665/windscribe-3.4.4.xpi";
      sha256 = "60a689617a3394891bc345f40b5f6923193bfcab8830ae80e83bc6757921c85f";
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
    "zoom-page-we" = buildFirefoxXpiAddon {
      pname = "zoom-page-we";
      version = "19.7";
      addonId = "zoompage-we@DW-dev";
      url = "https://addons.mozilla.org/firefox/downloads/file/3954805/zoom_page_we-19.7.xpi";
      sha256 = "d4ccd2333c73ac679f12430d97d82a3aa314a263907d3f372c8debd334e07b1c";
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
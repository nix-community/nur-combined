{ buildFirefoxXpiAddon, fetchurl, stdenv }:
  {
    "1password-x-password-manager" = buildFirefoxXpiAddon {
      pname = "1password-x-password-manager";
      version = "1.23.0";
      addonId = "{d634138d-c276-4fc8-924b-40a0ea21d284}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3715456/1password_x_password_manager-1.23.0-fx.xpi";
      sha256 = "4b92f66768168ae58f7439cf51232512465fff79c770820b165b64cd90130a4c";
      meta = with stdenv.lib;
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
    "adsum-notabs" = buildFirefoxXpiAddon {
      pname = "adsum-notabs";
      version = "1.1";
      addonId = "{c9f848fb-3fb6-4390-9fc1-e4dd4d1c5122}";
      url = "https://addons.mozilla.org/firefox/downloads/file/883289/no_tabs-1.1-an+fx-linux.xpi";
      sha256 = "48e846a60b217c13ee693ac8bfe23a8bdef2ec073f5f713cce0e08814f280354";
      meta = with stdenv.lib;
      {
        homepage = "https://gitlab.com/adsum/firefox-notabs";
        description = "Disable tabs completely, by always opening a new window instead.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "anchors-reveal" = buildFirefoxXpiAddon {
      pname = "anchors-reveal";
      version = "1.1";
      addonId = "jid1-XX0TcCGBa7GVGw@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/1690998/anchors_reveal-1.1-fx.xpi";
      sha256 = "0412acabe742f7e78ff77aa95c4196150c240592a1bbbad75012b39a05352c36";
      meta = with stdenv.lib;
      {
        homepage = "http://dascritch.net/post/2014/06/24/Sniffeur-d-ancre";
        description = "Reveal the anchors in a webpage";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "auto-tab-discard" = buildFirefoxXpiAddon {
      pname = "auto-tab-discard";
      version = "0.3.7";
      addonId = "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3610821/auto_tab_discard-0.3.7-an+fx.xpi";
      sha256 = "8d1d145d4063f14022576f91789d9cbb48fd9c1874c335a7b0c858ae9d404f6f";
      meta = with stdenv.lib;
      {
        homepage = "http://add0n.com/tab-discard.html";
        description = "Increase browser speed and reduce memory load and when you have numerous open tabs.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "betterttv" = buildFirefoxXpiAddon {
      pname = "betterttv";
      version = "7.2.91";
      addonId = "firefox@betterttv.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/3696386/betterttv-7.2.91-fx.xpi";
      sha256 = "6f9b0c1fb8a1da106d9a0acc63e730e4f6d1a34e16acd8fd1f828db5710a74e9";
      meta = with stdenv.lib;
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
    "bitwarden" = buildFirefoxXpiAddon {
      pname = "bitwarden";
      version = "1.48.1";
      addonId = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3714988/bitwarden_free_password_manager-1.48.1-an+fx.xpi";
      sha256 = "27088233b72c36f8636ae88e79d7e52a0b4480d7fc73ed6412233a2f95408256";
      meta = with stdenv.lib;
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
      url = "https://addons.mozilla.org/firefox/downloads/file/3711209/browserpass-3.7.2-fx.xpi";
      sha256 = "b1781405b46f3274697885b53139264dca2ab56ffc4435c093102ad5ebc59297";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/browserpass/browserpass-extension";
        description = "Browserpass is a browser extension for Firefox and Chrome to retrieve login details from zx2c4's pass (<a href=\"https://outgoing.prod.mozaws.net/v1/fcd8dcb23434c51a78197a1c25d3e2277aa1bc764c827b4b4726ec5a5657eb64/http%3A//passwordstore.org\" rel=\"nofollow\">passwordstore.org</a>) straight from your browser. Tags: passwordstore, password store, password manager, passwordmanager, gpg";
        license = licenses.isc;
        platforms = platforms.all;
        };
      };
    "buster-captcha-solver" = buildFirefoxXpiAddon {
      pname = "buster-captcha-solver";
      version = "1.1.0";
      addonId = "{e58d3966-3d76-4cd9-8552-1582fbc800c1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3659047/buster_captcha_solver_for_humans-1.1.0-an+fx.xpi";
      sha256 = "80b2f7c211862f4bd4e18df3cf1af3d0b4d31de6d7d5c387dfad79eb37feddba";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/dessant/buster";
        description = "Save time by asking Buster to solve captchas for you.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "canvasblocker" = buildFirefoxXpiAddon {
      pname = "canvasblocker";
      version = "1.5";
      addonId = "CanvasBlocker@kkapsner.de";
      url = "https://addons.mozilla.org/firefox/downloads/file/3711139/canvasblocker-1.5-an+fx.xpi";
      sha256 = "1ec7cfcf8567a2b70a8405980f0143316c560539688e9f43e8069f069bae5d51";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/kkapsner/CanvasBlocker/";
        description = "Alters some JS APIs to prevent fingerprinting.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "clearurls" = buildFirefoxXpiAddon {
      pname = "clearurls";
      version = "1.20.0";
      addonId = "{74145f27-f039-47ce-a470-a662b129930a}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3682334/clearurls-1.20.0-an+fx.xpi";
      sha256 = "2d4bdd6c702999f2d76c97cbd6a0bb80cbdef4665c3c104b38824e9dc0616df2";
      meta = with stdenv.lib;
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
      url = "https://addons.mozilla.org/firefox/downloads/file/589832/close_other_windows-0.1-an+fx-linux.xpi";
      sha256 = "6c189fb4d396f835bf8f0f09c9f1e9ae5dc7cde471b776d8c7d12592a373d3d3";
      meta = with stdenv.lib;
      {
        description = "Adds a button to close all tabs in other windows which are not pinned";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "cookie-autodelete" = buildFirefoxXpiAddon {
      pname = "cookie-autodelete";
      version = "3.6.0";
      addonId = "CookieAutoDelete@kennydo.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3711829/cookie_autodelete-3.6.0-an+fx.xpi";
      sha256 = "f83646d42f476c86384164fd4868fa9c5b7452491f1f37d4e219c3fb3c421def";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/Cookie-AutoDelete/Cookie-AutoDelete";
        description = "Control your cookies! This WebExtension is inspired by Self Destructing Cookies. When a tab closes, any cookies not being used are automatically deleted. Whitelist the ones you trust while deleting the rest. Support for Container Tabs.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "dark-night-mode" = buildFirefoxXpiAddon {
      pname = "dark-night-mode";
      version = "2.0.2";
      addonId = "{27c3c9d8-95cd-44e6-ae9c-ff537348b9f3}";
      url = "https://addons.mozilla.org/firefox/downloads/file/932525/dark_night_mode-2.0.2-an+fx.xpi";
      sha256 = "8ee966c8bda37c5b2d9cb08d8801eedcfc5ba39959f78bb57d84bc0ab489bfbd";
      meta = with stdenv.lib;
      {
        homepage = "https://darknightmode.com";
        description = "It is a universal night mode for the entire Internet. It uses a special algorithm to automatically change the colors of the websites you visit into dark mode so that you can browse without straining your eyes, especially at night.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "dark-scroll-for-tweetdeck" = buildFirefoxXpiAddon {
      pname = "dark-scroll-for-tweetdeck";
      version = "2.0.0";
      addonId = "{759d3eb8-baf1-49e0-938b-0f963fdac3ae}";
      url = "https://addons.mozilla.org/firefox/downloads/file/1754743/dark_scroll_for_tweetdeck-2.0.0-fx.xpi";
      sha256 = "e0f4e625eda09e9c8300ef650373d5a582a8c77c18eba572aa39d0bd8e3eb596";
      meta = with stdenv.lib;
      {
        description = "Makes the scrollbars on TweetDeck and other sites dark in Firefox. This should be done by the site itself, not by an addon :(\n\nImage based on Scroll by Juan Pablo Bravo, CL <a href=\"https://outgoing.prod.mozaws.net/v1/f9c83bffbd0bf3bfa6ea46deecfa4fa4e9d5a69f49f323c020877e0bf283efac/https%3A//thenounproject.com/term/scroll/18607/\" rel=\"nofollow\">https://thenounproject.com/term/scroll/18607/</a>";
        license = licenses.lgpl3;
        platforms = platforms.all;
        };
      };
    "darkreader" = buildFirefoxXpiAddon {
      pname = "darkreader";
      version = "4.9.27";
      addonId = "addon@darkreader.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3712931/dark_reader-4.9.27-an+fx.xpi";
      sha256 = "3388ad0c1e91e9fcb5103df1286bb5df0caf192aaf2a85a34acb046ca96b78a1";
      meta = with stdenv.lib;
      {
        homepage = "https://darkreader.org/";
        description = "Dark mode for every website. Take care of your eyes, use dark theme for night and daily browsing.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "decentraleyes" = buildFirefoxXpiAddon {
      pname = "decentraleyes";
      version = "2.0.15";
      addonId = "jid1-BoFifL9Vbdl2zQ@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3672658/decentraleyes-2.0.15-an+fx.xpi";
      sha256 = "2554069168458cc1351e5d37ee995de044e514ec72369829ff0bcbf31d586ddf";
      meta = with stdenv.lib;
      {
        homepage = "https://decentraleyes.org";
        description = "Protects you against tracking through \"free\", centralized, content delivery. It prevents a lot of requests from reaching networks like Google Hosted Libraries, and serves local files to keep sites from breaking. Complements regular content blockers.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "disconnect" = buildFirefoxXpiAddon {
      pname = "disconnect";
      version = "20.3.1.1";
      addonId = "2.0@disconnect.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/3655554/disconnect-20.3.1.1-fx.xpi";
      sha256 = "f1e98b4b1189975753c5c806234de70cbd7f09ae3925ab65ef834da5915ac64d";
      meta = with stdenv.lib;
      {
        homepage = "https://disconnect.me/";
        description = "Make the web faster, more private, and more secure.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "duckduckgo-privacy-essentials" = buildFirefoxXpiAddon {
      pname = "duckduckgo-privacy-essentials";
      version = "2021.1.8";
      addonId = "jid1-ZAdIEUB7XOzOJw@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3705801/duckduckgo_privacy_essentials-2021.1.8-an+fx.xpi";
      sha256 = "963633dc361669f0e6aee6944368c4bcbcbcad018d6802fb278e3679836b5b44";
      meta = with stdenv.lib;
      {
        homepage = "https://duckduckgo.com/app";
        description = "Privacy, simplified. Our add-on provides the privacy essentials you need to seamlessly take control of your personal information, no matter where the internet takes you: tracker blocking, smarter encryption, DuckDuckGo private search, and more.";
        license = licenses.asl20;
        platforms = platforms.all;
        };
      };
    "ecosia" = buildFirefoxXpiAddon {
      pname = "ecosia";
      version = "4.0.4";
      addonId = "{d04b0b40-3dab-4f0b-97a6-04ec3eddbfb0}";
      url = "https://addons.mozilla.org/firefox/downloads/file/964413/ecosia_the_search_engine_that_plants_trees-4.0.4-an+fx.xpi";
      sha256 = "b74bdbd58766df623bc044e265d8880da2872c37007a5c6e954560aaf130d90b";
      meta = with stdenv.lib;
      {
        homepage = "http://www.ecosia.org";
        description = "Ecosia is a search engine that uses 80% of its profits from ad revenue to plant trees. By searching with Ecosia you can help the environment for free. This extension adds <a href=\"https://outgoing.prod.mozaws.net/v1/c7a1fe7e1838aaf8fcdb3e88c6700a42c275a31c5fdea179157c9751846df4bf/http%3A//Ecosia.org\" rel=\"nofollow\">Ecosia.org</a> as the default search engine to your Firefox browser. Give it a try!";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "facebook-container" = buildFirefoxXpiAddon {
      pname = "facebook-container";
      version = "2.1.2";
      addonId = "@contain-facebook";
      url = "https://addons.mozilla.org/firefox/downloads/file/3650887/facebook_container-2.1.2-fx.xpi";
      sha256 = "86c75e90ae6f3f59999406c34229f05d563e024e293dfcabcfea10c75ce76cf7";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/mozilla/contain-facebook";
        description = "Prevent Facebook from tracking you around the web. The Facebook Container extension for Firefox helps you take control and isolate your web activity from Facebook.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "firefox-color" = buildFirefoxXpiAddon {
      pname = "firefox-color";
      version = "2.1.7";
      addonId = "FirefoxColor@mozilla.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3643624/firefox_color-2.1.7-fx.xpi";
      sha256 = "b7fb07b6788f7233dd6223e780e189b4c7b956c25c40493c28d7020493249292";
      meta = with stdenv.lib;
      {
        homepage = "https://color.firefox.com";
        description = "Build, save and share beautiful Firefox themes.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "floccus" = buildFirefoxXpiAddon {
      pname = "floccus";
      version = "4.4.10";
      addonId = "floccus@handmadeideas.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3718398/floccus-4.4.10-fx.xpi";
      sha256 = "e88d8ffed51f09fcfce9a18a2293e2589f517877a080b9cfe3d68da66842dbff";
      meta = with stdenv.lib;
      {
        homepage = "https://floccus.org";
        description = "Sync your bookmarks across browsers via Nextcloud, WebDAV or a local file (and thus any file sync solution)";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "foxyproxy-standard" = buildFirefoxXpiAddon {
      pname = "foxyproxy-standard";
      version = "7.5.1";
      addonId = "foxyproxy@eric.h.jung";
      url = "https://addons.mozilla.org/firefox/downloads/file/3616824/foxyproxy_standard-7.5.1-an+fx.xpi";
      sha256 = "42109bc250e20aafd841183d09c7336008ab49574b5e8aa9206991bb306c3a65";
      meta = with stdenv.lib;
      {
        homepage = "https://getfoxyproxy.org";
        description = "FoxyProxy is an advanced proxy management tool that completely replaces Firefox's limited proxying capabilities. For a simpler tool and less advanced configuration options, please use FoxyProxy Basic.";
        license = licenses.gpl2;
        platforms = platforms.all;
        };
      };
    "fraidycat" = buildFirefoxXpiAddon {
      pname = "fraidycat";
      version = "1.1.7";
      addonId = "{94060031-effe-4b93-89b4-9cd570217a8d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3648097/fraidycat-1.1.7-fx.xpi";
      sha256 = "b198bcb069860dd9010cca738773b63a4c0e49783fa0eaba046e2fe939457476";
      meta = with stdenv.lib;
      {
        homepage = "https://fraidyc.at/";
        description = "Follow from afar. Follow blogs, wikis, Twitter, Instagram, Tumblr - anyone on nearly any blog-like network - from your browser. No notifications, no unread messages, no 'inbox'. Just a single page overview of all your follows.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "gesturefy" = buildFirefoxXpiAddon {
      pname = "gesturefy";
      version = "3.0.7";
      addonId = "{506e023c-7f2b-40a3-8066-bc5deb40aebe}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3639516/gesturefy-3.0.7-fx.xpi";
      sha256 = "d874656e9900d31575a90ab848f66483d3836cb6b2f814470c438c5aa1879dc3";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/Robbendebiene/Gesturefy";
        description = "Navigate, operate, and browse faster with mouse gestures! A customizable mouse gesture add-on with a variety of different commands.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "ghostery" = buildFirefoxXpiAddon {
      pname = "ghostery";
      version = "8.5.4";
      addonId = "firefox@ghostery.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3687087/ghostery_privacy_ad_blocker-8.5.4-an+fx.xpi";
      sha256 = "79d2a7732cb7aa127824348658eb95ea685b9992d156c534a2825fedb9f8f420";
      meta = with stdenv.lib;
      {
        homepage = "http://www.ghostery.com/";
        description = "Ghostery is a powerful privacy extension. \n\nBlock ads, stop trackers and speed up websites.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "google-search-link-fix" = buildFirefoxXpiAddon {
      pname = "google-search-link-fix";
      version = "1.6.10";
      addonId = "jid0-XWJxt5VvCXkKzQK99PhZqAn7Xbg@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3589584/google_search_link_fix-1.6.10-an+fx.xpi";
      sha256 = "c3161b62b8c7fb27a67a7821a4c867ac852c16f47fbd6221be9dbb011c43bdc5";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/palant/searchlinkfix";
        description = "This extension prevents Google and Yandex search pages from modifying search result links when you click them. This is useful when copying links but it also helps privacy by preventing the search engines from recording your clicks.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "gopass-bridge" = buildFirefoxXpiAddon {
      pname = "gopass-bridge";
      version = "0.8.0";
      addonId = "{eec37db0-22ad-4bf1-9068-5ae08df8c7e9}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3630534/gopass_bridge-0.8.0-fx.xpi";
      sha256 = "cd314f07b72d82e52b2f52b274ef751cf85d872b42a96560167ee1df7fcd4db0";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/gopasspw/gopassbridge";
        description = "Gopass Bridge allows searching and inserting login credentials from the gopass password manager ( <a rel=\"nofollow\" href=\"https://outgoing.prod.mozaws.net/v1/fa484fa7cde64c1be04f689a80902fdf34bfe274b8675213f619c3a13e6606ab/https%3A//www.gopass.pw/\">https://www.gopass.pw/</a> ).";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "greasemonkey" = buildFirefoxXpiAddon {
      pname = "greasemonkey";
      version = "4.11";
      addonId = "{e4a8a97b-f2ed-450b-b12d-ee082ba24781}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3716451/greasemonkey-4.11-an+fx.xpi";
      sha256 = "5eb85a96f76a9b16a47cf207991d4237bf597c7b767574559204e2e0ff1173f0";
      meta = with stdenv.lib;
      {
        homepage = "http://www.greasespot.net/";
        description = "Customize the way a web page displays or behaves, by using small bits of JavaScript.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "h264ify" = buildFirefoxXpiAddon {
      pname = "h264ify";
      version = "1.1.0";
      addonId = "jid1-TSgSxBhncsPBWQ@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3398929/h264ify-1.1.0-an+fx.xpi";
      sha256 = "87bd3c4ab1a2359c01a1d854d7db8428b44316fef5b2ac09e228c5318c57a515";
      meta = with stdenv.lib;
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
      url = "https://addons.mozilla.org/firefox/downloads/file/3472456/header_editor-4.1.1-an+fx.xpi";
      sha256 = "389fba1a1a08b97f8b4bf0ed9c21ac2e966093ec43cecb80fc574997a0a99766";
      meta = with stdenv.lib;
      {
        homepage = "http://team.firefoxcn.net";
        description = "Manage browser's requests, include modify the request headers and response headers, redirect requests, cancel requests";
        license = licenses.gpl2;
        platforms = platforms.all;
        };
      };
    "honey" = buildFirefoxXpiAddon {
      pname = "honey";
      version = "12.4.5";
      addonId = "jid1-93CWPmRbVPjRQA@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3665480/honey-12.4.5-fx.xpi";
      sha256 = "d3589e96335235a7500db2c0059501f67cadcc0ebe0b2230bed85a6d16b4f288";
      meta = with stdenv.lib;
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
      version = "2021.1.27";
      addonId = "https-everywhere@eff.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3716461/https_everywhere-2021.1.27-an+fx.xpi";
      sha256 = "da049748bba7282c0f8c0ab85ac8f494e795e79d6bdc6f9f726d687aa8cc2a1f";
      meta = with stdenv.lib;
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
      version = "3.2.7";
      addonId = "jid1-KKzOGWgsW3Ao4Q@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3707490/i_dont_care_about_cookies-3.2.7-an+fx.xpi";
      sha256 = "d5f917408c64a254694d34ffa14c48edd5c3fc9f9d2ab45459cf7236acc9352d";
      meta = with stdenv.lib;
      {
        homepage = "https://www.i-dont-care-about-cookies.eu/";
        description = "Get rid of cookie warnings from almost all websites!";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "ipfs-companion" = buildFirefoxXpiAddon {
      pname = "ipfs-companion";
      version = "2.17.3";
      addonId = "ipfs-firefox-addon@lidel.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3717531/ipfs_companion-2.17.3-an+fx.xpi";
      sha256 = "b7e9b144ef6691bba3b6d682142c3a8241a96f2c618277763c0395e003ad858c";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/ipfs-shipyard/ipfs-companion";
        description = "Harness the power of IPFS in your browser";
        license = licenses.cc0;
        platforms = platforms.all;
        };
      };
    "keepass-helper" = buildFirefoxXpiAddon {
      pname = "keepass-helper";
      version = "1.3";
      addonId = "{e56fa932-ad2c-4cfa-b0d7-a35db1d9b0f6}";
      url = "https://addons.mozilla.org/firefox/downloads/file/839803/keepass_helper_url_in_title-1.3-an+fx.xpi";
      sha256 = "0ff5e82dd4526db8c7b8cddd7778f46d282de9f6fc4c1d11ac7aa7b0bbefe7e4";
      meta = with stdenv.lib;
      {
        description = "Puts a hostname or a URL in the window title.\nIt does not modify the title of a tab, just the window title.\nIt does not inject any JavaScript code to a website, so it can't corrupt, nor can it be corrupted by it.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "keepassxc-browser" = buildFirefoxXpiAddon {
      pname = "keepassxc-browser";
      version = "1.7.5";
      addonId = "keepassxc-browser@keepassxc.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3718260/keepassxc_browser-1.7.5-fx.xpi";
      sha256 = "ac4b6926890b903bb7870d51b8a07a8740e63784a0621f274436ac401e85dd46";
      meta = with stdenv.lib;
      {
        homepage = "https://keepassxc.org/";
        description = "Official browser plugin for the KeePassXC password manager (<a rel=\"nofollow\" href=\"https://outgoing.prod.mozaws.net/v1/aebde84f385b73661158862b419dd43b46ac4c22bea71d8f812030e93d0e52d5/https%3A//keepassxc.org\">https://keepassxc.org</a>).";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "languagetool" = buildFirefoxXpiAddon {
      pname = "languagetool";
      version = "3.3.1";
      addonId = "languagetool-webextension@languagetool.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3715167/grammatik_und_rechtschreibprufung_languagetool-3.3.1-fx.xpi";
      sha256 = "28b1d21f8fc33942ba12575a85fe95f2676198b5bd573a22a6b1321a1fe8e215";
      meta = with stdenv.lib;
      {
        homepage = "https://languagetool.org";
        description = "With this extension you can check text with the free style and grammar checker LanguageTool. It finds many errors that a simple spell checker cannot detect, like mixing up there/their, a/an, or repeating a word.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://languagetool.org/legal/";
          free = false;
          };
        platforms = platforms.all;
        };
      };
    "lastpass-password-manager" = buildFirefoxXpiAddon {
      pname = "lastpass-password-manager";
      version = "4.63.0.3";
      addonId = "support@lastpass.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3708976/lastpass_password_manager-4.63.0.3-an+fx.xpi";
      sha256 = "a932ed795e722a6c422799f7941468a2caf7d7f86a9839602dfb1b7d42063c18";
      meta = with stdenv.lib;
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
      version = "1.0.10";
      addonId = "leechblockng@proginosko.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3714255/leechblock_ng-1.0.10-an+fx.xpi";
      sha256 = "460a8a1aff43bfe8b300cd0004ab9203b6de306743a20d939f96ecdcb2a4fa61";
      meta = with stdenv.lib;
      {
        homepage = "https://www.proginosko.com/leechblock/";
        description = "LeechBlock NG is a simple productivity tool designed to block those time-wasting sites that can suck the life out of your working day. All you need to do is specify which sites to block and when to block them.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "link-cleaner" = buildFirefoxXpiAddon {
      pname = "link-cleaner";
      version = "1.5";
      addonId = "{6d85dea2-0fb4-4de3-9f8c-264bce9a2296}";
      url = "https://addons.mozilla.org/firefox/downloads/file/671858/link_cleaner-1.5-an+fx.xpi";
      sha256 = "1ecec8cbe78b4166fc50da83213219f30575a8c183f7a13aabbff466c71ce560";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/idlewan/link_cleaner";
        description = "Clean URLs that are about to be visited:\n- removes utm_* parameters\n- on item pages of aliexpress and amazon, removes tracking parameters\n- skip redirect pages of facebook, steam and reddit";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "linkhints" = buildFirefoxXpiAddon {
      pname = "linkhints";
      version = "1.1.1";
      addonId = "linkhints@lydell.github.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/3626392/link_hints-1.1.1-fx.xpi";
      sha256 = "84ac6143c3520b8912635a083cad4ee06c006c16c2bcbfaa71de6559f8b86069";
      meta = with stdenv.lib;
      {
        homepage = "https://lydell.github.io/LinkHints";
        description = "Click with your keyboard.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "mailvelope" = buildFirefoxXpiAddon {
      pname = "mailvelope";
      version = "4.4.0";
      addonId = "jid1-AQqSMBYb0a8ADg@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3666219/mailvelope-4.4.0-fx.xpi";
      sha256 = "03945eb7a4949f9429a3416ff46a791dafdcbd7943dc825c60ed39d996a1f03b";
      meta = with stdenv.lib;
      {
        homepage = "https://www.mailvelope.com/";
        description = "Enhance your webmail provider with end-to-end encryption. Secure email communication based on the OpenPGP standard.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "matte-black-red" = buildFirefoxXpiAddon {
      pname = "matte-black-red";
      version = "2020.10.20";
      addonId = "{a7589411-c5f6-41cf-8bdc-f66527d9d930}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3664064/matte_black_red-2020.10.20-an+fx.xpi";
      sha256 = "bc5e662440d345bcab60664c2213bd949f970b7de6e8dd927bd8d7e3c50f9715";
      meta = with stdenv.lib;
      {
        homepage = "https://elijahlopez.herokuapp.com/";
        description = "A modern dark / Matte Black theme with a red accent color.\nClick my name for more accents (request if not available).\nmonero:42hpQgwfvFw6RXpmcXHBJ85cZs9yF97kqfV3JpycnanG7JazfdL4WHkVL";
        license = licenses.cc-by-nc-sa-30;
        platforms = platforms.all;
        };
      };
    "metamask" = buildFirefoxXpiAddon {
      pname = "metamask";
      version = "9.0.3";
      addonId = "webextension@metamask.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/3713506/metamask-9.0.3-an+fx.xpi";
      sha256 = "692375925ffe029315963d91a084837ddf7137c2d15a121ca71e6b3f98d42761";
      meta = with stdenv.lib;
      {
        description = "Ethereum Browser Extension";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "multi-account-containers" = buildFirefoxXpiAddon {
      pname = "multi-account-containers";
      version = "7.3.0";
      addonId = "@testpilot-containers";
      url = "https://addons.mozilla.org/firefox/downloads/file/3713375/firefox_multi_account_containers-7.3.0-fx.xpi";
      sha256 = "4784cbd5de44d65f4cc014949dcbd315503f4913dfa7b3124b8d84c49515666a";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/mozilla/multi-account-containers/#readme";
        description = "Firefox Multi-Account Containers lets you keep parts of your online life separated into color-coded tabs that preserve your privacy. Cookies are separated by container, allowing you to use the web with multiple identities or accounts simultaneously.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "octotree" = buildFirefoxXpiAddon {
      pname = "octotree";
      version = "6.2.6";
      addonId = "jid1-Om7eJGwA1U8Akg@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3711228/octotree_github_code_tree-6.2.6-fx.xpi";
      sha256 = "f30d347488b84a0a6bedeaa7f76bb3181c951bc5d08b6ada85ae258275906f66";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/buunguyen/octotree/";
        description = "GitHub on steroids";
        platforms = platforms.all;
        };
      };
    "old-reddit-redirect" = buildFirefoxXpiAddon {
      pname = "old-reddit-redirect";
      version = "1.4.0";
      addonId = "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3714071/old_reddit_redirect-1.4.0-an+fx.xpi";
      sha256 = "ceb63ae82790f8d4c2f31a41292b25cba49ab98c9e7d76b60c48ee8c572bd206";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/tom-james-watson/old-reddit-redirect";
        description = "Ensure Reddit always loads the old design";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "org-capture" = buildFirefoxXpiAddon {
      pname = "org-capture";
      version = "0.2.1";
      addonId = "{ddefd400-12ea-4264-8166-481f23abaa87}";
      url = "https://addons.mozilla.org/firefox/downloads/file/1127481/org_capture-0.2.1-fx.xpi";
      sha256 = "5683ee1ebfafc24abc2d759c7180c4e839c24fa90764d8cf3285c5d72fc81f0a";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/sprig/org-capture-extension";
        description = "A helper for capturing things via org-protocol in emacs: First, set up: <a rel=\"nofollow\" href=\"https://outgoing.prod.mozaws.net/v1/04ad17418f8d35ee0f3edf4599aed951b2a5ef88d4bc7e0e3237f6d86135e4fb/http%3A//orgmode.org/worg/org-contrib/org-protocol.html\">http://orgmode.org/worg/org-contrib/org-protocol.html</a> or <a rel=\"nofollow\" href=\"https://outgoing.prod.mozaws.net/v1/fb401af8127ccf82bc948b0a7af0543eec48d58100c0c46404f81aabeda442e6/https%3A//github.com/sprig/org-capture-extension\">https://github.com/sprig/org-capture-extension</a>\n\nSee <a rel=\"nofollow\" href=\"https://outgoing.prod.mozaws.net/v1/6aad51cc4e2f9476f9fff344e6554eade08347181aed05f8b61cda05073daecb/https%3A//youtu.be/zKDHto-4wsU\">https://youtu.be/zKDHto-4wsU</a> for example usage";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "peertubeify" = buildFirefoxXpiAddon {
      pname = "peertubeify";
      version = "0.6.0";
      addonId = "{01175c8e-4506-4263-bad9-d3ddfd4f5a5f}";
      url = "https://addons.mozilla.org/firefox/downloads/file/1687641/peertubeify-0.6.0-an+fx.xpi";
      sha256 = "9ccd1eec053a1131629c60983d6fc5ff8ac96205bbcf5a1ed22c7bb46ad07d3b";
      meta = with stdenv.lib;
      {
        homepage = "https://gitlab.com/Ealhad/peertubeify";
        description = "PeerTubeify allows to redirect between YouTube and PeerTube and across PeerTube instances, automatically or by displaying a link.\n\nDon't forget to set your preferences :)\n\nPeerTubeify is not affiliated with PeerTube.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "plasma-integration" = buildFirefoxXpiAddon {
      pname = "plasma-integration";
      version = "1.8.0.1";
      addonId = "plasma-browser-integration@kde.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3715245/plasma_integration-1.8.0.1-fx.xpi";
      sha256 = "226f0931a139346d78d0d8ae950688a731cb07a3e430b3b3f779585ae33714e7";
      meta = with stdenv.lib;
      {
        homepage = "http://kde.org";
        description = "Multitask efficiently by controlling browser functions from the Plasma desktop.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "privacy-badger" = buildFirefoxXpiAddon {
      pname = "privacy-badger";
      version = "2020.12.10";
      addonId = "jid1-MnnxcxisBPnSXQ@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3691765/privacy_badger-2020.12.10-an+fx.xpi";
      sha256 = "635ded379b5c3259d7bf0997689215bcb0f1bbb77f9289f33b0c01b0cddc7ff0";
      meta = with stdenv.lib;
      {
        homepage = "https://privacybadger.org/";
        description = "Automatically learns to block invisible trackers.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "privacy-possum" = buildFirefoxXpiAddon {
      pname = "privacy-possum";
      version = "2019.7.18";
      addonId = "woop-NoopscooPsnSXQ@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3360398/privacy_possum-2019.7.18-an+fx.xpi";
      sha256 = "0840a8c443e25d8a65da22ce1b557216456b900a699b3541e42e1b47e8cb6c0e";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/cowlicks/privacypossum";
        description = "Privacy Possum monkey wrenches common commercial tracking methods by reducing and falsifying the data gathered by tracking companies.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "react-devtools" = buildFirefoxXpiAddon {
      pname = "react-devtools";
      version = "4.10.1";
      addonId = "@react-devtools";
      url = "https://addons.mozilla.org/firefox/downloads/file/3689412/react_developer_tools-4.10.1-fx.xpi";
      sha256 = "f089d5d4f82782b34d4bad9483bcc12d06cbcdfa8369e6ea516a736c07767a16";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/facebook/react";
        description = "React Developer Tools is a tool that allows you to inspect a React tree, including the component hierarchy, props, state, and more. To get started, just open the Firefox devtools and switch to the \"⚛️ Components\" or \"⚛️ Profiler\" tab.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "reddit-enhancement-suite" = buildFirefoxXpiAddon {
      pname = "reddit-enhancement-suite";
      version = "5.20.12";
      addonId = "jid1-xUfzOsOFlzSOXg@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3703195/reddit_enhancement_suite-5.20.12-an+fx.xpi";
      sha256 = "8c4ee11c701a916ef7d53611bd237882ae0130d77c64bdccef4e33297c317599";
      meta = with stdenv.lib;
      {
        homepage = "https://redditenhancementsuite.com/";
        description = "Reddit Enhancement Suite (RES) is a suite of tools to enhance your Reddit browsing experience.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "reddit-moderator-toolbox" = buildFirefoxXpiAddon {
      pname = "reddit-moderator-toolbox";
      version = "5.5.1";
      addonId = "yes@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3718253/moderator_toolbox_for_reddit-5.5.1-an+fx.xpi";
      sha256 = "9601b617280d875deec1e1b542f6ef8e57c381f705fb14f737f43e9fe396b815";
      meta = with stdenv.lib;
      {
        homepage = "https://www.reddit.com/r/toolbox";
        description = "This is bundled extension of the /r/toolbox moderator tools for <a rel=\"nofollow\" href=\"https://outgoing.prod.mozaws.net/v1/42268797a19a16a2ebeeda77cca1eda5a48db14e0cff56de4fab35eaef484216/http%3A//reddit.com\">reddit.com</a>\n\nContaining:\n\nMod Tools Enhanced\nMod Button\nMod Mail Pro\nMod Domain Tagger\nToolbox Notifier\nMod User Notes\nToolbox Config";
        license = licenses.asl20;
        platforms = platforms.all;
        };
      };
    "refined-github" = buildFirefoxXpiAddon {
      pname = "refined-github";
      version = "21.1.23";
      addonId = "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3713728/refined_github-21.1.23-an+fx.xpi";
      sha256 = "f6f382435c06a4510a059b4b03b9e50ddb4a377d2225d60024179c7e0b84a5b1";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/sindresorhus/refined-github";
        description = "Simplifies the GitHub interface and adds many useful features.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "save-page-we" = buildFirefoxXpiAddon {
      pname = "save-page-we";
      version = "25.2";
      addonId = "savepage-we@DW-dev";
      url = "https://addons.mozilla.org/firefox/downloads/file/3711952/save_page_we-25.2-fx.xpi";
      sha256 = "66f6e5d92ee4afdd911e38f77775c7ed5f3a96ae9576fab7980e37b1aafecf26";
      meta = with stdenv.lib;
      {
        description = "Save a complete web page (as currently displayed) as a single HTML file that can be opened in any browser. Save a single page, multiple selected pages or a list of page URLs. Automate saving from command line.";
        license = licenses.gpl2;
        platforms = platforms.all;
        };
      };
    "sidebery" = buildFirefoxXpiAddon {
      pname = "sidebery";
      version = "4.9.1";
      addonId = "{3c078156-979c-498b-8990-85f7987dd929}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3716798/sidebery-4.9.1-fx.xpi";
      sha256 = "aca8a6f3c23253a48a2530c1e4bd346103699811a5deae96e782c69349607971";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/mbnuqw/sidebery";
        description = "Tabs tree and bookmarks in sidebar with advanced containers configuration.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "simple-tab-groups" = buildFirefoxXpiAddon {
      pname = "simple-tab-groups";
      version = "4.7";
      addonId = "simple-tab-groups@drive4ik";
      url = "https://addons.mozilla.org/firefox/downloads/file/3683240/simple_tab_groups-4.7-fx.xpi";
      sha256 = "51f8aaec37c27eb31fd1f210dbcf3a5ad35c190e90b5a59c0d7573cca480f470";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/drive4ik/simple-tab-groups";
        description = "Create, modify, and quickly change tab groups";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "snowflake" = buildFirefoxXpiAddon {
      pname = "snowflake";
      version = "0.5.3";
      addonId = "{b11bea1f-a888-4332-8d8a-cec2be7d24b9}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3716273/snowflake-0.5.3-fx.xpi";
      sha256 = "a18bbf755ab056a7826959b221604ce8743d12b657c94a48737fa3ecbdb65561";
      meta = with stdenv.lib;
      {
        homepage = "https://snowflake.torproject.org/";
        description = "Snowflake is a WebRTC pluggable transport for Tor.\n\nEnabling this extension turns your browser into a proxy that connects Tor users in censored regions to the Tor network.";
        license = licenses.bsd3;
        platforms = platforms.all;
        };
      };
    "stylus" = buildFirefoxXpiAddon {
      pname = "stylus";
      version = "1.5.13";
      addonId = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3614089/stylus-1.5.13-fx.xpi";
      sha256 = "2bb379e655144e030ec931bab3ca01f11ee8710b4ff788a19977ed94f778a159";
      meta = with stdenv.lib;
      {
        homepage = "https://add0n.com/stylus.html";
        description = "Redesign your favorite websites with Stylus, an actively developed and community driven userstyles manager. Easily install custom themes from popular online repositories, or create, edit, and manage your own personalized CSS stylesheets.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "swedish-dictionary" = buildFirefoxXpiAddon {
      pname = "swedish-dictionary";
      version = "1.21";
      addonId = "swedish@dictionaries.addons.mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3539390/swedish_dictionary-1.21.xpi";
      sha256 = "7d2ce7f7bfb65cfb5dd4138686acd977cf589c6ce91fc342ae5e2e26a09d1dbe";
      meta = with stdenv.lib;
      {
        description = "Swedish spell-check dictionary.";
        license = licenses.lgpl3;
        platforms = platforms.all;
        };
      };
    "tabcenter-reborn" = buildFirefoxXpiAddon {
      pname = "tabcenter-reborn";
      version = "2.2.0";
      addonId = "tabcenter-reborn@ariasuni";
      url = "https://addons.mozilla.org/firefox/downloads/file/3662128/tab_center_reborn-2.2.0-fx.xpi";
      sha256 = "d2f06e663318298249e867f4b955ab490980f833d3b7b5fadc64f088518ee236";
      meta = with stdenv.lib;
      {
        homepage = "https://framagit.org/ariasuni/tabcenter-reborn";
        description = "Simple and powerful vertical tab bar";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "temporary-containers" = buildFirefoxXpiAddon {
      pname = "temporary-containers";
      version = "1.9.1";
      addonId = "{c607c8df-14a7-4f28-894f-29e8722976af}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3623550/temporary_containers-1.9.1-fx.xpi";
      sha256 = "392ef6ff878f4969bf753801a4e99f19ff2108e2d9c978e2d5570c8b13e0a2ac";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/stoically/temporary-containers";
        description = "Open tabs, websites, and links in automatically managed disposable containers. Containers isolate data websites store (cookies, storage, and more) from each other, enhancing your privacy and security while you browse.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "terms-of-service-didnt-read" = buildFirefoxXpiAddon {
      pname = "terms-of-service-didnt-read";
      version = "4.0.3";
      addonId = "jid0-3GUEt1r69sQNSrca5p8kx9Ezc3U@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3716368/terms_of_service_didnt_read-4.0.3-fx.xpi";
      sha256 = "4b49219cdb064e6ad2ef1373f2f227af4e6bc6402122ffb27c0123c503f90629";
      meta = with stdenv.lib;
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
      url = "https://addons.mozilla.org/firefox/downloads/file/3462082/text_contrast_for_dark_themes-2.1.6-fx.xpi";
      sha256 = "e768c13a4fa10e4dc2ce54f0539dd5a115c76babe6c044ae1115966f6062244d";
      meta = with stdenv.lib;
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
      url = "https://addons.mozilla.org/firefox/downloads/file/3594392/textern-0.7-fx.xpi";
      sha256 = "cf15dba57b32b24c2dbc79ea169fb53286c40a5c500a066ba81e67439021bb5a";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/jlebon/textern";
        description = "Edit text in your favourite external editor!";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "tomato-clock" = buildFirefoxXpiAddon {
      pname = "tomato-clock";
      version = "6.0.0";
      addonId = "jid1-Kt2kYYgi32zPuw@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3622546/tomato_clock-6.0.0-an+fx.xpi";
      sha256 = "03aae6f6d75e042cbf204042aa61ddd8aa8dcc23f08482c34fadc04931c80e58";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/samueljun/tomato-clock";
        description = "Tomato Clock is a simple browser extension that helps with online time management.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "transparent-standalone-image" = buildFirefoxXpiAddon {
      pname = "transparent-standalone-image";
      version = "2.1";
      addonId = "jid0-ezUl0hF1SPM9hLO5BMBkNoblB8s@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/738931/transparent_standalone_images-2.1-an+fx.xpi";
      sha256 = "f56bc840d5ac96d1697feed57e7ab0928ff2c47232e236d00560efc2f3bf57b5";
      meta = with stdenv.lib;
      {
        description = "This add-on renders standalone images on a transparent background, so you can see the image in all its glory!";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "tree-style-tab" = buildFirefoxXpiAddon {
      pname = "tree-style-tab";
      version = "3.6.5";
      addonId = "treestyletab@piro.sakura.ne.jp";
      url = "https://addons.mozilla.org/firefox/downloads/file/3705500/tree_style_tab_-3.6.5-fx.xpi";
      sha256 = "86fa603dde05569f954e4281ef96cefb5313953671be7dd8bedaaa80c0912684";
      meta = with stdenv.lib;
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
      version = "1.20.4";
      addonId = "tridactyl.vim@cmcaine.co.uk";
      url = "https://addons.mozilla.org/firefox/downloads/file/3697894/tridactyl-1.20.4-an+fx.xpi";
      sha256 = "9e2aba45307612923cbad7a4d4ff8c056883cfd7dc72b4244599ac3bb51e738b";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/cmcaine/tridactyl";
        description = "Vim, but in your browser. Replace Firefox's control mechanism with one modelled on Vim.\n\nThis addon is very usable, but is in an early stage of development. We intend to implement the majority of Vimperator's features.";
        license = licenses.asl20;
        platforms = platforms.all;
        };
      };
    "ublock-origin" = buildFirefoxXpiAddon {
      pname = "ublock-origin";
      version = "1.32.4";
      addonId = "uBlock0@raymondhill.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/3701081/ublock_origin-1.32.4-an+fx.xpi";
      sha256 = "5b94fd7f749319a6ff6d83dd20b05b29e733446465aff2ab7669499a3e8fb9cc";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/gorhill/uBlock#ublock-origin";
        description = "Finally, an efficient wide-spectrum content blocker. Easy on CPU and memory.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "umatrix" = buildFirefoxXpiAddon {
      pname = "umatrix";
      version = "1.4.0";
      addonId = "uMatrix@raymondhill.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/3396815/umatrix-1.4.0-an+fx.xpi";
      sha256 = "991f0fa5c64172b8a2bc0a010af60743eba1c18078c490348e1c6631882cbfc7";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/gorhill/uMatrix";
        description = "Point &amp; click to forbid/allow any class of requests made by your browser. Use it to block scripts, iframes, ads, facebook, etc.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "unpaywall" = buildFirefoxXpiAddon {
      pname = "unpaywall";
      version = "3.93";
      addonId = "{f209234a-76f0-4735-9920-eb62507a54cd}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3709278/unpaywall-3.93-fx.xpi";
      sha256 = "a1de4838bcb4d28339ff87fa47c69b3d8381026ba673c1303ec53a8778f422c5";
      meta = with stdenv.lib;
      {
        homepage = "http://unpaywall.org/products/extension";
        description = "Get free text of research papers as you browse, using Unpaywall's index of ten million legal, open-access articles.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "vim-vixen" = buildFirefoxXpiAddon {
      pname = "vim-vixen";
      version = "0.32";
      addonId = "vim-vixen@i-beam.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3700427/vim_vixen-0.32-an+fx.xpi";
      sha256 = "99c6c8e785a0796a12a2d2e59dd1b539cb1edc00e1d81cd993eac43926eb91e2";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/ueokande/vim-vixen";
        description = "Accelerates your web browsing with Vim power!!";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "vimium" = buildFirefoxXpiAddon {
      pname = "vimium";
      version = "1.66";
      addonId = "{d7742d87-e61d-4b78-b8a1-b469842139fa}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3518684/vimium_ff-1.66-fx.xpi";
      sha256 = "ff034c5e35eef842da531080e2d345360ccce09f6eb7dfa53fd2c2b7d662b758";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/philc/vimium";
        description = "The Hacker's Browser. Vimium provides keyboard shortcuts for navigation and control in the spirit of Vim.\n\nThis is a port of the popular Chrome extension to Firefox.\n\nMost stuff works, but the port to Firefox remains a work in progress.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "violentmonkey" = buildFirefoxXpiAddon {
      pname = "violentmonkey";
      version = "2.12.8";
      addonId = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3694624/violentmonkey-2.12.8-an+fx.xpi";
      sha256 = "159ea25020420250a0124b49eaadb2e7f67615bac80a1d2b0e2e13f7d0da5e35";
      meta = with stdenv.lib;
      {
        homepage = "https://violentmonkey.github.io/";
        description = "Violentmonkey provides userscripts support for browsers.\nIt's open source! <a rel=\"nofollow\" href=\"https://outgoing.prod.mozaws.net/v1/c8bcebd9a0e76f20c888274e94578ab5957439e46d59a046ff9e1a9ef55c282c/https%3A//github.com/violentmonkey/violentmonkey\">https://github.com/violentmonkey/violentmonkey</a>";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "zoom-page-we" = buildFirefoxXpiAddon {
      pname = "zoom-page-we";
      version = "17.13";
      addonId = "zoompage-we@DW-dev";
      url = "https://addons.mozilla.org/firefox/downloads/file/3712730/zoom_page_we-17.13-fx.xpi";
      sha256 = "e822268dc12ec45291a1788baa9cae9f00248de7b694b564c4a515d11dd18b6f";
      meta = with stdenv.lib;
      {
        description = "Zoom web pages (either per-site or per-tab) using full-page zoom, text-only zoom and minimum font size. Fit-to-width zooming can be applied to pages automatically. Fit-to-window scaling  can be applied to small images.";
        license = licenses.gpl2;
        platforms = platforms.all;
        };
      };
    }
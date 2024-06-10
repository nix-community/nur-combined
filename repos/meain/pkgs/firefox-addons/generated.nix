{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
  {
    "a-n-i-m-a-t-e-d-kitty-cat" = buildFirefoxXpiAddon {
      pname = "a-n-i-m-a-t-e-d-kitty-cat";
      version = "2.0";
      addonId = "{cf4e89f2-b8e0-4ad7-932d-7b82d8956543}";
      url = "https://addons.mozilla.org/firefox/downloads/file/2698590/a_n_i_m_a_t_e_d_kitty_cat-2.0.xpi";
      sha256 = "1ab1b18d712713b642b22a1f5fb1b2f5ff9b25b4c9123013873756439b769666";
      meta = with lib;
      {
        description = "Dogs have Owners, Cats have Staff.\n~ Unknown Source\n\nTAGS\ngallery gray cuddly cute black kitten feline domesticated animal love furry friend pets animated png animated ears &amp; tail walking paw prints footer whiskers\n\n=^..^=  \n(\") (\") SaSSyGirL";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://addons.mozilla.org/en-US/firefox/addon/animated-kitty-cat/";
          free = false;
        };
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "aw-watcher-web" = buildFirefoxXpiAddon {
      pname = "aw-watcher-web";
      version = "0.4.8";
      addonId = "{ef87d84c-2127-493f-b952-5b4e744245bc}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4114360/aw_watcher_web-0.4.8.xpi";
      sha256 = "6be85d9755013520a5a4835cb8ae2a3287e4cb9c12b5baf4957ab10368dd45d2";
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
          "http://localhost:5600/api/*"
          "http://localhost:5666/api/*"
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
    "aws-sso-containers" = buildFirefoxXpiAddon {
      pname = "aws-sso-containers";
      version = "1.8";
      addonId = "{5c474add-03f0-4c67-9479-f32939d7599a}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4256287/aws_sso_containers-1.8.xpi";
      sha256 = "0b31b7b4bb470bc31d5596a4656684e0039a32f6b68f4f4c0cd07a6092f0a715";
      meta = with lib;
      {
        homepage = "https://github.com/pyro2927/AWS_SSO_Containers";
        description = "Automatically places AWS SSO accounts into containers.";
        license = licenses.mit;
        mozPermissions = [
          "activeTab"
          "tabs"
          "cookies"
          "contextualIdentities"
          "storage"
          "webRequest"
          "webRequestBlocking"
          "https://signin.aws.amazon.com/saml"
          "https://*.awsapps.com/start/*"
          "https://*.amazonaws.com/federation/console?*"
          "https://*.amazonaws-us-gov.com/federation/console?*"
          "https://*.amazonaws.cn/federation/console?*"
          "https://*.amazonaws.com/federation/instance/appinstances"
          "https://*.amazonaws-us-gov.com/federation/instance/appinstances"
          "https://*.amazonaws.cn/federation/instance/appinstances"
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
    "ghostpage" = buildFirefoxXpiAddon {
      pname = "ghostpage";
      version = "0.4.0";
      addonId = "{c4f0d47b-a428-4fe9-87e2-f6500c1423eb}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3599688/ghostpage-0.4.0.xpi";
      sha256 = "66c89a92920502334ef5673afb807fcc5204c20dc82a8b08669bf57a37fc879f";
      meta = with lib;
      {
        description = "Boooooooooooooo!";
        license = licenses.mit;
        mozPermissions = [ "tabs" ];
        platforms = platforms.all;
      };
    };
    "global-speed" = buildFirefoxXpiAddon {
      pname = "global-speed";
      version = "2.9.9971";
      addonId = "{f4961478-ac79-4a18-87e9-d2fb8c0442c4}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4193461/global_speed-2.9.9971.xpi";
      sha256 = "9a18f0a7b356607e37a321578873bb277b0a9f2f3d937805b8e4b1100192592a";
      meta = with lib;
      {
        description = "Set a default speed for video and audio.";
        license = {
          shortName = "allrightsreserved";
          fullName = "All Rights Reserved";
          url = "https://github.com/polywock/globalSpeed/issues/247";
          free = false;
        };
        mozPermissions = [
          "storage"
          "https://*/*"
          "http://*/*"
          "file://*/*"
          "webNavigation"
        ];
        platforms = platforms.all;
      };
    };
    "markdown-viewer-webext" = buildFirefoxXpiAddon {
      pname = "markdown-viewer-webext";
      version = "1.8.1";
      addonId = "{943b8007-a895-44af-a672-4f4ea548c95f}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3894829/markdown_viewer_webext-1.8.1.xpi";
      sha256 = "fc9b61a9a55d96c71606272d91fe3e3b675e3392c50658686c928a740129d959";
      meta = with lib;
      {
        homepage = "https://github.com/Cimbali/markdown-viewer";
        description = "Displays markdown documents beautified in your browser.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "*://*/*.markdown"
          "*://*/*.md"
          "*://*/*.mdown"
          "*://*/*.mdwn"
          "*://*/*.mkd"
          "*://*/*.mkdn"
          "*://*/*.MARKDOWN"
          "*://*/*.MD"
          "*://*/*.MDOWN"
          "*://*/*.MDWN"
          "*://*/*.MKD"
          "*://*/*.MKDN"
          "file://*/*.markdown"
          "file://*/*.MARKDOWN"
          "file://*/*.md"
          "file://*/*.MD"
          "file://*/*.mdown"
          "file://*/*.MDOWN"
          "file://*/*.mdwn"
          "file://*/*.MDWN"
          "file://*/*.mkd"
          "file://*/*.MKD"
          "file://*/*.mkdn"
          "file://*/*.MKDN"
        ];
        platforms = platforms.all;
      };
    };
    "mastodon4-redirect" = buildFirefoxXpiAddon {
      pname = "mastodon4-redirect";
      version = "1.4";
      addonId = "mastodon4-redirect@raikas.dev";
      url = "https://addons.mozilla.org/firefox/downloads/file/4034983/mastodon4_redirect-1.4.xpi";
      sha256 = "fa3ade3ae83965d2e4b209815fa07c6b55646323c53c7700dcb3a9522d4608c6";
      meta = with lib;
      {
        description = "Redirects users from Mastodon4 supported instances to their home instance";
        license = licenses.mit;
        mozPermissions = [ "storage" "*://*/*" ];
        platforms = platforms.all;
      };
    };
    "nattynote" = buildFirefoxXpiAddon {
      pname = "nattynote";
      version = "2.1.1";
      addonId = "{13558633-c36e-4451-a180-ac70f734c6ce}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4190167/nattynote-2.1.1.xpi";
      sha256 = "d6409db69fab839d2aa693d8be0ae80288f84f785d8d8fbceeb07e87a77378d6";
      meta = with lib;
      {
        homepage = "https://github.com/ahmedelq/NattyNote";
        description = "Take time-stamped YouTube notes.";
        license = licenses.gpl3;
        mozPermissions = [ "storage" "unlimitedStorage" "*://*.youtube.com/*" ];
        platforms = platforms.all;
      };
    };
    "netflix-prime-auto-skip" = buildFirefoxXpiAddon {
      pname = "netflix-prime-auto-skip";
      version = "1.1.10";
      addonId = "NetflixPrime@Autoskip.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/4287801/netflix_prime_auto_skip-1.1.10.xpi";
      sha256 = "374c3c9c5bd0b555d4e980d41a73bb362c42d6ea9a446613adafc0275097d689";
      meta = with lib;
      {
        homepage = "https://github.com/Dreamlinerm/Netflix-Prime-Auto-Skip";
        description = "Automatically skip Ads, Intros, Credits and add Speed Control, etc. on Netflix, Prime video, Disney+, Crunchyroll and HBO max.";
        license = licenses.gpl3;
        mozPermissions = [
          "storage"
          "webRequest"
          "webRequestBlocking"
          "*://*.disneyplus.com/*"
          "*://*.starplus.com/*"
          "*://*.primevideo.com/*"
          "*://*.amazon.com/*"
          "*://*.amazon.co.jp/*"
          "*://*.amazon.de/*"
          "*://*.amazon.co.uk/*"
          "*://*.max.com/*"
          "*://*.hbomax.com/*"
          "*://*.netflix.com/*"
          "*://*.netflix.ca/*"
          "*://*.netflix.com.au/*"
          "*://*.hotstar.com/*"
          "*://*.crunchyroll.com/*"
          "https://static.crunchyroll.com/vilos-v2/web/vilos/player.html*"
        ];
        platforms = platforms.all;
      };
    };
    "notifications-preview-github" = buildFirefoxXpiAddon {
      pname = "notifications-preview-github";
      version = "23.4.6";
      addonId = "notifications-preview-github@tanmayrajani.github.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/4094000/notifications_preview_github-23.4.6.xpi";
      sha256 = "246991ab85e31b9a9c1c7bcaa5aa651346b7ee3a1e6a3b8039098350f9cc3ed9";
      meta = with lib;
      {
        homepage = "https://github.com/tanmayrajani/notifications-preview-github/";
        description = "Quickly see your notifications in a popup without leaving the current page";
        license = licenses.bsd2;
        mozPermissions = [ "storage" "https://github.com/*" ];
        platforms = platforms.all;
      };
    };
    "smartreader" = buildFirefoxXpiAddon {
      pname = "smartreader";
      version = "1.6";
      addonId = "contact@example.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3999045/smartreader-1.6.xpi";
      sha256 = "2786349515520feda8771c640662e66596bbf7bd5e8809f748bcfd05b9ce545e";
      meta = with lib;
      {
        description = "Modify a web page to make it more readable by bolding the beginning of a word (like bionic reading).";
        license = licenses.mpl20;
        mozPermissions = [ "<all_urls>" "http://*/*" "https://*/*" ];
        platforms = platforms.all;
      };
    };
    "try-another-search-engine" = buildFirefoxXpiAddon {
      pname = "try-another-search-engine";
      version = "0.10.0";
      addonId = "{14c48e36-100d-4d9b-a11a-890112654de9}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4252190/try_another_search_engine-0.10.0.xpi";
      sha256 = "0fd3dbe371f308d7a0c524b894bf3fcf37c1399083586942c5dfe83f08393c7e";
      meta = with lib;
      {
        description = "Allows quick cycling through predefined search engines (Seznam 🐶, Google, Bing, Brave &amp; DuckDuckGo 🦆) results\n\nCollects anonymous data about switching search engines. This behaviour can be turned off.";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "*://search.seznam.cz/*"
          "*://www.bing.com/*"
          "*://www.obrazky.cz/*"
          "*://www.google.com/*"
          "*://www.google.cz/*"
          "*://duckduckgo.com/*"
          "*://search.brave.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "unofficial-hypothesis" = buildFirefoxXpiAddon {
      pname = "unofficial-hypothesis";
      version = "1.470.0.2";
      addonId = "{7dc760e7-5cc5-4e76-8468-18b2b003f22a}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3670210/unofficial_hypothesis-1.470.0.2.xpi";
      sha256 = "077ea8edd0cf64c505e4950e494ac8ff14c6a0c63b5c490f747e118e3b669f49";
      meta = with lib;
      {
        homepage = "https://github.com/diegodlh/browser-extension";
        description = "An unofficial extension to collaboratively annotate the web using Hypothesis.";
        license = licenses.bsd2;
        mozPermissions = [
          "<all_urls>"
          "storage"
          "tabs"
          "identity"
          "contextMenus"
        ];
        platforms = platforms.all;
      };
    };
    "watchmarker-for-youtube" = buildFirefoxXpiAddon {
      pname = "watchmarker-for-youtube";
      version = "4.6.1";
      addonId = "yourect@coderect.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4231706/watchmarker_for_youtube-4.6.1.xpi";
      sha256 = "a9c804bb9af200404bb809d248a50d2c6482bc322dd24914f76fad1cf29a1c80";
      meta = with lib;
      {
        homepage = "http://sniklaus.com/";
        description = "Automatically mark videos on Youtube that you have already watched.";
        license = licenses.gpl3;
        mozPermissions = [
          "alarms"
          "downloads"
          "history"
          "tabs"
          "cookies"
          "webRequest"
          "webRequestBlocking"
          "https://www.youtube.com/*"
          "*://www.youtube.com/*"
        ];
        platforms = platforms.all;
      };
    };
  }
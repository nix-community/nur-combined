{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
  {
    "bitwarden-password-manager" = buildFirefoxXpiAddon {
      pname = "bitwarden-password-manager";
      version = "1.51.1";
      addonId = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3807401/bitwarden_free_password_manager-1.51.1-an+fx.xpi";
      sha256 = "9cd1db78e612473e1c7a9e57b9868f82b3d5fd770cbea7ffa488cc9efc65a345";
      meta = with lib;
      {
        homepage = "https://bitwarden.com";
        description = "A secure and free password manager for all of your devices.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "new-tab-override" = buildFirefoxXpiAddon {
      pname = "new-tab-override";
      version = "15.1.1";
      addonId = "newtaboverride@agenedia.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3782413/new_tab_override-15.1.1-fx.xpi";
      sha256 = "74d97de74c1d4d5cc146182dbbf9cdc3f383ba4c5d1492edbdb14351549a9d64";
      meta = with lib;
      {
        homepage = "https://www.soeren-hentzschel.at/firefox-webextensions/new-tab-override/";
        description = "New Tab Override allows you to set the page that shows whenever you open a new tab.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "old-reddit-redirect" = buildFirefoxXpiAddon {
      pname = "old-reddit-redirect";
      version = "1.5.1";
      addonId = "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3808545/old_reddit_redirect-1.5.1-an+fx.xpi";
      sha256 = "db55d34c64c4b3a9c0e2a5bf21cdd74ba25487bf1d9b2fce59925f9ec996fceb";
      meta = with lib;
      {
        homepage = "https://github.com/tom-james-watson/old-reddit-redirect";
        description = "Ensure Reddit always loads the old design";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "soundcloud-mp3-downloader" = buildFirefoxXpiAddon {
      pname = "soundcloud-mp3-downloader";
      version = "0.2.7";
      addonId = "jid1-hnmMaq1milpehc6uI@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3809848/mp3_downloader_for_soundcloudtm-0.2.7-fx.xpi";
      sha256 = "46aa43c0f0b6d248f7037136e42e151c6705868e9945babfb82c247dae973abe";
      meta = with lib;
      {
        description = "Add download link to all SoundClould tracks";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "ublock-origin" = buildFirefoxXpiAddon {
      pname = "ublock-origin";
      version = "1.36.2";
      addonId = "uBlock0@raymondhill.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/3806442/ublock_origin-1.36.2-an+fx.xpi";
      sha256 = "31f8c2126a3f4e3cfe3ef63550b842a5d4f071ec1c6e5aa377c2f29b11ff1415";
      meta = with lib;
      {
        homepage = "https://github.com/gorhill/uBlock#ublock-origin";
        description = "Finally, an efficient wide-spectrum content blocker. Easy on CPU and memory.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "vim-vixen" = buildFirefoxXpiAddon {
      pname = "vim-vixen";
      version = "1.2.1";
      addonId = "vim-vixen@i-beam.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3805318/vim_vixen-1.2.1-an+fx.xpi";
      sha256 = "4b2a6e9c62f353d8ec0f854c3071aa91cf46221bb2a6731590791ffb775204ec";
      meta = with lib;
      {
        homepage = "https://github.com/ueokande/vim-vixen";
        description = "Accelerates your web browsing with Vim power!!";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "youtube_downloader_webx" = buildFirefoxXpiAddon {
      pname = "youtube_downloader_webx";
      version = "1.1.6";
      addonId = "{f73df109-8fb4-453e-8373-f59e61ca4da3}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3802517/youtube_video_and_audio_downloader_webex-1.1.6-fx.xpi";
      sha256 = "60371a03d74cda3f200e8df8170056cc57fab0345bfa76b88d8d44e820b5ba16";
      meta = with lib;
      {
        homepage = "https://github.com/feller-prj/extractor-project";
        description = "Download YouTube videos in all available formats and extract the original audio files";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    }
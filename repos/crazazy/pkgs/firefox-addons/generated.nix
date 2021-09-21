{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
  {
    "bitwarden-password-manager" = buildFirefoxXpiAddon {
      pname = "bitwarden-password-manager";
      version = "1.52.1";
      addonId = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3831245/bitwarden_free_password_manager-1.52.1-an+fx.xpi";
      sha256 = "95d6ed5d3b4dabc8291d1a0a337dbc6cfe21920a23ab4a5e1fe3b014169e4bba";
      meta = with lib;
      {
        homepage = "https://bitwarden.com";
        description = "A secure and free password manager for all of your devices.";
        license = licenses.gpl3;
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
    "tabliss" = buildFirefoxXpiAddon {
      pname = "tabliss";
      version = "2.1.0";
      addonId = "extension@tabliss.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/3716637/tabliss_new_tab-2.1.0-fx.xpi";
      sha256 = "7381d681c4eef5bf91667e6b3918569c72009c6a7f62f9a33a44017b03d740ef";
      meta = with lib;
      {
        homepage = "https://tabliss.io";
        description = "A beautiful New Tab page with many customisable backgrounds and widgets that does not require any permissions.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "ublock-origin" = buildFirefoxXpiAddon {
      pname = "ublock-origin";
      version = "1.37.2";
      addonId = "uBlock0@raymondhill.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/3816867/ublock_origin-1.37.2-an+fx.xpi";
      sha256 = "b3a3c81891acb4620e33dd548b50375aad826376044a6143b5a947d0406a559e";
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
      version = "1.2.2";
      addonId = "vim-vixen@i-beam.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/3819811/vim_vixen-1.2.2-an+fx.xpi";
      sha256 = "f2421b7441dacca6cd3b8ced0f2578e5bf1909101249ef072f98786e3ae72ed8";
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
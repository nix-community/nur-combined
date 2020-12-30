{ buildFirefoxXpiAddon, fetchurl, stdenv }:
  {
    "lastpass-password-manager" = buildFirefoxXpiAddon {
      pname = "lastpass-password-manager";
      version = "4.62.0.6";
      addonId = "support@lastpass.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3693247/lastpass_password_manager-4.62.0.6-an+fx.xpi";
      sha256 = "4e4cc6061fe44442de7e91c35d6b2cfd2d2b0c2365cfb84dcba5d4e0fae5138c";
      meta = with stdenv.lib;
      {
        homepage = "https://lastpass.com/";
        description = "LastPass, an award-winning password manager, saves your passwords and gives you secure access from every computer and mobile device.";
        platforms = platforms.all;
        };
      };
    "old-reddit-redirect" = buildFirefoxXpiAddon {
      pname = "old-reddit-redirect";
      version = "1.2.0";
      addonId = "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3611260/old_reddit_redirect-1.2.0-an+fx.xpi";
      sha256 = "581ceb8cd9cf9a90b66996b78ff1a2f7fa458a23c139cdf6c7aef80688a40e4e";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/tom-james-watson/old-reddit-redirect";
        description = "Ensure Reddit always loads the old design";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "soundcloud-mp3-downloader" = buildFirefoxXpiAddon {
      pname = "soundcloud-mp3-downloader";
      version = "0.2.6";
      addonId = "jid1-hnmMaq1milpehc6uI@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/3622315/mp3_downloader_for_soundcloudtm-0.2.6-fx.xpi";
      sha256 = "ad03cfd7069f0a8a41f4728e3f058fb8b49763b21fd0d052c1a1c8050071a2cf";
      meta = with stdenv.lib;
      {
        description = "Add download link to all SoundClould tracks";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "startme" = buildFirefoxXpiAddon {
      pname = "startme";
      version = "2.2.23";
      addonId = "yourls@yourls.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/3692604/startme_jouw_persoonlijke_startpagina-2.2.23-fx.xpi";
      sha256 = "fabc46bc85f1949f520f95e53eaa297ada6d65676b2bdd5e30f6de1f230506f1";
      meta = with stdenv.lib;
      {
        homepage = "https://start.me";
        description = "Customize your New Tab Home Page in Firefox with <a href=\"https://outgoing.prod.mozaws.net/v1/762b49ebb2d28884518d6166c4662fd17acc8c7454596fbb3b3716d592fe3145/http%3A//start.me\" rel=\"nofollow\">start.me</a>.\n\nOrganize all your Bookmarks, RSS feeds and Notes in one place.\n\nOne homepage for all your browsers (Chrome, Firefox, Edge, etc) and devices.\n\nShare pages with friends or colleagues.";
        platforms = platforms.all;
        };
      };
    "ublock-origin" = buildFirefoxXpiAddon {
      pname = "ublock-origin";
      version = "1.32.2";
      addonId = "uBlock0@raymondhill.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/3699732/ublock_origin-1.32.2-an+fx.xpi";
      sha256 = "f48960b40661a529796ae75f1c1222c3321d29aa30a94bca6ea77275378f6494";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/gorhill/uBlock#ublock-origin";
        description = "Finally, an efficient wide-spectrum content blocker. Easy on CPU and memory.";
        license = licenses.gpl3;
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
    "youtube_downloader_webx" = buildFirefoxXpiAddon {
      pname = "youtube_downloader_webx";
      version = "1.1.3";
      addonId = "{f73df109-8fb4-453e-8373-f59e61ca4da3}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3690834/youtube_video_and_audio_downloader_webex-1.1.3-fx.xpi";
      sha256 = "3285cc1e52fe25bec6c3cb0209b1f7da400cf18940d9e0c865c51dcf25a13deb";
      meta = with stdenv.lib;
      {
        homepage = "https://github.com/feller-prj/extractor-project";
        description = "Download YouTube videos in all available formats and extract the original audio files";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    }
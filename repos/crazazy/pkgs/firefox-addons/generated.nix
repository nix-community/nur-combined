{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
  {
    "bitwarden-password-manager" = buildFirefoxXpiAddon {
      pname = "bitwarden-password-manager";
      version = "2023.9.2";
      addonId = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4180072/bitwarden_password_manager-2023.9.2.xpi";
      sha256 = "e76cc68f7f194b52f615ec9df80f82308cd55e6234afff5fb41ee7de9f7a27f2";
      meta = with lib;
      {
        homepage = "https://bitwarden.com";
        description = "A secure and free password manager for all of your devices.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "feedbroreader" = buildFirefoxXpiAddon {
      pname = "feedbroreader";
      version = "4.15.9";
      addonId = "{a9c2ad37-e940-4892-8dce-cd73c6cbbc0c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4134561/feedbroreader-4.15.9.xpi";
      sha256 = "330323ed10094530a7faf9d8d6352bb5ca194641b77befeaa959f3abed566fff";
      meta = with lib;
      {
        homepage = "http://nodetics.com/feedbro";
        description = "Advanced Feed Reader - Read news &amp; blogs or any RSS/Atom/RDF source.";
        platforms = platforms.all;
        };
      };
    "libredirect" = buildFirefoxXpiAddon {
      pname = "libredirect";
      version = "2.8.1";
      addonId = "7esoorv3@alefvanoon.anonaddy.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/4178347/libredirect-2.8.1.xpi";
      sha256 = "c91f19377b07b119eec4d53c28c45cdb5d0755287a79b715328654adb5c7ddfa";
      meta = with lib;
      {
        homepage = "https://libredirect.github.io";
        description = "Redirects YouTube, Twitter, TikTok... requests to alternative privacy friendly frontends.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "soundcloud-mp3-downloader" = buildFirefoxXpiAddon {
      pname = "soundcloud-mp3-downloader";
      version = "0.3.1";
      addonId = "jid1-hnmMaq1milpehc6uI@jetpack";
      url = "https://addons.mozilla.org/firefox/downloads/file/4169360/soundcloud_mp3_downloader-0.3.1.xpi";
      sha256 = "d0a51693459e8e80bb890f47043caa71b99bcd7c554af1f913d30aec890af6a3";
      meta = with lib;
      {
        description = "Add download link to all SoundClould tracks";
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
    "ublock-origin" = buildFirefoxXpiAddon {
      pname = "ublock-origin";
      version = "1.52.2";
      addonId = "uBlock0@raymondhill.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/4171020/ublock_origin-1.52.2.xpi";
      sha256 = "e8ee3f9d597a6d42db9d73fe87c1d521de340755fd8bfdd69e41623edfe096d6";
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
    "youtube_downloader_webx" = buildFirefoxXpiAddon {
      pname = "youtube_downloader_webx";
      version = "1.2.1";
      addonId = "{f73df109-8fb4-453e-8373-f59e61ca4da3}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3901737/youtube_downloader_webx-1.2.1.xpi";
      sha256 = "5a2fa3f36be42b3d136c9e07365d996b6a2940f38f3662e6b7ef3375cc5c64fa";
      meta = with lib;
      {
        homepage = "https://github.com/feller-prj/extractor-project";
        description = "Download YouTube videos in all available formats and extract the original audio files";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    }
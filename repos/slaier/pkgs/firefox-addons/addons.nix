{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
  {
    "aria2-integration" = buildFirefoxXpiAddon {
      pname = "aria2-integration";
      version = "0.4.5";
      addonId = "{e2488817-3d73-4013-850d-b66c5e42d505}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3025850/aria2_integration-0.4.5.xpi";
      sha256 = "1672866f9860499d1a1d5848baab506431ac7db2e99253d517c3735f84410f26";
      meta = with lib;
      {
        description = "Replace built-in download manager. When activated, detects the download links to direct links to this add-on and send to Aria2";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "copy-link-text-webextension" = buildFirefoxXpiAddon {
      pname = "copy-link-text-webextension";
      version = "1.6.4";
      addonId = "{b144be59-6bdc-41e0-9141-9f8d00373d93}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3883720/copy_link_text_webextension-1.6.4.xpi";
      sha256 = "21fa5ee67f4e751e9b6f8b37ed75edd3d9d00ae57ea6227eaece965a490b4ce8";
      meta = with lib;
      {
        homepage = "https://github.com/def00111/copy-link-text";
        description = "Copy the text of the link.";
        license = licenses.mpl20;
        platforms = platforms.all;
        };
      };
    "dictionary-anyvhere" = buildFirefoxXpiAddon {
      pname = "dictionary-anyvhere";
      version = "1.1.0";
      addonId = "{e90f5de4-8510-4515-9f67-3b6654e1e8c2}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3697426/dictionary_anyvhere-1.1.0.xpi";
      sha256 = "1cf8f1bbb9f0d1a36e7ba593eb5a9a666f6c938e6dec8b2334b4a9afc797423d";
      meta = with lib;
      {
        homepage = "https://github.com/meetDeveloper/Dictionary-Anywhere";
        description = "View definitions easily as you browse the web. Double-click any word to view its definition in a small pop-up bubble. It also supports Spanish, German, French language alongside English. Enjoy Reading Uninterrupted!!!.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    "new_tongwentang" = buildFirefoxXpiAddon {
      pname = "new_tongwentang";
      version = "2.2.0";
      addonId = "tongwen@softcup";
      url = "https://addons.mozilla.org/firefox/downloads/file/4029313/new_tongwentang-2.2.0.xpi";
      sha256 = "b51cc33f21edfa063628d86e2f8d05279690cc23f7ca3c25263084d1bc2b3b94";
      meta = with lib;
      {
        homepage = "https://github.com/softcup/New-Tongwentang-for-Firefox";
        description = "Traditional and Simplified Chinese Converter";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "rsshub-radar" = buildFirefoxXpiAddon {
      pname = "rsshub-radar";
      version = "1.9.0";
      addonId = "i@diygod.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/4019770/rsshub_radar-1.9.0.xpi";
      sha256 = "215d5830855b4827ec86c9de3f370c359adf49c195e76ba7b5306f5bb611acce";
      meta = with lib;
      {
        homepage = "https://docs.rsshub.app";
        description = "RSSHub Radar is a spin-off of RSSHub that helps you quickly discover and subscribe to RSS and RSSHub for your current site.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "undoclosetabbutton" = buildFirefoxXpiAddon {
      pname = "undoclosetabbutton";
      version = "7.5.0";
      addonId = "{4853d046-c5a3-436b-bc36-220fd935ee1d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3917941/undoclosetabbutton-7.5.0.xpi";
      sha256 = "5dc0a83f37797ee04850a45d3d73e8cf2371b7ed6720ba28926671fb246342be";
      meta = with lib;
      {
        homepage = "https://github.com/M-Reimer/undoclosetab";
        description = "Allows you to restore the tab you just closed with a single click—plus it can offer a list of recently closed tabs within a convenient context menu.";
        license = licenses.gpl3;
        platforms = platforms.all;
        };
      };
    }
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
    version = "1.10.1";
    addonId = "i@diygod.me";
    url = "https://addons.mozilla.org/firefox/downloads/file/4056771/rsshub_radar-1.10.1.xpi";
    sha256 = "6dc3c41ea1dd6079e9e26906803542180dbad4ff43a587afc91bc51b272dd736";
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

{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
{
  "certificate-pinner" = buildFirefoxXpiAddon {
    pname = "certificate-pinner";
    version = "0.17.10";
    addonId = "{9550e8a6-7884-43d1-ba9c-2c2928ab0a26}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3599612/certificate_pinner-0.17.10-an+fx.xpi";
    sha256 = "54b77a89a94156ce4cbdf372bfac1df222a13c776698bd91705714a118961e97";
    meta = with lib;
      {
        description = "Pins TLS certificates of configured web pages and interrupts/alerts when a new certificate is presented. Adds a button to the browser's toolbar for pinning and unpinning.";
        license = licenses.gpl2;
        platforms = platforms.all;
      };
  };
  "darkreader" = buildFirefoxXpiAddon {
    pname = "darkreader";
    version = "4.9.33";
    addonId = "addon@darkreader.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/3783471/dark_reader-4.9.33-an+fx.xpi";
    sha256 = "49e7ec13cfdb953dfb785a2442582788e895a5623956d0b7dff02f59db2e3159";
    meta = with lib;
      {
        homepage = "https://darkreader.org/";
        description = "Dark mode for every website. Take care of your eyes, use dark theme for night and daily browsing.";
        license = licenses.mit;
        platforms = platforms.all;
      };
  };
  "enhancer-for-youtube" = buildFirefoxXpiAddon {
    pname = "enhancer-for-youtube";
    version = "2.0.104.13";
    addonId = "enhancerforyoutube@maximerf.addons.mozilla.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/3803898/enhancer_for_youtubetm-2.0.104.13-fx.xpi";
    sha256 = "83dacb5ef1ecf82226437438b5b893f5b7d19c330c3e8c3712feb5a043c5b672";
    meta = with lib;
      {
        homepage = "https://www.mrfdev.com/enhancer-for-youtube";
        description = "Take control of YouTube and boost your user experience!";
        platforms = platforms.all;
      };
  };
  "facebook-container" = buildFirefoxXpiAddon {
    pname = "facebook-container";
    version = "2.2.1";
    addonId = "@contain-facebook";
    url = "https://addons.mozilla.org/firefox/downloads/file/3772109/facebook_container-2.2.1-fx.xpi";
    sha256 = "459b4273c3926b0a273614a46ddb7dffc091989e9dc602707f8a526abc2c26c9";
    meta = with lib;
      {
        homepage = "https://github.com/mozilla/contain-facebook";
        description = "Prevent Facebook from tracking you around the web. The Facebook Container extension for Firefox helps you take control and isolate your web activity from Facebook.";
        license = licenses.mpl20;
        platforms = platforms.all;
      };
  };
  "https-everywhere" = buildFirefoxXpiAddon {
    pname = "https-everywhere";
    version = "2021.4.15";
    addonId = "https-everywhere@eff.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/3760520/https_everywhere-2021.4.15-an+fx.xpi";
    sha256 = "8f6342077515669f73ae377346da4447428544559c870678488fa5b6b63d2500";
    meta = with lib;
      {
        homepage = "https://www.eff.org/https-everywhere";
        description = "Encrypt the web! HTTPS Everywhere is a Firefox extension to protect your communications by enabling HTTPS encryption automatically on sites that are known to support it, even when you type URLs or follow links that omit the https: prefix.";
        platforms = platforms.all;
      };
  };
  "lastpass-password-manager" = buildFirefoxXpiAddon {
    pname = "lastpass-password-manager";
    version = "4.75.0.4";
    addonId = "support@lastpass.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/3804007/lastpass_password_manager-4.75.0.4-an+fx.xpi";
    sha256 = "205aca771a76c7cb86702bae72ba8862ae2f83fc11919e3aedae51298975727f";
    meta = with lib;
      {
        homepage = "https://lastpass.com/";
        description = "LastPass, an award-winning password manager, saves your passwords and gives you secure access from every computer and mobile device.";
        platforms = platforms.all;
      };
  };
  "reddit-enhancement-suite" = buildFirefoxXpiAddon {
    pname = "reddit-enhancement-suite";
    version = "5.22.5";
    addonId = "jid1-xUfzOsOFlzSOXg@jetpack";
    url = "https://addons.mozilla.org/firefox/downloads/file/3784229/reddit_enhancement_suite-5.22.5-an+fx.xpi";
    sha256 = "213f1ada92bb9d2814e6760cf20a2dc3cf2cc31b503e2baa8fe2f784be6df11c";
    meta = with lib;
      {
        homepage = "https://redditenhancementsuite.com/";
        description = "Reddit Enhancement Suite (RES) is a suite of tools to enhance your Reddit browsing experience.";
        license = licenses.gpl3;
        platforms = platforms.all;
      };
  };
  "ublock-origin" = buildFirefoxXpiAddon {
    pname = "ublock-origin";
    version = "1.36.0";
    addonId = "uBlock0@raymondhill.net";
    url = "https://addons.mozilla.org/firefox/downloads/file/3798731/ublock_origin-1.36.0-an+fx.xpi";
    sha256 = "384f3e5241f87e90c376fb6964842ce204743feed554b8b7dabe09f119ea7d66";
    meta = with lib;
      {
        homepage = "https://github.com/gorhill/uBlock#ublock-origin";
        description = "Finally, an efficient wide-spectrum content blocker. Easy on CPU and memory.";
        license = licenses.gpl3;
        platforms = platforms.all;
      };
  };
}

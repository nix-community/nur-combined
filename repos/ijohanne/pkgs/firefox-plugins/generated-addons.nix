{ buildFirefoxXpiAddon, fetchurl, stdenv }:
{
  "certificate-pinner" = buildFirefoxXpiAddon {
    pname = "certificate-pinner";
    version = "0.17.10";
    addonId = "{9550e8a6-7884-43d1-ba9c-2c2928ab0a26}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3599612/certificate_pinner-0.17.10-an+fx.xpi";
    sha256 = "54b77a89a94156ce4cbdf372bfac1df222a13c776698bd91705714a118961e97";
    meta = with stdenv.lib;
      {
        description = "Pins TLS certificates of configured web pages and interrupts/alerts when a new certificate is presented. Adds a button to the browser's toolbar for pinning and unpinning.";
        license = licenses.gpl2;
        platforms = platforms.all;
      };
  };
  "darkreader" = buildFirefoxXpiAddon {
    pname = "darkreader";
    version = "4.9.26";
    addonId = "addon@darkreader.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/3684946/dark_reader-4.9.26-an+fx.xpi";
    sha256 = "5f2a2449524f5ab05c2e8568d2678c6b25795e87ce77ebc9448e13e8184e3c5f";
    meta = with stdenv.lib;
      {
        homepage = "https://darkreader.org/";
        description = "Dark mode for every website. Take care of your eyes, use dark theme for night and daily browsing.";
        license = licenses.mit;
        platforms = platforms.all;
      };
  };
  "enhancer-for-youtube" = buildFirefoxXpiAddon {
    pname = "enhancer-for-youtube";
    version = "2.0.101";
    addonId = "enhancerforyoutube@maximerf.addons.mozilla.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/3537917/enhancer_for_youtubetm-2.0.101-fx.xpi";
    sha256 = "b64c2f36b6fc93c22d2305bb25dd0af60c5f3d1fa7ce45592ba3344aa2a99715";
    meta = with stdenv.lib;
      {
        homepage = "https://www.mrfdev.com/enhancer-for-youtube";
        description = "Tons of features to improve your user experience on YouTube™.";
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
  "https-everywhere" = buildFirefoxXpiAddon {
    pname = "https-everywhere";
    version = "2020.11.17";
    addonId = "https-everywhere@eff.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/3679479/https_everywhere-2020.11.17-an+fx.xpi";
    sha256 = "a6ebcb0a05607e54e7a9fc0b5b3832eda6f13f8dce2ee802164a455919e385c9";
    meta = with stdenv.lib;
      {
        homepage = "https://www.eff.org/https-everywhere";
        description = "Encrypt the web! HTTPS Everywhere is a Firefox extension to protect your communications by enabling HTTPS encryption automatically on sites that are known to support it, even when you type URLs or follow links that omit the https: prefix.";
        platforms = platforms.all;
      };
  };
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
  "reddit-enhancement-suite" = buildFirefoxXpiAddon {
    pname = "reddit-enhancement-suite";
    version = "5.20.9";
    addonId = "jid1-xUfzOsOFlzSOXg@jetpack";
    url = "https://addons.mozilla.org/firefox/downloads/file/3652562/reddit_enhancement_suite-5.20.9-an+fx.xpi";
    sha256 = "115b010ceadaf5ddcb77739f557c2a4f59e73b668149ddc01b51b03633e3e9a0";
    meta = with stdenv.lib;
      {
        homepage = "https://redditenhancementsuite.com/";
        description = "Reddit Enhancement Suite (RES) is a suite of tools to enhance your Reddit browsing experience.";
        license = licenses.gpl3;
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
}

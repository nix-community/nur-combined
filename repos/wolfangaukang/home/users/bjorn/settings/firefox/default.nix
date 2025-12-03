{
  config,
  pkgs,
  lib,
}:

let
  inherit (pkgs.nur.repos.rycee) firefox-addons;
  inherit (lib) mkMerge;
  searchEngines = import ./engines.nix;

  settings = {
    search = {
      force = true;
      default = searchEngines.default;
      engines = searchEngines.enginesSet;
    };
    shutdown = {
      "browser.privatebrowsing.autostart" = true;
      "browser.startup.homepage" = "about:blank";
      # https://www.eff.org/https-everywhere/set-https-default-your-browser
      "dom.security.https_only_mode" = true;
      "privacy.clearOnShutdown.cache" = true;
      "privacy.clearOnShutdown.cookies" = true;
      "privacy.clearOnShutdown.downloads" = true;
      "privacy.clearOnShutdown.formdata" = true;
      "privacy.clearOnShutdown.history" = true;
      "privacy.clearOnShutdown.offlineApps" = true;
      "privacy.clearOnShutdown.openWindows" = true;
      "privacy.clearOnShutdown.sessions" = true;
      "privacy.clearOnShutdown.siteSettings" = true;
      "signon.rememberSignons" = false;
    };
  };

  base = {
    settings = {
      "browser.download.dir" = "${config.home.homeDirectory}/Elsxutujo";
      "browser.newtabpage.activity-stream.showSponsored" = false;
      "browser.tabs.warnOnClose" = false;
      "extensions.pocket.enabled" = false;
      "privacy.donottrackheader.enabled" = true;
      "privacy.trackingprotection.enabled" = true;
      "privacy.trackingprotection.socialtracking.enabled" = true;
      "ui.systemUsesDarkTheme" = 1;
    };
    extensions = with firefox-addons; [
      auto-tab-discard
      decentraleyes
      disable-javascript
      privacy-badger
      ublock-origin
      # 1: Following guide from EFF and dephasing the extension usage
      # https://www.eff.org/https-everywhere/set-https-default-your-browser
      #https-everywhere
    ];
    profiles = {
      default = {
        search = settings.search;
        name = "Sandbox";
        extensions.packages =
          base.extensions
          ++ (with firefox-addons; [
            darkreader
            privacy-redirect
          ]);
        settings = mkMerge [
          (base.settings)
          (settings.shutdown)
        ];
      };
      default-no-extensions = {
        search = settings.search;
        id = 1;
        name = "Sandbox (No extensions)";
        extensions.packages = (with firefox-addons; [ darkreader ]);
        settings = mkMerge [
          (base.settings)
          (settings.shutdown)
        ];
      };
    };
  };

  profiles = {
    personal = {
      search = settings.search;
      id = 2;
      name = "Personal";
      extensions.packages =
        base.extensions
        ++ (with firefox-addons; [
          addy_io
          darkreader
          multi-account-containers
          privacy-redirect
          video-downloadhelper
        ]);
      settings = base.settings;
    };
    gnaujep = {
      search = settings.search;
      id = 3;
      name = "Gnaujep";
      extensions.packages = base.extensions ++ (with firefox-addons; [ multi-account-containers ]);
      settings = base.settings;
    };
    j = {
      search = settings.search;
      id = 4;
      name = "J";
      extensions.packages = base.extensions ++ (with firefox-addons; [ multi-account-containers ]);
      settings = base.settings;
    };
    simplerisk = {
      search = settings.search;
      id = 2;
      name = "SimpleRisk";
      extensions.packages = base.extensions ++ (with firefox-addons; [ keybase ]);
      settings = base.settings;
    };
  };

in
{
  inherit profiles;
  defaultProfiles = base.profiles;
}

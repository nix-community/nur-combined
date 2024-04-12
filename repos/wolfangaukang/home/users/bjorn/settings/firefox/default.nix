{ config, pkgs, lib }:

let
  inherit (pkgs.nur.repos.rycee) firefox-addons;
  searchEngines = import ./engines.nix;

in
rec {
  package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    extraPolicies = {
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
    };
  };
  searchSettings = {
    force = true;
    default = searchEngines.default;
    engines = searchEngines.enginesSet;
  };
  baseSettings = {
    "browser.download.dir" = "${config.home.homeDirectory}/Elsxutujo";
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.tabs.warnOnClose" = false;
    "extensions.pocket.enabled" = false;
    "privacy.donottrackheader.enabled" = true;
    "privacy.trackingprotection.enabled" = true;
    "privacy.trackingprotection.socialtracking.enabled" = true;
  };
  baseExtensions = with firefox-addons; [
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
      search = searchSettings;
      name = "Sandbox";
      extensions = baseExtensions ++ (with firefox-addons; [ darkreader privacy-redirect ]);
      settings = lib.mkMerge [
        (baseSettings)
        {
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
        }
      ];
    };
    personal = {
      search = searchSettings;
      id = 1;
      name = "Personal";
      extensions = baseExtensions ++ (with firefox-addons; [
        addy_io
        darkreader
        multi-account-containers
        privacy-redirect
        video-downloadhelper
        # TODO: Missing keybase and VDH
      ]);
      settings = lib.mkMerge [
        (baseSettings)
      ];
    };
    gnaujep = {
      search = searchSettings;
      id = 2;
      name = "Gnaujep";
      extensions = baseExtensions ++ (with firefox-addons; [ multi-account-containers ]);
      settings = lib.mkMerge [
        (baseSettings)
      ];
    };
    j = {
      search = searchSettings;
      id = 3;
      name = "J";
      extensions = baseExtensions ++ (with firefox-addons; [ multi-account-containers ]);
      settings = lib.mkMerge [
        (baseSettings)
      ];
    };
  };
}

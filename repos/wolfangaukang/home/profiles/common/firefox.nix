{ pkgs
, lib
, firefox-pkg ? null
, extra-extensions ? [ ]
, ... }:

let
  inherit (pkgs.nur.repos.wolfangaukang) multifirefox vdhcoapp;
  inherit (pkgs.nur.repos.rycee) firefox-addons;

  defaultExtensions = with firefox-addons; [
    auto-tab-discard
    darkreader
    decentraleyes
    disable-javascript
    privacy-badger
    privacy-redirect
    ublock-origin
    # 1: Following guide from EFF and dephasing the extension usage
    # https://www.eff.org/https-everywhere/set-https-default-your-browser
    #https-everywhere
  ];

  defaultPkg = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    #cfg = {
    #  # Gnome shell native connector
    #  enableGnomeExtensions = true;
    #};
    extraNativeMessagingHosts = [ vdhcoapp ];
    extraPolicies = {
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
    };
  };

  defaultSettings = {
    "browser.download.dir" = "/home/bjorn/Elsxutujo";
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.tabs.warnOnClose" = false;
    "extensions.pocket.enabled" = false;
    "privacy.donottrackheader.enabled" = true;
    "privacy.trackingprotection.enabled" = true;
    "privacy.trackingprotection.socialtracking.enabled" = true;
  };


in {
  home.packages = [ multifirefox vdhcoapp ];
  programs.firefox = {
    enable = true;
    package = if firefox-pkg == null then defaultPkg else firefox-pkg;
    extensions = defaultExtensions ++ extra-extensions;
    profiles = 
      let
        defaultEngine = "DuckDuckGo";

      in {
        default = {
          name = "Sandbox";
          search.default = defaultEngine;
          settings = lib.mkMerge [
            (defaultSettings)
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
          id = 1;
          name = "Personal";
          search.default = defaultEngine;
          settings = lib.mkMerge [
            (defaultSettings)
          ];
        };
        gnaujep = {
          id = 2;
          name = "Gnaujep";
          search.default = defaultEngine;
          settings = lib.mkMerge [
            (defaultSettings)
          ];
        };
        j = {
          id = 3;
          name = "J";
          search.default = defaultEngine;
          settings = lib.mkMerge [
            (defaultSettings)
          ];
        };
    };
  };
}

{ pkgs
, self
, lib
, firefox-pkg ? null
, ... }:

let
  inherit (pkgs.nur.repos.wolfangaukang) multifirefox vdhcoapp;
  inherit (pkgs.nur.repos.rycee) firefox-addons;
  # FIXME: Find a way to limit this
  common = import "${self}/home/profiles/common/firefox" {
    inherit firefox-addons;
    lib = pkgs.lib;
  };
  searches = import "${self}/home/profiles/common/firefox/searches.nix";

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

in {
  home.packages = [ multifirefox vdhcoapp ];
  programs.firefox = {
    enable = true;
    package = if firefox-pkg == null then defaultPkg else firefox-pkg;
    profiles = 
      {
        default = {
          search = common.firefox.search;
          name = "Sandbox";
          extensions = common.firefox.extensions ++ (with firefox-addons; [ darkreader privacy-redirect ]);
          settings = lib.mkMerge [
            (common.firefox.settings)
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
          search = common.firefox.search;
          id = 1;
          name = "Personal";
          extensions = common.firefox.extensions ++ (with firefox-addons; [
            anonaddy
            darkreader
            multi-account-containers
            privacy-redirect
            # TODO: Missing keybase and VDH
          ]);
          settings = lib.mkMerge [
            (common.firefox.settings)
          ];
        };
        gnaujep = {
          search = common.firefox.search;
          id = 2;
          name = "Gnaujep";
          extensions = common.firefox.extensions ++ (with firefox-addons; [ multi-account-containers ]);
          settings = lib.mkMerge [
            (common.firefox.settings)
          ];
        };
        j = {
          search = common.firefox.search;
          id = 3;
          name = "J";
          extensions = common.firefox.extensions ++ (with firefox-addons; [ multi-account-containers ]);
          settings = lib.mkMerge [
            (common.firefox.settings)
          ];
        };
    };
  };
}

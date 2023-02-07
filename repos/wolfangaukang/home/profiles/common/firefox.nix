{ pkgs
, self
, lib
, firefox-pkg ? null
, ... }:

let
  inherit (pkgs.nur.repos.wolfangaukang) multifirefox vdhcoapp;
  inherit (pkgs.nur.repos.rycee) firefox-addons;
  common = import "${self}/home/profiles/common.nix" { inherit firefox-addons; };

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
      let
        search = common.firefox.search;
      in {
        default = {
          inherit search;
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
          inherit search;
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
          inherit search;
          id = 2;
          name = "Gnaujep";
          extensions = common.firefox.extensions ++ (with firefox-addons; [ multi-account-containers ]);
          settings = lib.mkMerge [
            (common.firefox.settings)
          ];
        };
        j = {
          inherit search;
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

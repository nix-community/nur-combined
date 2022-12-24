{ pkgs, lib, ... }:

let
  ff_common_settings = {
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.tabs.warnOnClose" = false;
    "extensions.pocket.enabled" = false;
    "privacy.donottrackheader.enabled" = true;
    "privacy.trackingprotection.enabled" = true;
    "privacy.trackingprotection.socialtracking.enabled" = true;
  };

  wolfangaukang_nur = pkgs.nur.repos.wolfangaukang;
  inherit (wolfangaukang_nur) multifirefox vdhcoapp;

in {
  home.packages = [ multifirefox vdhcoapp ];
  programs.firefox = {
    enable = true;
    #package = pkgs.firefox.override {
    package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
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
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      auto-tab-discard
      darkreader
      decentraleyes
      disable-javascript
      https-everywhere
      privacy-badger
      privacy-redirect
      ublock-origin
    ];
    profiles = {
      default = {
        name = "Sandbox";
        settings = lib.mkMerge [
          (ff_common_settings)
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
        settings = lib.mkMerge [
          (ff_common_settings)
        ];
      };
    };
  };
}

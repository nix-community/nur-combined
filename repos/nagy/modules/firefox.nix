{
  config,
  lib,
  pkgs,
  nur,
  ...
}:

let
  cfg = config.nagy.firefox;
in
{
  options.nagy.firefox = {
    enable = lib.mkEnableOption "firefox config";
  };
  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      policies = {
        Cookies = {
          AcceptThirdParty = "never";
          Behavior = "reject-tracker-and-partition-foreign";
          ExpireAtSessionEnd = true;
          Locked = false;
        };
        # DisableAppUpdate = true;  # already implemented in the module itself
        DisableFirefoxAccounts = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisableProfileRefresh = true;
        DisableFeedbackCommands = true;
        DisableSetDesktopBackground = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        Homepage = {
          URL = "about:home";
          Locked = false;
          StartPage = "homepage";
        };
        FirefoxHome = {
          Search = true;
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          SponsoredPocket = false;
          Snippets = false;
          Locked = false;
        };
        SearchSuggestEnabled = false;
      };
      preferences = {
        "general.smoothScroll" = false;
        "browser.aboutConfig.showWarning" = false;
        "dom.image-lazy-loading.enabled" = false;
        # "dom.iframe_lazy_loading.enabled" = false;
        "pdfjs.enableScripting" = false;
        "pdfjs.defaultZoomValue" = "page-fit";
        "pdfjs.sidebarViewOnLoad" = 2; # -1 is the default, 1 means thumbnail bar, 2 means outline
        # "browser.urlbar.dnsResolveSingleWordsAfterSearch" = 0;
        "browser.display.background_color.dark" = "#000000";
      };
    };

    # Firefox connects to these hosts on every start.
    # Hard disable them on the whole host.
    networking.hosts = {
      "0.0.0.0" = [
        "content-signature-2.cdn.mozilla.net"
        # maybe this one can still be disabled via `about:config`
        "firefox.settings.services.mozilla.com"
      ];
    };

    # From https://nixos.wiki/wiki/Firefox
    # You can make Firefox use xinput2 by setting the MOZ_USE_XINPUT2 environment
    # variable. This improves touchscreen support and enables additional touchpad
    # gestures. It also enables smooth scrolling as opposed to the stepped
    # scrolling that Firefox has by default.
    environment.sessionVariables = lib.mkIf config.services.xserver.enable { MOZ_USE_XINPUT2 = "1"; };
  };
}

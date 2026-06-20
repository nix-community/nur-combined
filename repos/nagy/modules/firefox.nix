{
  config,
  lib,
  pkgs,
  nur,
  ...
}:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-esr-140;
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
      Extensions =
        let
          makeXpiPath =
            addon:
            "${addon}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${addon.addonId}.xpi";
        in
        {
          Install = [
            # "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
            (makeXpiPath nur.repos.rycee.firefox-addons.ublock-origin)
            # "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi"
            (makeXpiPath nur.repos.rycee.firefox-addons.vimium)
            # "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi"
            (makeXpiPath nur.repos.rycee.firefox-addons.darkreader)
            # "https://addons.mozilla.org/firefox/downloads/latest/old-reddit-redirect/latest.xpi"
            (makeXpiPath nur.repos.rycee.firefox-addons.old-reddit-redirect)
            # # "https://addons.mozilla.org/firefox/downloads/latest/toggley/latest.xpi"
            # (makeXpiPath nur.repos.rycee.firefox-addons.toggley)

            # absolute file paths work here as well
            # https://github.com/mozilla/policy-templates#policiesjson-47
          ];
          Uninstall = [
            "amazon@search.mozilla.org"
            "bing@search.mozilla.org"
            "google@search.mozilla.org"
            "wikipedia@search.mozilla.org"
          ];
        };
      SearchEngines = {
        Remove = [
          "Amazon"
          "Bing"
          # "Google"
          "Twitter"
          "Wikipedia"
          "Yahoo"
        ];
        Default = "Google";
      };
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
      "browser.display.foreground_color.dark" = "#FFFFFF";
      "browser.display.background_color.dark" = "#000000";

      # https://support.mozilla.org/en-US/questions/1287625
      "dom.push.enabled" = false;
      "dom.webnotifications.enabled" = false;
      "notification.feature.enabled" = false; # this was not present in about:config

      "browser.safebrowsing.enabled" = false;
      "browser.safebrowsing.downloads.enabled" = false;
      "browser.safebrowsing.downloads.remote.enabled" = false;
      "browser.safebrowsing.downloads.remote.url" = "";
      "browser.safebrowsing.malware.enabled" = false;
      "browser.safebrowsing.phishing.enabled" = false;

      "browser.translations.enable" = false;

      "network.dns.disablePrefetch" = true;
      "network.dns.disablePrefetchFromHTTPS" = true;
      "network.captive-portal-service.enabled" = false;
      # https://wiki.archlinux.org/title/Firefox/Privacy#Disable/enforce_'Trusted_Recursive_Resolver'
      "network.trr.mode" = 5;
      # "geo.enabled" = false;
      # "beacon.enabled" = false;
      # "network.stricttransportsecurity.preloadlist" = false;
      # "network.http.sendRefererHeader" = 2; # 0 never send header, 1 only on click, 2 (default) send for all requests
      "network.http.referer.XOriginPolicy" = 1; # 0 is default, 1 means only send when base domain matches, 2 means only send when full domain matches
      # Disallow web mail clients to ask to set themselves as an app
      "network.protocol-handler.external.mailto" = false;

      "browser.urlbar.suggest.calculator" = true;

      # No need to check for blocked extensions
      # "extensions.blocklist.enabled" = false;

      "browser.tabs.crashReporting.sendReport" = false;
      "browser.tabs.firefox-view" = false;
      # "browser.fixup.dns_first_for_single_words" = true;
      "browser.fixup.domainsuffixwhitelist.meship" = true;
      "browser.fixup.domainsuffixwhitelist.ygg" = true;
      "browser.fixup.domainsuffixwhitelist.anon" = true;
      "browser.fixup.domainsuffixwhitelist.glue" = true; # OpenNIC
      "browser.fixup.fallback-to-https" = false;

      "widget.gtk.overlay-scrollbars.enabled" = false;
      "widget.non-native-theme.scrollbar.size.override" = 20;
      "widget.non-native-theme.scrollbar.style" = 4; # sharp corners

      "media.autoplay.default" = 5; # block audio and video by default
      # "media.autoplay.enabled" = true;
      # "media.eme.enabled" = false;
      "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
      "media.webspeech.synth.enabled" = false;
      # "browser.eme.ui.enabled" = false;

      # https://support.mozilla.org/en-US/kb/privacy-preserving-attribution?as=u&utm_source=inproduct
      # https://michael.kjorling.se/blog/2024/disabling-privacy-preserving-ad-measurement-in-firefox-128/
      "dom.private-attribution.submission.enabled" = false;

      # No more search by url bar typing
      "keyword.enabled" = false;

      # Disable favicons
      "browser.chrome.site_icons" = false;

      # HIDDEN PREF: disable recommendation pane in about:addons (uses Google Analytics)
      "extensions.getAddons.showPane" = false;
      # recommendations in about:addons' Extensions and Themes panes [FF68+]
      "extensions.htmlaboutaddons.recommendations.enabled" = false;

      # From here https://git.sr.ht/~toastal/nixcfg/tree/trunk/item/program/browser/firefox/settings.nix
      "browser.uidensity" = 1;

      # Disable open264 plugin
      "media.gmp-gmpopenh264.enabled" = false;

      # "media.navigator.enabled" = false; # Disable mic and camera
      # "media.peerconnection.enabled" = false; # Disable WebRTC

      # Disable expensive backdrop filter CSS property (performance, recommended for old and slow computers only):
      # "layout.css.backdrop-filter.enabled" = false;
      "layout.css.visited_links_enabled" = false;

      # Remove AI chatbot integration (sidebar, context menu):
      "browser.ml.enabled" = false;
      "browser.ml.chat.enabled" = false;

      # https://superuser.com/questions/1568072/hide-navigation-bar-in-firefox
      "full-screen-api.ignore-widgets" = true;

      # "browser.altClickSave" = true;
    };
  };

  # Firefox connects to these hosts on every start.
  # Hard disable them on the whole host.
  networking.hosts = {
    "0.0.0.0" = [
      "content-signature-2.cdn.mozilla.net"
      # Maybe this one can still be disabled via `about:config`
      "firefox.settings.services.mozilla.com"
    ];
  };

  # From https://nixos.wiki/wiki/Firefox
  # You can make Firefox use xinput2 by setting the MOZ_USE_XINPUT2 environment
  # variable. This improves touchscreen support and enables additional touchpad
  # gestures. It also enables smooth scrolling as opposed to the stepped
  # scrolling that Firefox has by default.
  environment.sessionVariables = lib.mkIf config.services.xserver.enable {
    MOZ_USE_XINPUT2 = "1";
    MOZ_CRASHREPORTER_DISABLE = "1";
  };

}

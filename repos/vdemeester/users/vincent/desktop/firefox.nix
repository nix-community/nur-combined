{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    # Temporary fix
    # https://github.com/nix-community/home-manager/issues/1641
    # (https://github.com/NixOS/nixpkgs/pull/105796)
    package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
      extraPolicies = {
        ExtensionSettings = { };
        CaptivePortal = false;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        # DisableFirefoxAccounts = true;
        FirefoxHome = {
          Pocket = false;
          # Snippets = false;
        };
        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
        };
      };
    };
    
    profiles.default = {
      id = 0;
      isDefault = true;
      settings = {
        "general.warnOnAboutConfig" = false;
        "browser.aboutConfig.showWarning" = false;
        # It keeps asking me on startup if I want firefox as default
        "browser.shell.checkDefaultBrowser" = false;
        # Disable pocket
        "extensions.pocket.enabled" = false;
        "extensions.pocket.site" = "";
        "extensions.pocket.oAuthConsumerKey" = "";
        "extensions.pocket.api" = "";
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        # performance
        "browser.download.animateNotifications" = false;
        "browser.tabs.animate" = false;
        "toolkit.cosmeticAnimations.enabled" = false;
        "html5.offmainthread" = true;
        "layers.acceleration.force-enabled" = true;
        "layers.async-video.enabled" = true;
        "layers.offmainthreadcomposition.async-animations" = true;
        "layers.offmainthreadcomposition.enabled" = true;
        "layout.frame_rate.precise" = true;
        "webgl.force-enabled" = true;
        "gfx.xrender.enabled" = true;
        "gfx.webrender.all" = true;
        "gfx.webrender.enable" = true;
        # Misc
        "privacy.donottrackheader.enabled" = true;
        # "privacy.firstparty.isolate" = true;
        #"privacy.resistFingerprinting" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        # FIXME(vdemeester) Enable thoses
        #"privacy.clearOnShutdown.history" = true;
        #"privacy.clearOnShutdown.siteSettings" = true;
        "browser.formfill.enable" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "browser.safebrowsing.enabled" = false;
        "browser.search.geoip.url" = "";
        "browser.selfsupport.url" = "";
        "browser.send_pings" = false;
        "browser.send_pings.require_same_host" = true;
        "browser.sessionstore.privacy_level" = 2;
        "browser.startup.homepage_override.buildID" = "";
        "browser.startup.homepage_override.mstone" = "ignore";
        "browser.urlbar.speculativeConnect.enabled" = false;
        "browser.contentblocking.category" = "strict";
        "browser.ctrlTab.recentlyUsedOrder" = false;
        "network.dns.disablePrefetch" = true;
        "network.dnsCacheEntries" = 100;
        "network.dnsCacheExpiration" = 60;
        #"network.http.referer.XOriginPolicy" = 2;
        #"network.http.referer.XOriginTrimmingPolicy" = 2;
        #"network.http.referer.spoofSource" = true;
        "network.http.sendRefererHeader" = 2;
        #"network.http.sendSecureXSiteReferrer" = false;
        #"network.http.speculative-parallel-limit" = 0;
        "network.predictor.enabled" = false;
        "network.prefetch-next" = false;
        "media.peerconnection.enabled" = false;
        "media.peerconnection.turn.disable" = true;
        "media.peerconnection.video.enabled" = false;
        "media.peerconnection.identity.timeout" = 1;
        "dom.battery.enabled" = false;
        # "dom.event.clipboardevents.enabled" = false;
        "dom.event.contextmenu.enabled" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.cachedClientID" = "";
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.hybridContent.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "toolkit.telemetry.server" = "";
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        # Red Hat specific
        "network.negotiate-auth.trusted-uris" = ".redhat.com";
      };
    };
    profiles.redhat = {
      id = 1;
    };
  };
}

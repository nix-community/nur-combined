{ config, pkgs, ... }:
let
  packageSettings =
    if pkgs.stdenv.isDarwin then { package = pkgs.firefox-bin; } else { };

  addons = with pkgs.nur.repos.rycee.firefox-addons; [
    decentraleyes
    keepassxc-browser
    multi-account-containers
    noscript
    privacy-badger
    temporary-containers
    terms-of-service-didnt-read
    ublock-origin
    user-agent-string-switcher
  ];
  # TODO: see if aarch can be supported upstream for this language set
  languagePacks =
    if (builtins.hasAttr "firefox-langpack-en-GB" pkgs.nur.repos.sigprof) then
      with pkgs.nur.repos.sigprof; [ firefox-langpack-en-GB ]
    else
      [ ];
  dictionaries = with pkgs.nur.repos.JayRovacsek; [ better-english ];
  extensions = addons ++ languagePacks ++ dictionaries;
in {
  programs.firefox = {
    enable = true;
    inherit extensions;

    profiles.jay = {
      search = {
        force = true;
        default = "DuckDuckGo";
        order = [ "DuckDuckGo" ];
        engines = {
          "Bing".metaData.hidden = true;
          "eBay".metaData.hidden = true;
          "Google".metaData.hidden = true;
          "Wikipedia (en)".hidden = true;
        };
      };
      bookmarks = {
        "Duck Duck Go" = {
          keyword = "d";
          url = "https://duckduckgo.com/?q=%s";
        };
        "Google Search" = {
          keyword = "g";
          url = "https://www.google.com/search?q=%s";
        };
        "Google AU Search" = {
          keyword = "ga";
          url = "https://www.google.com.au/search?q=%a";
        };
        "Youtube" = {
          keyword = "y";
          url = "https://www.youtube.com/results?search_query=%s";
        };
        "Github Search" = {
          keyword = "gh";
          url = "https://github.com/search?q=%s";
        };
        "Github Search for Nix" = {
          keyword = "ghn";
          url =
            "https://github.com/search?q=%s+language%3ANix&type=Code&ref=advsearch&l=Nix&l=";
        };
        "Github Code Search" = {
          keyword = "cs";
          url = "https://cs.github.com/?scopeName=All+repos&scope=&q=%s";
        };
        "Github Nix Code Search" = {
          keyword = "ncs";
          url =
            "https://cs.github.com/?scopeName=All+repos&scope=&q=%s+language%3Anix";
        };
        "Dockerhub Search" = {
          keyword = "dh";
          url = "https://hub.docker.com/search?q=%s";
        };
        "Nix Pkg Search" = {
          keyword = "np";
          url =
            "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&query=%s";
        };
        "Nix Options Search" = {
          keyword = "no";
          url =
            "https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&query=%s";
        };
        "Nix Uber Search" = {
          keyword = "ns";
          url =
            "https://search.nix.gsc.io/?q=%s&i=nope&files=&excludeFiles=&repos=";
        };
        "nib Jira Search" = {
          keyword = "j";
          url =
            "https://jira.nib.com.au/issues/?jql=text~%22%s%22%20or%20description%20~%20%22%s%22%20or%20summary%20~%20%22%s%22";
        };
        "nib Confluence Search" = {
          keyword = "c";
          url =
            "https://confluence.nib.com.au/dosearchsite.action?cql=siteSearch+~+%22%s%22&queryString=%s";
        };
        "nib Github Search" = {
          keyword = "ngh";
          url = "https://github.com/nib-group?q=%s&type=&language=";
        };
        OSRSWiki = {
          keyword = "osrs";
          url =
            "https://oldschool.runescape.wiki/?search=%s&title=Special%3ASearch&fulltext=Search";
        };
      };

      settings = {
        "accessibility.force_disabled" = 1;
        "app.normandy.api_url" = "";
        "app.normandy.enabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "app.update.auto" = false;
        "app.update.background.scheduling.enabled" = false;
        "beacon.enabled" = false;
        "breakpad.reportURL" = "";
        "browser.aboutConfig.showWarning" = false;
        "browser.bookmarks.max_backups" = 2;
        "browser.cache.disk.capacity" = 1048576;
        "browser.cache.disk.enable" = false;
        "browser.cache.memory.capacity" = -1;
        "browser.cache.memory.enable" = true;
        "browser.cache.offline.enable" = false;
        "browser.contentblocking.category" = "strict";
        "browser.crashReports.unsubmittedCheck.autoSubmit" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        "browser.crashReports.unsubmittedCheck.enabled" = false;
        "browser.disableResetPrompt" = true;
        "browser.discovery.enabled" = false;
        "browser.display.use_system_colors" = true;
        "browser.download.manager.addToRecentDocs" = false;
        "browser.download.useDownloadDir" = false;
        "browser.fixup.alternate.enabled" = false;
        "browser.formfill.enable" = false;
        "browser.helperApps.deleteTempFileOnExit" = true;
        "browser.messaging-system.whatsNewPanel.enabled" = false;
        "browser.newtab.preload" = false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" =
          false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.newtabpage.enabled" = false;
        "browser.newtabpage.enhanced" = false;
        "browser.newtabpage.introShown" = true;
        "browser.pagethumbnails.capturing_disabled" = true;
        "browser.ping-centre.telemetry" = false;
        "browser.privatebrowsing.forceMediaMemoryCache" = true;
        "browser.region.network.url" = "";
        "browser.region.update.enabled" = false;
        "browser.safebrowsing.allowOverride" = true;
        "browser.safebrowsing.appRepURL" = "";
        "browser.safebrowsing.blockedURIs.enabled" = false;
        "browser.safebrowsing.downloads.enabled" = false;
        "browser.safebrowsing.downloads.remote.enabled" = false;
        "browser.safebrowsing.downloads.remote.url" = "";
        "browser.safebrowsing.enabled" = false;
        "browser.safebrowsing.malware.enabled" = false;
        "browser.safebrowsing.phishing.enabled" = false;
        "browser.search.context.loadInBackground" = false;
        "browser.search.separatePrivateDefault.urlbarResult.enabled" = true;
        "browser.search.suggest.enabled" = false;
        "browser.search.update" = false;
        "browser.selfsupport.url" = "";
        "browser.send_pings" = false;
        "browser.sessionstore.privacy_level" = 2;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.ssl_override_behavior" = 1;
        "browser.startup.homepage_override.mstone" = "ignore";
        "browser.startup.homepage" = "about:blank";
        "browser.startup.page" = 0;
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.uitour.enabled" = false;
        "browser.uitour.url" = "";
        "browser.urlbar.groupLabels.enabled" = false;
        "browser.urlbar.quicksuggest.enabled" = false;
        "browser.urlbar.speculativeConnect.enabled" = false;
        "browser.urlbar.trimURLs" = false;
        "browser.xul.error_pages.expert_bad_cert" = true;
        "datareporting.healthreport.service.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "device.sensors.ambientLight.enabled" = false;
        "device.sensors.enabled" = false;
        "device.sensors.motion.enabled" = false;
        "device.sensors.orientation.enabled" = false;
        "device.sensors.proximity.enabled" = false;
        "dom.battery.enabled" = false;
        "dom.security.https_only_mode_ever_enabled" = true;
        "dom.security.https_only_mode" = true;
        "dom.webaudio.enabled" = false;
        "experiments.activeExperiment" = false;
        "experiments.enabled" = false;
        "experiments.manifest.uri" = "";
        "experiments.supported" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.available" = "off";
        "extensions.formautofill.creditCards.available" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "extensions.formautofill.heuristics.enabled" = false;
        "extensions.getAddons.cache.enabled" = false;
        "extensions.getAddons.showPane" = false;
        "extensions.pocket.enabled" = false;
        "extensions.shield-recipe-client.api_url" = "";
        "extensions.shield-recipe-client.enabled" = false;
        "extensions.webservice.discoverURL" = "";
        "keyword.enabled" = false;
        "media.autoplay.default" = 1;
        "media.autoplay.enabled" = false;
        "media.eme.enabled" = false;
        "media.gmp-widevinecdm.enabled" = false;
        "media.memory_cache_max_size" = 65536;
        "media.navigator.enabled" = false;
        "media.peerconnection.enabled" = false;
        "media.video_stats.enabled" = false;
        "network.allow-experiments" = false;
        "network.captive-portal-service.enabled" = false;
        "network.cookie.cookieBehavior" = 1;
        "network.dns.disablePrefetch" = true;
        "network.dns.disablePrefetchFromHTTPS" = true;
        "network.http.speculative-parallel-limit" = 0;
        "network.predictor.enable-prefetch" = false;
        "network.predictor.enabled" = false;
        "network.prefetch-next" = false;
        "network.protocol-handler.external.ms-windows-store" = false;
        "network.proxy.socks_remote_dns" = true;
        "network.trr.mode" = 3;
        "network.trr.uri" = "https://doh.libredns.gr/dns-query";
        "pdfjs.disabled" = true;
        "pdfjs.enableScripting" = false;
        "permissions.delegation.enabled" = false;
        "permissions.manager.defaultsUrl" = "";
        "privacy.clearOnShutdown.cache" = true;
        "privacy.clearOnShutdown.cookies" = false;
        "privacy.clearOnShutdown.downloads" = true;
        "privacy.clearOnShutdown.formdata" = true;
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.offlineApps" = true;
        "privacy.clearOnShutdown.sessions" = false;
        "privacy.clearOnShutdown.siteSettings" = false;
        "privacy.cpd.cache" = true;
        "privacy.cpd.cookies" = true;
        "privacy.cpd.formdata" = true;
        "privacy.cpd.history" = true;
        "privacy.cpd.passwords" = false;
        "privacy.cpd.sessions" = true;
        "privacy.cpd.siteSettings" = false;
        "privacy.donottrackheader.enabled" = true;
        "privacy.donottrackheader.value" = 1;
        "privacy.query_stripping" = true;
        "privacy.resistFingerprinting.block_mozAddonManager" = true;
        "privacy.resistFingerprinting.letterboxing" = false;
        "privacy.resistFingerprinting" = true;
        "privacy.sanitize.sanitizeOnShutdown" = true;
        "privacy.sanitize.timeSpan" = 0;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.trackingprotection.pbmode.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.usercontext.about_newtab_segregation.enabled" = true;
        "privacy.userContext.enabled" = true;
        "privacy.userContext.ui.enabled" = true;
        "privacy.window.name.update.enabled" = true;
        "security.ask_for_password" = 2;
        "security.cert_pinning.enforcement_level" = 2;
        "security.csp.enable" = true;
        "security.dialog_enable_delay" = 1000;
        "security.family_safety.mode" = 0;
        "security.insecure_connection_text.enabled" = true;
        "security.mixed_content.block_display_content" = true;
        "security.OCSP.enabled" = 1;
        "security.OCSP.require" = false;
        "security.password_lifetime" = 5;
        "security.pki.crlite_mode" = 2;
        "security.pki.sha1_enforcement_level" = 1;
        "security.remote_settings.crlite_filters.enabled" = true;
        "security.ssl.disable_session_identifiers" = true;
        "security.ssl.require_safe_negotiation" = true;
        "security.ssl.treat_unsafe_negotiation_as_broken" = true;
        "security.tls.enable_0rtt_data" = false;
        "security.tls.version.enable-deprecated" = false;
        "services.sync.prefs.sync-seen.browser.search.update" = true;
        "services.sync.prefs.sync.browser.newtabpage.activity-stream.redTopSite" =
          false;
        "services.sync.prefs.sync.browser.startup.homepage" = true;
        "services.sync.prefs.sync.browser.startup.page" = true;
        "signon.autofillForms" = false;
        "signon.formlessCapture.enabled" = false;
        "signon.rememberSignons" = false;
        "spellchecker.dictionary" = "en-GB";
        "toolkit.coverage.endpoint.base" = "";
        "toolkit.coverage.opt-out" = true;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.cachedClientID" = "";
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.hybridContent.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.prompted" = 2;
        "toolkit.telemetry.rejected" = true;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "toolkit.telemetry.server" = "";
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.unifiedIsOptIn" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.winRegisterApplicationRestart" = false;
        "webchannel.allowObject.urlWhitelist" = "";
        "webgl.renderer-string-override" = "";
        "webgl.vendor-string-override" = "";
        "widget.non-native-theme.enabled" = true;
      };
    };
  } // packageSettings;
}

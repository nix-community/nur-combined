{ config, lib, pkgs, ... }:

let
  inherit (builtins) toJSON;
  inherit (config) host;
  inherit (lib) concatLines filterAttrs mapAttrsToList;

  toUserJs = kv: concatLines (mapAttrsToList
    (k: v: "user_pref(${toJSON k}, ${toJSON v});")
    (filterAttrs (k: v: v != null) kv));
in
{
  home.packages = with pkgs; [
    firefox
  ];

  host.firefox.settings = {
    # Persist session
    "browser.sessionstore.warnOnQuit" = true;
    "browser.startup.page" = 3 /* restore session */;

    # Disable new tab page
    "browser.startup.homepage" = "about:blank";
    "browser.newtabpage.enabled" = false;

    # Disable extension recommendations
    "browser.discovery.enabled" = false;
    "extensions.getAddons.showPane" = false;
    "extensions.htmlaboutaddons.recommendations.enabled" = false;

    # Disable user experiments
    "app.normandy.enabled" = false;
    "app.shield.optoutstudies.enabled" = false;

    # Disable crash reports
    "browser.tabs.crashReporting.sendReport" = false;

    # Disable reporting binary file downloads to Google
    "browser.safebrowsing.downloads.remote.enabled" = false;

    # Disable prefetching
    "browser.urlbar.speculativeConnect.enabled" = false;
    "network.dns.disablePrefetch" = true;
    "network.http.speculative-parallel-limit" = 0;
    "network.predictor.enabled" = false;
    "network.prefetch-next" = false;

    # Enable DNS-over-HTTPS
    "network.trr.mode" = 2 /* on with native fallback */;
    "network.trr.excluded-domains" = "home.arpa";

    # Disable address guessing
    "browser.fixup.alternate.enabled" = false;
    "browser.urlbar.dnsResolveSingleWordsAfterSearch" = 0;

    # Disable remote address suggestions
    "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
    "browser.urlbar.suggest.quicksuggest.sponsored" = false;

    # Show address suggestions above search suggestions
    "browser.urlbar.showSearchSuggestionsFirst" = false;

    # Disable automatic form filling
    "browser.formfill.enable" = false;
    "extensions.formautofill.available" = "off";
    "extensions.formautofill.addresses.enabled" = false;
    "extensions.formautofill.creditCards.enabled" = false;

    # Disable writing ephemeral data to persistent storage
    "browser.privatebrowsing.forceMediaMemoryCache" = true;

    # Require certificate revocation check
    "security.OCSP.require" = true;

    # Block insecure subresources
    "security.mixed_content.block_display_content" = true;

    # Prefer HTTPS
    "dom.security.https_only_mode" = true;
    "dom.security.https_only_mode_send_http_background_request" = false;

    # Warn about CVE-2009-3555 vulnerability
    "security.ssl.treat_unsafe_negotiation_as_broken" = true;

    # Show details of TLS failures
    "browser.xul.error_pages.expert_bad_cert" = true;

    # Enable containers
    "privacy.userContext.enabled" = true;
    "privacy.userContext.ui.enabled" = true;

    # Disable interface tour
    "browser.uitour.enabled" = false;

    # Enable enhanced tracking protection (includes DNT, TCP)
    "browser.contentblocking.category" = "strict";

    # Partition service workers
    "privacy.partition.serviceWorkers" = true;

    # Enable spell checking in all text fields
    "layout.spellcheckDefault" = 2 /* single- and multi-line */;

    # Copy pretty URLs from address bar
    "browser.urlbar.decodeURLsOnCopy" = true;

    # Disable Pocket
    "extensions.pocket.enabled" = false;

    # Disable profile reset prompt
    "browser.disableResetPrompt" = true;

    # Use DuckDuckGo in private browsing
    "browser.search.separatePrivateDefault" = true;
    "browser.search.separatePrivateDefault.ui.enabled" = true;
    "browser.urlbar.placeholderName.private" = "DuckDuckGo";

    # Highlight all find text matches
    "findbar.highlightAll" = true;

    # Configure fonts
    "font.default.x-western" = "sans-serif";
    "font.name.monospace.x-western" = "Iosevka Custom Mono";
    "font.name.sans-serif.x-western" = "Roboto";
    "font.name-list.emoji" = "Noto Color Emoji";

    # Enable pre-release CSS
    "layout.css.has-selector.enabled" = true;
  };

  home.file.".mozilla/firefox/${host.firefox.profile}/chrome/userChrome.css".source = ../resources/userChrome.css;

  home.file.".mozilla/firefox/${host.firefox.profile}/user.js".text = toUserJs host.firefox.settings;
}

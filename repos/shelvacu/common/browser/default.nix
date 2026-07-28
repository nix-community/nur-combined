{
  config,
  lib,
  vaculib,
  vacuModuleType,
  ...
}:
let
  vary = {
    which = [
      "nixos"
      "nixpkgs"
    ];
    stable = [
      true
      false
    ];
  };
  mkEngine =
    { which, stable }:
    let
      stabilityName = if stable then "stable" else "unstable";
    in
    {
      Name =
        {
          nixos = "NixOS";
          nixpkgs = "Nixpkgs";
        }
        .${which}
        + " Manual ${stabilityName}";
      URLTemplate = "https://nixos.org/manual/${which}/${stabilityName}";
      Alias =
        let
          name =
            {
              nixos = "no";
              nixpkgs = "np";
            }
            .${which};
          manual = "m";
          stability = if stable then "" else "u";
        in
        "!" + name + manual + stability;
    };
  engines = lib.mapCartesianProduct mkEngine vary;
  amoUrl = amoId: "https://addons.mozilla.org/firefox/downloads/latest/${amoId}/latest.xpi";
  # list of extension ids
  # get extension id for installed extension by looking at about:debugging#/runtime/this-firefox
  extensions = [
    # keep-sorted start
    "@react-devtools"
    "addon@darkreader.org"
    "firefox-extension@steamdb.info"
    "firefox@betterttv.net"
    "gdpr@cavi.au.dk" # consent-o-matic
    "jid1-BoFifL9Vbdl2zQ@jetpack" # decentraleyes
    "myallychou@gmail.com" # Unhook
    "sponsorBlocker@ajay.app"
    "uBlock0@raymondhill.net"
    "{0d7cafdd-501c-49ca-8ebb-e3341caaa55e}" # youtube-nonstop
    "{446900e4-71c2-419f-a6a7-df9c091e268b}" # bitwarden-password-manager
    "{531906d3-e22f-4a6c-a102-8057b88a1a63}" # singlefile
    "{73a6fe31-595d-460b-a920-fcc0f8843232}" # noscript
    "{74145f27-f039-47ce-a470-a662b129930a}" # clearurls
    # keep-sorted end
  ];
in
lib.optionalAttrs (vacuModuleType == "nixos") {
  imports = vaculib.directoryGrabberList ./.;
  programs.firefox = {
    enable = lib.mkIf config.vacu.isGui true;
    policies = {
      # Docs: https://mozilla.github.io/policy-templates/
      SearchEngines.Add = [
        # keep-sorted start block=yes
        {
          Name = "Aliexpress";
          URLTemplate = "https://www.aliexpress.us/w/wholesale-{searchTerms}.html";
          Alias = "!ali";
        }
        {
          Name = "Amazon";
          URLTemplate = "https://www.amazon.com/s?k={searchTerms}";
          Alias = "!a";
        }
        {
          Name = "Kagi";
          URLTemplate = "https://kagi.com/search?q={searchTerms}";
        }
        {
          Name = "NixOS Options";
          URLTemplate = "https://search.nixos.org/options?channel=26.05&query={searchTerms}";
          Alias = "!no";
        }
        {
          Name = "NixOS Packages";
          URLTemplate = "https://search.nixos.org/packages?channel=26.051&query={searchTerms}";
          Alias = "!np";
        }
        {
          Name = "Python Docs";
          UrlTemplate = "https://docs.python.org/3/search.html?q={searchTerms}";
          Alias = "!py";
        }
        {
          Name = "Walmart";
          URLTemplate = "https://www.walmart.com/search?q={searchTerms}";
          Alias = "!w";
        }
        {
          Name = "Youtube";
          URLTemplate = "https://www.youtube.com/results?search_query={searchTerms}";
          Alias = "!yt";
        }
        {
          Name = "eBay";
          URLTemplate = "https://www.ebay.com/sch/i.html?_nkw={searchTerms}";
          Alias = "!e";
        }
        # keep-sorted end
      ]
      ++ engines;
      SearchEngines.Default = "Kagi";
      SearchSuggestEnabled = false;
      ExtensionSettings = lib.genAttrs extensions (extensionId: {
        installation_mode = "normal_installed";
        install_url = amoUrl extensionId;
      });
    };
    preferences = {
      # keep-sorted start
      "app.normandy.api_url" = "";
      "app.normandy.enabled" = false;
      "app.shield.optoutstudies.enabled" = false;
      # disable inertial/kinetic/momentum scrolling because it just gets in the way on touchpads
      # source: <https://kparal.wordpress.com/2019/10/31/disabling-kinetic-scrolling-in-firefox/>
      "apz.gtk.kinetic_scroll.enabled" = false;
      "browser.aboutConfig.showWarning" = false;
      "browser.display.use_system_colors" = true;
      "browser.download.lastDir" = "/home/shelvacu/Downloads";
      "browser.protections_panel.infoMessage.seen" = true;
      "browser.rights.3.shown" = true;
      "browser.safebrowsing.blockedURIs.enabled" = false;
      "browser.safebrowsing.downloads.enabled" = false;
      "browser.safebrowsing.malware.enabled" = false;
      "browser.safebrowsing.phishing.enabled" = false;
      "browser.shell.checkDefaultBrowser" = false;
      # 0 to hide the window close button
      # 2 to show the window close button (default)
      "browser.tabs.inTitlebar" = 0;
      "browser.urlbar.quickactions.timesShownOnboardingLabel" = 999;
      "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
      "browser.urlbar.suggest.quicksuggest.sponsored" = false;
      "datareporting.healthreport.uploadEnabled" = false;
      "datareporting.usage.uploadEnabled" = false;
      "devtools.everOpened" = true;
      "devtools.inspector.simple-highlighters.message-dismissed" = true;
      "dom.media.mediasession.enabled" = true; # as recommended by YouTube NonStop extension
      "extensions.formautofill.creditCards.enabled" = false;
      "identity.fxaccounts.enabled" = false;
      # disable picture-in-picture controls
      "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
      # DISABLE DNS OVER HTTPS; use the system resolver.
      "network.trr.mode" = 5;
      "security.OCSP.enabled" = false;
      "security.OCSP.require" = false;
      "security.ssl.require_safe_negotiation" = false;
      "security.tls.enable_0rtt_data" = false;
      "sidebar.animation.enabled" = false;
      "sidebar.backupState" = ''{"width":"","command":"","expanded":true,"hidden":false}'';
      "sidebar.main.tools" = "history";
      "sidebar.revamp" = true;
      "sidebar.verticalTabs" = true;
      "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;
      # vvv default is for tabs button to toggle tab icons v.s. tab icons + description.
      #    "hide-sidebar"  => toggle between tab icons + description and NO visibility at all.
      "sidebar.visibility" = "hide-sidebar";
      # dont offer to save passwords
      "signon.rememberSignons" = false;
      "trailhead.firstrun.didSeeAboutWelcome" = true;
      "webgl.disabled" = false;
      # keep-sorted end
    };
  };
}

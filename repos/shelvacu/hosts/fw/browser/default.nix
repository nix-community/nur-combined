{ vaculib, ... }:
{
  imports = vaculib.directoryGrabberList ./.;
  programs.firefox = {
    enable = true;
    policies = {
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
          URLTemplate = "https://search.nixos.org/options?channel=25.11&query={searchTerms}";
          Alias = "!no";
        }
        {
          Name = "NixOS Packages";
          URLTemplate = "https://search.nixos.org/packages?channel=25.11&query={searchTerms}";
          Alias = "!np";
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
      ];
      SearchEngines.Default = "Kagi";
      SearchSuggestEnabled = false;
      ExtensionSettings = {
        # keep-sorted start block=yes
        "addon@darkreader.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        };
        "firefox-extension@steamdb.info" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/steam-database/latest.xpi";
        };
        "firefox@betterttv.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/betterttv/latest.xpi";
        };
        "gdpr@cavi.au.dk" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/consent-o-matic/latest.xpi";
        };
        "jid1-BoFifL9Vbdl2zQ@jetpack" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/decentraleyes/latest.xpi";
        };
        "myallychou@gmail.com" = {
          # Unhook
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-recommended-videos/latest.xpi";
        };
        "sponsorBlocker@ajay.app" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
        };
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        };
        "{74145f27-f039-47ce-a470-a662b129930a}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi";
        };
        # keep-sorted end
      };
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

{ vaculib, ... }:
{
  imports = builtins.attrValues (vaculib.directoryGrabber { path = ./.; });
  programs.firefox = {
    enable = true;
    policies = {
      SearchEngines.Add = [
        {
          Name = "Kagi";
          URLTemplate = "https://kagi.com/search?q={searchTerms}";
        }
        {
          Name = "NixOS Packages";
          URLTemplate = "https://search.nixos.org/packages?channel=25.11&query={searchTerms}";
          Alias = "!np";
        }
        {
          Name = "NixOS Options";
          URLTemplate = "https://search.nixos.org/options?channel=25.11&query={searchTerms}";
          Alias = "!no";
        }
        {
          Name = "eBay";
          URLTemplate = "https://www.ebay.com/sch/i.html?_nkw={searchTerms}";
          Alias = "!e";
        }
        {
          Name = "Amazon";
          URLTemplate = "https://www.amazon.com/s?k={searchTerms}";
          Alias = "!a";
        }
        {
          Name = "Walmart";
          URLTemplate = "https://www.walmart.com/search?q={searchTerms}";
          Alias = "!w";
        }
        {
          Name = "Aliexpress";
          URLTemplate = "https://www.aliexpress.us/w/wholesale-{searchTerms}.html";
          Alias = "!ali";
        }
        {
          Name = "Youtube";
          URLTemplate = "https://www.youtube.com/results?search_query={searchTerms}";
          Alias = "!yt";
        }
      ];
      SearchEngines.Default = "Kagi";
      SearchSuggestEnabled = false;
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        };
        "addon@darkreader.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        };
        "sponsorBlocker@ajay.app" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
        };
        "firefox-extension@steamdb.info" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/steam-database/latest.xpi";
        };
        # Unhook
        "myallychou@gmail.com" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-recommended-videos/latest.xpi";
        };
        "firefox@betterttv.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/betterttv/latest.xpi";
        };
        "{74145f27-f039-47ce-a470-a662b129930a}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi";
        };
        "jid1-BoFifL9Vbdl2zQ@jetpack" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/decentraleyes/latest.xpi";
        };
        "gdpr@cavi.au.dk" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/consent-o-matic/latest.xpi";
        };
      };
    };
    preferences = {
      # dont offer to save passwords
      "signon.rememberSignons" = false;
      "browser.urlbar.suggest.quicksuggest.sponsored" = false;
      "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;

      ### from colin's user.js
      "security.tls.enable_0rtt_data" = false;
      "security.ssl.require_safe_negotiation" = false;
      "security.OCSP.enabled" = false;
      "security.OCSP.require" = false;
      "browser.display.use_system_colors" = true;
      # DISABLE DNS OVER HTTPS; use the system resolver.
      "network.trr.mode" = 5;
      "webgl.disabled" = false;
      # disable inertial/kinetic/momentum scrolling because it just gets in the way on touchpads
      # source: <https://kparal.wordpress.com/2019/10/31/disabling-kinetic-scrolling-in-firefox/>
      "apz.gtk.kinetic_scroll.enabled" = false;
      # enable vertical tab view, like Sidebery (but loses the top-window horizontal tabs)
      #"browser.toolbarbuttons.introduced.sidebar-button" = true;
      "sidebar.animation.enabled" = false;
      "sidebar.backupState" = ''{"width":"","command":"","expanded":true,"hidden":false}'';
      "sidebar.main.tools" = "history";
      "sidebar.revamp" = true;
      "sidebar.verticalTabs" = true;
      # vvv default is for tabs button to toggle tab icons v.s. tab icons + description.
      #    "hide-sidebar"  => toggle between tab icons + description and NO visibility at all.
      "sidebar.visibility" = "hide-sidebar";
      # 0 to hide the window close button
      # 2 to show the window close button (default)
      "browser.tabs.inTitlebar" = 0;
      "browser.download.lastDir" = "/home/shelvacu/Downloads";
      "trailhead.firstrun.didSeeAboutWelcome" = true;
      "browser.aboutConfig.showWarning" = false;
      "browser.shell.checkDefaultBrowser" = false;
      # disable "safe browsing" = in which my browser asks Google whether a site is malicious or not, for every site i visit (?)
      "browser.safebrowsing.blockedURIs.enabled" = false;
      "browser.safebrowsing.downloads.enabled" = false;
      "browser.safebrowsing.malware.enabled" = false;
      "browser.safebrowsing.phishing.enabled" = false;
    };
  };
}

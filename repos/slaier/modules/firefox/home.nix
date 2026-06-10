{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override (prev: {
      extraPolicies = (prev.extraPolicies or { }) // {
        CaptivePortal = false;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisableFirefoxAccounts = true;
        FirefoxHome = {
          Pocket = false;
          Snippets = false;
        };
        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
        };
      };
      extraPrefsFiles = (prev.extraPrefsFiles or [ ]) ++ [
        "${pkgs.arkenfox-userjs}/user.cfg"
        "${./overlay.js}"
      ];
    });
    profiles.default = {
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        adnauseam
        bitwarden
        buster-captcha-solver
        clearurls
        history-cleaner
        i-dont-care-about-cookies
        imagus
        localcdn
        new_tongwentang
        offline-qr-code-generator
        rsshub-radar
        violentmonkey
        (buildFirefoxXpiAddon {
          pname = "copy-link-text-sytelix";
          version = "1.5.0";
          addonId = "{7f069302-8ecc-45b1-84be-745f021d040e}";
          url = "https://addons.mozilla.org/firefox/downloads/file/4397391/copy_link_text_sytelix-1.5.0.xpi";
          sha256 = "0aff955e12ae8b99d207bbbe7d945b24c0cb50de450095ffd212842ede86d830";
          meta = with lib; {
            description = "The only extension that lets you effortlessly copy link text on both desktop and mobile—via right-click, Alt+C shortcut, or Copy Mode activation.";
            license = licenses.mpl20;
            mozPermissions = [
              "activeTab"
              "clipboardWrite"
              "contextMenus"
              "<all_urls>"
            ];
            platforms = platforms.all;
          };
        })
      ];
      bookmarks = {
        force = true;
        settings = [
          {
            toolbar = true;
            bookmarks = [
              {
                name = "Nix sites";
                bookmarks = [
                  {
                    name = "NUR search";
                    url = "https://nur.nix-community.org/";
                  }
                  {
                    name = "Nix Manual";
                    url = "https://nixos.org/manual/nix/stable/";
                  }
                  {
                    name = "Nixpkgs Manual";
                    url = "https://ryantm.github.io/nixpkgs/";
                  }
                  {
                    name = "Noogle";
                    url = "https://noogle.dev/";
                  }
                ];
              }
              {
                name = "Learn";
                bookmarks = [
                  {
                    name = "Rust OS";
                    url = "https://learningos.github.io/rust-based-os-comp2022/";
                  }
                  {
                    name = "nLab";
                    url = "https://ncatlab.org/nlab/show/HomePage";
                  }
                ];
              }
              {
                name = "Collection";
                bookmarks = [
                  {
                    name = "ACGN";
                    url = "https://www.myiys.com/";
                  }
                  {
                    name = "MirrorZ";
                    url = "https://mirrorz.org/site";
                  }
                  {
                    name = "Pling";
                    url = "https://www.pling.com/";
                  }
                ];
              }
              {
                name = "Post";
                bookmarks = [
                  {
                    name = "Proxy Env";
                    url = "https://about.gitlab.com/blog/2021/01/27/we-need-to-talk-no-proxy";
                  }
                  {
                    name = "Google Language Codes";
                    url = "https://sites.google.com/site/tomihasa/google-language-codes";
                  }
                ];
              }
              {
                name = "Misc";
                bookmarks = [
                  {
                    name = "Dns Lookup";
                    url = "https://dnslookup.online/";
                  }
                  {
                    name = "Second Hand Silicon";
                    url = "https://secondhandsilicon.com";
                  }
                ];
              }
            ];
          }
        ];
      };
      settings = {
        "browser.urlbar.suggest.topsites" = false;
        "browser.warnOnQuitShortcut" = false;
        "browser.toolbars.bookmarks.visibility" = "newtab";
        "extensions.activeThemeID" = "elemental-soft-colorway@mozilla.org";
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
        "browser.newtabpage.activity-stream.nova.enabled" = false;
        "widget.gtk.rounded-bottom-corners.enabled" = true;
      };
      search = {
        default = "Google NCR";
        privateDefault = "Google NCR";
        engines = {
          "amazondotcom-us".metaData.hidden = true;
          "wikipedia".metaData.hidden = true;
          "bing".metaData.hidden = true;
          "ddg".metaData.hidden = true;
          "google".metaData.hidden = true;
          "perplexity".metaData.hidden = true;
          "Google NCR" = {
            urls = [
              {
                template = "https://www.google.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                  {
                    name = "hl";
                    value = "zh-CN";
                  }
                  {
                    name = "client";
                    value = "firefox-b-d";
                  }
                  {
                    name = "channel";
                    value = "entpr";
                  }
                ];
              }
            ];
            definedAliases = [ "@g" ];
          };
          "NixOS packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          "NixOS options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "type";
                    value = "options";
                  }
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };
          "Home Manager options" = {
            urls = [
              {
                template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}&source=home_manager";
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@hm" ];
          };
          "Github" = {
            urls = [
              {
                template = "https://github.com/search?q={searchTerms}&ref=opensearch&type=code";
              }
            ];
            definedAliases = [ "@gh" ];
          };
        };
        force = true;
      };
    };
  };
  home.file."${config.programs.firefox.configPath}/default/chrome" =
    let
      theme = pkgs.fetchFromGitHub {
        owner = "akkva";
        repo = "gwfox";
        rev = "2.12";
        sha256 = "sha256-JYXudeVi6hv9VnJ6LSnZpBTa6HZs3G9Awo6bO0vds18=";
      };
    in
    {
      source = "${theme}/chrome";
      recursive = true;
      force = true;
    };
}

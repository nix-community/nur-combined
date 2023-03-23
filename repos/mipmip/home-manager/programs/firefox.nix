{ config, pkgs, ... }:

{
    programs.firefox = {
        enable = true;
        package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
            extraPolicies = {
                CaptivePortal = false;
                DisableFirefoxStudies = true;
                DisablePocket = true;
                DisableTelemetry = true;
                DisableFirefoxAccounts = false;
                NoDefaultBookmarks = true;
                OfferToSaveLogins = false;
                OfferToSaveLoginsDefault = false;
                PasswordManagerEnabled = false;
                FirefoxHome = {
                    Search = true;
                    Pocket = false;
                    Snippets = false;
                    TopSites = false;
                    Highlights = false;
                };
                UserMessaging = {
                    ExtensionRecommendations = false;
                    SkipOnboarding = true;
                };
            };
        };
        profiles =
          let defaultSettings = {
            "browser.startup.homepage" = "about:blank";
          };
          in {
            default = {
              id = 0;
              isDefault = true;
              settings = defaultSettings // {
              };
            };

            adevinta = {
              id = 1;
              settings = defaultSettings // {
                "browser.startup.homepage" = "https://automobile.it";
              };
            };

            mahmoud = {
                id = 2;
                name = "mahmoud";
#                search = {
#                    force = true;
#                    default = "DuckDuckGo";
#                    engines = {
#                        "Kagi" = {
#                            urls = [{
#                                template = "https://kagi.com/search?q={searchTerms}";
#                            }];
#                            #icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
#                            definedAliases = [ "@k" ];
#                        };
#                        "Nix Packages" = {
#                            urls = [{
#                                template = "https://search.nixos.org/packages";
#                                params = [
#                                    { name = "type"; value = "packages"; }
#                                    { name = "query"; value = "{searchTerms}"; }
#                                ];
#                            }];
#                            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
#                            definedAliases = [ "@np" ];
#                        };
#                        "NixOS Wiki" = {
#                            urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
#                            iconUpdateURL = "https://nixos.wiki/favicon.png";
#                            updateInterval = 24 * 60 * 60 * 1000;
#                            definedAliases = [ "@nw" ];
#                        };
#                        "Wikipedia (en)".metaData.alias = "@wiki";
#                        "Google".metaData.hidden = true;
#                        "Amazon.com".metaData.hidden = true;
#                        "Bing".metaData.hidden = true;
#                        "eBay".metaData.hidden = true;
#                    };
#                };
                settings = {
                    "general.smoothScroll" = true;
                };
            };
          };
    };
}

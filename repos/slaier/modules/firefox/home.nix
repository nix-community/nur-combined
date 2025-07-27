{ pkgs, lib, ... }:
with lib;
let
  profilesPath =
    if pkgs.stdenv.isDarwin then
      "Library/Application Support/Firefox/Profiles"
    else
      ".mozilla/firefox";
in
{
  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
      extraPolicies = {
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
    };
    profiles.default = {
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        adnauseam
        aria2-integration
        bitwarden
        buster-captcha-solver
        clearurls
        copy-link-text
        history-cleaner
        i-dont-care-about-cookies
        localcdn
        new_tongwentang
        offline-qr-code-generator
        rsshub-radar
        violentmonkey
      ] ++ (with pkgs.nur.repos.bandithedoge.firefoxAddons; [
        imagus
      ]);
      bookmarks = {
        force = true;
        settings = [
          {
            name = "Nix sites";
            bookmarks = [
              { name = "NUR search"; url = "https://nur.nix-community.org/"; }
              { name = "Nix Manual"; url = "https://nixos.org/manual/nix/stable/"; }
              { name = "Nixpkgs Manual"; url = "https://ryantm.github.io/nixpkgs/"; }
              { name = "Noogle"; url = "https://noogle.dev/"; }
            ];
          }
          {
            name = "Learn";
            bookmarks = [
              { name = "Rust OS"; url = "https://learningos.github.io/rust-based-os-comp2022/"; }
              { name = "nLab"; url = "https://ncatlab.org/nlab/show/HomePage"; }
            ];
          }
          {
            name = "Collection";
            bookmarks = [
              { name = "ACGN"; url = "https://www.myiys.com/"; }
              { name = "MirrorZ"; url = "https://mirrorz.org/site"; }
              { name = "Pling"; url = "https://www.pling.com/"; }
            ];
          }
          {
            name = "Post";
            bookmarks = [
              { name = "Proxy Env"; url = "https://about.gitlab.com/blog/2021/01/27/we-need-to-talk-no-proxy"; }
              { name = "Google Language Codes"; url = "https://sites.google.com/site/tomihasa/google-language-codes"; }
            ];
          }
          { name = "Dns Lookup"; url = "https://dnslookup.online/"; }
        ];
      };
      settings = {
        "browser.urlbar.suggest.topsites" = false;
        "browser.warnOnQuitShortcut" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.uiCustomization.state" = ''
          {
              "placements": {
                  "widget-overflow-fixed-list": [],
                  "unified-extensions-area": [
                      "i_diygod_me-browser-action",
                      "_ublacklist-browser-action",
                      "adnauseam_rednoise_org-browser-action",
                      "jid1-kkzogwgsw3ao4q_jetpack-browser-action",
                      "keepassxc-browser_keepassxc_org-browser-action",
                      "offline-qr-code_rugk_github_io-browser-action",
                      "tongwen_softcup-browser-action",
                      "_74145f27-f039-47ce-a470-a662b129930a_-browser-action",
                      "_b86e4813-687a-43e6-ab65-0bde4ab75758_-browser-action"
                  ],
                  "nav-bar": [
                      "back-button",
                      "forward-button",
                      "stop-reload-button",
                      "customizableui-special-spring1",
                      "urlbar-container",
                      "customizableui-special-spring2",
                      "downloads-button",
                      "bookmarks-menu-button",
                      "_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action",
                      "_e2488817-3d73-4013-850d-b66c5e42d505_-browser-action",
                      "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action",
                      "offline-qr-code_rugk_github_io-browser-action",
                      "fxa-toolbar-menu-button",
                      "unified-extensions-button"
                  ],
                  "toolbar-menubar": [
                      "menubar-items"
                  ],
                  "TabsToolbar": [
                      "tabbrowser-tabs",
                      "new-tab-button",
                      "alltabs-button"
                  ],
                  "PersonalToolbar": [
                      "personal-bookmarks"
                  ]
              },
              "seen": [
                  "i_diygod_me-browser-action",
                  "_ublacklist-browser-action",
                  "adnauseam_rednoise_org-browser-action",
                  "jid1-kkzogwgsw3ao4q_jetpack-browser-action",
                  "keepassxc-browser_keepassxc_org-browser-action",
                  "offline-qr-code_rugk_github_io-browser-action",
                  "tongwen_softcup-browser-action",
                  "_74145f27-f039-47ce-a470-a662b129930a_-browser-action",
                  "_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action",
                  "_b86e4813-687a-43e6-ab65-0bde4ab75758_-browser-action",
                  "_e2488817-3d73-4013-850d-b66c5e42d505_-browser-action",
                  "developer-button"
              ],
              "dirtyAreaCache": [
                  "unified-extensions-area",
                  "nav-bar"
              ],
              "currentVersion": 20,
              "newElementCount": 2
          }
        '';
        "extensions.activeThemeID" = "elemental-soft-colorway@mozilla.org";
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "layout.css.color-mix.enabled" = true;
        "layout.css.has-selector.enabled" = true;
        "svg.context-properties.content.enabled" = true;
        "userChrome.Tabs.Option7.Enabled" = true;
        "userChrome.TabSeparators.Saturation.Medium.Enabled" = true;
        "userChrome.Menu.Size.Compact.Enabled" = true;
        "userChrome.Menu.Icons.Regular.Enabled" = true;
      };
      extraConfig =
        let
          src = lib.sourceFilesBySuffices ./. [ ".js" ];
        in
        ''
          ${fileContents "${pkgs.nur.repos.ataraxiasjel.arkenfox-userjs}/share/user.js/user.js"}
          ${fileContents "${src}/overlay.js"}
        '';
      search = {
        default = "Google NCR";
        engines = {
          "amazondotcom-us".metaData.hidden = true;
          "wikipedia".metaData.hidden = true;
          "bing".metaData.hidden = true;
          "ddg".metaData.hidden = true;
          "google".metaData.hidden = true;
          "Google NCR" = {
            urls = [{
              template = "https://www.google.com/search";
              params = [
                { name = "q"; value = "{searchTerms}"; }
                { name = "hl"; value = "zh-CN"; }
              ];
            }];
            definedAliases = [ "@g" ];
          };
          "NixOS packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          "NixOS options" = {
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                { name = "type"; value = "options"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };
          "Home Manager options" = {
            urls = [{
              template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master";
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@hm" ];
          };
          "Github" = {
            urls = [{
              template = "https://github.com/search?q={searchTerms}&ref=opensearch&type=code";
            }];
            definedAliases = [ "@gh" ];
          };
        };
        force = true;
      };
      containersForce = true;
      containers = {
        work = {
          id = 2;
          icon = "briefcase";
          color = "orange";
        };
      };
    };
  };
  home.file."${profilesPath}/default/chrome" = {
    source = pkgs.wavefox;
    recursive = true;
    force = true;
  };
}

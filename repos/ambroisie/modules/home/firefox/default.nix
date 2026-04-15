{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.firefox;
in
{
  imports = [
    ./tridactyl
  ];

  options.my.home.firefox = with lib; {
    enable = mkEnableOption "firefox configuration";

    tridactyl = {
      enable = mkOption {
        type = types.bool;
        description = "tridactyl configuration";
        example = false;
        default = config.my.home.firefox.enable;
      };
    };

    ff2mpv = {
      enable = mkOption {
        type = types.bool;
        description = "ff2mpv configuration";
        example = false;
        default = config.my.home.mpv.enable;
      };
    };
  };

  config.programs.firefox = lib.mkIf cfg.enable {
    enable = true;

    package = pkgs.firefox.override {
      nativeMessagingHosts = ([ ]
        ++ lib.optional cfg.tridactyl.enable pkgs.tridactyl-native
        # Watch videos using mpv
        ++ lib.optional cfg.ff2mpv.enable pkgs.ff2mpv-go
      );
    };

    profiles = {
      default = {
        id = 0;

        settings = {
          "browser.bookmarks.showMobileBookmarks" = true; # Mobile bookmarks
          "browser.download.useDownloadDir" = false; # Ask for download location
          "browser.in-content.dark-mode" = true; # Dark mode
          "browser.ml.chat.enabled" = false; # No AI
          "browser.ml.chat.menu" = false; # No AI
          "browser.ml.chat.page" = false; # No AI
          "browser.ml.chat.page.footerBadge" = false; # No AI
          "browser.ml.chat.page.menuBadge" = false; # No AI
          "browser.ml.chat.shortcuts" = false; # No AI
          "browser.ml.chat.sidebar" = false; # No AI
          "browser.ml.enable" = false; # No AI
          "browser.ml.linkPreview.enabled" = false; # No AI
          "browser.ml.pageAssist.enabled" = false; # No AI
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false; # Disable top stories
          "browser.newtabpage.activity-stream.feeds.sections" = false;
          "browser.newtabpage.activity-stream.feeds.system.topstories" = false; # Disable top stories
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false; # Disable pocket
          "browser.tabs.groups.smart.enabled" = false; # No AI
          "browser.tabs.groups.smart.userEnabled" = false; # No AI
          "browser.urlbar.trimURLs" = false; # Always show the `http://` prefix
          "extensions.ml.enabled" = false; # No AI
          "extensions.pocket.enabled" = false; # Disable pocket
          "media.eme.enabled" = true; # Enable DRM
          "media.gmp-widevinecdm.enabled" = true; # Enable DRM
          "media.gmp-widevinecdm.visible" = true; # Enable DRM
          "sidebar.notification.badge.aichat" = false; # No AI
          "signon.autofillForms" = false; # Disable built-in form-filling
          "signon.rememberSignons" = false; # Disable built-in password manager
          "ui.systemUsesDarkTheme" = true; # Dark mode
        };

        extensions = {
          packages = with pkgs.nur.repos.rycee.firefox-addons; ([
            bitwarden
            consent-o-matic
            form-history-control
            reddit-comment-collapser
            reddit-enhancement-suite
            refined-github
            sponsorblock
            ublock-origin
          ]
          ++ lib.optional (cfg.tridactyl.enable) tridactyl
          ++ lib.optional (cfg.ff2mpv.enable) ff2mpv
          );
        };
      };
    };
  };
}

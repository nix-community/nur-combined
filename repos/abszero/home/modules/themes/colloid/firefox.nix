{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkMerge mkBefore;
  cfg = config.abszero.programs.firefox;

  tme = pkgs.colloid-gtk-theme.src + "/src/other/firefox/chrome/Colloid";
in

{
  imports = [
    ../../programs/firefox.nix
    ../base/firefox-vertical-tabs
  ];

  programs.firefox.profiles.${cfg.profile} = {
    userChrome = mkMerge [
      (mkBefore ''@import "${tme}/theme.css";'')
      ''

        /* Fix placement of window decorations */
        * {
          --uc-win-ctrl-vertical-offset: 0;
        }

        /* Fix findbar padding */
        .findbar-container {
          height: inherit !important;
        }

        /* Fix border and size of extension icons */
        toolbaritem.unified-extensions-item > toolbarbutton:not(#n):not(#n):not(#n) {
          border-radius: 6px !important;
          padding: 0 1px !important;
          margin: 0 3px !important;
        }

        /* Fix navigation bar height */
        toolbar#nav-bar.browser-toolbar {
          height: 46px !important;
        }
      ''
    ];
    userContent = mkBefore ''
      @import "${tme}/colors/light.css";
      @import "${tme}/colors/dark.css";

      @import "${tme}/pages/newtab.css";
      @import "${tme}/pages/privatebrowsing.css";

      @import "${tme}/parts/video-player.css";
    '';
    settings = {
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "browser.uidensity" = 2;
      "svg.context-properties.content.enabled" = true;
      "browser.tabs.inTitlebar" = 1;
    };
  };
}

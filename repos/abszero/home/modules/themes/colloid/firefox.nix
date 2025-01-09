{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkMerge mkBefore mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.colloid.firefox;
  firefoxCfg = config.abszero.programs.firefox;

  tme = pkgs.colloid-gtk-theme.src + "/src/other/firefox/chrome/Colloid";
in

{
  imports = [ ../base/firefox-vertical-tabs ];

  options.abszero.themes.colloid.firefox.enable =
    mkExternalEnableOption config "colloid firefox theme";

  config = mkIf cfg.enable {
    abszero.themes.base.firefox.verticalTabs = true;

    programs.firefox.profiles.${firefoxCfg.profile} = {
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
  };
}

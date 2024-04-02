{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.services.hidpi;
  cursorTheme = cfg.enable && cfg.cursorTheme;
  cursorSize = cfg.enable && cfg.cursorSize;

  indexThemeText = theme: generators.toINI {} {"icon theme" = { Inherits = "${theme}"; }; };

  mkDefaultCursorFile = theme: pkgs.writeTextDir
    "share/icons/default/index.theme"
    "${indexThemeText theme}";

  defaultCursorPkg = mkDefaultCursorFile cfg.cursorTheme;
in
{
  options = {
    services.hidpi = {
      cursorTheme = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "Adwaita";
        description = "The name of the default cursor theme.";
      };

      cursorSize = mkOption {
        type = types.nullOr types.int;
        default = null;
      };

      dpi = mkOption {
        type = types.nullOr types.int;
        default = null;
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.cursorTheme != null) {
      environment.systemPackages = [ defaultCursorPkg ];
    })

    (mkIf (cfg.cursorSize != null) {
      environment.variables.XCURSOR_SIZE = toString cfg.cursorSize;
    })

    (mkIf (cfg.dpi != null) {
      services.xserver.displayManager.sessionCommands = ''
        printf "%s\n" "Xft.dpi: ${toString cfg.dpi}" | xrdb -merge
      '';
      # workaround: for qt5 taken from plasma
      environment.variables.QT_AUTO_SCREEN_SCALE_FACTOR = "0";
      environment.variables.QT_SCREEN_SCALE_FACTORS = toString (cfg.dpi / 96.0);
    })
  ];
}

# https://github.com/NixOS/nixpkgs/issues/22652#issuecomment-927163685

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

      console = mkEnableOption "fix hidpi console font";
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
      services.xserver.displayManager.sessionCommands = optionalString (cfg.dpi != null) ''
        printf "%s\n" "Xft.dpi: ${toString cfg.dpi}" | xrdb -merge
      '';
      environment.variables.QT_ENABLE_HIGHDPI_SCALING = "1";
    })

    # https://github.com/NixOS/nixpkgs/issues/274545
    (mkIf cfg.console {
      console.font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
      systemd.services.my-reload-systemd-vconsole-setup =
        { wantedBy = [ "graphical.target" ];
          after = [ "graphical.target" ];
          serviceConfig =
            { RemainAfterExit = true;
              ExecStart = "/run/current-system/systemd/bin/systemctl restart systemd-vconsole-setup";
            };
        };
    })
  ];
}

# Module to set a default cursor theme

{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.environment.defaultCursor;

  indexThemeText = theme: generators.toINI {} {"icon theme" = { Inherits = "${theme}"; }; };

  mkDefaultCursorFile = theme: pkgs.writeTextDir
    "share/icons/default/index.theme"
    "${indexThemeText theme}";

  defaultCursorPkg = mkDefaultCursorFile cfg.theme;
in
{
  options = {
    environment.defaultCursor = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to set a default cursor theme for graphical environments.
        '';
      };

      theme = mkOption {
        type = types.str;
        default = "";
        example = "Adwaita";
        description = "The name of the defualt cursor theme.";
      };

      size = mkOption {
        type = types.nullOr types.int;
        default = null;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      defaultCursorPkg
    ];

    environment.variables.XCURSOR_SIZE = optionalString (cfg.size != null) (toString cfg.size);
  };
}

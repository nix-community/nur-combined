{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.nnn;
in
{
  meta.maintainers = [ maintainers.sikmir ];

  options.programs.nnn = {
    enable = mkEnableOption "The missing terminal file manager for X";

    package = mkOption {
      default = pkgs.nnn;
      defaultText = literalExample "pkgs.nnn";
      description = "nnn package to install.";
      type = types.package;
    };

    pluginsPackage = mkOption {
      default = null;
      description = "nnn plugins package to install.";
      type = types.nullOr types.package;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [
      {
        home.packages = [ cfg.package ];

        home.sessionVariables = {
          NNN_COLORS = "5236";
        };
      }

      (
        mkIf (cfg.pluginsPackage != null) {
          xdg.configFile."nnn/plugins".source =
            "${cfg.pluginsPackage}/share/nnn/plugins";
        }
      )
    ]
  );
}

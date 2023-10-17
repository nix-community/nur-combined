{ config, lib, pkgs, ... }:

let
  inherit (lib) mkOption types mkIf mkPackageOption;
  settingsFormat = pkgs.formats.ini { };
  cfg = config.services.gammastep;
in

{
  options.services.gammastep = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Enable Redshift to change your screen's colour temperature depending on
        the time of day.
      '';
    };

    package = mkPackageOption pkgs "gammastep" {};

    temperature = {
      day = mkOption {
        type = types.int;
        default = 5500;
        description = lib.mdDoc ''
          Colour temperature to use during the day, between
          `1000` and `25000` K.
        '';
      };
      night = mkOption {
        type = types.int;
        default = 3700;
        description = lib.mdDoc ''
          Colour temperature to use at night, between
          `1000` and `25000` K.
        '';
      };
    };

    settings = mkOption {
      type = types.submodule { freeformType = settingsFormat.type; };
      default = { };
      description = lib.mdDoc ''
        Configuration for gammastep.
      '';
    };

  };
  config = mkIf cfg.enable {
    services.gammastep.settings = {
      general = {
        temp-day = cfg.temperature.day;
        temp-night = cfg.temperature.night;
      };
      manual = {
        lat = config.location.latitude;
        lon = config.location.longitude;
      };
    };
    environment.etc."gammastep.ini".source =
      settingsFormat.generate "gammastep.ini" cfg.settings;

    systemd.user.services.gammastep = {
      path = [ cfg.package ];
      script = ''
        gammastep -c /etc/gammastep.ini
      '';
      serviceConfig = {
        RestartSec = 3;
        Restart = "on-failure";
      };
      wantedBy = [ "graphical-session.target" ];
    };
  };
}

{ config, lib, pkgs, options, ... }:

with lib;

let
  pkg = pkgs.callPackage ../pkgs/rtl {};
  cfg = config.services.rtl;
  dataDir = "/var/lib/rtl";
in
{
  options.services.rtl = {
    enable = mkEnableOption "Ride The Lightning - A full function web browser app for LND and C-Lightning";

    host = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        Host for the rtl node server.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 3003;
      description = ''
        Port for the rtl node server.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.rtl = {
      description = "Ride The Lightning";
      wantedBy = [ "multi-user.target" ];
      after = [ "networking.target" ];
      serviceConfig = {
        WorkingDirectory = dataDir;
        ExecStart = "${pkg}/bin/rtl";
        Restart = "always";
        TimeoutSec = 120;
        RestartSec = 30;

        StateDirectory = "rtl";
        DynamicUser = true;
        User = "rtl";
        Group = "rtl";
        ProtectSystem = "strict";
      };
      environment = {
        RTL_CONFIG_PATH = dataDir;
        HOST = cfg.host;
        PORT = toString cfg.port;
      };
    };
  };
}

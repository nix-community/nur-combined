{ config, pkgs, lib, ... }:
let
  cfg = config.services.safetwitch;
in {
  options.services.safetwitch = with lib; {
    enable = mkEnableOption "A privacy respecting frontend for twitch.tv";
    package = mkPackageOption pkgs "safetwitch" { };

    url = mkOption {
      type = types.str;
    };

    port = mkOption {
      type = types.oneOf [ types.port types.path ];
      default = 7000;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.safetwitch = {
      description = "A privacy respecting frontend for twitch.tv";

      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        URL = cfg.url;
        PORT = toString cfg.port;
      };

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
      };
    };
  };
}

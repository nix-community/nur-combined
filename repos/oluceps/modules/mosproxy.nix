{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.mosproxy;
  configFormat = pkgs.formats.yaml { };
  configFile = configFormat.generate "mosproxy.yaml" cfg.config;
in
{
  options.services.mosproxy = {
    enable = mkEnableOption "mosproxy service";
    package = mkPackageOption pkgs "mosproxy" { };
    config = mkOption {
      inherit (configFormat) type;
      default = { };
      description = "The configuration attribute set.";
    };
    redisPort = mkOption {
      type = with types; nullOr port;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mosproxy = {
      description = "mosproxy Daemon";
      after = [ "network.target" ]
        ++ lib.optional (cfg.redisPort != null) "redis-mosproxy.service";
      wantedBy = [ "multi-user.target" ];
      wants = [ "nss-lookup.target" ];
      before = [ "nss-lookup.target" ];
      restartTriggers = [ configFile ];
      serviceConfig = {
        Restart = "on-failure";
        StateDirectory = "mosproxy";
        ExecStart = "${cfg.package}/bin/mosproxy router -c ${configFile}";
      };
    };

    services.redis.servers.mosproxy.enable = (cfg.redisPort != null);

    environment.systemPackages = [ cfg.package ];
  };
}

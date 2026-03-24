{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.prometheus-teamspeak3-exporter;
  name = "teamspeak3";
in
{
  options.services.prometheus-teamspeak3-exporter = with types; mkOption {
    type = types.submodule {
      options = {
        enable = mkEnableOption "the prometheus ${name} exporter";
        enableLocalScraping = mkEnableOption "enable scraping by local prometheus";
        port = mkOption {
          type = types.port;
          default = 9189;
          description = ''
            Port to listen on.
          '';
        };
        listenAddress = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = ''
            Address to listen on.
          '';
        };
        extraFlags = mkOption {
          type = types.listOf types.str;
          default = [ "-enablechannelmetrics" "-ignorefloodlimits" ];
          description = ''
            Extra commandline options to pass to the ${name} exporter.
          '';
        };
        user = mkOption {
          type = types.str;
          default = "${name}-exporter";
          description = ''
            User name under which the ${name} exporter shall be run.
          '';
        };
        group = mkOption {
          type = types.str;
          default = "${name}-exporter";
          description = ''
            Group under which the ${name} exporter shall be run.
          '';
        };
        remoteServer = mkOption {
          type = types.str;
          default = "127.0.0.1:10011";
          description = ''
            Remote Teamspeak3 server to query
          '';
        };
        remoteUsername = mkOption {
          type = types.str;
          default = "serveradmin";
          description = ''
            Username to use when querying the server
          '';
        };
        remotePassword = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            Password to use when querying the server
          '';
        };

      };
    };
    default = { };
  };
  config = mkIf cfg.enable {
    users.users."${cfg.user}" = {
      description = "Prometheus ${name} exporter service user";
      isSystemUser = true;
      group = "${cfg.group}";
    };
    users.groups."${cfg.group}" = { };

    systemd.services."prometheus-${name}-exporter" = {
      environment = { };
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      environment = {
        SERVERQUERY_PASSWORD = cfg.remotePassword;
      };
      serviceConfig.Restart = "always";
      serviceConfig.PrivateTmp = true;
      serviceConfig.WorkingDirectory = /tmp;
      serviceConfig.DynamicUser = false;
      serviceConfig.User = "${cfg.user}";
      serviceConfig.Group = "${cfg.group}";
      serviceConfig.ExecStart = ''
        ${getBin pkgs.prometheus-teamspeak3-exporter}/bin/ts3exporter ${concatStringsSep " " cfg.extraFlags} \
        -listen "${cfg.listenAddress}:${toString cfg.port}" \
        -remote ${cfg.remoteServer} -user ${cfg.remoteUsername}
      '';
    };

    services.prometheus.scrapeConfigs = mkIf cfg.enableLocalScraping [
      {
        job_name = "${name}";
        honor_labels = true;
        static_configs = [{
          targets = [ "127.0.0.1:${toString cfg.port}" ];
        }];
      }
    ];
  };
}

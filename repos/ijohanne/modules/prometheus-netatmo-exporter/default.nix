{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.prometheus-netatmo-exporter;
  name = "netatmo";
in
{
  options.services.prometheus-netatmo-exporter = with types; mkOption {
    type = types.submodule {
      options = {
        enable = mkEnableOption "the prometheus ${name} exporter";
        enableLocalScraping = mkEnableOption "enable scraping by local prometheus";
        port = mkOption {
          type = types.port;
          default = 9210;
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
        clientId = mkOption {
          type = types.nullOr types.str;
          description = ''
            Client ID for NetAtmo app
          '';
        };
        clientSecret = mkOption {
          type = types.nullOr types.str;
          description = ''
            Client secret for NetAtmo app
          '';
        };
        username = mkOption {
          type = types.nullOr types.str;
          description = ''
            Username of NetAtmo account
          '';
        };
        password = mkOption {
          type = types.nullOr types.str;
          description = ''
            Password of NetAtmo account
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
      serviceConfig.Restart = "always";
      serviceConfig.PrivateTmp = true;
      serviceConfig.WorkingDirectory = /tmp;
      serviceConfig.DynamicUser = false;
      serviceConfig.User = "${cfg.user}";
      serviceConfig.Group = "${cfg.group}";
      serviceConfig.ExecStart = ''
        ${getBin pkgs.prometheus-netatmo-exporter}/bin/netatmo-exporter \
        -a "${cfg.listenAddress}:${toString cfg.port}" \
        -i "${cfg.clientId}" \
        -s "${cfg.clientSecret}" \
        -u "${cfg.username}" \
        -p "${cfg.password}"
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

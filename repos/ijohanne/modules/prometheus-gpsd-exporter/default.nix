self:
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.prometheus-gpsd-exporter;
  name = "gpsd";
  package = self.legacyPackages.${pkgs.stdenv.hostPlatform.system}.prometheus-gpsd-exporter;
in
{
  options.services.prometheus-gpsd-exporter = with types; mkOption {
    type = types.submodule {
      options = {
        enable = mkEnableOption "the prometheus ${name} exporter";
        enableLocalScraping = mkEnableOption "scraping by local prometheus";
        port = mkOption {
          type = types.port;
          default = 9015;
          description = "Port to listen on.";
        };
        listenAddress = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Address to listen on.";
        };
        gpsdHost = mkOption {
          type = types.str;
          default = "localhost";
          description = "Hostname or IP of the gpsd instance to connect to.";
        };
        gpsdPort = mkOption {
          type = types.port;
          default = 2947;
          description = "Port of the gpsd instance.";
        };
        extraFlags = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Extra commandline options to pass to the exporter.";
        };
        user = mkOption {
          type = types.str;
          default = "${name}-exporter";
          description = "User name under which the ${name} exporter shall be run.";
        };
        group = mkOption {
          type = types.str;
          default = "${name}-exporter";
          description = "Group under which the ${name} exporter shall be run.";
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
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Restart = "always";
        PrivateTmp = true;
        WorkingDirectory = "/tmp";
        DynamicUser = false;
        User = cfg.user;
        Group = cfg.group;
        ExecStart = concatStringsSep " " ([
          "${getBin package}/bin/gpsd-prometheus-exporter"
          "-H ${cfg.gpsdHost}"
          "-p ${toString cfg.gpsdPort}"
          "-E ${toString cfg.port}"
          "-L ${cfg.listenAddress}"
        ] ++ cfg.extraFlags);
      };
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

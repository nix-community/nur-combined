self:
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.pg-exporter;
  package = self.legacyPackages.${pkgs.system}.pg-exporter;

  settingsFormat = pkgs.formats.yaml { };

  disabledFile = pkgs.writeText "pg-exporter-disabled.yml" (builtins.toJSON
    (builtins.listToAttrs (map (name: { inherit name; value = { skip = true; }; }) cfg.disabledCollectors)));

  settingsFile = settingsFormat.generate "pg-exporter-custom.yml" cfg.settings;

  configDir = pkgs.runCommand "pg-exporter-config" { } (''
    mkdir -p $out
  '' + optionalString cfg.defaultCollectors ''
    cp ${package}/share/pg_exporter/*.yml $out/
  '' + optionalString (cfg.disabledCollectors != [ ]) ''
    cp ${disabledFile} $out/9999-disabled.yml
  '' + optionalString (cfg.settings != { }) ''
    cp ${settingsFile} $out/9999-custom.yml
  '');
in
{
  options.services.pg-exporter = with types; mkOption {
    type = types.submodule {
      options = {
        enable = mkEnableOption "pg_exporter PostgreSQL metrics exporter";
        port = mkOption {
          type = types.port;
          default = 9630;
          description = "Port to listen on.";
        };
        listenAddress = mkOption {
          type = types.str;
          default = "0.0.0.0";
          description = "Address to listen on.";
        };
        environmentFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Environment file containing PG_EXPORTER_URL and other secrets.";
        };
        defaultCollectors = mkOption {
          type = types.bool;
          default = true;
          description = "Include bundled collector YAML configs from the package.";
        };
        disabledCollectors = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Bundled collector names to disable (generates skip: true overrides).";
        };
        settings = mkOption {
          type = settingsFormat.type;
          default = { };
          description = "Custom collectors defined in Nix, rendered to YAML.";
        };
        autoDiscovery = mkOption {
          type = types.bool;
          default = false;
          description = "Enable --auto-discovery to monitor all databases.";
        };
        extraFlags = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Additional CLI flags to pass to pg_exporter.";
        };
        user = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "User to run the service as. If null, DynamicUser is used.";
        };
        enableLocalScraping = mkEnableOption "scraping by local prometheus";
        grafanaDashboard = mkEnableOption "Grafana dashboard provisioning for pg_exporter";
      };
    };
    default = { };
  };

  config = mkIf cfg.enable {
    systemd.services.pg-exporter = {
      description = "pg_exporter PostgreSQL metrics exporter";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "postgresql.service" ];
      serviceConfig = {
        Restart = "always";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
      } // (if cfg.user != null then {
        User = cfg.user;
      } else {
        DynamicUser = true;
        ProtectSystem = "strict";
      }) // {
        ExecStart = concatStringsSep " " ([
          "${getBin package}/bin/pg_exporter"
          "--config=${configDir}"
          "--web.listen-address=${cfg.listenAddress}:${toString cfg.port}"
        ]
        ++ optional cfg.autoDiscovery "--auto-discovery"
        ++ cfg.extraFlags);
      } // optionalAttrs (cfg.environmentFile != null) {
        EnvironmentFile = cfg.environmentFile;
      };
    };

    services.grafana.provision.dashboards.settings.providers = mkIf cfg.grafanaDashboard [
      {
        name = "pg-exporter";
        options.path = pkgs.runCommand "pg-exporter-dashboards" { } ''
          mkdir -p $out
          cp ${./dashboard.json} $out/postgres.json
        '';
      }
    ];

    services.prometheus.scrapeConfigs = mkIf cfg.enableLocalScraping [
      {
        job_name = "postgres";
        honor_labels = true;
        static_configs = [{
          targets = [ "127.0.0.1:${toString cfg.port}" ];
        }];
      }
    ];
  };
}

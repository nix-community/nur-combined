{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.prometheus-nut-exporter;
  port = lists.last (strings.splitString ":" cfg.address);
in {
  options.services.prometheus-nut-exporter = {
    enable = mkEnableOption "the prometheus NUT exporter";
    address = mkOption {
      type = types.str;
      default = "127.0.0.1:9995";
      description = ''
        Address of nut exporter
      '';
    };
    nutAddress = mkOption {
      type = types.str;
      default = "127.0.0.1:3493";
      description = ''
        Path under which to expose metrics.
      '';
    };
    telemetryPath = mkOption {
      type = types.str;
      default = "/metrics";
      description = ''
        Path under which to expose metrics.
      '';
    };
    debugLevel = mkOption {
      type = types.str;
      default = "info";
      description = ''
        The log level used by the console
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services."prometheus-nut-exporter" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      environment = {
        RUST_LOG = cfg.debugLevel;
        HTTP_PORT = port;
        HTTP_PATH = cfg.telemetryPath;
      };
      serviceConfig = {
        ExecStart = ''
          ${pkgs.nur.repos.dukzcry.prometheus-nut-exporter}/bin/prometheus-nut-exporter
        '';
      };
    };
    services.prometheus = {
      scrapeConfigs = [{
        job_name = "nut";
        metrics_path = cfg.telemetryPath;
        static_configs = [{
          targets = [ cfg.nutAddress ];
        }];
        relabel_configs = [
          { source_labels = ["__address__"];    target_label = "__param_target"; }
          { source_labels = ["__param_target"]; target_label = "instance"; }
          { source_labels = []; target_label = "__address__"; replacement = cfg.address; }
        ];
      }];
    };

  };
}

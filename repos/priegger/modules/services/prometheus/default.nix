{ config, pkgs, lib, ... }:

with lib;
let
  hostName = config.networking.hostName;
  prometheusPort = builtins.elemAt (lib.strings.splitString ":" config.services.prometheus.listenAddress) 1;

  nodeExporterPort = toString config.services.prometheus.exporters.node.port;
  torExporterPort = toString config.services.prometheus.exporters.tor.port;

  cfg = config.priegger.services.prometheus;
in
{
  options.priegger.services.prometheus = {
    enable = mkEnableOption "Enable the Prometheus monitoring daemon and some exporters.";
  };

  config = mkIf cfg.enable {
    services.prometheus = {
      enable = true;

      exporters = mkDefault {
        node = {
          enable = true;
          enabledCollectors = [ "logind" "systemd" "tcpstat" ];
          extraFlags = [
            "--collector.textfile.directory=/var/lib/prometheus-node-exporter-text-files"
          ];
        };
        tor = {
          enable = mkDefault config.services.tor.enable;
        };
      };

      scrapeConfigs = [
        {
          job_name = "prometheus";
          static_configs = [
            { targets = [ "${hostName}:${prometheusPort}" ]; }
          ];
        }
        (
          mkIf config.services.prometheus.exporters.node.enable {
            job_name = "node";
            static_configs = [
              { targets = [ "${hostName}:${nodeExporterPort}" ]; }
            ];
          }
        )
        (
          mkIf config.services.prometheus.exporters.tor.enable {
            job_name = "tor";
            static_configs = [
              { targets = [ "${hostName}:${torExporterPort}" ]; }
            ];
          }
        )
      ];

      ruleFiles = [
        ./files/prometheus-alerts.yml
        (mkIf config.services.prometheus.exporters.node.enable ./files/node-alerts.yml)
      ];
    };

    system.activationScripts.node-exporter-system-version = mkIf config.services.prometheus.exporters.node.enable ''
      mkdir -pm 0775 /var/lib/prometheus-node-exporter-text-files
      (
        cd /var/lib/prometheus-node-exporter-text-files
        (
          echo -n "system_version ";
          if [ -L /nix/var/nix/profiles/system ]; then
            readlink /nix/var/nix/profiles/system | cut -d- -f2
          else
            echo NaN
          fi
        ) > system-version.prom.next
        mv system-version.prom.next system-version.prom
      )
    '';
  };
}

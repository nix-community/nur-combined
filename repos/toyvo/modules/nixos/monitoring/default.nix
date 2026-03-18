{
  config,
  lib,
  pkgs,
  homelab,
  ...
}:
let
  cfg = config.services.monitoring;
  lokiUrl = "http://${homelab.nas.ip}:3100/loki/api/v1/push";
  prometheusUrl = "http://${homelab.nas.ip}:9090/api/v1/write";
  hostname = config.networking.hostName;

  alloyConfig = ''
    // Node metrics — push to Prometheus via remote_write
    prometheus.exporter.unix "node" {
      disable_collectors = ["mdadm"]
    }

    prometheus.scrape "node" {
      targets    = prometheus.exporter.unix.node.targets
      forward_to = [prometheus.relabel.instance.receiver]
      scrape_interval = "15s"
    }

    prometheus.relabel "instance" {
      rule {
        target_label = "instance"
        replacement  = "${hostname}"
      }
      forward_to = [prometheus.remote_write.default.receiver]
    }

    prometheus.remote_write "default" {
      endpoint {
        url = "${prometheusUrl}"
      }
    }

    // Journal log collection — push to Loki
    loki.source.journal "systemd" {
      forward_to = [loki.relabel.journal.receiver]
      relabel_rules = loki.relabel.journal.rules
      labels = {
        host = "${hostname}",
      }
    }

    loki.relabel "journal" {
      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }
      rule {
        source_labels = ["__journal_priority_keyword"]
        target_label  = "priority"
      }
      forward_to = [loki.write.default.receiver]
    }

    loki.write "default" {
      endpoint {
        url = "${cfg.lokiPushUrl}"
        headers = {
          "X-Scope-OrgID" = "${hostname}",
        }
      }
    }
  '';
in
{
  options.services.monitoring = {
    enable = lib.mkEnableOption "monitoring agent (Grafana Alloy)";

    lokiPushUrl = lib.mkOption {
      type = lib.types.str;
      default = lokiUrl;
      description = "Loki push API URL";
    };
  };

  config = lib.mkIf cfg.enable {
    services.alloy = {
      enable = true;
      extraFlags = [ "--stability.level=generally-available" ];
    };

    users.users.alloy = {
      isSystemUser = true;
      group = "alloy";
      extraGroups = [ "systemd-journal" ];
    };
    users.groups.alloy = { };

    environment.etc."alloy/config.alloy".text = alloyConfig;
  };
}

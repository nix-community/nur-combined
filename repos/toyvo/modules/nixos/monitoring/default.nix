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

  # Detect which services are enabled on this machine
  caddyEnabled = config.services.caddy.enable;
  postgresEnabled = config.services.postgresql.enable;
  keaEnabled = config.services.kea.dhcp4.enable or false;

  # Alloy scrape blocks for detected services
  caddyScrape = lib.optionalString caddyEnabled ''
    // Caddy metrics
    prometheus.scrape "caddy" {
      targets = [{"__address__" = "localhost:2019"}]
      forward_to = [prometheus.relabel.instance.receiver]
      scrape_interval = "15s"
      metrics_path = "/metrics"
    }
  '';

  postgresScrape = lib.optionalString postgresEnabled ''
    // PostgreSQL metrics (via NixOS postgres exporter on :9187)
    prometheus.scrape "postgres" {
      targets = [{"__address__" = "localhost:9187"}]
      forward_to = [prometheus.relabel.instance.receiver]
      scrape_interval = "15s"
    }
  '';

  keaScrape = lib.optionalString keaEnabled ''
    // Kea DHCP metrics (via NixOS kea exporter on :9547)
    prometheus.scrape "kea" {
      targets = [{"__address__" = "localhost:9547"}]
      forward_to = [prometheus.relabel.instance.receiver]
      scrape_interval = "15s"
    }
  '';

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

    ${caddyScrape}
    ${postgresScrape}
    ${keaScrape}

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

    # Enable NixOS Prometheus exporters for detected services
    services.prometheus.exporters.postgres = lib.mkIf postgresEnabled {
      enable = true;
      runAsLocalSuperUser = true;
    };

    services.prometheus.exporters.kea = lib.mkIf keaEnabled {
      enable = true;
      controlSocketPaths = [
        "/run/kea/kea-dhcp4.socket"
      ];
    };

    environment.etc."alloy/config.alloy".text = alloyConfig;
  };
}

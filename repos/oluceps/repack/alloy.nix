{ pkgs, reIf, ... }:
reIf {
  services.alloy = {
    enable = true;
  };
  systemd.services.alloy.serviceConfig = {
    ReadOnlyPaths = [ "/var/log/zeek" ];
  };
  environment.etc."alloy/config.alloy".text = # alloy
    ''
      livedebugging {
        enabled = false
      }
      // discovery.relabel "journal" {
      // 	targets = []
      // 	rule {
      // 		source_labels = ["__journal__systemd_unit"]
      // 		target_label  = "unit"
      // 	}
      // }
      // loki.source.journal "journal" {
      //     max_age       = "12h0m0s"
      //     relabel_rules = discovery.relabel.journal.rules
      //     forward_to    = [loki.write.default.receiver]
      //     labels        = {
      //         host = "hastur",
      //         job  = "systemd-journal",
      //     }
      // }
      local.file_match "zeek_logs" {
        path_targets = [
          { "__path__" = "/var/log/zeek/dns.log" },
          { "__path__" = "/var/log/zeek/ssl.log" },
        ]
        sync_period = "5s"
      }

      loki.source.file "zeek_logs" {
        targets    = local.file_match.zeek_logs.targets
        forward_to = [loki.write.default.receiver]
        tail_from_end = true
      }

      local.file_match "zeek_conns" {
        path_targets = [
          { "__path__" = "/var/log/zeek/conn.log" },
        ]
        sync_period = "5s"
      }

      loki.source.file "zeek_conns" {
        targets    = local.file_match.zeek_conns.targets
        forward_to = [loki.process.conn_geo.receiver]
        tail_from_end = true
      }

      loki.process "conn_geo" {
        stage.json {
          expressions = {
            ts        = "ts",
            dst = "\"id.resp_h\"",
            dpt = "\"id.resp_p\"",
            proto     = "proto",
            ip_proto  = "ip_proto",
          }
        }

        stage.geoip {
          source  = "dst"
          db      = "${
            pkgs.fetchurl {
              url = "https://github.com/P3TERX/GeoLite.mmdb/releases/download/2025.09.19/GeoLite2-ASN.mmdb";
              hash = "sha256-XcKyiL+glMPlyoMuXnDXF0zPEJ/yjTKIwJiNc4L6zz0=";
            }
          }"
          db_type = "asn"
        }
        stage.geoip {
          source  = "dst"
          db      = "${
            pkgs.fetchurl {
              url = "https://github.com/P3TERX/GeoLite.mmdb/releases/download/2025.09.16/GeoLite2-City.mmdb";
              hash = "sha256-b9IhwKmT2kRy7YhD18LtzKc2okuv5YYsPvqJoLfA03M=";
            }
          }"
          db_type = "city"
        }

        stage.labels {
          values = {
            ts  = "",
            dst = "",
            dpt = "",
            proto     = "",
            ip_proto  = "",
            dst_city = "geoip_city_name",
            dst_as_org = "geoip_autonomous_system_organization",
            dst_lat = "geoip_location_latitude",
            dst_lon = "geoip_location_longitude",
          }
        }
        forward_to = [loki.write.default.receiver]
      }

      loki.write "default" {
      	endpoint {
      		url = "http://[fdcc::1]:3030/loki/api/v1/push"
      	}
      	external_labels = {}
      }
    '';
}

{ pkgs, reIf, ... }:
reIf {
  services.alloy = {
    enable = true;
  };
  environment.etc."alloy/config.alloy".text = ''
    livedebugging {
      enabled = true
    }
    discovery.relabel "journal" {
    	targets = []
    	rule {
    		source_labels = ["__journal__systemd_unit"]
    		target_label  = "unit"
    	}
    }
    loki.source.journal "journal" {
        max_age       = "12h0m0s"
        relabel_rules = discovery.relabel.journal.rules
        forward_to    = [loki.process.nftables_geo.receiver]
        labels        = {
            host = "vm1",
            job  = "systemd-journal",
        }
    }
    loki.process "nftables_geo" {
      stage.regex {
        expression = "\\[NFT_VM_FORWARD_LOG\\].*DST=(?P<dst>\\S+)"
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
            dst_city = "geoip_city_name",
            dst_as_org = "geoip_autonomous_system_organization",
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

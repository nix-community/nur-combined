{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.monitoring.internet;
  textfileDir = "/var/lib/alloy/textfiles";

  speedtestScript = pkgs.writeShellScript "speedtest-to-prom" ''
    set -euo pipefail

    OUTDIR="${textfileDir}"
    TMPFILE=$(${pkgs.coreutils}/bin/mktemp)
    OUTFILE="$OUTDIR/speedtest.prom"

    cleanup() { ${pkgs.coreutils}/bin/rm -f "$TMPFILE"; }
    trap cleanup EXIT

    result=$(${pkgs.fast-cli-zig}/bin/fast-cli --upload --json 2>/dev/null) || {
      ${pkgs.coreutils}/bin/rm -f "$OUTFILE"
      exit 0
    }

    download=$(printf '%s' "$result" | ${pkgs.jq}/bin/jq -r '.download_mbps // empty')
    upload=$(printf '%s' "$result"   | ${pkgs.jq}/bin/jq -r '.upload_mbps // empty')
    latency=$(printf '%s' "$result"  | ${pkgs.jq}/bin/jq -r '.ping_ms // empty')

    # Abort cleanly if any value is empty (null or missing field)
    if [ -z "$download" ] || [ -z "$upload" ] || [ -z "$latency" ]; then
      ${pkgs.coreutils}/bin/rm -f "$OUTFILE"
      exit 0
    fi

    {
      printf '# HELP internet_download_speed_mbps Internet download speed in Mbps (fast.com)\n'
      printf '# TYPE internet_download_speed_mbps gauge\n'
      printf 'internet_download_speed_mbps %s\n' "$download"
      printf '# HELP internet_upload_speed_mbps Internet upload speed in Mbps (fast.com)\n'
      printf '# TYPE internet_upload_speed_mbps gauge\n'
      printf 'internet_upload_speed_mbps %s\n' "$upload"
      printf '# HELP internet_latency_ms Internet round-trip latency in milliseconds (fast.com)\n'
      printf '# TYPE internet_latency_ms gauge\n'
      printf 'internet_latency_ms %s\n' "$latency"
    } > "$TMPFILE"

    ${pkgs.coreutils}/bin/mv "$TMPFILE" "$OUTFILE"
  '';

  internetAlloyConfig = ''
    // ICMP probes — internet uptime monitoring
    prometheus.exporter.blackbox "internet" {
      config_file = "/etc/alloy/blackbox-internet.yaml"

      target {
        name    = "google-dns"
        address = "8.8.8.8"
        module  = "icmp_ipv4"
      }

      target {
        name    = "cloudflare-dns"
        address = "1.1.1.1"
        module  = "icmp_ipv4"
      }
    }

    prometheus.scrape "blackbox_internet" {
      targets         = prometheus.exporter.blackbox.internet.targets
      forward_to      = [prometheus.relabel.instance.receiver]
      scrape_interval = "15s"
    }
  '';
in
{
  options.services.monitoring.internet = {
    enable = lib.mkEnableOption "internet uptime and speed monitoring";

    speedtestInterval = lib.mkOption {
      type = lib.types.str;
      default = "30min";
      description = "How often to run the speed test (systemd OnUnitActiveSec format).";
    };
  };

  config = lib.mkIf cfg.enable {
    services.monitoring.textfileDirectory = textfileDir;
    services.monitoring.alloyExtraConfig = internetAlloyConfig;

    environment.etc."alloy/blackbox-internet.yaml".text = ''
      modules:
        icmp_ipv4:
          prober: icmp
          timeout: 5s
          icmp:
            preferred_ip_protocol: ip4
    '';

    # Create textfile directory owned by alloy user
    systemd.tmpfiles.rules = [
      "d ${textfileDir} 0755 alloy alloy -"
    ];

    # Alloy needs CAP_NET_RAW to send ICMP packets
    systemd.services.alloy.serviceConfig = {
      AmbientCapabilities = [ "CAP_NET_RAW" ];
      DynamicUser = lib.mkForce false;
    };

    systemd.services.speedtest = {
      description = "Internet speed test via fast.com";
      serviceConfig = {
        Type = "oneshot";
        User = "alloy";
        ExecStart = speedtestScript;
      };
    };

    systemd.timers.speedtest = {
      description = "Periodic internet speed test";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5min";
        OnUnitActiveSec = cfg.speedtestInterval;
        Persistent = true;
      };
    };
  };
}

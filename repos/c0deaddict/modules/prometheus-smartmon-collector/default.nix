{ pkgs, lib, config, ... }:

with lib;

let

  repo = pkgs.fetchFromGitHub {
    owner = "prometheus-community";
    repo = "node-exporter-textfile-collector-scripts";
    rev = "414fb44693444cb96a55c7152cdd84d531888e1f";
    sha256 = "13ja3l78bb47xhdfsmsim5sqggb9avg3x872jqah1m7jm9my7m98";
  };

  cfg = config.services.prometheus.smartmon-collector;

in {

  options.services.prometheus.smartmon-collector = {
    enable = mkEnableOption "the prometheus smartmon collector";

    interval = mkOption {
      type = types.str;
      default = "2m";
      description = "Interval to collect smartmon information on.";
    };

    textfileDir = mkOption {
      type = types.str;
      default = "/var/lib/prometheus/node-exporter/textfile";
      description = "Textfile directory that node-exporter is watching";
    };
  };

  config = mkIf cfg.enable {
    systemd.services."prometheus-smartmon-collector" = {
      description = "Prometheus smartmon collector";
      path = with pkgs; [ python3 smartmontools moreutils ];
      serviceConfig = {
        Type = "oneshot";
        PrivateTmp = true;
        ExecStart = pkgs.writers.writeDash "smartmon" ''
          python3 "${repo}/smartmon.py" | sponge ${cfg.textfileDir}/smartmon.prom
        '';
      };
    };

    systemd.timers."prometheus-smartmon-collector" = {
      description = "Timer for the Prometheus smartmon collector";
      partOf = [ "prometheus-smartmon-collector.service" ];
      wantedBy = [ "timers.target" ];
      timerConfig.OnBootSec = "1m";
      timerConfig.OnUnitActiveSec = cfg.interval;
    };
  };

}

{ pkgs, lib, config, ... }:

with lib;

let

  repo = pkgs.fetchFromGitHub {
    owner = "prometheus-community";
    repo = "node-exporter-textfile-collector-scripts";
    rev = "414fb44693444cb96a55c7152cdd84d531888e1f";
    sha256 = "13ja3l78bb47xhdfsmsim5sqggb9avg3x872jqah1m7jm9my7m98";
  };

  cfg = config.services.prometheus.nvme-collector;

in {

  options.services.prometheus.nvme-collector = {
    enable = mkEnableOption "the prometheus nvme collector";

    interval = mkOption {
      type = types.str;
      default = "2m";
      description = "Interval to collect nvme metrics on.";
    };

    textfileDir = mkOption {
      type = types.str;
      default = "/var/lib/prometheus/node-exporter/textfile";
      description = "Textfile directory that node-exporter is watching";
    };
  };

  config = mkIf cfg.enable {
    systemd.services."prometheus-nvme-collector" = {
      description = "Prometheus nvme collector";
      path = with pkgs; [ bash nvme-cli gawk jq moreutils ];
      serviceConfig = {
        Type = "oneshot";
        PrivateTmp = true;
        ExecStart = pkgs.writers.writeDash "nvme-collect" ''
          "${repo}/nvme_metrics.sh" | sponge ${cfg.textfileDir}/nvme.prom
        '';
      };
    };

    systemd.timers."prometheus-nvme-collector" = {
      description = "Timer for the Prometheus nvme collector";
      partOf = [ "prometheus-nvme-collector.service" ];
      wantedBy = [ "timers.target" ];
      timerConfig.OnBootSec = "1m";
      timerConfig.OnUnitActiveSec = cfg.interval;
    };
  };

}

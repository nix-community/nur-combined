{ config, pkgs, lib, ... }:

with lib;
let
  hostName = config.networking.hostName;
  prometheusPort = builtins.elemAt (lib.strings.splitString ":" config.services.prometheus.listenAddress) 1;

  nodeTextfileDirectory = "/var/lib/prometheus-node-exporter-text-files";
  nodeExporterPort = toString config.services.prometheus.exporters.node.port;

  cfg = config.priegger.services.prometheus;
in
{
  options.priegger.services.prometheus = {
    enable = mkEnableOption "Enable the Prometheus monitoring daemon and some exporters.";

    exporters.node.textfileDirectory = mkOption {
      type = types.str;
      readOnly = true;
      description = ''
        Path to the promethes node exporter textfile directory.
        This option is read-only.
      '';
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays =
      let
        unbreak = p: p.overrideAttrs (old: { meta = old.meta // { broken = false; }; });
      in
      [
        # error: Package ‘python3.7-stem-1.7.1’ in /nix/store/... is marked as broken, refusing to evaluate.
        (
          mkIf
            config.services.prometheus.exporters.tor.enable
            (self: super: { python3Packages = super.python3Packages // { stem = unbreak super.python3Packages.stem; }; })
        )
      ];

    priegger.services.prometheus.exporters.node.textfileDirectory = nodeTextfileDirectory;

    services.prometheus = {
      enable = true;

      exporters = {
        node = {
          enable = mkDefault true;
          enabledCollectors = [ "logind" "systemd" "tcpstat" ];
          extraFlags = [
            "--collector.textfile.directory=${nodeTextfileDirectory}"
          ];
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
      ];

      ruleFiles = [
        ./files/prometheus-alerts.yml
        (mkIf config.services.prometheus.exporters.node.enable ./files/node-alerts.yml)
      ];
    };

    system.activationScripts.node-exporter-system-version = mkIf config.services.prometheus.exporters.node.enable ''
      mkdir -pm 0775 ${nodeTextfileDirectory}
      (
        cd ${nodeTextfileDirectory}
        (
          echo -n "system_version "
          if [ -L /nix/var/nix/profiles/system ]; then
            readlink /nix/var/nix/profiles/system | cut -d- -f2
          else
            echo NaN
          fi

          echo "system_activation_time_seconds $(date -u '+%s')"

          echo -n "system_nixpkgs_time_seconds "
          if [ -x /run/current-system/sw/bin/nixos-version ]; then
            nixos_revision="$(/run/current-system/sw/bin/nixos-version --revision)"
            commit_json="$(${pkgs.curl}/bin/curl -H 'Accept: application/vnd.github.v3+json' https://api.github.com/repos/NixOS/nixpkgs/commits/"$nixos_revision")"
            if [ "$?" = "0" ]; then
              nixos_date="$(echo "$commit_json" | ${pkgs.jq}/bin/jq -r .commit.author.date)"
              date --date="$nixos_date" -u '+%s'
            else
              echo NaN
            fi
          else
            echo NaN
          fi
        ) > system-version.prom.next
        mv system-version.prom.next system-version.prom
      )
    '';
  };
}

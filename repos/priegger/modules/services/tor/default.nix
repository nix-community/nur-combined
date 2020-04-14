{ config, pkgs, lib, ... }:

with lib;
let
  torOnionDirectory = "/var/lib/tor/onion";
  nodeTextfileDirectory = config.priegger.services.prometheus.exporters.node.textfileDirectory;

  torMetrics = pkgs.writeScript "tor-metrics" ''
    #!/usr/bin/env bash
    set -xeu -o pipefail

    mkdir -pm 0775 ${nodeTextfileDirectory}
    (
      cd ${nodeTextfileDirectory}
      (
        onionCount="$(find ${torOnionDirectory}/ -maxdepth 1 -mindepth 1 -type d | wc -l)"
        if [ "$onionCount" -gt 0 ]; then
          echo "# HELP tor_onion_service_info A metric with a constant '1' value labeled by name and hostname of the onion service."
          echo "# TYPE tor_onion_service_info gauge"
          ls -d ${torOnionDirectory}/* | while read service_dir; do
            name="$(basename "$service_dir")"
            hostname="$(cat "$service_dir/hostname")"
            echo "tor_onion_service_info{name=\"$name\",hostname=\"$hostname\"} 1"
          done
        fi
      ) > tor-metrics.prom.next
      mv tor-metrics.prom.next tor-metrics.prom
    )
  '';

  cfg = config.priegger.services.tor;
in
{
  options.priegger.services.tor = {
    enable = mkEnableOption "Enable the Tor daemon. By default, the daemon is run without relay, exit or bridge connectivity. ";
  };

  config = mkIf cfg.enable {
    services.tor = {
      enable = mkDefault true;
      controlPort = mkDefault 9051;

      client.enable = mkDefault true;

      hiddenServices = mkIf config.services.openssh.enable {
        "ssh" = {
          map = [
            { port = 22; }
          ];
          version = 3;
        };
      };
    };

    programs.ssh.extraConfig = mkIf config.services.tor.enable ''
      Host *.onion
      ProxyCommand ${pkgs.netcat}/bin/nc -x${config.services.tor.client.socksListenAddress} -X5 %h %p
    '';

    systemd = mkIf (config.services.tor.enable && config.priegger.services.prometheus.enable) {
      services = {
        "tor-metrics" = {
          description = "Additional metrics for tor";
          path = with pkgs; [ bash ];
          serviceConfig = {
            User = "root";
            ExecStart = torMetrics;
          };
        };
      };

      paths = {
        "tor-onion-service-names" = {
          description = "Tor onion service hostname paths";
          wantedBy = [ "multi-user.target" ];
          pathConfig = let
            paths = map (name: "${torOnionDirectory}/${name}") (attrNames config.services.tor.hiddenServices);
          in
            {
              PathExists = toString paths;
              PathChanged = toString paths;
              Unit = "tor-metrics.service";
            };
        };
      };
    };
  };
}

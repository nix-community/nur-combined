{ config, pkgs, lib, ... }:

with lib;
let
  hostName = config.networking.hostName;

  torOnionDirectory = "/var/lib/tor/onion";
  nodeTextfileDirectory = config.priegger.services.prometheus.exporters.node.textfileDirectory;

  torExporterPort = toString config.services.prometheus.exporters.tor.port;

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
    enable = mkEnableOption "Enable the Tor daemon. By default, the daemon is run without relay, exit or bridge connectivity.";
  };

  config = mkIf cfg.enable {
    services.tor = {
      enable = mkDefault true;
      client.enable = mkDefault true;
    } // (if builtins.hasAttr "settings" config.services.tor then {
      settings.ControlPort = mkDefault 9051;
    } else {
      controlPort = mkDefault 9051;
    }) // (if builtins.hasAttr "onionServices" config.services.tor.relay then {
      relay.onionServices = mkIf config.services.openssh.enable {
        "ssh" = {
          map = [
            { port = 22; }
          ];
          version = 3;
        };
      };

    } else {
      hiddenServices = mkIf config.services.openssh.enable {
        "ssh" = {
          map = [
            { port = 22; }
          ];
          version = 3;
        };
      };
    });

    programs.ssh.extraConfig = mkIf config.services.tor.enable (if builtins.isAttrs config.services.tor.client.socksListenAddress then ''
      Host *.onion
      ProxyCommand ${pkgs.netcat}/bin/nc -x${config.services.tor.client.socksListenAddress.addr}:${toString config.services.tor.client.socksListenAddress.port} -X5 %h %p
    '' else ''
      Host *.onion
      ProxyCommand ${pkgs.netcat}/bin/nc -x${config.services.tor.client.socksListenAddress} -X5 %h %p
    '');

    services.prometheus = mkIf config.services.prometheus.enable {
      exporters = {
        tor = {
          enable = mkDefault true;
        };
      };

      scrapeConfigs = [
        (
          mkIf config.services.prometheus.exporters.tor.enable {
            job_name = "tor";
            static_configs = [
              { targets = [ "${hostName}:${torExporterPort}" ]; }
            ];
          }
        )
      ];
    };

    /*
    TODO: There is some rate limiting/cpu usage issue, so this is disabled for now.

    systemd =
      let
        onionServiceNames =
          map
            (name: "${torOnionDirectory}/${name}")
            (attrNames config.services.tor.hiddenServices);

        hasNodeExporter = config.services.prometheus.exporters.node.enable;
        hasTor = config.services.tor.enable;
        hasOnionService = onionServiceNames != [ ];
      in
      mkIf (hasNodeExporter && hasTor && hasOnionService) {
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
          "tor-onion-services" = {
            description = "Tor onion service hostname paths";
            wantedBy = [ "multi-user.target" ];
            pathConfig = {
              PathExists = toString onionServiceNames;
              PathChanged = toString onionServiceNames;
              Unit = "tor-metrics.service";
            };
          };
        };
      };
    */
  };
}

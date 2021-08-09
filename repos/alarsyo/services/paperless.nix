{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my.services.paperless;
  my = config.my;
  domain = config.networking.domain;
in
{
  options.my.services.paperless = {
    enable = lib.mkEnableOption "Paperless";

    port = mkOption {
      type = types.port;
      default = 8080;
      example = 8080;
      description = "Internal port for Paperless service";
    };
  };

  config = mkIf cfg.enable {
    # HACK: see https://github.com/NixOS/nixpkgs/issues/111852
    networking.firewall.extraCommands = ''
      iptables -N DOCKER-USER || true
      iptables -F DOCKER-USER
      iptables -A DOCKER-USER -i eno1 -m state --state RELATED,ESTABLISHED -j ACCEPT
      iptables -A DOCKER-USER -i eno1 -j DROP
    '';

    services.nginx.virtualHosts = {
      "paperless.${domain}" = {
        forceSSL = true;
        useACMEHost = domain;

        listen = [
          # FIXME: hardcoded tailscale IP
          {
            addr = "100.80.61.67";
            port = 443;
            ssl = true;
          }
          {
            addr = "100.80.61.67";
            port = 80;
            ssl = false;
          }
        ];

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };

    my.services.restic-backup = mkIf cfg.enable {
      paths = [
        "/var/lib/docker/volumes/paperless_data"
        "/var/lib/docker/volumes/paperless_media"
        "/home/alarsyo/paperless-ng/backups"
      ];
    };
  };
}

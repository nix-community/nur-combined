{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    ;

  cfg = config.my.services.immich;
  my = config.my;

  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";
in {
  options.my.services.immich = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Immich config";

    home = mkOption {
      type = types.str;
      default = "/var/lib/immich";
      example = "/var/lib/immich";
      description = "Home for the immich service, where data will be stored";
    };

    port = mkOption {
      type = types.port;
      example = 8080;
      description = "Internal port for Immich webapp";
    };
  };

  config = mkIf cfg.enable {
    users.users.immich = {
      isSystemUser = true;
      home = cfg.home;
      createHome = true;
      group = "immich";
    };
    users.groups.immich = {};

    services.nginx.virtualHosts = {
      "immich.${domain}" = {
        forceSSL = true;
        useACMEHost = fqdn;

        listen = [
          # FIXME: hardcoded tailscale IP
          {
            addr = "100.115.172.44";
            port = 443;
            ssl = true;
          }
          {
            addr = "100.115.172.44";
            port = 80;
            ssl = false;
          }
        ];

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };

        extraConfig = ''
          proxy_connect_timeout 600;
          proxy_read_timeout 600;
          proxy_send_timeout 600;
          client_max_body_size 1000m;
          access_log syslog:server=unix:/dev/log,tag=immich;
        '';
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = ["immich.${domain}"];
  };
}

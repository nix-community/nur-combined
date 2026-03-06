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

  cfg = config.my.services.journiv;
  my = config.my;

  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";
in {
  options.my.services.journiv = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Journiv config";

    home = mkOption {
      type = types.str;
      default = "/var/lib/journiv";
      example = "/var/lib/journiv";
      description = "Home for the journiv service, where data will be stored";
    };

    port = mkOption {
      type = types.port;
      example = 8080;
      description = "Internal port for Journiv webapp";
    };
  };

  config = mkIf cfg.enable {
    users.users.journiv = {
      isSystemUser = true;
      home = cfg.home;
      createHome = true;
      group = "journiv";
    };
    users.groups.journiv = {};

    services.nginx.virtualHosts = {
      "journiv.${domain}" = {
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
          client_max_body_size 500m;
          access_log syslog:server=unix:/dev/log,tag=journiv;
        '';
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = ["journiv.${domain}"];

    # my.services.restic-backup = mkIf cfg.enable {
    #   paths = [
    #     cfg.home
    #   ];
    #   exclude = [
    #     "${cfg.home}/storage"
    #   ];
    # };
  };
}

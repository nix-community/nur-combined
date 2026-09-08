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

  cfg = config.my.services.bookorbit;
  my = config.my;

  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";
in {
  options.my.services.bookorbit = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Bookorbit config";

    home = mkOption {
      type = types.str;
      default = "/var/lib/bookorbit";
      example = "/var/lib/bookorbit";
      description = "Home for the bookorbit service, where data will be stored";
    };

    port = mkOption {
      type = types.port;
      example = 8080;
      description = "Internal port for Bookorbit webapp";
    };
  };

  config = mkIf cfg.enable {
    users.users.bookorbit = {
      isSystemUser = true;
      home = cfg.home;
      createHome = true;
      group = "bookorbit";
    };
    users.groups.bookorbit = {};

    services.nginx.virtualHosts = {
      "bookorbit.${domain}" = {
        forceSSL = true;
        useACMEHost = fqdn;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };

        extraConfig = ''
          proxy_connect_timeout 600;
          proxy_read_timeout 600;
          proxy_send_timeout 600;
          client_max_body_size 1000m;
          access_log syslog:server=unix:/dev/log,tag=bookorbit;
        '';
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = ["bookorbit.${domain}"];
  };
}

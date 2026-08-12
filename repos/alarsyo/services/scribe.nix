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

  cfg = config.my.services.scribe;
  my = config.my;

  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";
in {
  options.my.services.scribe = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Scribe config";

    home = mkOption {
      type = types.str;
      default = "/var/lib/scribe";
      example = "/var/lib/scribe";
      description = "Home for the scribe service, where data will be stored";
    };

    port = mkOption {
      type = types.port;
      default = 2343;
      example = 8080;
      description = "Internal port for Scribe service";
    };
  };

  config = mkIf cfg.enable {
    users.users.scribe = {
      isSystemUser = true;
      home = cfg.home;
      createHome = true;
      group = "scribe";
    };
    users.groups.scribe = {};

    services.nginx.virtualHosts = {
      "scribe.${domain}" = {
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
          client_max_body_size 200m;
        '';
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = ["scribe.${domain}"];
  };
}

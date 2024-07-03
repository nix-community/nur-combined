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

  cfg = config.my.services.mealie;
  my = config.my;

  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";
in {
  options.my.services.mealie = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Mealie";
    port = mkOption {
      type = types.port;
      example = 8080;
      description = "Internal port for Mealie webapp";
    };
  };

  config = mkIf cfg.enable {
    services.mealie = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = cfg.port;
    };

    services.nginx.virtualHosts."mealie.${domain}" = {
      forceSSL = true;
      useACMEHost = fqdn;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}/";
        proxyWebsockets = true;
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = ["mealie.${domain}"];

    my.services.restic-backup = {
      paths = ["/var/lib/mealie"];
    };
  };
}

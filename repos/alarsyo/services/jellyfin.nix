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
    ;

  cfg = config.my.services.jellyfin;
  my = config.my;

  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";

  # hardcoded in NixOS module :(
  jellyfinPort = 8096;
in {
  options.my.services.jellyfin = {
    enable = mkEnableOption "Jellyfin";
  };

  config = mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      group = "media";
    };

    # Proxy to Jellyfin
    services.nginx.virtualHosts."jellyfin.${domain}" = {
      forceSSL = true;
      useACMEHost = fqdn;

      locations."/" = {
        proxyPass = "http://localhost:${toString jellyfinPort}/";
        proxyWebsockets = true;
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = ["jellyfin.${domain}"];
  };
}

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my.services.jellyfin;
  my = config.my;

  domain = config.networking.domain;

  # hardcoded in NixOS module :(
  jellyfinPort = 8096;
in {
  options.my.services.jellyfin = {
    enable = mkEnableOption "Jellyfin";
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      group = "media";
    };

    # Proxy to Jellyfin
    services.nginx.virtualHosts."jellyfin.${domain}" = {
      forceSSL = true;
      useACMEHost = domain;

      locations."/" = {
        proxyPass = "http://localhost:${toString jellyfinPort}/";
        proxyWebsockets = true;
      };
    };
  };
}

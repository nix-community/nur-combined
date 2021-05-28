# A FLOSS media server
{ config, lib, ... }:
let
  cfg = config.my.services.jellyfin;
  domain = config.networking.domain;
  jellyfinDomain = "jellyfin.${config.networking.domain}";
in
{
  options.my.services.jellyfin = {
    enable = lib.mkEnableOption "Jellyfin Media Server";
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      group = "media";
    };

    # Proxy to Jellyfin
    services.nginx.virtualHosts."${jellyfinDomain}" = {
      forceSSL = true;
      useACMEHost = domain;

      locations."/" = {
        proxyPass = "http://127.0.0.1:8096/";
        extraConfig = ''
          proxy_buffering off;
        '';
      };

      locations."/socket" = {
        proxyPass = "http://127.0.0.1:8096/";
        proxyWebsockets = true;
      };
    };
  };
}

{ config, lib, ... }:

let
  domain = "miniflux.${config.networking.hostName}.${config.networking.domain}";
in

{

  imports = [
    ({config, ...}: {
      config = lib.mkIf config.services.invidious.enable {
        services.miniflux.config = {
            INVIDIOUS_INSTANCE = "invidious.${config.networking.hostName}.${config.networking.domain}";
            YOUTUBE_EMBED_URL_OVERRIDE = "http://invidious.${config.networking.hostName}.${config.networking.domain}/embed/";
        };
      };
    })
  ];
  config = lib.mkIf config.services.miniflux.enable {
    networking.ports.miniflux.enable = true;

    services.miniflux = {
      config = {
        LISTEN_ADDR = "localhost:${toString config.networking.ports.miniflux.port}";
        BASE_URL = "http://${domain}";
        FETCH_ODYSEE_WATCH_TIME=toString 1;
        FETCH_YOUTUBE_WATCH_TIME=toString 1;
      };

      # if you are not allowed you shouldn't even been able to open the homepage lol
      adminCredentialsFile = builtins.toFile "creds" ''
        ADMIN_USERNAME=admin
        ADMIN_PASSWORD=adminadmin
      '';
    };
    services.nginx.virtualHosts."${domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.networking.ports.miniflux.port}";
        proxyWebsockets = true;
      };
    };
    services.postgresqlBackup.databases = [ "miniflux" ];
  };
}

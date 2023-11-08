{ config, lib, ... }:
{
  config = lib.mkIf config.services.miniflux.enable {
    networking.ports.miniflux.enable = true;

    services.miniflux = {
      config = {
        LISTEN_ADDR = "localhost:${toString config.networking.ports.miniflux.port}";
      };

      # if you are not allowed you shouldn't even been able to open the homepage lol
      adminCredentialsFile = builtins.toFile "creds" ''
        ADMIN_USERNAME=admin
        ADMIN_PASSWORD=adminadmin
      '';
    };
    services.nginx.virtualHosts."miniflux.${config.networking.hostName}.${config.networking.domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.networking.ports.miniflux.port}";
        proxyWebsockets = true;
      };
    };
    services.postgresqlBackup.databases = [ "miniflux" ];
  };
}

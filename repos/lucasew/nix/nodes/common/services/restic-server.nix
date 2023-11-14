{ config, lib, ... }:

{
  config = lib.mkIf config.services.restic.server.enable {
    networking.ports.restic-server.enable = true;
    services.restic.server = {
      appendOnly = true;
      listenAddress = "127.0.0.1:${toString config.networking.ports.restic-server.port}";
      extraFlags = [ "--no-auth" ];
    };

    services.nginx.virtualHosts."restic.${config.networking.hostName}.${config.networking.domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.networking.ports.restic-server.port}";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 10G;
        '';
      };
    };

    services.prometheus.scrapeConfigs = [
      {
        job_name = "restic-server";
        static_configs = [
          {
            targets = ["127.0.0.1:${toString config.networking.ports.restic-server.port}" ];
          }
        ];
      }
    ];
  };
}

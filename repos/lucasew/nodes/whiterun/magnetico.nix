{ config, lib, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.services.magnetico.enable {
    services.magnetico.web.port = 65530;
    services.magnetico.crawler.port = 65529;

    networking.firewall.allowedTCPPorts = [ config.services.magnetico.crawler.port ];

    services.nginx.virtualHosts."magnetico.${config.networking.hostName}.${config.networking.domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.magnetico.web.port}";
      };
    };
  };
}

{ config, lib, ... }:
let
  inherit (lib) mkIf mkForce;
in
{
  config = mkIf config.services.magnetico.enable {
    services.magnetico.web.port = 65530;
    services.magnetico.crawler.port = 65529;
    services.magnetico.crawler.extraOptions = [ "-v" ]; # verbose

    systemd.services.magneticod.wantedBy = mkForce []; # disable start on boot

    networking.firewall.allowedTCPPorts = [ config.services.magnetico.crawler.port ];

    services.nginx.virtualHosts."magnetico.${config.networking.hostName}.${config.networking.domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.magnetico.web.port}";
      };
    };
  };
}

{ config, lib, ... }:
let
  inherit (lib) mkIf mkForce mkDefault;
in
{
  config = mkIf config.services.magnetico.enable {
    networking.ports.magnetico-web.enable = true;
    # networking.ports.magnetico-web.port = mkDefault 49146;
    networking.ports.magnetico-crawler.enable = true;
    # networking.ports.magnetico-crawler.port = mkDefault 49140;
    services.magnetico.web = {
      inherit (config.networking.ports.magnetico-web) port;
    };
    services.magnetico.crawler = {
      inherit (config.networking.ports.magnetico-crawler) port;
      extraOptions = [ "-v" ]; # verbose
    };

    systemd.services.magneticod.wantedBy = mkForce []; # disable start on boot

    networking.firewall.allowedTCPPorts = [ config.services.magnetico.crawler.port ];

    services.nginx.virtualHosts."magnetico.${config.networking.hostName}.${config.networking.domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.magnetico.web.port}";
      };
    };
  };
}

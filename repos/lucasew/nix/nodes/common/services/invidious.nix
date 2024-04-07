{ config, lib, ... }:

let
  domain = "invidious.${config.networking.hostName}.${config.networking.domain}";
in

lib.mkIf config.services.invidious.enable {
  networking.ports.invidious.enable = true;
  # networking.ports.invidious.port = lib.mkDefault 49149;
  services.invidious = {
    inherit (config.networking.ports.invidious) port;
    settings = {
      db = {
        user = "invidious";
        dbname = "invidious";
      };
    };
  };

  services.nginx.virtualHosts."${domain}" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.networking.ports.invidious.port}";
      proxyWebsockets = true;
    };
  };
}

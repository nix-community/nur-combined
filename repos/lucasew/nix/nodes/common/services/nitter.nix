{ config, lib, ... }:

let
  domain = "nitter.${config.networking.hostName}.${config.networking.domain}";
in

{
  imports = [
    ({config, ...}: {
      config = lib.mkIf config.services.invidious.enable {
        services.nitter.preferences.replaceYouTube = "invidious.${config.networking.hostName}.${config.networking.domain}";
      };
    })

    ({config, ...}: {
      config = lib.mkIf config.services.libreddit.enable {
        services.nitter.preferences.replaceReddit = "libreddit.${config.networking.hostName}.${config.networking.domain}";
      };
    })
  ];
  config = lib.mkIf config.services.nitter.enable {
    networking.ports.nitter.enable = true;

    services.nitter.server = {
      inherit (config.networking.ports.nitter) port;
    };

    services.nitter.preferences.replaceTwitter = domain;

    services.nginx.virtualHosts."${domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.networking.ports.nitter.port}";
        proxyWebsockets = true;
      };
    };
  };
}

{ lib, config, ... }:
lib.mkIf config.services.libreddit.enable {
  services.libreddit = {
    port = 65532;
  };

  services.nginx.virtualHosts."libreddit.${config.networking.hostName}.${config.networking.domain}" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.libreddit.port}";
      proxyWebsockets = true;
    };
  };
}

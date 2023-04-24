{ lib, config, ... }:
let
  vhost = "tt-rss.${config.networking.hostName}.${config.networking.domain}";
in {
  config = lib.mkIf config.services.tt-rss.enable {
    services.tt-rss = {
      singleUserMode = true;
      selfUrlPath = "http://${vhost}";
      logDestination = "syslog";
      virtualHost = vhost;
    };
  };
}

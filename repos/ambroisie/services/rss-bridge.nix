# Get RSS feeds from websites that don't natively have one
{ config, lib, ... }:
let
  cfg = config.my.services.rss-bridge;
  domain = config.networking.domain;
  rss-bridgeDomain = "rss-bridge.${config.networking.domain}";
in
{
  options.my.services.rss-bridge = {
    enable = lib.mkEnableOption "RSS-Bridge service";
  };

  config = lib.mkIf cfg.enable {
    services.rss-bridge = {
      enable = true;
      whitelist = [ "*" ]; # Whitelist all
      virtualHost = rss-bridgeDomain; # Setup virtual host
    };

    services.nginx.virtualHosts."${rss-bridgeDomain}" = {
      forceSSL = true;
      useACMEHost = domain;
    };
  };
}

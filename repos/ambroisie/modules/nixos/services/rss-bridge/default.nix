# Get RSS feeds from websites that don't natively have one
{ config, lib, ... }:
let
  cfg = config.my.services.rss-bridge;
in
{
  options.my.services.rss-bridge = {
    enable = lib.mkEnableOption "RSS-Bridge service";
  };

  config = lib.mkIf cfg.enable {
    services.rss-bridge = {
      enable = true;
      config = {
        system.enabled_bridges = [ "*" ]; # Whitelist all
      };
      virtualHost = "rss-bridge.${config.networking.domain}";
    };

    # The service above configures the domain, no need for my wrapper
    services.nginx.virtualHosts."rss-bridge.${config.networking.domain}" = {
      forceSSL = true;
      useACMEHost = config.networking.domain;
    };
  };
}

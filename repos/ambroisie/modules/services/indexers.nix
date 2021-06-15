# Torrent and usenet meta-indexers
{ config, lib, ... }:
let
  cfg = config.my.services.indexers;

  domain = config.networking.domain;
  jackettDomain = "jackett.${config.networking.domain}";
  nzbhydraDomain = "nzbhydra.${config.networking.domain}";

  jackettPort = 9117;
  nzbhydraPort = 5076;
in
{
  options.my.services.indexers = with lib; {
    jackett.enable = mkEnableOption "Jackett torrent meta-indexer";
    nzbhydra.enable = mkEnableOption "NZBHydra2 torrent meta-indexer";
  };

  config = {
    services.jackett = lib.mkIf cfg.jackett.enable {
      enable = true;
    };

    # Jackett wants to eat *all* my RAM if left to its own devices
    systemd.services.jackett = {
      serviceConfig = {
        MemoryHigh = "15%";
        MemoryMax = "25%";
      };
    };


    services.nginx.virtualHosts."${jackettDomain}" =
      lib.mkIf cfg.jackett.enable {
        forceSSL = true;
        useACMEHost = domain;

        locations."/".proxyPass = "http://127.0.0.1:${toString jackettPort}/";
      };

    services.nzbhydra2 = lib.mkIf cfg.nzbhydra.enable {
      enable = true;
    };

    services.nginx.virtualHosts."${nzbhydraDomain}" =
      lib.mkIf cfg.nzbhydra.enable {
        forceSSL = true;
        useACMEHost = domain;

        locations."/".proxyPass = "http://127.0.0.1:${toString nzbhydraPort}/";
      };
  };
}

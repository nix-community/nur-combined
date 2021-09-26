# Torrent and usenet meta-indexers
{ config, lib, ... }:
let
  cfg = config.my.services.indexers;

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

    services.nzbhydra2 = lib.mkIf cfg.nzbhydra.enable {
      enable = true;
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "jackett";
        port = jackettPort;
      }
      {
        subdomain = "nzbhydra";
        port = nzbhydraPort;
      }
    ];
  };
}

# Torrent and usenet meta-indexers
{ config, lib, ... }:
let
  cfg = config.my.services.indexers;

  jackettPort = 9117;
  nzbhydraPort = 5076;
  prowlarrPort = 9696;
in
{
  options.my.services.indexers = with lib; {
    jackett.enable = mkEnableOption "Jackett torrent meta-indexer";
    nzbhydra.enable = mkEnableOption "NZBHydra2 usenet meta-indexer";
    prowlarr.enable = mkEnableOption "Prowlarr torrent & usenet meta-indexer";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.jackett.enable {
      services.jackett = {
        enable = true;
      };

      # Jackett wants to eat *all* my RAM if left to its own devices
      systemd.services.jackett = {
        serviceConfig = {
          MemoryHigh = "15%";
          MemoryMax = "25%";
        };
      };

      my.services.nginx.virtualHosts = [
        {
          subdomain = "jackett";
          port = jackettPort;
        }
      ];
    })

    (lib.mkIf cfg.nzbhydra.enable {
      services.nzbhydra2 = {
        enable = true;
      };

      my.services.nginx.virtualHosts = [
        {
          subdomain = "nzbhydra";
          port = nzbhydraPort;
        }
      ];
    })

    (lib.mkIf cfg.prowlarr.enable {
      services.prowlarr = {
        enable = true;
      };

      my.services.nginx.virtualHosts = [
        {
          subdomain = "prowlarr";
          port = prowlarrPort;
        }
      ];
    })
  ];
}

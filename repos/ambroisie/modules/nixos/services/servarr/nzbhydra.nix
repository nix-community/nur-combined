{ config, lib, ... }:
let
  cfg = config.my.services.servarr.nzbhydra;
in
{
  options.my.services.servarr.nzbhydra = with lib; {
    enable = lib.mkEnableOption "NZBHydra2" // {
      default = config.my.services.servarr.enableAll;
    };
  };

  config = lib.mkIf cfg.enable {
    services.nzbhydra2 = {
      enable = true;
    };

    my.services.nginx.virtualHosts = {
      nzbhydra = {
        port = 5076;
        websocketsLocations = [ "/" ];
      };
    };

    # NZBHydra2 does not log authentication failures...
  };
}

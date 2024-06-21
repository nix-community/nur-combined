# A nice UI for various torrent clients
{ config, lib, ... }:
let
  cfg = config.my.services.flood;
in
{
  options.my.services.flood = with lib; {
    enable = mkEnableOption "Flood UI";

    port = mkOption {
      type = types.port;
      default = 9092;
      example = 3000;
      description = "Internal port for Flood UI";
    };
  };

  config = lib.mkIf cfg.enable {
    services.flood = {
      enable = true;

      inherit (cfg) port;
    };

    my.services.nginx.virtualHosts = {
      flood = {
        inherit (cfg) port;
      };
    };
  };
}

{ config, lib, ... }:
let
  cfg = config.my.services.servarr.jackett;
in
{
  options.my.services.servarr.jackett = with lib; {
    enable = lib.mkEnableOption "Jackett" // {
      default = config.my.services.servarr.enableAll;
    };

    port = mkOption {
      type = types.port;
      default = 9117;
      example = 8080;
      description = "Internal port for webui";
    };
  };

  config = lib.mkIf cfg.enable {
    services.jackett = {
      enable = true;
      inherit (cfg) port;
    };

    # Jackett wants to eat *all* my RAM if left to its own devices
    systemd.services.jackett = {
      serviceConfig = {
        MemoryHigh = "15%";
        MemoryMax = "25%";
      };
    };

    my.services.nginx.virtualHosts = {
      jackett = {
        inherit (cfg) port;
      };
    };

    # Jackett does not log authentication failures...
  };
}

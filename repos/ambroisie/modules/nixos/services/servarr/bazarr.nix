{ config, lib, ... }:
let
  cfg = config.my.services.servarr.bazarr;
in
{
  options.my.services.servarr.bazarr = with lib; {
    enable = lib.mkEnableOption "Bazarr" // {
      default = config.my.services.servarr.enableAll;
    };

    port = mkOption {
      type = types.port;
      default = 6767;
      example = 8080;
      description = "Internal port for webui";
    };
  };

  config = lib.mkIf cfg.enable {
    services.bazarr = {
      enable = true;
      group = "media";
      listenPort = cfg.port;
    };

    # Set-up media group
    users.groups.media = { };

    my.services.nginx.virtualHosts = {
      bazarr = {
        inherit (cfg) port;
      };
    };

    # Bazarr does not log authentication failures...
  };
}

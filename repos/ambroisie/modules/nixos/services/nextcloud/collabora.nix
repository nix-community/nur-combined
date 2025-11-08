# Document editor with Nextcloud
{ config, lib, ... }:
let
  cfg = config.my.services.nextcloud.collabora;
in
{
  options.my.services.nextcloud.collabora = with lib; {
    enable = mkEnableOption "Collabora integration";

    port = mkOption {
      type = types.port;
      default = 9980;
      example = 8080;
      description = "Internal port for API";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nextcloud = {
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) richdocuments;
      };
    };

    services.collabora-online = {
      enable = true;
      inherit (cfg) port;

      aliasGroups = [
        {
          host = "https://collabora.${config.networking.domain}";
          # Allow using from nextcloud
          aliases = [ "https://${config.services.nextcloud.hostName}" ];
        }
      ];

      settings = {
        # Rely on reverse proxy for SSL
        ssl = {
          enable = false;
          termination = true;
        };
      };
    };

    my.services.nginx.virtualHosts = {
      collabora = {
        inherit (cfg) port;
        websocketsLocations = [
          "~ ^/cool/(.*)/ws$"
          "^~ /cool/adminws"
        ];
      };
    };
  };
}

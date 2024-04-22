# Audiobook and podcast library
{ config, lib, ... }:
let
  cfg = config.my.services.audiobookshelf;
in
{
  options.my.services.audiobookshelf = with lib; {
    enable = mkEnableOption "Audiobookshelf, a self-hosted podcast manager";

    port = mkOption {
      type = types.port;
      default = 8000;
      example = 4242;
      description = "The port on which Audiobookshelf will listen for incoming HTTP traffic.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.audiobookshelf = {
      enable = true;
      inherit (cfg) port;

      group = "media";
    };

    # Set-up media group
    users.groups.media = { };

    my.services.nginx.virtualHosts = {
      audiobookshelf = {
        inherit (cfg) port;
        # Proxy websockets for RPC
        extraConfig = {
          locations."/".proxyWebsockets = true;
        };
      };
    };
  };
}

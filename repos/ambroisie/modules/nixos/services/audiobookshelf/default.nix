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
        websocketsLocations = [ "/" ];
      };
    };

    services.fail2ban.jails = {
      audiobookshelf = ''
        enabled = true
        filter = audiobookshelf
        port = http,https
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/audiobookshelf.conf".text = ''
        [Definition]
        failregex = ^.*ERROR: \[Auth\] Failed login attempt for username ".*" from ip <ADDR>
        journalmatch = _SYSTEMD_UNIT=audiobookshelf.service
      '';
    };
  };
}

# A FLOSS media server
{ config, lib, ... }:
let
  cfg = config.my.services.jellyfin;
in
{
  options.my.services.jellyfin = {
    enable = lib.mkEnableOption "Jellyfin Media Server";
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      group = "media";
    };

    # Set-up media group
    users.groups.media = { };

    systemd.services.jellyfin = {
      serviceConfig = {
        # Loose umask to make Jellyfin metadata more broadly readable
        UMask = lib.mkForce "0002";
      };
    };

    my.services.nginx.virtualHosts = {
      jellyfin = {
        port = 8096;
        extraConfig = {
          locations."/" = {
            extraConfig = ''
              proxy_buffering off;
            '';
          };
          # Too bad for the repetition...
          locations."/socket" = {
            proxyPass = "http://127.0.0.1:8096/";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}

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
        websocketsLocations = [ "/socket" ];
        extraConfig = {
          locations."/" = {
            extraConfig = ''
              proxy_buffering off;
            '';
          };
        };
      };
    };

    services.fail2ban.jails = {
      jellyfin = ''
        enabled = true
        filter = jellyfin
        port = http,https
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/jellyfin.conf".text = ''
        [Definition]
        failregex = ^.*Authentication request for .* has been denied \(IP: "?<ADDR>"?\)\.
        journalmatch = _SYSTEMD_UNIT=jellyfin.service
      '';
    };
  };
}

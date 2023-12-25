# The total autonomous media delivery system.
# Relevant link [1].
#
# [1]: https://youtu.be/I26Ql-uX6AM
{ config, lib, ... }:
let
  cfg = config.my.services.pirate;

  ports = {
    bazarr = 6767;
    lidarr = 8686;
    radarr = 7878;
    sonarr = 8989;
  };

  mkService = service: {
    services.${service} = {
      enable = true;
      group = "media";
    };
  };

  mkRedirection = service: {
    my.services.nginx.virtualHosts = {
      ${service} = {
        port = ports.${service};
      };
    };
  };

  mkFail2Ban = service: lib.mkIf cfg.${service}.enable {
    services.fail2ban.jails = {
      ${service} = ''
        enabled = true
        filter = ${service}
        action = iptables-allports
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/${service}.conf".text = ''
        [Definition]
        failregex = ^.*\|Warn\|Auth\|Auth-Failure ip <HOST> username .*$
        journalmatch = _SYSTEMD_UNIT=${service}.service
      '';
    };
  };

  mkFullConfig = service: lib.mkIf cfg.${service}.enable (lib.mkMerge [
    (mkService service)
    (mkRedirection service)
  ]);
in
{
  options.my.services.pirate = {
    enable = lib.mkEnableOption "Media automation";

    bazarr = {
      enable = lib.my.mkDisableOption "Bazarr";
    };

    lidarr = {
      enable = lib.my.mkDisableOption "Lidarr";
    };

    radarr = {
      enable = lib.my.mkDisableOption "Radarr";
    };

    sonarr = {
      enable = lib.my.mkDisableOption "Sonarr";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # Set-up media group
      users.groups.media = { };
    }
    # Bazarr does not log authentication failures...
    (mkFullConfig "bazarr")
    # Lidarr for music
    (mkFullConfig "lidarr")
    (mkFail2Ban "lidarr")
    # Radarr for movies
    (mkFullConfig "radarr")
    (mkFail2Ban "radarr")
    # Sonarr for shows
    (mkFullConfig "sonarr")
    (mkFail2Ban "sonarr")
  ]);
}

# The total autonomous media delivery system.
# Relevant link [1].
#
# [1]: https://youtu.be/I26Ql-uX6AM
{ config, lib, ... }:
let
  cfg = config.my.services.servarr;

  ports = {
    bazarr = 6767;
    lidarr = 8686;
    radarr = 7878;
    readarr = 8787;
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
  options.my.services.servarr = {
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

    readarr = {
      enable = lib.my.mkDisableOption "Readarr";
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
    # Readarr for books
    (mkFullConfig "readarr")
    (mkFail2Ban "readarr")
    # Sonarr for shows
    (mkFullConfig "sonarr")
    (mkFail2Ban "sonarr")

    # HACK: until https://github.com/NixOS/nixpkgs/issues/360592 is resolved
    (lib.mkIf cfg.sonarr.enable {
      nixpkgs.config.permittedInsecurePackages = [
        "aspnetcore-runtime-6.0.36"
        "aspnetcore-runtime-wrapped-6.0.36"
        "dotnet-sdk-6.0.428"
        "dotnet-sdk-wrapped-6.0.428"
      ];
    })
  ]);
}

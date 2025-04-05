# Templated *arr configuration
starr:
{ config, lib, ... }:
let
  cfg = config.my.services.servarr.${starr};
  ports = {
    lidarr = 8686;
    radarr = 7878;
    readarr = 8787;
    sonarr = 8989;
  };
in
{
  options.my.services.servarr.${starr} = with lib; {
    enable = lib.mkEnableOption (lib.toSentenceCase starr) // {
      default = config.my.services.servarr.enableAll;
    };

    port = mkOption {
      type = types.port;
      default = ports.${starr};
      example = 8080;
      description = "Internal port for webui";
    };
  };

  config = lib.mkIf cfg.enable {
    services.${starr} = {
      enable = true;
      group = "media";

      settings = {
        server = {
          port = cfg.port;
        };
      };
    };

    # Set-up media group
    users.groups.media = { };

    my.services.nginx.virtualHosts = {
      ${starr} = {
        port = cfg.port;
      };
    };

    services.fail2ban.jails = {
      ${starr} = ''
        enabled = true
        filter = ${starr}
        action = iptables-allports
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/${starr}.conf".text = ''
        [Definition]
        failregex = ^.*\|Warn\|Auth\|Auth-Failure ip <HOST> username .*$
        journalmatch = _SYSTEMD_UNIT=${starr}.service
      '';
    };
  };
}

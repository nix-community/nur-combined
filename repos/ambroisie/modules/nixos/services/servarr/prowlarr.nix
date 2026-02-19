# Torrent and NZB indexer
{ config, lib, ... }:
let
  cfg = config.my.services.servarr.prowlarr;
in
{
  options.my.services.servarr.prowlarr = with lib; {
    enable = lib.mkEnableOption "Prowlarr" // {
      default = config.my.services.servarr.enableAll;
    };

    port = mkOption {
      type = types.port;
      default = 9696;
      example = 8080;
      description = "Internal port for webui";
    };
  };

  config = lib.mkIf cfg.enable {
    services.prowlarr = {
      enable = true;

      settings = {
        server = {
          port = cfg.port;
        };
      };
    };

    my.services.nginx.virtualHosts = {
      prowlarr = {
        inherit (cfg) port;
      };
    };

    services.fail2ban.jails = {
      prowlarr = ''
        enabled = true
        filter = prowlarr
        action = iptables-allports
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/prowlarr.conf".text = ''
        [Definition]
        failregex = ^.*\|Warn\|Auth\|Auth-Failure ip <HOST> username .*$
        journalmatch = _SYSTEMD_UNIT=prowlarr.service
      '';
    };
  };
}

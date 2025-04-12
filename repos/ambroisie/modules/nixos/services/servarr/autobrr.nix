# IRC-based indexer
{ config, lib, ... }:
let
  cfg = config.my.services.servarr.autobrr;
in
{
  options.my.services.servarr.autobrr = with lib; {
    enable = mkEnableOption "autobrr IRC announce tracker" // {
      default = config.my.services.servarr.enableAll;
    };

    port = mkOption {
      type = types.port;
      default = 7474;
      example = 8080;
      description = "Internal port for webui";
    };

    sessionSecretFile = mkOption {
      type = types.str;
      example = "/run/secrets/autobrr-secret.txt";
      description = ''
        File containing the session secret.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.autobrr = {
      enable = true;

      settings = {
        inherit (cfg) port;
        checkForUpdates = false;
      };

      secretFile = cfg.sessionSecretFile;
    };

    my.services.nginx.virtualHosts = {
      autobrr = {
        inherit (cfg) port;
      };
    };

    services.fail2ban.jails = {
      autobrr = ''
        enabled = true
        filter = autobrr
        action = iptables-allports
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/autobrr.conf".text = ''
        [Definition]
        failregex = "message":"Auth: Failed login attempt username: \[.*\] ip: <HOST>"
        journalmatch = _SYSTEMD_UNIT=autobrr.service
      '';
    };
  };
}

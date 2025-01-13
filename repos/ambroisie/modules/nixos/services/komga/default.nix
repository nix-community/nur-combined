# A Comics/Manga media server
{ config, lib, ... }:
let
  cfg = config.my.services.komga;
in
{
  options.my.services.komga = with lib; {
    enable = mkEnableOption "Komga comics server";

    port = mkOption {
      type = types.port;
      default = 4584;
      example = 8080;
      description = "Internal port for webui";
    };
  };

  config = lib.mkIf cfg.enable {
    services.komga = {
      enable = true;
      inherit (cfg) port;

      group = "media";

      settings = {
        logging.level.org.gotson.komga = "DEBUG"; # Needed for fail2ban
      };
    };

    # Set-up media group
    users.groups.media = { };

    my.services.nginx.virtualHosts = {
      komga = {
        inherit (cfg) port;
      };
    };

    services.fail2ban.jails = {
      komga = ''
        enabled = true
        filter = komga
        port = http,https
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/komga.conf".text = ''
        [Definition]
        failregex = ^.* ip=<HOST>,.*Bad credentials.*$
        journalmatch = _SYSTEMD_UNIT=komga.service
      '';
    };
  };
}
